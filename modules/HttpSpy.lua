local HttpSpy = {}
local Request = import("objects/Request")
local RequestList={}

local requiredMethods = {
    ["hookFunction"] = true,
    ["hookMetaMethod"] = true,
    ["exploitRequest"] = true
}

local function scan(query)
    local requests = {}
    query = query or ""
    
    return requests
end

local function requestHook(type, ...)
    table.insert(RequestList, {
        Type=type,
        Data={...}
    })
end
coroutine.create(function() -- Ill make this better later
    local Request; Request=
    hookFunction(exploitRequest, function(...)
        requestHook("exploitRequest", ...)
        return Request(rqTable)
    end)
    
    local HttpGet; HttpGet=
    hookMetaMethod(game, "__namecall", function(self, ...)
        if self==game and getnamecallmethod and getnamecallmethod()=="HttpGet" or getnamecallmethod()=="HttpGetAsync" then
            requestHook("HttpGet", ...)
        end
        return HttpGet(self,...)
    end)
end)

HttpSpy.Scan = scan
HttpSpy.RequiredMethods = requiredMethods
return HttpSpy