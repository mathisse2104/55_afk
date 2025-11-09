local ESX = exports["es_extended"]:getSharedObject()
local isAFK = false
local inZone = false
local currentZone = nil
local afkTimer = 0
local lastPos = nil
local isActivating = false

-- Make blips for afk zone
CreateThread(function()
    if not Shared.Config.Blips.Enabled then return end

    for _, zone in pairs(Shared.Config.Zones) do
        -- Radius-blip
        local radiusBlip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, zone.radius)
        SetBlipHighDetail(radiusBlip, true)
        SetBlipColour(radiusBlip, Shared.Config.Blips.Color)
        SetBlipAlpha(radiusBlip, 80)

        -- Point blip
        local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
        SetBlipSprite(blip, Shared.Config.Blips.Sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Shared.Config.Blips.Scale)
        SetBlipColour(blip, Shared.Config.Blips.Color)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.name or Shared.Config.Blips.Name or "AFK Zone")
        EndTextCommandSetBlipName(blip)
    end
end)

-- Check if player is in afk zone
CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local wasInZone = inZone
        inZone = false
        currentZone = nil

        for _, zone in pairs(Shared.Config.Zones) do
            if #(coords - zone.coords) < zone.radius then
                inZone = true
                currentZone = zone.name
                break
            end
        end

       -- If players not in afk zone
        if not inZone and (isAFK or isActivating) then
            if isAFK then
                StopAFK()
                lib.notify({
                    title = "AFK",
                    description = "You have left the AFK Zone.",
                    type = "error"
                })
            end
            if isActivating then
                isActivating = false
                SendNUIMessage({ action = "hideHUD" })
            end
        end
    end
end)

-- Command /afk
RegisterCommand("afk", function()
    if not inZone then
        lib.notify({
            title = "AFK",
            description = "You must be in the AFK zone to do this!",
            type = "error"
        })
        return
    end

    if isAFK then
        lib.notify({
            title = "AFK",
            description = "You're already AFK!",
            type = "info"
        })
        return
    end

    if isActivating then
        lib.notify({
            title = "AFK",
            description = "AFK is already activating, please wait...",
            type = "info"
        })
        return
    end

    StartAFKActivation()
end)

-- Start afk
function StartAFKActivation()
    isActivating = true
    local ped = PlayerPedId()
    lastPos = GetEntityCoords(ped)

    lib.notify({
        title = "AFK",
        description = ("Stay %d seconds still to be afk..."):format(Shared.Config.AFKActivationTime),
        type = "info"
    })

    CreateThread(function()
        local elapsed = 0
        while elapsed < Shared.Config.AFKActivationTime and isActivating do
            Wait(1000)
            
            if not inZone then
                isActivating = false
                SendNUIMessage({ action = "hideHUD" })
                return
            end

            local newPos = GetEntityCoords(ped)
            if #(newPos - lastPos) > 0.3 then
                isActivating = false
                SendNUIMessage({ action = "hideHUD" })
                lib.notify({
                    title = "AFK",
                    description = "You moved! try again.",
                    type = "error"
                })
                return
            end
            
            elapsed = elapsed + 1
        end

        if isActivating then
            isActivating = false
            isAFK = true
            afkTimer = 0
            lastPos = GetEntityCoords(ped)

            -- Shouw hud
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
                description = ("You are afk in zone: %s!"):format(currentZone),
                type = "success"
            })

            StartAFKRewardLoop()
        end
    end)
end

 -- Stop afk
function StopAFK()
    isAFK = false
    afkTimer = 0
    SendNUIMessage({ action = "afkStopped" })
    Wait(2000)
    SendNUIMessage({ action = "hideHUD" })
end


function StartAFKRewardLoop()
    CreateThread(function()
        while isAFK do
            Wait(1000)
            afkTimer = afkTimer + 1

            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            if not inZone or #(coords - lastPos) > 0.5 then
                StopAFK()
                lib.notify({
                    title = "AFK",
                    description = "You aren't AFK anymore",
                    type = "error"
                })
                return
            end

            -- Update progressbar
            local timeUntilReward = (Shared.Config.RewardInterval * 60) - (afkTimer % (Shared.Config.RewardInterval * 60))
            local percent = (timeUntilReward / (Shared.Config.RewardInterval * 60)) * 100
            SendNUIMessage({
                action = "updateProgress",
                percent = percent
            })

            -- Every minute reward
            if afkTimer % (Shared.Config.RewardInterval * 60) == 0 then
                TriggerServerEvent("afkzone:giveRewards")
                SendNUIMessage({ 
                    action = "rewardReceived",
                    rewardInterval = Shared.Config.RewardInterval
                })
                lib.notify({
                    title = "AFK Reward",
                    description = ("You have received a reward %s!"):format(currentZone),
                    type = "success"
                })
            end
        end
    end)
end

-- Command afk stop
RegisterCommand("stopafk", function()
    if isAFK then
        StopAFK()
        lib.notify({
            title = "AFK",
            description = "You are no longer AFK!",
            type = "success"
        })
    else
        lib.notify({
            title = "AFK",
            description = "You are not AFK!",
            type = "error"
        })
    end
end)
