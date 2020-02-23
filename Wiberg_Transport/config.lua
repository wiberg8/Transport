Config = {}

Config.TitelServer = "Kungastaden"
Config.AntalPoliser = 1
Config.TimerCarFind = 600
Config.DeliveryTid = 1200
Config.CooldownTid = 3000

Config.Start = {
    ["Start"] = {
        ["Pos"] = vector3(150.92, -1965.44, 18.96),
        ["Text"] = "Prata",
        ["Ped"] = {
            ["Pos"] = vector3(150.0, -1964.32, 19.0), 
            ["Heading"] = 231.91276550293, 
            ["Model"] = 1640504453 ,
        }
    }
}

Config.Transporter = {
    [1] = {
        ["Vehicle"] = {
            ["Pos"] = vector3(1731.0, 3708.88, 34.2),
            ["Heading"] = 10.290909767151,
            ['Models'] = {"boxville", "boxville2", "sadler"},
        },
        ['Delivery'] = {
            ['Pos'] = vector3(625.6, -2988.2, 6.04),
            ['Text'] = "Lämna",
        },
        ['Compensation'] = {
            {"WEAPON_PISTOL", "disc_ammo_pistol"}, 
            {"WEAPON_SNSPISTOL", "disc_ammo_pistol"},
        }, 
    },
    [2] = {
        ["Vehicle"] = {
            ["Pos"] = vector3(593.96, 2804.44, 41.92),
            ["Heading"] = 295.25784301758,
            ['Models'] = {"boxville", "boxville2", "sadler"},
        },
        ['Delivery'] = {
            ['Pos'] = vector3(0.04, -2481.6, 6.0),
            ['Text'] = "Lämna",
        },
        ['Compensation'] = {
            {"WEAPON_PISTOL", "disc_ammo_pistol"}, 
            {"WEAPON_SNSPISTOL", "disc_ammo_pistol"},
        }, 
    },
}