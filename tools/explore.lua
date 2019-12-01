dofile("../data/WritLogger.lua")

                        -- Narrow input range to something
                        -- we want to test
local INPUT_LOG   = WritLoggerVars["Default"]["@ziggr"]["$AccountWide"]["log"]
-- local INPUT_RANGE = {23,50} -- PTS
local INPUT_RANGE = {82,1000}
local input = {}
for i = INPUT_RANGE[1], INPUT_RANGE[2] do
    if not INPUT_LOG[i] then break end
    table.insert(input, INPUT_LOG[i])
end

                        -- Master writ log, accumulated but not output
                        -- commingled with daily lines.
MASTER_LINES = {}

CHAR_ABBREV = {
    ["Zhaksyr the Mighty"   ] = "zh"
,   ["Zithara"              ] = "zi"
,   ["S'camper"             ] = "sc"
,   ["Z'foompo"             ] = "fo"
,   ["Zerwanwe"             ] = "rw"
,   ["Zagrush"              ] = "ag"
,   ["Hammer-Meets-Thumb"   ] = "hm"
,   ["Zifithri"             ] = "tr"
,   ["Blaithe"              ] = "bl"
}

                        -- ord    = order in output
                        -- type   = CRAFTING_TYPE_X numeric value
                        -- abbrev = abbreviation. Not used
                        -- req_ct = largest number of items (crafted or mats)
                        --          required for this crafting type's daily
                        --          writs. Not used.
CRAFT = {
    ["BLACKSMITHING"] = { ord = 1, type = 1, abbrev = "bs", req_ct = 3 }
,   ["CLOTHIER"     ] = { ord = 2, type = 2, abbrev = "cl", req_ct = 3 }
,   ["WOODWORKING"  ] = { ord = 3, type = 6, abbrev = "ww", req_ct = 3 }
,   ["JEWELRY"      ] = { ord = 4, type = 7, abbrev = "jw", req_ct = 2 }
,   ["ALCHEMY"      ] = { ord = 5, type = 4, abbrev = "al", req_ct = 2 }
,   ["ENCHANTING"   ] = { ord = 6, type = 3, abbrev = "en", req_ct = 2 }
,   ["PROVISIONING" ] = { ord = 7, type = 5, abbrev = "pr", req_ct = 2 }
}
                        -- Index craft by numeric CRAFTING_TYPE_X
                        -- in addition to above index by symbol.
local cc = {}
for k,v in pairs(CRAFT) do cc[v.type] = v end
for k,v in ipairs(cc) do CRAFT[k] = v end
cc = nil

