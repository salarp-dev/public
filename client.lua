QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function()
    for _, model in ipairs(Config.MeterModels) do
        exports.ox_target:addModel(model, {
            {
                event = "qb-meterrobbery:client:startRobbery",
                icon = "fas fa-money-bill-wave",
                label = "Rob Meter",
                duty = false,
                parameters = {}
            },
        }, 1.5)
    end
end)

RegisterNetEvent('qb-meterrobbery:client:startRobbery')
AddEventHandler('qb-meterrobbery:client:startRobbery', function(data)
    local meter = data.meter

    QBCore.Functions.TriggerCallback('qb-meterrobbery:server:canRob', function(canRob)
        if canRob then
            TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)

            TriggerEvent('qb-lockpick:client:openLockpick', function(success)
                if success then
                    TriggerServerEvent('qb-meterrobbery:server:success')
                    TriggerServerEvent('qb-meterrobbery:server:setCooldown')
                else
                    TriggerServerEvent('qb-meterrobbery:server:failed')
                end

                ClearPedTasks(PlayerPedId())
            end)
        end
    end, meter)
end)
