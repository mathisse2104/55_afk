💤 55 Development — AFK Zone System

An advanced AFK System for your FiveM server, developed by 55 Development.
Players can automatically receive AFK rewards inside predefined zones, with Discord logs and a custom hud.


⚙️ Requirements

ESX Legacy (or compatible version)

ox_lib (for notifications and NUI messages)

🧩 Features

✅ Multiple AFK zones with radius
✅ Automatic rewards system
✅ Discord webhook logging
✅ Blips on the map
✅ Requires staying still for X seconds before activating
✅ Stops AFK mode when moving or leaving the zone
✅ Progress bar + notifications
✅ /afk and /stopafk commands

⚙️ Configuration
Shared.Config = {

    -- Time between rewards (in minutes)
    RewardInterval = 1,

    -- Time the player must stand still before becoming AFK (in seconds)
    AFKActivationTime = 5,

    -- AFK Zones
    Zones = {
        {
            name = "AFK Beach",
            coords = vector3(-1596.8313, -1021.5772, 13.0179),
            radius = 50.0
        },
        {
            name = "AFK Dock",
            coords = vector3(100.0, -3000.0, 6.0),
            radius = 40.0
        }
    },

    -- Rewards
    Rewards = {
        { item = "money", count = 2000000 },
        { item = "bread", count = 1 }
    },

    -- Blip Settings
    Blips = {
        Enabled = true,         -- Turn off if you don’t want map blips
        Name = "AFK Zone",      -- Name displayed on the map
        Sprite = 280,           -- Blip icon ID
        Color = 2,              -- Blip color (green)
        Scale = 0.9             -- Size of the blip
    },

    -- Discord Logging
    Discord = {
        Enabled = false,
        WebhookURL = "",
        Username = "",
        AvatarURL = "",
        ThumbnailURL = "",
        FooterIconURL = "",
        Titel = "💤 AFK Log",
        Color = 3447003,
        FooterText = "55 Development"
    }
}



    
🌐 Website: https://mathisse.nl
💬 Discord: https://discord.mathisse.nl/
▶️ Youtube: https://youtu.be/7rFPQCKacPw
