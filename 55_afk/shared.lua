Shared = {}

Shared.Config = {
    RewardInterval = 1, -- Minuten
    AFKActivationTime = 5, -- Seconden
    NPCModel = 'ig_car3guy1', 

    -- AFK routing buckets
    AFKBucket = {
        Min = 1000,
        Max = 10000
    },


    -- Tip: Zorg dat de coords op de grond staan (niet in de lucht) voor de NPC
    Zones = {
        {
            name = "AFK Strand",
            coords = vector3(-1596.8313, -1021.5772, 13.0179),
            radius = 50.0,
            heading = 90.0 -- Richting waarin de NPC kijkt
        },
        {
            name = "AFK Haven",
            coords = vector3(100.0, -3000.0, 6.0),
            radius = 40.0,
            heading = 90.0
        }
    },

    -- Rewards
    Rewards = {
        { item = "money", count = 2000000 },
        { item = "bread", count = 1 }
    },

    -- Blips
    Blips = {
        Enabled = true,
        Name = "AFK Zone",
        Sprite = 280,
        Color = 2,
        Scale = 0.9
    },

    -- Discord logging
    Discord = {
        Enabled = true,
        WebhookURL = "",
        Username = "55 Development",
        AvatarURL = "https://mathisse.nl/logo.png",
        ThumbnailURL = "https://mathisse.nl/logo.png",
        FooterIconURL = "https://mathisse.nl/logo.png",
        Titel = "💤 AFK Logs",
        Color = 3447003,
        FooterText = "55 Development"
    }
}
