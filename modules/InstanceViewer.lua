local InstanceViewer={}
local InstanceObj=import("objects/Instance")
local jsonApi=game:GetService("HttpService"):JSONDecode(game:HttpGet"https://anaminus.github.io/rbx/json/api/latest.json")

local requiredMethods = {
    ["getGc"] = true,
    ["getSenv"] = true,
    ["getProtos"] = true,
    ["getConstants"] = true,
    ["getScriptClosure"] = true,
    ["isXClosure"] = true
}

local function scan(query)
    local services = {}
    query = query or ""

    for _i, v in pairs(game:GetChildren()) do
		local isService=pcall(function()
			return game:GetService(v.ClassName)
		end)
		if typeof(v)=="Instance" and
			not services[v] and
			v.Name:lower():find(query) and
			isService
		then
			services[v]=InstanceObj.new(v)
		end
    end

    return services
end

local function getInstanceMethods(instance: Instance)
	local Methods={}
	local isService=pcall(function()
		return game:GetService(instance.ClassName)
	end)
	table.foreach(jsonApi, function(_i, v)
		pcall(function()
			if v.Class==instance.ClassName and v.type=="function" then
				local a=(isService and game:GetService(instance.ClassName) or game:FindFirstChildWhichIsA(instance.ClassName, true))
				table.insert(Methods, a and a[v.Name] or function() end)
			end
		end)
	end)
	return Methods
end

local function getInstanceProperties(instance: Instance)
	local Properties={}
	local isService=pcall(function()
		return game:GetService(instance.ClassName)
	end)
	table.foreach(jsonApi, function(_i, v)
		pcall(function()
			if (v.Class==instance.ClassName or v.Class=="Instance") and v.type=="Property" then
				Properties[v.Name]={
					type=v.ValueType,
					tags=v.Tags,
					value=(table.find(v.Tags, "hidden") and (getHiddenProperty or function(...) return nil end)(instance, v.Name) or instance[v.Name])
				}
			end
		end)
	end)
	return Properties
end

InstanceViewer.RequiredMethod=requiredMethods
InstanceViewer.Scan=scan
InstanceViewer.GetInstanceMethods = getInstanceMethods
InstanceViewer.GetInstanceProperties = getInstanceProperties
return InstanceViewer