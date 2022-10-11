local LocalScript = {}

function LocalScript.new(instance)
    local localScript = {}
    local closure = getScriptClosure(instance)

    localScript.Instance = instance
    xpcall(function()
        localScript.Environment = getSenv(instance)
    end, function() localScript.Environment={} end)
    localScript.Constants = getConstants(closure)
    localScript.Protos = getProtos(closure)
    xpcall(function()
        localScript.Source = decompileScript(instance) or "This script has no source."
    end, function()
        localScript.Source = "There was an issue while decompiling."
    end)
    
    return localScript
end

return LocalScript