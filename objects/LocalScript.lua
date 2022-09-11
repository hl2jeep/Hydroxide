local LocalScript = {}

function LocalScript.new(instance)
    local localScript = {}
    local closure = getScriptClosure(instance)

    localScript.Instance = instance
    localScript.Environment = getSenv(instance)
    localScript.Constants = getConstants(closure)
    localScript.Protos = getProtos(closure)
    xpcall(function()
        localScript.Source = decompileScript(instance)
    end, function()
        localScript.Source = "There was an issue while decompiling."
    end)
    
    return localScript
end

return LocalScript