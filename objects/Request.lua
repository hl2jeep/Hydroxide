local Request={}

function Request.new(data)
    local req={}
    req.Url=(data.Type=="HttpGet" and data.Data[1] or data.Data["Url"])
    req.Headers=(data.Type=="HttpGet" and {} or data.Data["Headers"] or {})
    req.Method=(data.Type=="HttpGet" and "GET" or data.Data["Method"] or "GET")

    return req
end

return Request