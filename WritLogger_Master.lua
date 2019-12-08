local WritLogger = WritLogger


function WritLogger.OnLootReceived(event_code, looted_by, item_link, quantity, item_sound, loot_type, is_stolen)
    local self = WritLogger
    self.Logger():Debug("OnLootReceived ec:%d link:%s"
        , event_code, item_link)
    self.MasterRecord(item_link)
end

function WritLogger.MasterRegister()
    local self = WritLogger
    local event_id_list = { EVENT_LOOT_RECEIVED
                          }
    for _, event_id in ipairs(event_id_list) do
        EVENT_MANAGER:RegisterForEvent( self.name
                                      , event_id
                                      , function(...)
                                            self.OnLootReceived(...)
                                        end
                                      )
    end
end

WritLogger.MASTER_ICON_TO_CRAFTING_TYPE = {
    ["/esoui/art/icons/master_writ_blacksmithing.dds"] = CRAFTING_TYPE_BLACKSMITHING    or 1
,   ["/esoui/art/icons/master_writ_clothier.dds"     ] = CRAFTING_TYPE_CLOTHIER         or 2
,   ["/esoui/art/icons/master_writ_woodworking.dds"  ] = CRAFTING_TYPE_WOODWORKING      or 3
,   ["/esoui/art/icons/master_writ_jewelry.dds"      ] = CRAFTING_TYPE_JEWELRYCRAFTING  or 4
,   ["/esoui/art/icons/master_writ_alchemy.dds"      ] = CRAFTING_TYPE_ALCHEMY          or 5
,   ["/esoui/art/icons/master_writ_enchanting.dds"   ] = CRAFTING_TYPE_ENCHANTING       or 6
,   ["/esoui/art/icons/master_writ_provisioning.dds" ] = CRAFTING_TYPE_PROVISIONING     or 7
}

function WritLogger.MasterRecord(item_link)
    local self = WritLogger
    local icon, _, _, _, item_style = GetItemLinkInfo(item_link)
    local crafting_type = self.MASTER_ICON_TO_CRAFTING_TYPE[icon]
    if not crafting_type then return end

    row = {}
    row.char_name     = self.GetCharacterName()
    row.time          = self.ISODate()
    row.quest_type    = self.QTYPE.MASTER
    row.crafting_type = crafting_type
    row.item_link     = item_link

    local line = self.SummarizeMaster( row.time:sub(1,10)
                                     , row.char_name
                                     , row.crafting_type
                                     , row.item_link
                                     )
    self.saved_vars.master = self.saved_vars.master or {}
    table.insert(self.saved_vars.master, line)
    self.RecordRow(row)
end

