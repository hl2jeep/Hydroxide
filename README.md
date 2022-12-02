## Script
```lua
local owner = "sponguss"
local branch = "revision"

local function webImport(file)
    return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format(owner, branch, file)), file .. '.lua')()
end

webImport("init") -- ctuidseehv ^-^
webImport("ui/main")
```

# spongdroxide (Hydroxide)
<i>General purpose pen-testing tool for games on the Roblox engine</i>

Please report issues at the "Issues" tab in github, instead of DM'ing me

<p align="center">
    <img src="https://cdn.discordapp.com/attachments/633472429917995038/722143730500501534/Hydroxide_Logo.png"/>
    </br>
    <img src="https://cdn.discordapp.com/attachments/694726636138004593/742408546334933002/unknown.png" width="677px"/>
</p>

## Features
* Upvalue Scanner
    - View/Modify Upvalues
    * View first-level values in table upvalues
    * View information of closure
* Constant Scanner
    * View/Modify Constants
    * View information of closure
* Script Scanner
    * View general information of scripts (source, protos, constants, etc.)
    * Retrieve all protos found in GC
* Module Scanner
    * View general information of modules (return value, source, protos, constants, etc.)
    * Retrieve all protos found in GC
* RemoteSpy
    * Log calls of remote objects (RemoteEvent, RemoteFunction, BindableEvent, BindableFunction)
    * Ignore/Block calls based on parameters passed
    * Traceback calling function/closure
* ClosureSpy
    * Log calls of closures
    * View general information of closures (location, protos, constants, etc.)
* Instance Viewer (WIP)
    * View properties and methods of certain instances
    * View how many descendants and methods an instance has
    * Edit properties & run methods with any arguments
* Http Spy (TESTING)
    * Log the use of the request or syn.request function
    * Log the use of game:HttpGet and game:HttpGetAsync
    * Log the use of HttpService's request functions (SOON)
    * Prevent people from using anti-HttpSpy

More to come, soon.

## Images/Videos
<p align="center">
    <img src="https://i.gyazo.com/63afdd764cdca533af5ebca843217a7e.gif" />
    <img src="https://cdn.upload.systems/uploads/KqYKbtD4.gif">
</p>

## Spongdroxide's Modifications
- Source tab & Environment tab in Script Scanner are now fully functional
- RemoteSpy has more context menu buttons, like "Copy Arguments"!
- RGB Mode
- View a module's return value (Module Scanner)
- New instance viewer tab, which is not yet complete sadly
- Quick Loading (Enabled by adding the "quick_loading.oh" file)
- More error handlers for specific parts
- Possibly faster at loading and other stuff
- A new HTTPSPY tab

## Testers & Credits
* Testers
    * _Currently there's no testers, DM spongus#7609 to become one!_

* Credits
    * sponguss: Scripter
    * Upbolt: Creator of Hydroxide
    * Dylann: Ideas
    * brr/Brodi: Testing Game

_Have any ideas or want to contribute to Spongdroxide? Make a pull request or DM spongus#7609 to be a developer!_
