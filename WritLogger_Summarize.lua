WritLogger = WritLogger or {}

                        -- ord    = order in output
                        -- type   = CRAFTING_TYPE_X numeric value
                        -- abbrev = abbreviation. Not used
                        -- req_ct = largest number of items (crafted or mats)
                        --          required for this crafting type's daily
                        --          writs. Not used.
local CRAFT = {
    ["BLACKSMITHING"] = { ord = 1, type = 1, abbrev = "bs" }
,   ["CLOTHIER"     ] = { ord = 2, type = 2, abbrev = "cl" }
,   ["WOODWORKING"  ] = { ord = 3, type = 6, abbrev = "ww" }
,   ["JEWELRY"      ] = { ord = 4, type = 7, abbrev = "jw" }
,   ["ALCHEMY"      ] = { ord = 5, type = 4, abbrev = "al" }
,   ["ENCHANTING"   ] = { ord = 6, type = 3, abbrev = "en" }
,   ["PROVISIONING" ] = { ord = 7, type = 5, abbrev = "pr" }
}
                        -- Index craft by numeric CRAFTING_TYPE_X
                        -- in addition to above index by symbol.
local cc = {}
for k,v in pairs(CRAFT) do cc[v.type] = v end
for k,v in ipairs(cc) do CRAFT[k] = v end
cc = nil