--[[
REQUIREMENT_ABBREV_OLD = {
    [CRAFT.ALCHEMY.type] = {
        ["Drain Health Poison"      ] = "dr.h"
    ,   ["Damage Health Poison"     ] = "dm.h"
    ,   ["Damage Magicka Poison"    ] = "dm.m"
    ,   ["Damage Stamina Poison"    ] = "dm.s"
    ,   ["Essence of Health"        ] = "es.h", ["Restore Health" ] = "es.h"
    ,   ["Essence of Magicka"       ] = "es.m", ["Restore Magicka"] = "es.m"
    ,   ["Essence of Stamina"       ] = "es.s", ["Restore Stamina"] = "es.s"
    ,   ["Essence of Ravage Health" ] = "rv.h", ["Ravage Health"  ] = "rv.h"
    ,   ["Ravage Magicka"           ] = "rv.m"
    ,   ["Ravage Stamina"           ] = "rv.s"
    ,   ["Lorkhan's Tears"          ] = "lork"
    ,   ["Alkahest"                 ] = "alka"
    ,   ["nirnroot"                 ] = "nirn"
    ,   ["Spider Egg"               ] = "spdr"
    ,   ["Mudcrab Chitin"           ] = "mudc"
    ,   ["imp stool"                ] = "imps"
    ,   ["violet coprinus"          ] = "vcop"
    ,   ["Nightshade"               ] = "nish"

    ,   ["Damage Stamina Poison IX and acquiring Spider Eggs"    ] = "dam stam + spider eggs"
    ,   ["Damage Magicka Poison IX and acquiring Violet Coprinus"] = "dam mag + violet copr"
    ,   ["Damage Health Poison IX and acquiring Nightshade"      ] = "dam health + nightshade"
    ,   ["Essence of Health and acquiring some Nirnroot"         ] = "ess health + nirnroot"
    }
,   [CRAFT.ENCHANTING.type] = {
        ["Glyph of Stamina"   ] = "stam"
    ,   ["Ta Aspect Rune"     ] = "ta  ", ["Ta"     ] = "ta  "

    ,   ["Kedeko"             ] = "kdko"
    ,   ["Makko"              ] = "mkko"
    ,   ["Makkoma"            ] = "mkkm"
    ,   ["Hade"               ] = "hade"
    ,   ["Deni"               ] = "deni"
    ,   ["Rekura"             ] = "rekr"
    ,   ["Pora"               ] = "pora"

    ,   ["Glyph of Magicka and an Oko Essence Rune"       ] = "mag + oko"
    ,   ["Glyph of Stamina and acquiring a Ta Aspect Rune"] = "stam + ta"
    }
,   [CRAFT.PROVISIONING.type] = {
        ["Firsthold Fruit and Cheese Plate" ] = "ffcp"
    ,   ["Muthsera's Remorse"               ] = "muth"
    ,   ["Four-Eye Grog"                    ] = "fori"
    ,   ["Hagraven's Tonic"                 ] = "hagr"
    ,   ["Markarth Mead"                    ] = "mark"
    ,   ["Mazte"                            ] = "mazt"
    ,   ["Red Eye Beer"                     ] = "rebr"
    ,   ["Surilie Syrah Wine"               ] = "suri"
    ,   ["Baked Potato"                     ] = "pota"
    ,   ["Banana Surprise"                  ] = "bana"
    ,   ["Hearty Garlic Corn Chowder"       ] = "hgar"
    ,   ["Lilmoth Garlic Hagfish"           ] = "lilm"
    ,   ["Clarified Syrah Wine"             ] = "csyw"
    ,   ["Grape Preserves"                  ] = "grap"
    ,   ["Fishy Stick"                      ] = "fish"

    ,   ["Lilmoth Garlic Hagfish and Hagraven's Tonic"            ] = "pr6a lilmoth + hagraven"
    ,   ["Firsthold Fruit and Cheese Plate and Muthsera's Remorse"] = "pr6c firsthold + muthsera"
    }
,   [CRAFT.CLOTHIER.type] = {
        ["shoes"                        ] = "shoe"
    ,   ["hat"                          ] = "hat "
    ,   ["sash"                         ] = "sash"
    ,   ["robe"                         ] = "robe"
    ,   ["breeches"                     ] = "bree"
    ,   ["epaulets"                     ] = "eps "
    ,   ["helmet"                       ] = "hmet"
    ,   ["arm cops"                     ] = "armc"
    ,   ["bracers"                      ] = "brcr"

    ,   ["several Robes, Breeches, and Epaulets" ] = "cl.1 robe breech eps"
    ,   ["several Helmets, Arm Cops, and Bracers"] = "cl.2 helm cops bracers"
    }
,   [CRAFT.BLACKSMITHING.type] = {
        ["greatsword"                   ] = "2hgs"
    ,   ["sabatons"                     ] = "sabt"
    ,   ["gauntlets"                    ] = "gaun"
    ,   ["sword"                        ] = "1hsw"
    ,   ["cuirass"                      ] = "cuir"
    ,   ["greaves"                      ] = "grev"
    ,   ["helm"                         ] = "helm"
    ,   ["dagger"                       ] = "dagg"
    ,   ["dagger"                       ] = "paul"

    ,   ["several Greaves, Swords, and Cuirasses"] = "bs.1 1hsw cuirass greaves"
    ,   ["several Helms, Daggers, and Pauldrons" ] = "bs.2 dagg helm pauldrons"
    }
,   [CRAFT.WOODWORKING.type] = {
        ["bow"                          ] = "bow "
    ,   ["inferno staff"                ] = "infs"
    ,   ["ice staff"                    ] = "ices"
    ,   ["lightning staff"              ] = "ligs"
    ,   ["shield"                       ] = "shld"
    ,   ["restoration staff"            ] = "rest"

    ,   ["several Restoration Staves and Shields"] = "ww.1 resto shield"
    ,   ["several Bows and Shields"              ] = "ww.2 bow shield"
    }
,   [CRAFT.JEWELRY.type] = {
        ["necklace"                     ] = "neck"
    ,   ["ring"                         ] = "ring"

    ,   ["three Electrum Rings"             ] = "3 rings"
    ,   ["Copper Ring and Copper Necklace"  ] = "ring + neck"
    }
}
--]]

