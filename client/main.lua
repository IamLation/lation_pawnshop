-- Initalize table to store points & peds
local points, peds = {}, {}

-- Initalize variables to manage TextUI if applicable
local inRange, showingUI, keyListener = {}, false, false

-- Used to create blip if enabled
--- @param key string
local function CreateBlips(key)
    local data = Config.Shops[key]
    local coords = data.coords
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, data.blip.sprite)
    SetBlipColour(blip, data.blip.color)
    SetBlipScale(blip, data.blip.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.blip.label)
    EndTextCommandSetBlipName(blip)
end

-- Function used to make numbers prettier (Credits to ESX for the function)
--- @param value number
local function GroupDigits(value)
	local left, num, right = string.match(value, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

-- Used to manage key listening
--- @param shopId string
local function KeyListener(shopId)
    while keyListener do
        Wait(0)
        if IsControlJustReleased(0, Config.Setup.interact) then
            exports.ox_inventory:openInventory('stash', shopId)
            showingUI = false
        end
    end
end

-- Used to manage the TextUI if applicable
--- @param shopId string
local function ManageTextUI(shopId)
    local pos = Config.Shops[shopId].coords
    while inRange[shopId] do
        Wait(350)
        local distance = #(GetEntityCoords(cache.ped) - vec3(pos.x, pos.y, pos.z))
        if distance < 2.0 then
            if not showingUI and not LocalPlayer.state.invOpen then
                ShowTextUI(Strings.TextUI.openShop.label, Strings.TextUI.openShop.icon)
                showingUI = true
            end
            if not keyListener then
                keyListener = true
                CreateThread(function() KeyListener(shopId) end)
            end
            if LocalPlayer.state.invOpen then
                HideTextUI(Strings.TextUI.openShop.label)
                showingUI = false
            end
        else
            HideTextUI(Strings.TextUI.openShop.label)
            showingUI = false
            if keyListener then
                keyListener = false
            end
        end
    end
end

-- Create shops based on configurations
for shopId, data in pairs(Config.Shops) do
    local point = lib.points.new(data.coords, 50)
    -- Enter function
    function point:onEnter()
        local hour = GetClockHours()
        if hour >= data.hour.min and hour < data.hour.max then
            if data.spawnPed then
                peds[shopId] = SpawnNPC(data.pedModel, data.coords)
            end
            if Config.Setup.target == 'none' then
                inRange[shopId] = true
                CreateThread(function() ManageTextUI(shopId) end)
            else
                local target = {
                    name = 'shop' ..shopId,
                    coords = data.coords,
                    radius = data.radius,
                    debug = Config.Setup.debug,
                    distance = 2,
                    options = {
                        {
                            label = Strings.Target.openShop.label,
                            icon = Strings.Target.openShop.icon,
                            distance = 2,
                            action = function() exports.ox_inventory:openInventory('stash', shopId) end,
                            onSelect = function() exports.ox_inventory:openInventory('stash', shopId) end
                        }
                    }
                }
                AddCircleZone(target)
            end
        end
    end
    -- Exit function
    function point:onExit()
        if peds[shopId] and DoesEntityExist(peds[shopId]) then
            DeleteEntity(peds[shopId])
        end
        peds[shopId] = nil
        inRange[shopId] = false
        if Config.Setup.target ~= 'none' then
            RemoveCircleZone('shop' ..shopId)
        end
    end
    points[shopId] = point
end

-- Callback used to confirm transaction before completion
--- @param shopId string
--- @param item string
--- @param price number
--- @param quantity number
lib.callback.register('lation_pawnshop:ConfirmSale', function(_, shopId, item, price, quantity)
    if not shopId or not item or not price or not quantity then return false end
    local label = Config.Shops[shopId].allowlist[item].label
    if not label then return false end
    local confirmation = lib.alertDialog({
        header = Strings.Alert.confirmSale.header,
        content = Strings.Alert.confirmSale.content:format(tostring(GroupDigits(quantity)), label, tostring(GroupDigits(price))),
        centered = true,
        cancel = true
    })
    if not confirmation or confirmation == 'cancel' then return false end
    return true
end)

-- Event handler to add blips to the map
AddEventHandler('lation_pawnshop:onPlayerLoaded', function()
    while not PlayerLoaded do Wait(0) end
    for shopId, data in pairs(Config.Shops) do
        if data.blip.enabled then
            CreateBlips(shopId)
        end
    end
end)