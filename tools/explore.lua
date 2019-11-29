dofile("../data/WritLogger.lua")

                        -- Narrow input range to something
                        -- we want to test
local INPUT_LOG   = WritLoggerVars["Default"]["@ziggr"]["$AccountWide"]["log"]
local INPUT_RANGE = {20,22}
local input = {}
for i = INPUT_RANGE[1], INPUT_RANGE[2] do
    table.insert(input, INPUT_LOG[i])
end

CHAR_ABBREV = {
    ["Zhaksyr the Mighty"] = "zh"
}

CRAFT_TYPE = {
    ["ALCHEMY"     ] = 4
,   ["ENCHANTING"  ] = 3
,   ["PROVISIONING"] = 5
}

CRAFT_ABBREV = {
    [CRAFT_TYPE.ALCHEMY     ] = "al"
,   [CRAFT_TYPE.ENCHANTING  ] = "en"
,   [CRAFT_TYPE.PROVISIONING] = "pr"
}

CRAFT_REQ_CT = {
    [CRAFT_TYPE.ALCHEMY     ] = 2
,   [CRAFT_TYPE.ENCHANTING  ] = 2
,   [CRAFT_TYPE.PROVISIONING] = 2
}

REQUIREMENT_ABBREV = {
    [CRAFT_TYPE.ALCHEMY] = {
        ["Drain Health Poison"] = "xdrh"
    ,   ["Lorkhan's Tears"    ] = "lork"
    ,   ["Alkahest"           ] = "alka"
    }
,   [CRAFT_TYPE.ENCHANTING] = {
        ["Glyph of Stamina"   ] = "stam"
    ,   ["Ta Aspect Rune"     ] = "ta"
    }
,   [CRAFT_TYPE.PROVISIONING] = {
        ["Firsthold Fruit and Cheese Plate"] = "ffcp"
    ,   ["Muthsera's Remorse"              ] = "muth"
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

local function dump(t)
    local s = ""
    for k,v in pairs(t) do s = s..k.." " end
    print(s)
end

function ToRowString(input_row)
    if (not input_row) or (input_row.quest_type ~= "daily") then
        return nil
    end

    local req_abbrev    = REQUIREMENT_ABBREV[input_row.crafting_type]
    if not req_abbrev then
        Error("unknown crafting_type:%d", input_row.crafting_type)
        return nil
    end

    local req_list = AbbreviateMulti(req_abbrev, input_row.desc2)
                        -- Pad to a fixed number of reqs for each crafting type.
    local req_ct   = CRAFT_REQ_CT[input_row.crafting_type]
    for i = #req_list,req_ct-1 do
        table.insert(req_list,"")
    end

    local req      = table.concat(req_list,"\t")
    local char     = AbbreviateOne(CHAR_ABBREV, input_row.char_name)
    local date     = input_row.time:sub(1,10)
    local ctype    = CRAFT_ABBREV[input_row.crafting_type]

    return string.format("%s\t%s\t%s\t%s", date, char, ctype, req)
end

for _,input_row in ipairs(input) do
    local line = ToRowString(input_row)
    if line then
        print(line)
    end
end