-- for desc2 strings to a single abbreviation
REQUIREMENT_ABBREV = {
    [CRAFT.ALCHEMY.type] = {
        ["Damage Stamina Poison IX and acquiring Spider Eggs"       ] = "dam stam + spider eggs"
    ,   ["Damage Magicka Poison IX and acquiring Violet Coprinus"   ] = "dam mag + violet copr"
    ,   ["Damage Health Poison IX and acquiring Nightshade"         ] = "dam health + nightshade"
    ,   ["Drain Health Poison IX and acquiring Lorkhan's Tears"     ] = "drain health + lorkhan's"
    ,   ["Essence of Health and acquiring some Nirnroot"            ] = "ess health + nirnroot"
    ,   ["Essence of Magicka and acquiring some Imp Stool"          ] = "ess mag + imp stool"
    ,   ["Essence of Ravage Health and acquiring Alkahest"          ] = "rav health + alkahest"
    }
,   [CRAFT.ENCHANTING.type] = {
        ["Glyph of Magicka and an Oko Essence Rune"                 ] = "mag + oko"
    ,   ["Glyph of Magicka and acquiring a Deni Essence Rune"       ] = "mag + deni"
    ,   ["Glyph of Magicka and acquiring a Makko Essence Rune"      ] = "mag + makko"
    ,   ["Glyph of Magicka and acquiring an Oko Essence Rune"       ] = "mag + oko"
    ,   ["Glyph of Magicka and an Oko Essence Rune"                 ] = "mag + oko"
    ,   ["Glyph of Stamina and acquiring a Ta Aspect Rune"          ] = "stam + ta"
    ,   ["Glyph of Stamina and a Ta Aspect Rune"                    ] = "stam + ta"
    ,   ["Glyph of Health and a Jehade Potency Rune"                ] = "health + jehade"
    ,   ["Glyph of Health and acquiring a Kedeko Potency Rune"      ] = "health + kedeko"
    ,   ["Glyph of Health and acquiring a Hade Potency Rune"        ] = "health + hade"
    }
,   [CRAFT.PROVISIONING.type] = {
        ["Baked Apples and Lemon Flower Mazte"                      ] = "dc1a baked apples + lemon flower"
    ,   ["Carrot Soup and Golden Lager"                             ] = "dc1b carrot soup + golden lager"
    ,   ["Fishy Stick and Surilie Syrah Wine"                       ] = "dc1c fishy + surilie"
    ,   ["Pellitine Tomato Rice and Seaflower Tea"                  ] = "dc2a pelletine + seaflower"
    ,   ["Alik'r Beets with Goat Cheese and Gossamer Matze"         ] = "dc2b alik'r beets + gossamer"
    ,   ["Breton Pork Sausage and Ginger Wheat Beer"                ] = "dc2c breton pork + ginger wheat"
    ,   ["Cinnamon Grape Jelly and Torval Mint Tea"                 ] = "dc3a cinnamon grape + torval"
    ,   ["Garlic Mashed Potatoes and Mulled Wine"                   ] = "dc3b garlic mashed + mulled wine"
    ,   ["Senchal Curry Fish and Rice and Nereid Wine"              ] = "dc3b senchal curry + nereid wine"

    ,   ["Chicken Breast and Mazte"                                 ] = "ad1a chicken breast + mazte"
    ,   ["Banana Surprise and Four-Eye Grog"                        ] = "ad1b banana + four-eye"
    ,   ["Baked Potato and Red Rye Beer"                            ] = "ad1c baked potato + red rye"
    ,   ["Whiterun Cheese-Baked Trout and Mermaid Whiskey"          ] = "ad2a whiterun cheese + mermaid"
    ,   ["Garlic Pumpkin Seeds and Treacleberry Tea"                ] = "ad2b garlic pumpkin + treacleberry"
    ,   ["Nibenese Garlic Carrots and Barley Nectar"                ] = "ad2c nibenese garlic + barley nectar"
    ,   ["Elinhir Roast Antelope and Sorry, Honey Lager"            ] = "ad3a elinhir roast + sorry honey"
    ,   ["Cyrodilic Pumpkin Fritters and Spiceberry Chai"           ] = "ad3b cyrodilic pumpkin + spiceberry"
    ,   ["Chorrol Corn on the Cob and Spiced Mazte"                 ] = "ad3c chorrol corn + spiced mazte"

    ,   ["Grape Preserves and Clarified Syrah Wine"                 ] = "ep1a grape + clarified"
    ,   ["Roast Corn and Nut Brown Ale"                             ] = "ep1b roast corn + nut brown ale"
    ,   ["Chicken Breast and Bog Iron Ale"                          ] = "ep1c chicken breast + bog iron ale"
    ,   ["Redoran Peppered Melon and Bitterlemon Tea"               ] = "ep2a redoran peppered + bitterlemon"
    ,   ["Battaglir Chowder and Eltheric Hooch"                     ] = "ep2b battaglir + elthiric"
    ,   ["Venison Pasty and Honey Rye"                              ] = "ep2c venison pasty + honey rye"
    ,   ["Stormhold Baked Bananas and Maormer Tea"                  ] = "ep3a stormhold baked + maomer tea"
    ,   ["Jerall View Inn Carrot Cake and Sour Mash"                ] = "ep3b jerall view + sour mash"
    ,   ["Hare in Garlic Sauce and Rye-in-Your-Eye"                 ] = "ep3c hare in garlic + rye-in-your-eye"

    ,   ["Mammoth Snout Pie and Two%-Zephyr Tea"                    ] = "pr4a mammoth snout + two-zephyr"
    ,   ["Skyrim Jazbay Crostata and Blue Road Marathon"            ] = "pr4b skyrim jazbay + blue road"
    ,   ["Cyrodiilic Cornbread and Gods-Blind-Me"                   ] = "pr4c cyrodilic cornbread + gods-blind-me"
    ,   ["Orcrest Garlic Apple Jelly and Grandpa’s Bedtime Tonic"   ] = "pr5a orcrest garlic + grandpa's bedtime"
    ,   ["West Weald Corn Chowder and Comely Wench Whisky"          ] = "pr5b west weald + comely wench"
    ,   ["Millet-Stuffed Pork Loin and Aetherial Tea"               ] = "pr5c millet-stuffed + aetherial"
    ,   ["Lilmoth Garlic Hagfish and Hagraven's Tonic"              ] = "pr6a lilmoth + hagraven"
    ,   ["Hearty Garlic Corn Chowder and Markarth Mead"             ] = "pr6b hearty garlic + markarth"
    ,   ["Firsthold Fruit and Cheese Plate and Muthsera's Remorse"  ] = "pr6c firsthold + muthsera"
    }
,   [CRAFT.CLOTHIER.type] = {
        ["Robes, Breeches, and Epaulets"        ] = "cl.1 robe breech eps"
    ,   ["Helmets, Arm Cops, and Bracers"       ] = "cl.2 helm cops bracers"
    ,   ["Arm Cops, Helmets, and Bracers"       ] = "cl.2 helm cops bracers"
    ,   ["Shoes, Hats, and Sashes"              ] = "cl.3 shoes hat sash"
    }
,   [CRAFT.BLACKSMITHING.type] = {
        ["Greaves, Swords, and Cuirasses"       ] = "bs.1 sword cuirass greaves"
    ,   ["Swords, Cuirass, and Greaves"         ] = "bs.1 sword cuirass greaves"
    ,   ["Helms, Daggers, and Pauldrons"        ] = "bs.2 dagg helm pauldrons"
    ,   ["Greatswords, Sabatons, and Gauntlets" ] = "bs.3 g-sword sabatons gaunts"
    }
,   [CRAFT.WOODWORKING.type] = {
        ["Restoration Staves and Shields"                   ] = "ww.1 resto shield"
    ,   ["Bows and Shields"                                 ] = "ww.2 bow shield"
    ,   ["Inferno Staves, Ice Staves, and Lightning Staves" ] = "ww.3 tri-staff"
    }
,   [CRAFT.JEWELRY.type] = {
        ["three %S+ Rings"                      ] = "jw.1 3 rings"
    ,   ["%S+ Ring and %S+ Necklace"            ] = "jw.2 ring + neck"
    ,   ["%S+ Ring and an? %S+ Necklace"        ] = "jw.2 ring + neck"
    ,   ["two %S+ Necklaces"                    ] = "jw.3 2 necklaces"
    }
}

