local instance = {}
local Methods = import("modules/InstanceViewer")

function instance.new(instance)
    local newInstance = {}

    newInstance.Instance = instance
    newInstance.Path = instance:GetFullName()
    newInstance.Descendants = instance:GetDescendants()
    newInstance.Children = instance:GetChildren()
    newInstance.IsService = (instance.Parent==game)
    newInstance.Properties=Methods.GetInstanceProperties(instance)
    newInstance.Methods=Methods.GetInstanceMethods(instance)
    
    return newInstance
end

return instance