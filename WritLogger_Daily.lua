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

-- GetJournalQuestStepInfo() returns
WritLogger.JQSI = {
  step_text             = 1 -- string
, visibility            = 2 -- number:nilable
, step_type             = 3 -- number
, tracker_override_text = 4 -- string
, num_conditions        = 5 -- number
}

-- GetJournalQuestConditionInfo() returns
WritLogger.JQCI = {
  condition_text        = 1 -- string
, current               = 2 -- number
, max                   = 3 -- number
, is_fail_condition     = 4 -- boolean
, is_complete           = 5 -- boolean
, is_credit_shared      = 6 -- boolean
, is_visible            = 7 -- boolean
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
    local lct_result_list = LibCraftText.ParseQuest(quest_index)
    if not lct_result_list then
        self.Logger():Warn( "Bug: LibCraftText could not parse qi:%d %s"
                           , quest_index, qname )
        lct_result_list = {}
    end
    self.DailyRecord(quest_index, crafting_type, lct_result_list)
end

function WritLogger.DailyRecord(quest_index, crafting_type, lct_result_list)
    local self = WritLogger
    local qinfo = { GetJournalQuestInfo(quest_index) }
d(1)
-- d(qinfo)
-- d(self.JQI)
    local qdesc = qinfo[self.JQI.background_text]
    local row = {}
    row.char_name     = self.GetCharacterName()
    row.time          = self.ISODate()
    row.quest_type    = self.QTYPE.DAILY
    row.crafting_type = crafting_type
    row.desc          = qdesc

    for _,result in ipairs(lct_result_list) do
        local cond = nil
                        -- Provisioning: show the food/drink name
        if result.item and result.item.name then
            cond = { name = result.item.name }

                        -- Alchemy potion/poison name
        elseif result.trait and result.trait.name then
            cond = { name = result.trait.name }
                        -- Lorkan's Tears or Alkahest
            if result.solvent then
                cond.solvent = result.solvent.name
            end
                        --  "Acquire Nirnroot"
        elseif result.material and result.material.name then
            cond = { name = result.material.name }
        end

        if cond then
            row.cond = row.cond or {}
            table.insert(row.cond, cond)
        end

        row._x = result
    end

    self.RecordRow(row)
end

function WritLogger.RecordRow(row)
    local self = WritLogger
    self.saved_vars.log = self.saved_vars.log or {}
    self.saved_vars.z = nil
    -- self.saved_vars.z = self.saved_vars.z or 0
    -- self.saved_vars.z = self.saved_vars.z + 1

d(2)
    table.insert(self.saved_vars.log, row)

end
