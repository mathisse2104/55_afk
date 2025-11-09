Shared = {}

Shared.Config = {
    RewardInterval = 15, -- Minutes
    AFKActivationTime = 5, -- Seconds

    -- Zones
    Zones = {
        {
            name = "AFK Strand",
            coords = vector3(-1596.8313, -1021.5772, 13.0179),
            radius = 50.0
        },
        {
            name = "AFK Haven",
            coords = vector3(100.0, -3000.0, 6.0),
            radius = 40.0
        }
    },

    -- Rewards
    Rewards = {
        { item = "money", count = 2000000 },
        { item = "bread", count = 1 }
    },

    -- Blip settings
    Blips = {
        Enabled = true,
        Name = "AFK Zone",
        Sprite = 280, 
        Color = 2,     
        Scale = 0.9
    },

    -- Discord log
    Discord = {
        Enabled = false,
        WebhookURL = "",
        Username = "55 Development",
        AvatarURL = "",
        ThumbnailURL = "",
        FooterIconURL = "",
        Titel = "💤 AFK Log",
        Color = 3447003,
        FooterText = "55 Development"
    }
}
