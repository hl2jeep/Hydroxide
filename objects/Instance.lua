local instance = {}

function instance.new(instance)
    local newInstance = {}

    newInstance.Instance = instance
    newInstance.Path = instance:GetFullName()
    newInstance.Descendants = instance:GetDescendants()
    newInstance.Children = instance:GetChildren()
    newInstance.Properties={}
    newInstance.FillProperties=function() -- Prevent slow loading
        local api=game:GetService("HttpService"):JSONDecode(game:HttpGet("https://anaminus.github.io/rbx/json/api/latest.json"))
        table.foreach(api, function(_, v)
            if (v.Class) and (v.Class==typeof(instance) or v.Class==instance.ClassName or instance:IsA(v.Class)) and (not v.Type or v.Type~="Function") then
                newInstance.Properties[v.Name]=instance[v.Name]
            end
        end)
    end
    
    return newInstance
end

return instance