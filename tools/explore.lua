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

REQUIREMENT_ABBREV = {
    [CRAFT.ALCHEMY.type] = {
        ["Drain Health Poison"] = "xdrh"
    ,   ["Lorkhan's Tears"    ] = "lork"
    ,   ["Alkahest"           ] = "alka"
    }
,   [CRAFT.ENCHANTING.type] = {
        ["Glyph of Stamina"   ] = "stam"
    ,   ["Ta Aspect Rune"     ] = "ta"
    }
,   [CRAFT.PROVISIONING.type] = {
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

function ToRowString(input_row)
    if (not input_row) or (input_row.quest_type ~= "daily") then
        return nil
    end
    local craft = CRAFT[input_row.crafting_type]

    local req_abbrev    = REQUIREMENT_ABBREV[input_row.crafting_type]
    if not req_abbrev then
        Error("unknown crafting_type:%d", input_row.crafting_type)
        return nil
    end

    local req_list = AbbreviateMulti(req_abbrev, input_row.desc2)
                        -- Pad to a fixed number of reqs for each crafting type.
    local req_ct   = craft.req_ct
    for i = #req_list,req_ct-1 do
        table.insert(req_list,"")
    end

    local req      = table.concat(req_list,"\t")
    local char     = AbbreviateOne(CHAR_ABBREV, input_row.char_name)
    local date     = input_row.time:sub(1,10)
    local ctype    = craft.abbrev

    return string.format("%s\t%s\t%s\t%s", date, char, ctype, req)
end

function Accumulate(input_row, output_row)
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
        output_row.req       = {}
        for ctype,c in ipairs(CRAFT) do
            local r = {}
            for i = 1,c.req_ct do
                table.insert(r,"")
            end
            output_row.req[c.ord] = r
        end
    end

    local crafting_type = input_row.crafting_type
    local craft         = CRAFT[crafting_type]
    local req_abbrev    = REQUIREMENT_ABBREV[input_row.crafting_type]
    if not req_abbrev then
        Error("unknown crafting_type:%d", input_row.crafting_type)
        return output
    end

    local req_list = AbbreviateMulti(req_abbrev, input_row.desc2)
                        -- Pad to a fixed number of reqs for each crafting type.
    for i = #req_list,craft.req_ct-1 do
        table.insert(req_list,"")
    end
    output_row.req[craft.ord] = req_list
-- dump(output_row)
    return output
end

function ToOutput(output_row)
    local t = {}
    if not output_row.date then return nil end
    table.insert(t, output_row.date)
    table.insert(t, output_row.char_name)
    for ord = 1,7 do
        local req = output_row.req[ord]
        local s   = table.concat(req, "\t")
        table.insert(t, s)
    end
    return table.concat(t, "\t")
end

local output_row = {}
for _,input_row in ipairs(input) do
    local line = Accumulate(input_row, output_row)
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