-- shorten desc2 strings to a single abbreviation
WritLogger.REQUIREMENT_ABBREV = {
    [CRAFT.ALCHEMY.type] = {
        { abbrev = "1" , name = "dam stam + spider eggs"             , desc = { "Damage Stamina Poison IX and acquiring Spider Eggs"       } }
    ,   { abbrev = "2" , name = "dam mag + violet copr"              , desc = { "Damage Magicka Poison IX and acquiring Violet Coprinus"   } }
    ,   { abbrev = "3" , name = "dam health + nightshade"            , desc = { "Damage Health Poison IX and acquiring Nightshade"         } }
    ,   { abbrev = "4" , name = "rav health + alkahest"              , desc = { "Essence of Ravage Health and acquiring Alkahest"          } }
    ,   { abbrev = "5" , name = "ess stam + mudcrab"                 , desc = { "Essence of Stamina and acquiring Mudcrab Chitin"          } }
    ,   { abbrev = "6" , name = "ess mag + imp stool"                , desc = { "Essence of Magicka and acquiring some Imp Stool"          } }
    ,   { abbrev = "7" , name = "ess health + nirnroot"              , desc = { "Essence of Health and acquiring some Nirnroot"            } }
    ,   { abbrev = "8" , name = "drain health + lorkhan's"           , desc = { "Drain Health Poison IX and acquiring Lorkhan's Tears"     } }
    }
,   [CRAFT.ENCHANTING.type] = {
        { abbrev = "m1", name = "mag + oko"                          , desc = { "Glyph of Magicka and an Oko Essence Rune"                 } }
    ,   { abbrev = "m2", name = "mag + deni"                         , desc = { "Glyph of Magicka and acquiring a Deni Essence Rune"       } }
    ,   { abbrev = "m3", name = "mag + makko"                        , desc = { "Glyph of Magicka and acquiring a Makko Essence Rune"      } }
    ,   { abbrev = "m4", name = "mag + makkoma"                      , desc = { "Glyph of Magicka and acquiring a Makkoma Essence Rune"    } }
    ,   { abbrev = "m5", name = "mag + oko"                          , desc = { "Glyph of Magicka and acquiring an Oko Essence Rune"
                                                                              , "Glyph of Magicka and an Oko Essence Rune"                 } }
    ,   { abbrev = "s1", name = "stam + ta"                          , desc = { "Glyph of Stamina and acquiring a Ta Aspect Rune"
                                                                              , "Glyph of Stamina and a Ta Aspect Rune"                    } }
    ,   { abbrev = "h1", name = "health + jehade"                    , desc = { "Glyph of Health and a Jehade Potency Rune"                } }
    ,   { abbrev = "h2", name = "health + kedeko"                    , desc = { "Glyph of Health and acquiring a Kedeko Potency Rune"      } }
    ,   { abbrev = "h3", name = "health + hade"                      , desc = { "Glyph of Health and acquiring a Hade Potency Rune"        } }
    ,   { abbrev = "h4", name = "health + pode"                      , desc = { "Glyph of Health and acquiring a Pode Potency Rune"        } }
    ,   { abbrev = "h5", name = "health + idode"                     , desc = { "Glyph of Health and acquiring an Idode Potency Rune"      } }
    ,   { abbrev = "h5", name = "health + rede"                      , desc = { "Glyph of Health and acquiring a Rede Potency Rune"        } }
    }
,   [CRAFT.PROVISIONING.type] = {
        { abbrev = "d1", name = "fishy + surilie"                    , desc = { "Fishy Stick and Surilie Syrah Wine"                       } }
    ,   { abbrev = "d2", name = "baked apples + lemon flower"        , desc = { "Baked Apples and Lemon Flower Mazte"                      } }
    ,   { abbrev = "d3", name = "carrot soup + golden lager"         , desc = { "Carrot Soup and Golden Lager"                             } }
    ,   { abbrev = "d4", name = "pelletine + seaflower"              , desc = { "Pellitine Tomato Rice and Seaflower Tea"                  } }
    ,   { abbrev = "d5", name = "alik'r beets + gossamer"            , desc = { "Alik'r Beets with Goat Cheese and Gossamer Matze"         } }
    ,   { abbrev = "d6", name = "breton pork + ginger wheat"         , desc = { "Breton Pork Sausage and Ginger Wheat Beer"                } }
    ,   { abbrev = "d7", name = "cinnamon grape + torval"            , desc = { "Cinnamon Grape Jelly and Torval Mint Tea"                 } }
    ,   { abbrev = "d8", name = "garlic mashed + mulled wine"        , desc = { "Garlic Mashed Potatoes and Mulled Wine"                   } }
    ,   { abbrev = "d9", name = "senchal curry + nereid wine"        , desc = { "Senchal Curry Fish and Rice and Nereid Wine"              } }

    ,   { abbrev = "a1", name = "chicken breast + mazte"             , desc = { "Chicken Breast and Mazte"                                 } }
    ,   { abbrev = "a2", name = "banana + four-eye"                  , desc = { "Banana Surprise and Four-Eye Grog"                        } }
    ,   { abbrev = "a3", name = "baked potato + red rye"             , desc = { "Baked Potato and Red Rye Beer"                            } }
    ,   { abbrev = "a4", name = "whiterun cheese + mermaid"          , desc = { "Whiterun Cheese%-Baked Trout and Mermaid Whiskey"         } }
    ,   { abbrev = "a5", name = "garlic pumpkin + treacleberry"      , desc = { "Garlic Pumpkin Seeds and Treacleberry Tea"                } }
    ,   { abbrev = "a6", name = "nibenese garlic + barley nectar"    , desc = { "Nibenese Garlic Carrots and Barley Nectar"                } }
    ,   { abbrev = "a7", name = "elinhir roast + sorry honey"        , desc = { "Elinhir Roast Antelope and Sorry, Honey Lager"            } }
    ,   { abbrev = "a8", name = "cyrodilic pumpkin + spiceberry"     , desc = { "Cyrodilic Pumpkin Fritters and Spiceberry Chai"           } }
    ,   { abbrev = "a9", name = "chorrol corn + spiced mazte"        , desc = { "Chorrol Corn on the Cob and Spiced Mazte"                 } }

    ,   { abbrev = "e1", name = "chicken breast + bog iron ale"      , desc = { "Chicken Breast and Bog%-Iron Ale"                         } }
    ,   { abbrev = "e2", name = "grape + clarified"                  , desc = { "Grape Preserves and Clarified Syrah Wine"                 } }
    ,   { abbrev = "e3", name = "roast corn + nut brown ale"         , desc = { "Roast Corn and Nut Brown Ale"                             } }
    ,   { abbrev = "e4", name = "venison pasty + honey rye"          , desc = { "Venison Pasty and Honey Rye"                              } }
    ,   { abbrev = "e5", name = "redoran peppered + bitterlemon"     , desc = { "Redoran Peppered Melon and Bitterlemon Tea"               } }
    ,   { abbrev = "e6", name = "battaglir + elthiric"               , desc = { "Battaglir Chowder and Eltheric Hooch"                     } }
    ,   { abbrev = "e7", name = "stormhold baked + maomer tea"       , desc = { "Stormhold Baked Bananas and Maormer Tea"                  } }
    ,   { abbrev = "e8", name = "jerall view + sour mash"            , desc = { "Jerall View Inn Carrot Cake and Sour Mash"                } }
    ,   { abbrev = "e9", name = "hare in garlic + rye-in-your-eye"   , desc = { "Hare in Garlic Sauce and Rye%-in%-Your%-Eye"              } }

    ,   { abbrev = "p1", name = "mammoth snout + two-zephyr"         , desc = { "Mammoth Snout Pie and Two%-Zephyr Tea"                    } }
    ,   { abbrev = "p2", name = "skyrim jazbay + blue road"          , desc = { "Skyrim Jazbay Crostata and Blue Road Marathon"            } }
    ,   { abbrev = "p3", name = "cyrodilic cornbread + gods-blind-me", desc = { "Cyrodilic Cornbread and Gods%-Blind%-Me"                  } }
    ,   { abbrev = "p4", name = "millet-stuffed + aetherial"         , desc = { "Millet%-Stuffed Pork Loin and Aetherial Tea"              } }
    ,   { abbrev = "p5", name = "orcrest garlic + grandpa's bedtime" , desc = { "Orcrest Garlic Apple Jelly and Grandpa's Bedtime Tonic"   } }
    ,   { abbrev = "p6", name = "west weald + comely wench"          , desc = { "West Weald Corn Chowder and Comely Wench Whiskey"         } }
    ,   { abbrev = "p7", name = "lilmoth + hagraven"                 , desc = { "Lilmoth Garlic Hagfish and Hagraven's Tonic"              } }
    ,   { abbrev = "p8", name = "firsthold + muthsera"               , desc = { "Firsthold Fruit and Cheese Plate and Muthsera's Remorse"  } }
    ,   { abbrev = "p9", name = "hearty garlic + markarth"           , desc = { "Hearty Garlic Corn Chowder and Markarth Mead"             } }
    }
,   [CRAFT.CLOTHIER.type] = {
        { abbrev = "1" , name = "robe breech eps"                    , desc = { "Robes, Breeches, and Epaulets"                            } }
    ,   { abbrev = "2" , name = "helm cops bracers"                  , desc = { "Helmets, Arm Cops, and Bracers"
                                                                              , "Arm Cops, Helmets, and Bracers"                           } }
    ,   { abbrev = "3" , name = "shoes hat sash"                     , desc = { "Shoes, Hats, and Sashes"                                  } }
    }
,   [CRAFT.BLACKSMITHING.type] = {
        { abbrev = "1" , name = "sword cuirass greaves"              , desc = { "Greaves, Swords, and Cuirasses"
                                                                              , "Swords, Cuirass, and Greaves"                             } }
    ,   { abbrev = "2" , name = "dagg helm pauldrons"                , desc = { "Helms, Daggers, and Pauldrons"                            } }
    ,   { abbrev = "3" , name = "g-sword sabatons gaunts"            , desc = { "Greatswords, Sabatons, and Gauntlets"                     } }
    }
,   [CRAFT.WOODWORKING.type] = {
        { abbrev = "1" , name = "resto shield"                       , desc = { "Restoration Staves and Shields"                           } }
    ,   { abbrev = "2" , name = "bow shield"                         , desc = { "Bows and Shields"                                         } }
    ,   { abbrev = "3" , name = "tri-staff"                          , desc = { "Inferno Staves, Ice Staves, and Lightning Staves"         } }
    }
,   [CRAFT.JEWELRY.type] = {
        { abbrev = "1" , name = "3 rings"                            , desc = { "three %S+ Rings"                                          } }
    ,   { abbrev = "2" , name = "ring + neck"                        , desc = { "%S+ Ring and %S+ Necklace"
                                                                              , "%S+ Ring and an? %S+ Necklace"                            } }
    ,   { abbrev = "3" , name = "2 necklaces"                        , desc = { "two %S+ Necklaces"                                        } }
    }
}

