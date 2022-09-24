local instance = {}

function instance.new(instance)
    local newInstance = {}

    newInstance.Instance = instance
    newInstance.Path = instance:GetFullName()
    newInstance.Descendants = instance:GetDescendants()
    newInstance.Children = instance:GetChildren()
    newInstance.IsService = (instance.Parent==game)

    return newInstance
end

return instance