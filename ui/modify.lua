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
            "Follow what the voices in your head say.",
            "GET OUT OF MY HEAD GET OUT OF MY HEAD",
            "The voices are getting louder",
            "I am losing my grip on reality",
            "hydroxide jumpscare",
            "sometimes i think... but then i forget",
            "spongus amongus",
            "i hate fucking ni-"
        }
        slogan.Text=random[math.random(1,#random)]
    end
    do -- Fix an issue where the Protos button would always look like its selected
        local label: TextLabel=Interface.Base.Body.Pages.ScriptScanner.Info.Options.Clip.Content.Protos.Label
        label.TextTransparency=0
        label.TextColor3=Color3.fromRGB(200,200,200)
    end
end
return modify