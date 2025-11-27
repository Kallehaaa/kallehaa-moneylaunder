
local npc = {x = 751.6189, y = 1295.0414, z = 359.2962, heading = 90.0}


Citizen.CreateThread(function()
    local hash = GetHashKey("a_m_m_hasjew_01")
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(20)
    end

    local npc_entity = CreatePed(4, hash, npc.x, npc.y, npc.z, npc.heading, false, true)
    SetEntityAsMissionEntity(npc_entity, true, true)
    SetBlockingOfNonTemporaryEvents(npc_entity, true)
    SetPedDiesWhenInjured(npc_entity, false)
    SetPedCanPlayAmbientAnims(npc_entity, true)
    SetPedCanRagdollFromPlayerImpact(npc_entity, false)
    SetEntityInvincible(npc_entity, true)
    FreezeEntityPosition(npc_entity, true)

    exports.ox_target:addLocalEntity(npc_entity, {
        {
            name = 'launder_money',
            label = 'Hvidvask penge',
            icon = 'fas fa-dollar-sign',
            onSelect = function()
                lib.showContext('laundering_menu')
            end,
            canInteract = function(entity, distance, coords, name)
                return distance < 2.0 
            end
        }
    })
end)

lib.registerContext({
    id = 'laundering_menu',
    title = 'Hvidvask Pengene',
    canClose = true,
    options = {
        {
            title = 'Indtast mængden af sorte penge du vil hvidvaske',
            description = 'Indtast det beløb du vil hvidvaske.',
            onSelect = function()
                local input = lib.inputDialog('Hvidvask Penge', {'Mængde'})
                if input then
                    local amount = tonumber(input[1])
                    if amount and amount > 0 then
                        TriggerServerEvent('kallelaunder', amount)
                    else
                        lib.notify({
                            title = 'Fejl',
                            description = 'Ugyldigt. Indtast et gyldigt tal.',
                            type = 'error',
                            duration = 5000
                        })
                    end
                end
            end
        },
        {
            title = 'Afslut',
            onSelect = function()
                lib.hideContext()
            end
        }
    }
})
