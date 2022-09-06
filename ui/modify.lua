function modify(Interface)
    do -- Add source tab
        local sourceResultScroll=import("rbxassetid://10822962466")
        sourceResultScroll.Parent=Interface.Base.Body.Pages.ScriptScanner.Info.Sections.Source
    end
end
return modify