local function AbbreviateMulti(abbr_table, text)
    local abbr_list = {}
    if not text then return abbr_list end
    for k,v in pairs(abbr_table) do
        if string.find(text, k) then
            table.insert(abbr_list, v)
        end
    end
    table.sort(abbr_list)
    return abbr_list
end

local function AbbreviateOne(abbr_table, text)
    if not text then return nil end
    for k,v in pairs(abbr_table) do
        if string.find(text, k) then
            return v
        end
    end
    return nil
end

local function Error(...)
    print(string.format(...))
end

local function rdump(t)
    if type(t) ~= "table" then return tostring(t) end

    local s = "{"
    for k,v in pairs(t) do s = s..k..":"..rdump(v).." " end
    s = s.."}"
    return s
end

local function dump(t)
    print(rdump(t))
end

function AccumulateDaily(input_row, output_row)
    if (not input_row) or (input_row.quest_type ~= "daily") then
        return nil
    end
                        -- Did we move to a new character or date?
                        -- Output current accumulator and start a
                        -- fresh one.
    local output   = nil
    local date     = input_row.time:sub(1,10)
    if (output_row.date      ~= date)
            or (output_row.char_name ~= input_row.char_name ) then
        output               = ToOutput(output_row)
        output_row.date      = date
        output_row.char_name = input_row.char_name
        output_row.req       = { ".", ".", "", "", "", "", "" }
    end

    local crafting_type = input_row.crafting_type
    local craft         = CRAFT[crafting_type]
    local req_abbrev    = REQUIREMENT_ABBREV[input_row.crafting_type]
    if not req_abbrev then
        Error("unknown crafting_type:%d", input_row.crafting_type)
        return output
    end

    local abbrev = AbbreviateOne(req_abbrev, input_row.desc2)
    output_row.req[craft.ord] = abbrev
