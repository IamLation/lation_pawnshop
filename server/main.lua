-- Initialize table to store inventories for hook filter
local inventories = {}

-- Initialize variable to track removal status of non-stackable items
local waiting = false

-- Function used to make numbers prettier (Credits to ESX for the function)
--- @param value number
local function GroupDigits(value)
	local left, num, right = string.match(value, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

-- Thread to handle removal of non-stackable items
-- A pretty hacky solution, but works nevertheless
--- @param source number
--- @param item string
--- @param count number
local function AwaitRemoval(source, item, count)
    local source = source
    local wait = 5 -- Increase this number slightly if items failing to remove
    while waiting do
        Wait(0)
        wait = wait - 1
        if wait <= 0 then
            exports.ox_inventory:RemoveItem(source, item, count)
            waiting = false
            break
        end
    end
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
local function BeginTransaction(payload)
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
    local identifier = GetIdentifier(source)
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
                    else
                        if payload.action == 'swap' then
                            EventLog('[main.lua]: BeginTransaction: cannot place item on top of non-matching item, cannot proceed..')
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
                    TriggerClientEvent('lation_pawnshop:Notify', source, Strings.Notify.complete:format(tostring(GroupDigits(price)), data.account, tostring(GroupDigits(quantity)), info.label), 'success')
                    AddMoney(source, data.account, price)
                    if Logs.Events.item_sold then
                        local log = Strings.Logs.item_sold.message
                        local message = string.format(log, tostring(playerName), tostring(identifier), tostring(GroupDigits(quantity)), info.label, tostring(GroupDigits(price)))
                        PlayerLog(source, Strings.Logs.item_sold.title, message)
                    end
                    if data.placeholders then
                        if not payload.toSlot.stack then
                            waiting = true
                            CreateThread(function() AwaitRemoval(source, payload.fromSlot.name, payload.count) end)
                        end
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

-- If auto_clear is enabled, clear shops at specified interval
if Config.Setup.auto_clear.enable then
    local interval = Config.Setup.auto_clear.interval * 60000
    CreateThread(function()
        while true do
            for shopId, data in pairs(Config.Shops) do
                exports.ox_inventory:ClearInventory(shopId)
                if data.placeholders then
                    for item, _ in pairs(data.allowlist) do
                        exports.ox_inventory:AddItem(shopId, item, 1)
                    end
                end
            end
            Wait(interval)
        end
    end)
end

-- Register the swapItems hook
exports.ox_inventory:registerHook('swapItems', function(payload)
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