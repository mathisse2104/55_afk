local ESX = exports["es_extended"]:getSharedObject()

local isAFK = false
local isActivating = false
local inZone = false
local currentZone = nil
local afkTimer = 0
local lastPos = nil
local spawnedPeds = {}

-- BLIPS
CreateThread(function()
    if not Shared.Config.Blips.Enabled then return end

    for _, zone in pairs(Shared.Config.Zones) do
        local radiusBlip = AddBlipForRadius(zone.coords.xyz, zone.radius)
        SetBlipColour(radiusBlip, Shared.Config.Blips.Color)
        SetBlipAlpha(radiusBlip, 80)

        local blip = AddBlipForCoord(zone.coords.xyz)
        SetBlipSprite(blip, Shared.Config.Blips.Sprite)
        SetBlipScale(blip, Shared.Config.Blips.Scale)
        SetBlipColour(blip, Shared.Config.Blips.Color)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.name)
        EndTextCommandSetBlipName(blip)
    end
end)


-- ZONE CHECK 
CreateThread(function()
    while true do
        Wait(1000)
        local coords = GetEntityCoords(PlayerPedId())

        local wasInZone = inZone
        inZone = false
        currentZone = nil

        for _, zone in pairs(Shared.Config.Zones) do
            if #(coords - zone.coords) <= zone.radius then
                inZone = true
                currentZone = zone.name
                break
            end
        end

        -- Alleen stoppen als je de zone verlaat
        if wasInZone and not inZone and isAFK then
            StopAFK("Je hebt de AFK-zone verlaten")
        end
    end
end)

--------------------------------------------------
-- NPC SPAWNEN & INTERACTIE (MET STOP OPTIE)
--------------------------------------------------
CreateThread(function()
    -- npc inladen
    local model = GetHashKey(Shared.Config.NPCModel)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    for i, zone in pairs(Shared.Config.Zones) do
        local npc = CreatePed(4, model, zone.coords.x, zone.coords.y, zone.coords.z - 1.0, zone.heading or 0.0, false, false)
        
        SetEntityAsMissionEntity(npc, true, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)

        -- OX_TARGET Interactie
        exports.ox_target:addLocalEntity(npc, {
            {
                name = 'afk_start_'..i,
                label = 'Start AFK Modus',
                icon = 'fa-solid fa-bed',
                distance = 2.5,
                canInteract = function()
                    return not isAFK
                end,
                onSelect = function()
                    if isActivating then
                        lib.notify({ title = "AFK", description = "AFK wordt al geactiveerd", type = "info" })
                        return
                    end
                    StartAFKActivation()
                end
            },
            {
                name = 'afk_stop_'..i,
                label = 'Stop AFK Modus',
                icon = 'fa-solid fa-person-walking-arrow-right',
                distance = 2.5,
                canInteract = function()
                    return isAFK
                end,
                onSelect = function()
                    StopAFK("AFK stop gezet")
                end
            }
        })

        table.insert(spawnedPeds, npc)
    end
end)

-- Voorkomt dubbele peds bij restart
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    for _, npc in ipairs(spawnedPeds) do
        if DoesEntityExist(npc) then
            DeleteEntity(npc)
        end
    end
end)

-- AFK ACTIVEREN
function StartAFKActivation()
    isActivating = true
    local ped = PlayerPedId()
    lastPos = GetEntityCoords(ped)

    lib.notify({
        title = "AFK",
        description = ("Blijf %d seconden stilstaan…"):format(Shared.Config.AFKActivationTime),
        type = "info"
    })

    CreateThread(function()
        local elapsed = 0

        while elapsed < Shared.Config.AFKActivationTime do
            Wait(1000)

            -- Check of speler nog in zone is
            if not inZone then
                isActivating = false
                lib.notify({
                    title = "AFK",
                    description = "Je bent uit de AFK-zone gegaan",
                    type = "error"
                })
                return
            end

            -- Check beweging
            if #(GetEntityCoords(ped) - lastPos) > 0.5 then 
                isActivating = false
                lib.notify({
                    title = "AFK",
                    description = "Je bewoog, probeer opnieuw",
                    type = "error"
                })
                return
            end

            elapsed = elapsed + 1
        end

        -- START AFK
        isActivating = false
        isAFK = true
        afkTimer = 0
        lastPos = GetEntityCoords(ped)

        TriggerServerEvent("afkzone:setAfkBucket")

        SendNUIMessage({
            action = "showHUD",
            zone = currentZone
        })
            
        SendNUIMessage({
            action = "afkActive",
            rewardInterval = Shared.Config.RewardInterval
        })
       
        lib.notify({
            title = "AFK",
            description = ("AFK geactiveerd in %s"):format(currentZone or "Zone"),
            type = "success"
        })
  
        StartAFKRewardLoop()
    end)
end

-- AFK STOPPEN
function StopAFK(reason)
    if not isAFK then return end

    isAFK = false
    isActivating = false
    afkTimer = 0

    TriggerServerEvent("afkzone:resetBucket")
    
    SendNUIMessage({ action = "afkStopped" })
    Wait(1500)
    SendNUIMessage({ action = "hideHUD" })

    lib.notify({
        title = "AFK",
        description = reason or "AFK gestopt",
        type = "info"
    })
end


-- REWARD LOOP
function StartAFKRewardLoop()
    CreateThread(function()
        while isAFK do
            Wait(1000)
            afkTimer = afkTimer + 1 
                
            local timeUntilReward = (Shared.Config.RewardInterval * 60) - (afkTimer % (Shared.Config.RewardInterval * 60))
            local percent = (timeUntilReward / (Shared.Config.RewardInterval * 60)) * 100

            SendNUIMessage({
                action = "updateProgress",
                percent = percent
            })

            if afkTimer % (Shared.Config.RewardInterval * 60) == 0 then
                TriggerServerEvent("afkzone:giveRewards")
            end
        end
    end)
end


-- COMMANDS
RegisterCommand("afk", function()
    if isAFK then
        lib.notify({title = "AFK", description = "Je bent al AFK", type = "error"})
    elseif not inZone then
        lib.notify({title = "AFK", description = "Niet in zone", type = "error"})
    else
        StartAFKActivation()
    end
end)

RegisterCommand("stopafk", function()
    StopAFK("AFK stop gezet")
end)
