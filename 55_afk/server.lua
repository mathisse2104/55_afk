local ESX = exports["es_extended"]:getSharedObject()

-- DISCORD WEBHOOK
local function sendDiscordWebhook(message)
    if not Shared.Config.Discord.Enabled or Shared.Config.Discord.WebhookURL == "" then
        return
    end

    local timestamp = os.date("%Y-%m-%d %H:%M:%S")

    local webhookData = {
        username = Shared.Config.Discord.Username,
        avatar_url = Shared.Config.Discord.AvatarURL,
        embeds = {
            {
                title = Shared.Config.Discord.Titel,
                description = message,
                color = Shared.Config.Discord.Color,
                thumbnail = { url = Shared.Config.Discord.ThumbnailURL },
                footer = {
                    text = Shared.Config.Discord.FooterText .. " • " .. timestamp,
                    icon_url = Shared.Config.Discord.FooterIconURL
                }
            }
        }
    }

    PerformHttpRequest(
        Shared.Config.Discord.WebhookURL,
        function() end,
        "POST",
        json.encode(webhookData),
        { ["Content-Type"] = "application/json" }
    )
end


-- AFK START ramdom bucket
RegisterNetEvent("afkzone:setAfkBucket", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local bucket = math.random(
        Shared.Config.AFKBucket.Min,
        Shared.Config.AFKBucket.Max
    )

    SetPlayerRoutingBucket(src, bucket)

    sendDiscordWebhook((
        "**AFK gestart**\n\n" ..
        "**Speler:** %s\n" ..
        "**ID:** %d\n" ..
        "**Wereld:** %d"
    ):format(xPlayer.getName(), src, bucket))
end)

--------------------------------------------------
-- AFK STOP → WERELD 0
--------------------------------------------------
RegisterNetEvent("afkzone:resetBucket", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    SetPlayerRoutingBucket(src, 0)

    if xPlayer then
        sendDiscordWebhook((
            "**AFK gestopt**\n\n" ..
            "**Speler:** %s\n" ..
            "**ID:** %d\n" ..
            "**Wereld:** 0"
        ):format(xPlayer.getName(), src))
    end
end)

--------------------------------------------------
-- AFK REWARDS
--------------------------------------------------
RegisterNetEvent("afkzone:giveRewards", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    for _, reward in pairs(Shared.Config.Rewards) do
        xPlayer.addInventoryItem(reward.item, reward.count)
    end

    local msg = (
        "**AFK REWARD**\n\n" ..
        "**Speler:** %s\n" ..
        "**ID:** %d\n\n**Rewards:**"
    ):format(xPlayer.getName(), src)

    for _, reward in pairs(Shared.Config.Rewards) do
        msg = msg .. ("\n• `%s` x%d"):format(reward.item, reward.count)
    end

    sendDiscordWebhook(msg)
end)



AddEventHandler("playerDropped", function()
    SetPlayerRoutingBucket(source, 0)
end)
