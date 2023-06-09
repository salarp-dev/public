QBCore = exports['qb-core']:GetCoreObject()
local canRob = true

QBCore.Functions.CreateCallback('qb-meterrobbery:server:canRob', function(source, cb, meter)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local policeCount = QBCore.Functions.GetDutyCount('police')

    if policeCount >= Config.RequiredCops then
        if not Config.RobbedMeters[meter] then
            if Player.Functions.GetItemByName('lockpick') ~= nil then
                if canRob then
                    cb(true)
                    canRob = false
                    SetTimeout(Config.MeterCooldown * 60000, function()
                        canRob = true
                    end)
                else
                    TriggerClientEvent('QBCore:Notify', src, Locales['lt']['cooldown_active'], 'error')
                    cb(false)
                end
            else
                TriggerClientEvent('QBCore:Notify', src, Locales['lt']['missing_item'], 'error')
                cb(false)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, Locales['lt']['meter_robbed'], 'error')
            cb(false)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Locales['lt']['not_enough_cops'], 'error')
        cb(false)
    end
end)

RegisterServerEvent('qb-meterrobbery:server:setCooldown')
AddEventHandler('qb-meterrobbery:server:setCooldown', function(meter, src)
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = math.random(Config.MinReward, Config.MaxReward)

    Player.Functions.AddItem('coin', amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['coin'], 'add', amount)

    if Config.RobbedMeters[meter] == true then
        TriggerClientEvent('QBCore:Notify', src, Locales['lt']['meter_robbed'], 'error')
    else
        Config.RobbedMeters[meter] = true
        TriggerClientEvent('qb-meterrobbery:client:robberyInProgress', src)
        SetTimeout(Config.RobberyCooldown * 1000, function()
            Config.RobbedMeters[meter] = nil
            canRob[src] = true
            cooldowns[src] = os.time() + Config.MeterCooldown * 60
            SetTimeout(Config.MeterCooldown * 60000, function()
                cooldowns[src] = nil
            end)
        end)
        TriggerClientEvent('QBCore:Notify', src, Locales['lt']['robbery_success'], 'success')
    end
end)

RegisterServerEvent('qb-meterrobbery:server:success')
AddEventHandler('qb-meterrobbery:server:success', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = math.random(Config.MinReward, Config.MaxReward)

    Player.Functions.AddItem('coin', amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['coin'], 'add', amount)

    canRob = false
end)
RegisterServerEvent('qb-meterrobbery:server:failed')
AddEventHandler('qb-meterrobbery:server:failed', function()
    local src = source

    -- Random chance to remove lockpick from inventory
    if math.random() < 0.5 then
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.RemoveItem('lockpick', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['lockpick'], "remove")
  
        QBCore.Functions.Notify("You failed to pick the lock and lost the lockpick.", "error")
    else
        QBCore.Functions.Notify("You failed to pick the lock.", "error")
    end

    canRob = true
end)