function WritLogger.DailyDescToReq(crafting_type, desc2)
    if not desc2 then return nil end
    local self = WritLogger
    local rlist = self.REQUIREMENT_ABBREV[crafting_type]
    for _,r in ipairs(rlist) do
        for _,d in ipairs(r.desc) do
            if string.find(desc2, d) then
                return r
            end
        end
    end
    return nil
end

-- Return a 1- or 2-character ID for what this daily writ requires.
function WritLogger.DescToID(crafting_type, desc2)
    local self = WritLogger
    local r = self.DailyDescToReq(crafting_type, desc2)
    if r then return r.abbrev end
    return nil
end

local function sdump(t)
    local o = {}
    for k,v in pairs(t) do
        local s = tostring(k)..":"..tostring(v)
        table.insert(o,s)
    end
    return table.concat(o," ")
end

function WritLogger.table_rcopy(t)
    local tt = {}
    for k,v in pairs(t) do
        if type(c) ~= "table" then
            tt[k] = v
        else
            tt[k]= WritLogger.table_rcopy(v)
        end
    end
    return tt
end

function WritLogger.DailyBlank()
    local r ={ " ", " ", " ", " ", " ", "  ", "  " }
    return r
end

-- Add one daily crafting writ to an accumulator.
-- If the requested date+char_name match the current accumulator, just insert
-- the daily writ in to the accumulator and return nil.
-- If requested date+char_name does not match given accumulator,
-- reset the accumulator to the new date+char_name, and also return
-- the pre-reset accumulator's contents as something worth outputting.
function WritLogger.AccumulateDaily(input, accumulator)
    local self = WritLogger
    local output_accumulator = nil
    local date = input.time:sub(1,10)
    if date ~= accumulator.date or input.char_name ~= accumulator.char_name then
        output_accumulator = WritLogger.table_rcopy(accumulator)
        accumulator.date        = date
        accumulator.char_name   = input.char_name
        accumulator.req_id_list = self.DailyBlank()
    end

    local ord = CRAFT[input.crafting_type].ord
    local id  = self.DescToID(input.crafting_type, input.desc2)
    if id then
        accumulator.req_id_list[ord] = id
    end
    return output_accumulator
