local WritLogger = WritLogger

WritLogger.QTYPE = { ["DAILY" ] = "daily"
                   , ["MASTER"] = "master"
                   }

function WritLogger.OnQuestAdded(event_code, journal_index, quest_name, objective_name)
    local self = WritLogger
    self.Logger():Debug("OnQuestAdded ec:%d ji:%d qn:%s"
        , event_code, journal_index, quest_name )
    self.DailyParse(journal_index)
end

function WritLogger.DailyRegister()
    local self = WritLogger
    local event_id_list = { EVENT_QUEST_ADDED
                          -- , EVENT_CRAFT_COMPLETED
                          -- , EVENT_QUEST_COMPLETE
                          -- , EVENT_QUEST_REMOVED
                          }
    for _, event_id in ipairs(event_id_list) do
        EVENT_MANAGER:RegisterForEvent( self.name
                                      , event_id
                                      , function(...)
                                            self.OnQuestAdded(...)
                                        end
                                      )
    end
end

-- GetJournalQuestInfo() returns:
WritLogger.JQI = {
  quest_name            =  1 -- string
, background_text       =  2 -- string
, active_step_text      =  3 -- string
, active_step_type      =  4 -- number
, active_step_tracker_override_text =  5 -- string
, completed             =  6 -- boolean
, tracked               =  7 -- boolean
, quest_level           =  8 -- number
, pushed                =  9 -- boolean
, quest_type            = 10 -- number
, instance_display_type = 11 -- number InstanceDisplayType
}

function WritLogger.DailyParse(quest_index)
    local self = WritLogger
    local qinfo = { GetJournalQuestInfo(quest_index) }
    local qname = qinfo[self.JQI.quest_name]
    local crafting_type = LibCraftText.DailyQuestNameToCraftingType(qname)
    if not crafting_type then
        self.Logger():Debug( "DailyParse qi:%d %s not daily crafting quest"
                           , quest_index, qname )
        return
    end
    self.DailyRecord(quest_index, crafting_type)
end

function WritLogger.DailyRecord(quest_index, crafting_type)
    local self = WritLogger
    local qinfo = { GetJournalQuestInfo(quest_index) }
    local row = { time          = self.ISODate()
                , char_name     = self.GetCharacterName()
                , quest_type    = self.QTYPE.DAILY
                , crafting_type = crafting_type
                , desc2         = qinfo[self.JQI.active_step_text]
                }
    -- self.RecordRow(row)

    local date = row.time:sub(1,10)
    local req_id  = self.DescToID(crafting_type, row.desc2)
    if not req_id then
        self.Logger():Error( "Unknown req_id for ct:%d desc2:%s"
                           , crafting_type
                           , row.desc2 )
        self.saved_vars.errors = self.saved_vars.errors or {}
        table.insert(self.saved_vars.errors, row)
    end
    self.RecordToSummary( date
                        , row.char_name
                        , crafting_type
                        , req_id )
end

function WritLogger.RecordRow(row)
    local self = WritLogger
    self.saved_vars.log = self.saved_vars.log or {}
    self.saved_vars.z = nil
    table.insert(self.saved_vars.log, row)

end
