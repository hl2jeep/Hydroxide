function modify(Interface)
    do -- Add source tab
        local sourceResultScroll=import("rbxassetid://10822962466")
        sourceResultScroll.Parent=Interface.Base.Body.Pages.ScriptScanner.Info.Sections.Source
    end
    do -- Randomize Slogan
        local slogan=Interface.Base.Body.Pages.Home.Slogan
        local random={
            "adam is my new boyfriend >.<",
            "daddy~",
            "ReD stands for REtarD",
            "astolfo is so fucking hot",
            "fr (feeling racist)",
            "syn chan > krnl chan",
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
    do -- Change selected tab
        local label=Interface.Base.Body.Pages.ScriptScanner.Info.Options.Clip.Content.Protos.Label
        label.TextTransparency=0.2
        label.TextColor3=Color3.fromRGB(200,200,200)

        Interface.Base.Body.Pages.ScriptScanner.Info.Sections.Protos.Visible=false;
        Interface.Base.Body.Pages.ScriptScanner.Info.Sections.Source.Visible=true;
    end
    do -- Add ModuleScanner info tab
        local info=import("rbxassetid://10896419712")
        info.Parent=Interface.Base.Body.Pages.ModuleScanner
    end
end
return modify