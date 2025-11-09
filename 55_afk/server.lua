local ESX = exports["es_extended"]:getSharedObject()

-- Discord Webhook Function
local function sendDiscordWebhook(message)
    if not Shared.Config.Discord.Enabled or Shared.Config.Discord.WebhookURL == "" then
        return
    end

    local timestamp = os.date("%Y-%m-%d %H:%M:%S")

    local webhookData = {
        ["username"] = Shared.Config.Discord.Username,
        ["avatar_url"] = Shared.Config.Discord.AvatarURL,
        ["embeds"] = {
            {
                ["title"] = Shared.Config.Discord.Titel,
                ["description"] = message,
                ["color"] = Shared.Config.Discord.Color,
                ["thumbnail"] = { ["url"] = Shared.Config.Discord.ThumbnailURL },
                ["footer"] = {
                    ["text"] = Shared.Config.Discord.FooterText .. " • " .. timestamp,
                    ["icon_url"] = Shared.Config.Discord.FooterIconURL
                }
            }
        }
    }

    PerformHttpRequest(Shared.Config.Discord.WebhookURL, function() end, 'POST', json.encode(webhookData), {
        ['Content-Type'] = 'application/json'
    })
end

-- AFK Rewards
RegisterNetEvent("afkzone:giveRewards", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    for _, reward in pairs(Shared.Config.Rewards) do
        xPlayer.addInventoryItem(reward.item, reward.count)
    end

    local message = ("**%s** (%d) have received an afk reward.\n Rewards:"):format(xPlayer.getName(), src)
    for _, reward in pairs(Shared.Config.Rewards) do
        message = message .. ("\n• `%s` x%d"):format(reward.item, reward.count)
    end

    sendDiscordWebhook(message)
end)