-- dump(output_row)
    return output
end

-- From http://lua-users.org/wiki/SplitJoin
function zo_strsplit(sep,str)
    sep = sep or "\t"
    local ret={}
    local n=1
    for w in str:gmatch("([^"..sep.."]*)") do
        ret[n] = ret[n] or w -- only set once (so the blank after a string is ignored)
        if w=="" then
            n = n + 1
        end -- step forwards on a blank but not a string
    end
    return unpack(ret)
end

local function ZO_LinkHandler_ParseLink(link)
    if type(link) == "string" then
        local linkStyle, data, text = link:match("|H(.-):(.-)|h(.-)|h")
        return text, linkStyle, zo_strsplit(':', data)
    end
end

-- Break an item_link string into its numeric pieces
--
-- The writ1..writ6 fields are what we really want.
-- Their meanings change depending on the master writ type.
--
function ToWritFields(item_link)
    local x = { ZO_LinkHandler_ParseLink(item_link) }
    local o = {
        text             =          x[ 1]
    ,   link_style       = tonumber(x[ 2])
    ,   unknown3         = tonumber(x[ 3])
    ,   item_id          = tonumber(x[ 4])
    ,   sub_type         = tonumber(x[ 5])
    ,   internal_level   = tonumber(x[ 6])
    ,   enchant_id       = tonumber(x[ 7])
    ,   enchant_sub_type = tonumber(x[ 8])
    ,   enchant_level    = tonumber(x[ 9])
    ,   writ1            = tonumber(x[10])
    ,   writ2            = tonumber(x[11])
    ,   writ3            = tonumber(x[12])
    ,   writ4            = tonumber(x[13])
    ,   writ5            = tonumber(x[14])
    ,   writ6            = tonumber(x[15])
    ,   item_style       = tonumber(x[16])
    ,   is_crafted       = tonumber(x[17])
    ,   is_bound         = tonumber(x[18])
    ,   is_stolen        = tonumber(x[19])
    ,   charge_ct        = tonumber(x[20])
    ,   unknown21        = tonumber(x[21])
    ,   unknown22        = tonumber(x[22])
    ,   unknown23        = tonumber(x[23])
    ,   writ_reward      = tonumber(x[24])
    }

    return o
end
function AccumulateMaster(input_row)
    if (not input_row) or (input_row.quest_type ~= "master") then
        return nil
    end

    local date                  = input_row.time:sub(1,10)
    local output_row            = {}
    output_row.date             = date
    output_row.char_name        = input_row.char_name
    output_row.crafting_type    = input_row.crafting_type -- nil for old log
    output_row.item_link        = input_row.item_link

    local w                     = ToWritFields(input_row.item_link)
    local t = { output_row.date
              , output_row.char_name     or ""
              , output_row.crafting_type or ""
              , output_row.item_link
              , w.writ1                  or "?"
              , w.writ2
              , w.writ3
              , w.writ4
              , w.writ5
              , w.writ6
              , math.floor(w.writ_reward/10000)
              }
    table.insert(MASTER_LINES, table.concat(t, "\t"))
end

function OutputMasterList()
    for _,line in ipairs(MASTER_LINES) do
        print(line)
    end
end

function ToOutput(output_row)
    local t = {}
    if not output_row.date then return nil end
    table.insert(t, output_row.date)
    table.insert(t, output_row.char_name)
    for ord = 1,7 do
        local req = output_row.req[ord] or ""
        -- local s   = table.concat(req, "\t")
        table.insert(t, req)
    end
    return table.concat(t, "\t")
end

local output_row = {}
for _,input_row in ipairs(input) do
    AccumulateMaster(input_row)
    local line = AccumulateDaily(input_row, output_row)
-- dump(output_row)
    if line then
        print(line)
    end

end
-- dump(output_row)
local last_line = ToOutput(output_row)
if last_line then
    print(last_line)
end

OutputMasterList()


