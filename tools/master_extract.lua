dofile("../data/WritLogger.lua")
LOG1 = WritLoggerVars["Default"]["@ziggr"]["$AccountWide"]["log"]
dofile("../data/WritLogger.bak.lua")
LOG2 = WritLoggerVars["Default"]["@ziggr"]["$AccountWide"]["log"]

dofile("../WritLogger_Summarize.lua")

WritLogger = WritLogger or {}
WritLogger.saved_vars = WritLogger.saved_vars or WritLoggerVars["Default"]["@ziggr"]["$AccountWide"]

                        -- Merge old and new data
LOG = {}
for k,v in pairs(LOG1) do table.insert(LOG, v) end
for k,v in pairs(LOG2) do table.insert(LOG, v) end

                        -- Convert to summary lines
seen = {}
SUMMARY_LINES = {}
for k,v in pairs(LOG) do
    if v.item_link then
        local line = WritLogger.SummarizeMaster( v.time:sub(1,10)
                                               , v.char_name
                                               , v.crafting_type
                                               , v.item_link
                                               )
        if line and not seen[line] then
            seen[line] = 1
            table.insert(SUMMARY_LINES, line)
        end
    end
end

table.sort(SUMMARY_LINES)

for i,line in ipairs(SUMMARY_LINES) do
    print(string.format("[%d] = \"%s\",",i,line))
end
