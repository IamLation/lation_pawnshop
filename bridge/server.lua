-- Get framework
if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
    Framework = 'esx'
elseif GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    Framework = 'qb'
else
    -- Add support for a custom framework here
    print('Error: no framework detected')
end

-- Get player from source
--- @param source number Player ID
GetPlayer = function(source)
    if not source then return end
    if Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    else
        -- Add support for a custom framework here
    end
end

-- Function to get a players identifier
--- @param source number Player ID
GetPlayerIdentifier = function(source)
    local player = GetPlayer(source)
    if not player then return end
    if Framework == 'esx' then
        return player.identifier
    elseif Framework == 'qb' then
        return player.PlayerData.citizenid
    else
        -- Add support for a custom framework here
    end
end

-- Function to get a players name
--- @param source number Player ID
GetName = function(source)
    local player = GetPlayer(source)
    if not player then return end
    if Framework == 'esx' then
        return player.getName()
    elseif Framework == 'qb' then
        return player.PlayerData.charinfo.firstname..' '..player.PlayerData.charinfo.lastname
    else
        -- Add support for a custom framework here
    end
end

-- Function used to convert money type
--- @param moneyType string
ConvertMoneyType = function(moneyType)
    if moneyType == 'money' and Framework == 'qb' then
        moneyType = 'cash'
    elseif moneyType == 'cash' and Framework == 'esx' then
        moneyType = 'money'
    end
    return moneyType
end

-- Function used to add money to account
--- @param source number
--- @param moneyType string
--- @param amount number
AddMoney = function(source, moneyType, amount)
    local player = GetPlayer(source)
    if not player then return end
    moneyType = ConvertMoneyType(moneyType)
    if Framework == 'esx' then
        if moneyType == 'dirty' then moneyType = 'black_money' end
        player.addAccountMoney(moneyType, amount)
    elseif Framework == 'qb' then
        if moneyType == 'dirty' then
            exports.ox_inventory:AddItem(source, 'markedbills', amount)
            return
        end
        player.Functions.AddMoney(moneyType, amount)
    else
        -- Add support for a custom framework here
    end
end