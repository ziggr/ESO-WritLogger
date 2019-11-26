local WritLogger = _G['WritLogger'] -- defined in WritLogger_Define.lua
WritLogger.Log = {}
local Log = WritLogger.Log

-- LibDebugLogger ------------------------------------------------------------

-- If Sirinsidiator's LibDebugLogger is installed, then return a logger from
-- that. If not, return a NOP replacement.

local NOP = {}
function NOP:Debug(...) end
function NOP:Info(...) end
function NOP:Warn(...) end
function NOP:Error(...) end

WritLogger.log_to_chat            = false
WritLogger.log_to_chat_warn_error = false

function WritLogger.Logger()
    local self = WritLogger
    if not self.logger then
        if LibDebugLogger then
            self.logger = LibDebugLogger.Create(self.name)
        end
        if not self.logger then
            self.logger = NOP
            WritLogger.log_to_chat_warn_error  = true
                        -- Comment out this line before release.
            WritLogger.log_to_chat             = true
        end
    end
    return self.logger
end

function WritLogger.LogOne(color, ...)
    if WritLogger.log_to_chat then
        d("|c"..color..WritLogger.name..": "..string.format(...).."|r")
    end
end

function WritLogger.LogOneWarnError(color, ...)
    if WritLogger.log_to_chat or WritLogger.log_to_chat_warn_error then
        d("|c"..color..WritLogger.name..": "..string.format(...).."|r")
    end
end

function Log.Debug(...)
    WritLogger.LogOne("666666",...)
    WritLogger.Logger():Debug(...)
end

function Log.Info(...)
    WritLogger.LogOne("999999",...)
    WritLogger.Logger():Info(...)
end

function Log.Warn(...)
    WritLogger.LogOneWarnError("FF8800",...)
    WritLogger.Logger():Warn(...)
end

function Log.Error(...)
    WritLogger.LogOneWarnError("FF6666",...)
    WritLogger.Logger():Error(...)
end
