-- Initialize global variables to store framework & inventory
Framework, Inventory = nil, nil

-- Get framework
local function InitializeFramework()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = 'esx'
    elseif GetResourceState('qbx_core') == 'started' then
        Framework = 'qbx'
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'qb'
    elseif GetResourceState('ox_core') == 'started' then
        Ox = require '@ox_core.lib.init'
        Framework = 'ox'
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

-- Get player from source
--- @param source number Player ID
function GetPlayer(source)
    if not source then return end
    if Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    elseif Framework == 'qbx' then
        return exports.qbx_core:GetPlayer(source)
    elseif Framework == 'ox' then
        return Ox.GetPlayer(source)
    else
        -- Add custom framework here
    end
end

-- Function to get a player identifier by source
--- @param source number Player ID
function GetIdentifier(source)
    local player = GetPlayer(source)
    if not player then return end
    if Framework == 'esx' then
        return player.identifier
    elseif Framework == 'qb' or Framework == 'qbx' then
        return player.PlayerData.citizenid
    elseif Framework == 'ox' then
        return player.charId
    else
        -- Add custom framework here
    end
end

-- Function to get a player's name
--- @param source number Player ID
--- @return string
function GetName(source)
    local player = GetPlayer(source)
    if not player then return 'Unknown' end
    if Framework == 'esx' then
        return player.getName()
    elseif Framework == 'qb' or Framework == 'qbx' then
        return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    elseif Framework == 'ox' then
        return player.get('firstName') .. ' ' .. player.get('lastName')
    else
        -- Add custom framework here
    end
    return 'Unknown'
end

-- Returns correct framework money type if needed
--- @param type string Money type
--- @return string
local function ConvertMoneyType(type)
    if type == 'money' and (Framework == 'qb' or Framework == 'qbx') then
        type = 'cash'
    elseif type == 'cash' and (Framework == 'esx' or Framework == 'ox') then
        type = 'money'
    else
        -- Add custom framework here
    end
    return type
end

-- Add money to players account
--- @param source number Player ID
--- @param type string Account to add to
--- @param amount number Amount to add
function AddMoney(source, type, amount)
    local player = GetPlayer(source)
    if not player then return end
    if Framework == 'esx' then
        if type == 'dirty' then type = 'black_money' end
        player.addAccountMoney(ConvertMoneyType(type), amount)
    elseif Framework == 'qb' or Framework == 'qbx' then
        if type == 'dirty' then
            return exports.ox_inventory:AddItem(source, 'markedbills', amount)
        end
        player.Functions.AddMoney(ConvertMoneyType(type), amount)
    elseif Framework == 'ox' then
        if type == 'cash' or type == 'money' or type == 'dirty' then
            if type == 'dirty' then type = 'black_money' end
            exports.ox_inventory:AddItem(source, ConvertMoneyType(type), amount)
        else
            local accountId = Ox.GetCharacterAccount(source).id
            Ox.DepositMoney(source, accountId, amount)
        end
    else
        -- Add custom framework here
    end
end

-- Initialize defaults
InitializeFramework()
InitializeInventory()