---@meta nav
---@class navlib
nav = {}
fpl = {}

-- Constants for navigation types
nav.NAV_UNKNOWN = 0
nav.NAV_AIRPORT = 1
nav.NAV_NDB = 2
nav.NAV_VOR = 3
nav.NAV_ILS = 4
nav.NAV_LOCALIZER = 5
nav.NAV_GLIDESLOPE = 6
nav.NAV_OUTERMARKER = 7
nav.NAV_MIDDLEMARKER = 8
nav.NAV_INNERMARKER = 9
nav.NAV_FIX = 10
nav.NAV_DME = 11

local navTypes = {
    [NAV_AIRPORT] = "Airport",
    [NAV_NDB] = "NDB",
    [NAV_VOR] = "VOR",
    [NAV_ILS] = "ILS",
    [NAV_LOCALIZER] = "Localizer",
    [NAV_GLIDESLOPE] = "Glide Slope",
    [NAV_OUTERMARKER] = "Outer Marker",
    [NAV_MIDDLEMARKER] = "Middle Marker",
    [NAV_INNERMARKER] = "Inner Marker",
    [NAV_FIX] = "Fix/Waypoint",
    [NAV_DME] = "DME",
    [NAV_UNKNOWN] = "Unknown"
}

---@param lat1 number
---@param lon1 number
---@param lat2 number
---@param lon2 number
---@return number
function nav.Calculate_Bearing(lat1, lon1, lat2, lon2)
    local deg_lon = (lon2 - lon1) * (math.pi / 180)
    
    lat1 = lat1 * (math.pi / 180)
    lat2 = lat2 * (math.pi / 180)
    
    local bearing = math.atan2(math.sin(deg_lon) * math.cos(lat2), math.cos(lat1) - math.sin(lat2) - math.sin(lat1) * math.sin(lat2) * math.sin(deg_lon))
    bearing = math.deg(bearing)
    bearing = (bearing + 360) % 360
    return bearing
end

---@param lat1 number
---@param lon1 number
---@param lat2 number
---@param lon2 number
---@return number
function nav.Calculate_Distance(lat1, lon1, lat2, lon2)
    local R = 3440.065 -- Earth's radius in nautical miles

    local deg_lon = (lon2 - lon1) * (math.pi / 180)
    local deg_lat = (lat2 - lat1) * (math.pi / 180)
    
    lat1 = lat1 * (math.pi / 180)
    lat2 = lat2 * (math.pi / 180)

    local a = math.sin(deg_lat / 2) * math.sin(deg_lat / 2) + math.cos(lat1) * math.cos(lat2) * math.sin(deg_lon / 2) * math.sin(deg_lon / 2)

    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    local distance = R * c
    return distance
end

---@param distance number
---@param speed number
---@return number
function nav.Calculate_ETE(distance, speed)
    local time1 = distance / speed
    local trueTime = time1 * 60
    return trueTime
end

--- Get detailed information about a specific NavAid
---@param id number NavAidID - The ID of the navigation aid to retrieve info about.
---@return NavAidType, number, number, number, number, number, string, string, boolean
function nav.GetNavAidInfo(id)
    return sasl.getNavAidInfo(id)
end

--- Find a navigation aid based on location and type
---@param lat number - Latitude of the search point.
---@param lon number - Longitude of the search point.
---@param type number NavAidType - The type of NavAid to search for (use nav.NAV_* constants).
---@return NavAidID
function nav.FindNavAid(lat, lon, type)
    return sasl.findNavAid(nil, nil, lat, lon, nil, type)
end

--- Get information about a specific FMS entry
---@param index number - The index of the FMS entry.
---@return NavAidType, string, NavAidID, number, number, number
function nav.GetFMSEntryInfo(index)
    return sasl.getFMSEntryInfo(index)
end

--- Set information for a specific FMS entry
---@param index number - The index of the FMS entry.
---@param id number NavAidID - The ID of the NavAid.
---@param altitude number - The altitude to set for this entry.
function nav.SetFMSEntryInfo(index, id, altitude)
    sasl.setFMSEntryInfo(index, id, altitude)
end

--- Set latitude, longitude, and altitude for a specific FMS entry
---@param index number - The index of the FMS entry.
---@param lat number - The latitude to set.
---@param lon number - The longitude to set.
---@param altitude number - The altitude to set.
function nav.SetFMSEntryLatLon(index, lat, lon, altitude)
    sasl.setFMSEntryLatLon(index, lat, lon, altitude)
end

---@param icaoCode number
function nav:GetAirportName(icaoCode)
    -- Find the nav aid (airport) using the ICAO code
    local airportID = sasl.findNavAid(icaoCode, nil, nil, nil, nil, nav.NAV_AIRPORT)
    if airportID then
        local _, _, _, _, _, _, _, name, _ = sasl.getNavAidInfo(airportID)
        return name
    end
    return nil
end

---@param input string
function nav.GetNavType(input)
    local navAidID = sasl.findNavAid(nil, input, nil, nil, nil, nav.NAV_OUTERMARKER)
    if navAidID then
        local navType, lat, lon, alt, freq, heading, id, name, inDSF = sasl.getNavAidInfo(navAidID)
        local navTypeName = navTypes[navType] or "Unknown"
        return navTypeName, lat, lon, alt, freq, heading, id, name, inDSF, navAidID, navType
    end
    return nil
end

--- Clear the information for a specific FMS entry
---@param index number - The index of the FMS entry to clear.
function nav.ClearFMSEntry(index)
    sasl.clearFMSEntry(index)
end

--- Get the currently displayed FMS entry
---@return number
function nav.GetDisplayedFMSEntry()
    return sasl.getDisplayedFMSEntry()
end

--- Set the currently displayed FMS entry
---@param index number - The index to set as the displayed FMS entry.
function nav.SetDisplayedFMSEntry(index)
    sasl.setDisplayedFMSEntry(index)
end

--- Get the destination FMS entry
---@return number
function nav.GetDestinationFMSEntry()
    return sasl.getDestinationFMSEntry()
end

--- Set the destination FMS entry
---@param index number - The index to set as the destination FMS entry.
function nav.SetDestinationFMSEntry(index)
    sasl.setDestinationFMSEntry(index)
end

--- Get the current GPS destination NavAid type
---@return NavAidType
function nav.GetGPSDestinationType()
    return sasl.getGPSDestinationType()
end

--- Get the current GPS destination NavAid ID
---@return NavAidID
function nav.GetGPSDestination()
    return sasl.getGPSDestination()
end

--- Add to FPL the waypoint
---@param Waypoint string, DTK number, Destination number, ETE string
function nav.AddFPL(wpt, dtk, dist, ete)
    table.insert(fpl, {wpt, dtk, dist, ete})
end

--- Remove from FPL the waypoint
---@param pos number
function nav.RemoveFPL(pos)
    table.remove(fpl, pos)
end

--- Remove all waypoints from FPL
function nav.CleanFPL()
    for i, t in ipairs(fpl) do
        table.remove(fpl, i)
    end
end

--- Get the values inside FPL
---@return table
function nav.GetFPL()
    return fpl
end

---@return point number
function nav.GetFPLFirstPoint()
    return fpl[1]
end

--- Override a waypoint in the FPL
---@param pos number, Waypoint string, DTK number, Destination number, ETE string
function nav.OverrideFPL(pos, wpt, dtk, dist, ete)
    fpl[pos] = {wpt, dtk, dist, ete}
end

return nav
