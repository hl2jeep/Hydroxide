function modify(Interface)
    do -- Add source tab
        local sourceResultScroll=import("rbxassetid://10822962466")
        sourceResultScroll.Parent=Interface.Base.Body.Pages.ScriptScanner.Info.Sections.Source
    end
    do -- Randomize Slogan
        local slogan=Interface.Base.Body.Pages.Home.Slogan
        local random={
            "adam is my new boyfriend >.<",
            "jet is cute tbh",
            "daddy~",
            "ReD stands for REtarD",
            "astolfo is so fucking hot",
            "fr (feeling racist)",
            "krnl chan > syn chan",
            "No lunar, your stupid book cant predict the future",
            "\"dev im getting raped by monkeys\" - jet",
            "Follow what the voices in your head say."
        }
        slogan.Text=random[math.random(1,#random)]
    end
end
return modify