-- Function to show a notification
--- @param message string
--- @param type string
function ShowNotification(message, type)
    if Config.Setup.notify == 'ox_lib' then
        lib.notify({ title = 'Pawn Shop', description = message, type = type, position = 'top', icon = 'fas fa-shop' })
    elseif Config.Setup.notify == 'esx' then
        ESX.ShowNotification(message)
    elseif Config.Setup.notify == 'qb' then
        QBCore.Functions.Notify(message, type)
    elseif Config.Setup.notify == 'okok' then
        exports['okokNotify']:Alert('Pawn Shop', message, 5000, type, false)
    elseif Config.Setup.notify == 'custom' then
        -- Add custom notification export/event here
    end
end

-- Event handler to show notifications from server
--- @param message string
--- @param type string
RegisterNetEvent('lation_pawnshop:Notify', function(message, type)
    ShowNotification(message, type)
end)

-- Function used to display TextUI
--- @param text string 
--- @param icon string
function ShowTextUI(text, icon)
    local displaying, _ = lib.isTextUIOpen()
    if displaying then return end
    lib.showTextUI(text, {
        position = 'left-center',
        icon = icon
    })
end

-- Function used to hide/remove TextUI
--- @param label string
function HideTextUI(label)
    local isOpen, text = lib.isTextUIOpen()
    if isOpen and text == label then
        lib.hideTextUI()
    end
end

-- Function to add circle target zones
--- @param data table
function AddCircleZone(data)
    if Config.Setup.target == 'ox_target' then
        exports.ox_target:addSphereZone(data)
    elseif Config.Setup.target == 'qb-target' then
        exports['qb-target']:AddCircleZone(data.name, data.coords, data.radius, {
            name = data.name,
            debugPoly = Config.Setup.debug}, {
            options = data.options,
            distance = 2,
        })
    elseif Config.Setup.target == 'qtarget' then
        exports.qtarget:AddCircleZone(data.name, data.coords, data.radius, {
            name = data.name,
            debugPoly = Config.Setup.debug}, {
            options = data.options,
            distance = 2,
        })
    elseif Config.Setup.target == 'custom' then
        -- Add support for a custom target system here
    elseif Config.Setup.target == 'none' then
        -- TextUI is being used
    else
        print('No target system defined in the config file.')
    end
end

-- Function to remove circle target zones
--- @param id number | string
function RemoveCircleZone(id)
    if Config.Setup.target == 'ox_target' then
        exports.ox_target:removeZone(id)
    elseif Config.Setup.target == 'qb-target' then
        exports['qb-target']:RemoveZone(id)
    elseif Config.Setup.target == 'qtarget' then
        exports.qtarget:RemoveZone(id)
    elseif Config.Setup.target == 'custom' then
        -- Add support for a custom target system here
    elseif Config.Setup.target == 'none' then
        -- TextUI is being used
    else
        print('No target system defined in the config file.')
    end
end

-- Function used to spawn NPCs
--- @param model string
--- @param coords vector3 | vector4
function SpawnNPC(model, coords)
    if not model or not coords then return end
    lib.requestModel(model, 10000)
    while not HasModelLoaded(model) do Wait(0) end
    local ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    return ped
end