-- WritLogger: Record a history of each daily and/or master writ acquired.

local WritLogger = _G['WritLogger'] -- defined in WritLogger_Define.lua
local WW = WritLogger
local LAM2 = LibAddonMenu2 or LibStub("LibAddonMenu-2.0")

WritLogger.name            = "WritLogger"
WritLogger.savedVarVersion = 1

WritLogger.default = {
}

local Log  = WritLogger.Log

-- Init ----------------------------------------------------------------------

function WritLogger.OnAddOnLoaded(event, addonName)
    if addonName == WritLogger.name then
        WritLogger:Initialize()
    end
end

function WritLogger:Initialize()
    self.version = self.FindVersion(self.name)

                        -- Account-wide for most things
    self.saved_vars = ZO_SavedVars:NewAccountWide(
                              "WritLoggerVars"
                            , self.savedVarVersion
                            , nil
                            , self.default
                            )
end

-- Postamble -----------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent( WritLogger.name
                              , EVENT_ADD_ON_LOADED
                              , WritLogger.OnAddOnLoaded
                              )
