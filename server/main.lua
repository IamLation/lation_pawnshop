-- Initialize table to store inventories for hook filter
local inventories = {}

-- Function used to make numbers prettier (Credits to ESX for the function)
--- @param value number
local GroupDigits = function(value)
	local left, num, right = string.match(value, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

-- Register necessary shops/stashes
for shopId, data in pairs(Config.Shops) do
    if data.placeholders then
        local slots, items = 0, {}
        for item, _ in pairs(data.allowlist) do
            slots = slots + 1
            items[#items + 1] = item
        end
        exports.ox_inventory:RegisterStash(shopId, data.name, slots, data.weight)
        for _, item in pairs(items) do
            exports.ox_inventory:AddItem(shopId, item, 1)
        end
    else
        exports.ox_inventory:RegisterStash(shopId, data.name, data.slots, data.weight)
    end
    inventories[#inventories + 1] = shopId
end

-- Used to handle all movements and final transaction in inventory
--- @param payload table
local BeginTransaction = function(payload)
    if not payload then return false end
    if payload.toType == 'player' then
        EventLog('[main.lua]: BeginTransaction: inventory is not a shop, cannot proceed..')
        return false
    end
    if payload.toType == 'stash' and payload.fromType == 'stash' then
        EventLog('[main.lua]: BeginTransaction: cannot move items inside the shop, cannot proceed..')
        return false
    end
    local source = payload.source
    if not source then
        EventLog('[main.lua]: BeginTransaction: source not found, cannot proceed..')
        return false
    end
    local playerName = GetName(source)
    local identifier = GetPlayerIdentifier(source)
    local shop = Config.Shops[payload.toInventory].name
    if not shop then
        EventLog('[main.lua]: BeginTransaction: unable to find shop in config, cannot proceed..')
        return false
    end
    EventLog('[main.lua]: BeginTransaction: currently interacting with shop: ' ..tostring(shop))
    for shopId, data in pairs(Config.Shops) do
        if payload.toInventory == shopId then
            local itemAccepted = false
            EventLog('[main.lua]: BeginTransaction: this shop accepts the following item(s):  ' ..json.encode(data.allowlist, { indent = true }))
            for item, info in pairs(data.allowlist) do
                if payload.fromSlot.name == item then
                    if data.placeholders then
                        if payload.fromSlot.name ~= payload.toSlot.name then
                            TriggerClientEvent('lation_pawnshop:Notify', source, Strings.Notify.wrongSlot, 'inform')
                            EventLog('[main.lua]: BeginTransaction: item is not placed in correct slot, cannot proceed..')
                            return false
                        end
                    end
                    itemAccepted = true
                    local price, quantity = math.floor(info.price * payload.count), payload.count
                    local result = lib.callback.await('lation_pawnshop:ConfirmSale', source, nil, shopId, item, price, quantity)
                    if not result then
                        EventLog('[main.lua]: BeginTransaction: sale was cancelled by player, cannot proceed..')
                        return false
                    end
                    TriggerClientEvent('lation_pawnshop:Notify', source, Strings.Notify.complete ..GroupDigits(price).. Strings.Notify.complete2 ..data.account.. Strings.Notify.complete3 ..GroupDigits(quantity).. ' ' ..tostring(info.label), 'success')
                    AddMoney(source, data.account, price)
                    if Logs.Types.itemSold.enabled then
                        DiscordLogs(
                            Logs.Types.itemSold.webhook,
                            Strings.Logs.titles.itemSold,
                            Strings.Logs.messages.playerName ..playerName..
                            Strings.Logs.messages.playerID ..tostring(source)..
                            Strings.Logs.messages.playerIdent ..identifier..
                            Strings.Logs.messages.message ..Strings.Logs.messages.itemSold.. GroupDigits(quantity).. ' ' ..info.label.. Strings.Logs.messages.itemSold2.. GroupDigits(price).. ' ' ..data.account,
                            Strings.Logs.colors.green
                        )
                    end
                    return true
                end
            end
            if not itemAccepted then
                EventLog('[main.lua]: BeginTransaction: transaction failed, this shop does not accept: ' .. tostring(payload.fromSlot.name))
                TriggerClientEvent('lation_pawnshop:Notify', source, Strings.Notify.cantSell, 'error')
                return false
            end
        end
    end
    return false
end

-- Register the swapItems hook
exports.ox_inventory:registerHook('swapItems', function(payload)
    EventLog(json.encode(payload, { indent = true }))
    local result = BeginTransaction(payload)
    return result
end, {inventoryFilter = inventories})

-- Clear stashes on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    for shopId, _ in pairs(Config.Shops) do
        exports.ox_inventory:ClearInventory(shopId)
    end
end)

-- Event handler to clear stashes on server shutdown/restart
AddEventHandler('txAdmin:events:serverShuttingDown', function()
    for shopId, _ in pairs(Config.Shops) do
        exports.ox_inventory:ClearInventory(shopId)
    end
end)