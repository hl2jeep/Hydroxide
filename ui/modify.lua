function modify(Interface)
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
    do -- Customizable Hydroxide
        if (isfile and isfile("custom_oh.json")) then
            local CustomOH=game:GetService("HttpService"):JSONDecode((readfile or function(...)return""end)("custom_oh.json"))
            if (CustomOH.RGB and CustomOH.RGB==true) then
                local rgbObjects={Interface.Open.Border, Interface.Base.Border, Interface.Base.MessageBox.Border}
                table.foreach(rgbObjects, function(_, o: ImageLabel)
                    coroutine.create(function()
                        local x=0 
                        local y=1/255
                        while true do
                            o.ImageColor3=Color3.fromHSV(x,1,1)
                            x+=y
                            if x>=1 then
                                x=0
                            end
                            task.wait()
                        end
                    end)
                end)
            end
        end
    end
end
return modify