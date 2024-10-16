Config = {} -- Do not alter

-- 🔎 Looking for more high quality scripts?
-- 🛒 Shop Now: https://lationscripts.com
-- 💬 Join Discord: https://discord.gg/9EbY4nM5uu
-- 😢 How dare you leave this option false?!
Config.YouFoundTheBestScripts = true

----------------------------------------------
--        🛠️ Setup the basics below
----------------------------------------------

Config.Setup = {
    -- Use only if needed, directed by support or know what you're doing
    -- Notice: enabling debug features will significantly increase resmon
    -- And should always be disabled in production
    debug = false,
    -- Do you want to be notified via server console if an update is available?
    version = true,
    -- Target system, available options are: 'ox_target', 'qb-target', 'qtarget', 'custom' & 'none'
    -- 'custom' needs to be added to client/functions.lua
    -- If 'none' then TextUI is used instead of targeting
    target = 'none',
    -- Notification system, available options are: 'ox_lib', 'esx', 'qb', 'okok' & 'custom'
    -- 'custom' needs to be added to client/functions.lua
    notify = 'ox_lib',
    -- If using TextUI (Config.Setup.target = 'none') then what key do you want to open the shop?
    -- Default is 38 (E), find more control ID's here: https://docs.fivem.net/docs/game-references/controls/
    interact = 38,
    -- 'auto_clear' is a system to automatically clear shops after certain amount of time
    auto_clear = {
        -- Do you want to enable the auto clearing system?
        enable = false,
        -- If enable = true, how long (in minutes) should shops be cleared?
        interval = 60
    }
}

----------------------------------------------
--       🏪 Create your pawn shops
----------------------------------------------

Config.Shops = {
    ['vinewood'] = { -- Unique identifier for this shop
        name = 'Vinewood Pawn & Jewelry', -- Shop name
        slots = 25, -- How many slots are available
        weight = 100000, -- How much weight is available
        coords = vec4(-1459.2361, -413.2576, 36.2567, 343.8426), -- Where this shop exists
        radius = 1.0, -- How large of a circle zone radius (for targeting only)
        spawnPed = false, -- Spawn a ped to interact with here?
        pedModel = 'a_m_y_beach_02', -- If spawnPed = true, what ped model?
        -- You can limit the hours at which the shop is available here
        -- Min is the earliest the shop is available (default 06:00AM)
        -- Max is the latest the shop is available (detault 21:00 aka 9PM)
        -- If you want it available 24/7, set min to 0 and max to 24
        hour = { min = 6, max = 21 },
        account = 'cash', -- Give 'cash', 'bank' or 'dirty' money when selling here?
        allowlist = {
            -- What items can be sold here
            -- Any item not in this list, cannot be sold here
            -- ['itemSpawnName'] = { label = 'Item Name', price = sellPrice }
            ['water'] = { label = 'Water', price = 50 },
            ['panties'] = { label = 'Knickers', price = 10 },
            ['lockpick'] = { label = 'Lockpick', price = 25 },
            ['phone'] = { label = 'Phone', price = 150 },
            ['armour'] = { label = 'Bulletproof Vest', price = 225 },
            -- Add & remove items here as desired
            -- Be sure to follow the same format as above
        },
        -- If placeholders = true then the "slots" amount above will be overridden
        -- This option will fill the shop with "display" items, and only
        -- Display items that are possible to sell here. If false, it will be
        -- An empty inventory, and the "slots" amount above will not be overridden
        placeholders = true,
        blip = {
            enabled = true, -- Enable or disable the blip for this shop
            sprite = 59, -- Sprite ID (https://docs.fivem.net/docs/game-references/blips/)
            color = 0, -- Color (https://docs.fivem.net/docs/game-references/blips/#blip-colors)
            scale = 0.8, -- Size/scale
            label = 'Pawn Shop' -- Label
        }
    },
    ['strawberry'] = {
        name = 'Strawberry Ave Pawn Shop',
        slots = 25,
        weight = 100000,
        coords = vec4(182.7942, -1319.3451, 29.3173, 244.3924),
        radius = 1.0,
        spawnPed = true,
        pedModel = 'a_m_y_beach_02',
        hour = { min = 6, max = 21 },
        account = 'cash',
        allowlist = {
            ['water'] = { label = 'Water', price = 50 },
            ['panties'] = { label = 'Knickers', price = 10 },
            ['lockpick'] = { label = 'Lockpick', price = 25 },
            ['phone'] = { label = 'Phone', price = 150 },
            ['armour'] = { label = 'Bulletproof Vest', price = 225 },
        },
        placeholders = false,
        blip = {
            enabled = true,
            sprite = 59,
            color = 0,
            scale = 0.8,
            label = 'Pawn Shop'
        }
    },
    -- Add more pawn shops here as desired
    -- Be sure to follow the same format as above
}