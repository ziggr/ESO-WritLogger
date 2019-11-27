local WritLogger = WritLogger

function WritLogger.GetCharacterName()
    return GetUnitName("player")
end

function WritLogger.ISODate()
    return os.date('%Y-%m-%dT%H:%M:%S')
end
