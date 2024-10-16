-- Initialize global variables to store framework & inventory
Framework, Inventory = nil, nil

-- Initialize global player variables
PlayerLoaded, PlayerData = nil, {}

-- Get framework
local function InitializeFramework()
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
            if GetCurrentResourceName() ~= resourceName then return end
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_pawnshop:onPlayerLoaded')
        end)

    elseif GetResourceState('qbx_core') == 'started' then
        Framework = 'qbx'

        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_pawnshop:onPlayerLoaded')
        end)

        RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
            table.wipe(PlayerData)
            PlayerLoaded = false
        end)

        AddEventHandler('onResourceStart', function(resourceName)
            if GetCurrentResourceName() ~= resourceName then return end
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_pawnshop:onPlayerLoaded')
        end)
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'qb'

        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_pawnshop:onPlayerLoaded')
        end)

        RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
            table.wipe(PlayerData)
            PlayerLoaded = false
        end)

        AddEventHandler('onResourceStart', function(resourceName)
            if GetCurrentResourceName() ~= resourceName then return end
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_pawnshop:onPlayerLoaded')
        end)
    elseif GetResourceState('ox_core') == 'started' then
        Ox = require '@ox_core.lib.init'
        Framework = 'ox'

        AddEventHandler('ox:playerLoaded', function()
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_pawnshop:onPlayerLoaded')
        end)

        AddEventHandler('ox:playerLogout', function()
            table.wipe(PlayerData)
            PlayerLoaded = false
        end)

        AddEventHandler('onResourceStart', function(resourceName)
            if GetCurrentResourceName() ~= resourceName then return end
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_pawnshop:onPlayerLoaded')
        end)
    else
        -- Add custom framework here
    end
end

-- Get inventory
local function InitializeInventory()
    if GetResourceState('ox_inventory') == 'started' then
        Inventory = 'ox_inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        Inventory = 'qb-inventory'
    elseif GetResourceState('qs-inventory') == 'started' then
        Inventory = 'qs-inventory'
    elseif GetResourceState('ps-inventory') == 'started' then
        Inventory = 'ps-inventory'
    elseif GetResourceState('origen_inventory') == 'started' then
        Inventory = 'origen_inventory'
    elseif GetResourceState('codem-inventory') == 'started' then
        Inventory = 'codem-inventory'
    else
        -- Add custom inventory here
    end
end

-- Returns player data
function GetPlayerData()
    if Framework == 'esx' then
        return ESX.GetPlayerData()
    elseif Framework == 'qb' then
        return QBCore.Functions.GetPlayerData()
    elseif Framework == 'qbx' then
        return exports.qbx_core:GetPlayerData()
    elseif Framework == 'ox' then
        return Ox.GetPlayer()
    else
        -- Add custom framework here
    end
end

-- Initialize defaults
InitializeFramework()
InitializeInventory()