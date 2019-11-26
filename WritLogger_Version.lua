-- FindVersion([add-on-name])
--
-- Return a "5.2.1" version string calculated from the manifest file's
-- ## AddOnVersion: 050201 number.
--
-- Function is in its own file because there's a good chance it will
-- get copy-paste-edit-ed into other Zig add-ons over time.
-- Either that, or Zig finall goes the way of Phinix and others and
-- publishes a "LibZiggr" with common utility code.
--

local WritLogger = WritLogger

-- O(n add-ons) scan to return info for the requested add-on.
function WritLogger.FindAddOnInfo(add_on_name)
    local self      = WritLogger
    local name      = add_on_name or self.name
    local mgr       = GetAddOnManager()
    local add_on_ct = mgr:GetNumAddOns()
    for i = 1, add_on_ct do
        local r = { mgr:GetAddOnInfo(i) }
        if r[1] == name then
            info = r
            r.index = i
            return r
        end
    end
    return nil
end

-- Find and return the given add-on's version string "5.2.1"
function WritLogger.FindVersion(add_on_name)
    local self = WritLogger
    local info = self.FindAddOnInfo(add_on_name)
    if not info and info.index then return nil end

    local mgr           = GetAddOnManager()
    local version_raw   = mgr:GetAddOnVersion(info.index)
    if not version_raw then return nil end

    local n  = tonumber(version_raw)
    local d1 = math.floor(n / 10000)
    local d2 = math.floor(n /   100) % 100
    local d3 = math.floor(n /     1) % 100

    local version_str = string.format("%d.%d.%d", d1, d2, d3)

    return version_str
end