end

function WritLogger.DailyAccumulatorToString(accumulator)
    if not (accumulator and accumulator.req_id_list) then return "" end
    return table.concat(accumulator.req_id_list,"")
end

------------------------------------------------------------------------------

WritLogger.CHAR = {
  ["Zithara"]            = { ord =  1, name = "Zithara"            }
, ["S'camper"]           = { ord =  2, name = "S'camper"           }
, ["Z'foompo"]           = { ord =  3, name = "Z'foompo"           }
, ["Zerwanwe"]           = { ord =  4, name = "Zerwanwe"           }
, ["Zagrush"]            = { ord =  5, name = "Zagrush"            }
, ["Hammer-Meets-Thumb"] = { ord =  6, name = "Hammer-Meets-Thumb" }
, ["Zifithri"]           = { ord =  7, name = "Zifithri"           }
, ["Blaithe"]            = { ord =  8, name = "Blaithe"            }
, ["Zhaksyr the Mighty"] = { ord =  9, name = "Zhaksyr the Mighty" }
, ["Zecorwyn"]           = { ord = 10, name = "Zecorwyn"           }
, ["Lilwen"]             = { ord = 11, name = "Lilwen"             }
, ["Alexander Mundus"]   = { ord = 12, name = "Alexander Mundus"   }
, ["Simone Chevalier"]   = { ord = 13, name = "Simone Chevalier"   }
, ["Hagnar the Slender"] = { ord = 14, name = "Hagnar the Slender" }
, ["Daenir Haggertyn"]   = { ord = 15, name = "Daenir Haggertyn"   }
, ["Zugbesha"]           = { ord = 16, name = "Zugbesha"           }
, ["Zancalmo"]           = { ord = 17, name = "Zancalmo"           }
}
                        -- Index by ord as well as name.
local cc = {}
for char_name,_ in pairs(WritLogger.CHAR) do table.insert(cc, char_name) end
for _,char_name in ipairs(cc) do
    local char_row = WritLogger.CHAR[char_name]
    WritLogger.CHAR[char_row.ord] = char_row
end

                        -- A giant matrix of all char's 10-char summary
                        --   ["date"] = "char1 char2 char3 ... char11"
WritLogger.DAILY_GRID = {}

function WritLogger.DailyRecord(date, char_name, crafting_type, desc2)
    local self = WritLogger
    if not self.DAILY_GRID[date] then
        local dg = {}
        for char_name,char_row in pairs(self.CHAR) do
            table.insert(dg, self.DailyBlank())
        end
        self.DAILY_GRID[date] = dg
    end
    local dg_row    = self.DAILY_GRID[date]
    local char_row  = self.CHAR[char_name]
    local char_cell = dg_row[char_row.ord]
    local id        = self.DescToID(crafting_type, desc2)
    local craft_row = CRAFT[crafting_type]
    char_cell[craft_row.ord] = id
end
