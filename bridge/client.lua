PlayerLoaded, PlayerData = nil, {}

-- Get framework
if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
    Framework = 'esx'

    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
        PlayerLoaded = true
        TriggerEvent('lation_pawnshop:onPlayerLoaded')
    end)

    RegisterNetEvent('esx:onPlayerLogout', function()
        table.wipe(PlayerData)
        PlayerLoaded = false
    end)

    AddEventHandler('onResourceStart', function(resourceName)
        if GetCurrentResourceName() ~= resourceName or not ESX.PlayerLoaded then
            return
        end
        PlayerData = ESX.GetPlayerData()
        PlayerLoaded = true
        TriggerEvent('lation_pawnshop:onPlayerLoaded')
    end)

elseif GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    Framework = 'qb'

    AddStateBagChangeHandler('isLoggedIn', '', function(_bagName, _key, value, _reserved, _replicated)
        if value then
            PlayerData = QBCore.Functions.GetPlayerData()
        else
            table.wipe(PlayerData)
        end
        PlayerLoaded = value
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        TriggerEvent('lation_pawnshop:onPlayerLoaded')
    end)

    AddEventHandler('onResourceStart', function(resourceName)
        if GetCurrentResourceName() ~= resourceName or not LocalPlayer.state.isLoggedIn then
            return
        end
        PlayerData = QBCore.Functions.GetPlayerData()
        PlayerLoaded = true
        TriggerEvent('lation_pawnshop:onPlayerLoaded')
    end)
else
    -- Add support for a custom framework here
    print('Error: no framework detected')
end