local ohInstance = {}

function ohInstance.new(instance)
    local newInstance = {}

    newInstance.Instance = instance
    newInstance.Path = getInstancePath(instance);
    newInstance.Descendants = instance:GetDescendants()
    newInstance.Children = instance:GetChildren()
    newInstance.IsService = (instance.Parent==game)

    return newInstance
end

return ohInstance