local WritLogger = WritLogger

function WritLogger.OnQuestAdded(event_code, journal_index, quest_name, objective_name)
    WritLogger.Logger():Debug("OnQuestAdded ec:%d ji:%d qn:%s on:%s"
        , event_code, journal_index, quest_name, objective_name )
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
