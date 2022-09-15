local ModuleScanner = {}
local Methods = import("modules/ModuleScanner")

if not hasMethods(Methods.RequiredMethods) then
    return ModuleScanner
end

local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://10914701046").Base.Body.Pages.ModuleScanner
local Assets = import("rbxassetid://5042114982").ModuleScanner
local Info = Page.Info

local Query = Page.Query
local Search = Query.Search
local Refresh = Query.Refresh
local Results = Page.Results.Clip.Content

local moduleList = List.new(Results)
local moduleLogs = {}
local selectedLog
local selected={}
local constants = {
    fadeLength = TweenInfo.new(0.15),
    textWidth = Vector2.new(133742069, 20)
}

local InfoSource = Info.Sections.Source
local InfoEnvironment = Info.Sections.Environment
local InfoProtos = Info.Sections.Protos
local InfoConstants = Info.Sections.Constants
local InfoScript = Info.ScriptObject

local EnvironmentResultsClip = InfoEnvironment.Results.Clip
local EnvironmentResults = EnvironmentResultsClip.Content

local ConstantsResultsClip = InfoConstants.Results.Clip
local ConstantsResults = ConstantsResultsClip.Content

local ProtosResultsClip = InfoProtos.Results.Clip
local ProtosResults = ProtosResultsClip.Content
local protosList = List.new(ProtosResults)
local constantsList = List.new(ConstantsResults)
local environmentList = List.new(EnvironmentResults)

local pathContext = ContextMenuButton.new("rbxassetid://4891705738", "Get Module Path")
moduleList:BindContextMenu(ContextMenu.new({ pathContext }))
local copyEnvContext = ContextMenuButton.new("rbxassetid://4891705738", "Copy Env Value")
local copyProtoNameContext = ContextMenuButton.new("rbxassetid://4891705738", "Copy Proto Name")
local copyProtoInfoContext = ContextMenuButton.new("rbxassetid://4891705738", "Copy Proto Info")
local copyConstantValue = ContextMenuButton.new("rbxassetid://4891705738", "Copy Constant Value")

environmentList:BindContextMenu(ContextMenu.new({ copyEnvContext }))
protosList:BindContextMenu(ContextMenu.new({ copyProtoNameContext, copyProtoInfoContext }))
constantsList:BindContextMenu(ContextMenu.new({ copyConstantValue }))

copyEnvContext:SetCallback(function()
    local selectedEnv=selected.selectedEnv
    local val=selected.selectedEnv.value
    if val then
        setClipboard(dataToString(val))
    end

    MessageBox.Show("Success", ("%s's value was copied to your clipboard."):format(selectedEnv.index), MessageType.OK)
end)

copyProtoNameContext:SetCallback(function()
    if selected.selectedProto and selected.selectedProto.name~="" then
        setClipboard(selected.selectedProto.name)
        MessageBox.Show("Success", ("%s was copied to your clipboard."):format(selected.selectedProto.name), MessageType.OK)
    end
end)

copyProtoInfoContext:SetCallback(function()
    if selected.selectedProto then
        setClipboard(dataToString(getInfo(selected.selectedProto.value)))
        MessageBox.Show("Success", ("A table with %s's information was copied to your clipboard."):format(
            (selected.selectedProto.name=="" and "the unnamed function" or selected.selectedProto.name)
        ), MessageType.OK)
    end
end)

copyConstantValue:SetCallback(function()
    if selected.selectedConstant then
        setClipboard(dataToString(selected.selectedConstant.value))
        MessageBox.Show("Success", ("The value of the constant %d was copied to your clipboard."):format(selected.selectedConstant.index), MessageType.OK)
    end
end)

pathContext:SetCallback(function()
    local selectedInstance = selectedLog.ModuleScript.Instance

    setClipboard(getInstancePath(selectedInstance))
    MessageBox.Show("Success", ("%s's path was copied to your clipboard."):format(selectedInstance.Name), MessageType.OK)
end)

local function createProto(index, value, Instance)
    local instance = Assets.ProtoPod:Clone()
    local information = instance.Information
    local functionName = getInfo(value).name or ''
    local indexWidth = game:GetService("TextService"):GetTextSize(index, 18, "SourceSans", constants.textWidth).X + 8

    if functionName == '' then
        functionName = "Unnamed function"
        information.Label.TextColor3 = oh.Constants.Syntax["unnamed_function"]
    end
    
    information.Index.Text = index
    information.Label.Text = functionName

    information.Index.Size = UDim2.new(0, indexWidth, 0, 20)
    information.Label.Size = UDim2.new(1, -(indexWidth + 20), 1, 0)
    information.Icon.Position = UDim2.new(0, indexWidth, 0, 2)
    information.Label.Position = UDim2.new(0, indexWidth + 20, 0, 0)

    ListButton.new(instance, protosList):SetRightCallback(function()
        selected.selectedProto={index=index, value=value, Instance=Instance, name=toString(getInfo(value).name or '')}
        selected.selectedProtoLog=instance
    end)
end

local function createConstant(index, value, Instance)
    local instance = Assets.ConstantPod:Clone()
    local information = instance.Information
    local valueType = type(value)
    local indexWidth = game:GetService("TextService"):GetTextSize(index, 18, "SourceSans", constants.textWidth).X + 8    

    information.Index.Text = index

    information.Index.Size = UDim2.new(0, indexWidth, 0, 20)
    information.Label.Size = UDim2.new(1, -(indexWidth + 20), 1, 0)
    information.Icon.Position = UDim2.new(0, indexWidth, 0, 2)
    information.Label.Position = UDim2.new(0, indexWidth + 20, 0, 0)

    if valueType == "function" then
        local functionName = getInfo(value).name or ''

        if functionName == '' then
            functionName = "Unnamed function"
            information.Label.TextColor3 = oh.Constants.Syntax["unnamed_constant"]
        end
        
        information.Label.Text = functionName
    elseif valueType == "userdata" then
        information.Label.Text=(typeof(value)=="Instance" and getInstancePath(value) or userdataValue(value))
    elseif valueType == "table" then
        if #value==0 then
            information.Label.Text="Empty Table"
            information.Label.TextColor3 = oh.Constants.Syntax["empty_table"]
        else
            information.Label.Text="Table"
        end
    else
        information.Label.Text = toString(value)
    end
    
    ListButton.new(instance, constantsList):SetRightCallback(function()
        selected.selectedConstant={index=index, value=value, Instance=Instance}
        selected.selectedConstantLog=instance
    end)
end

local function createEnvironment(index, value, tbpos, Instance)
    local instance = Assets.ConstantPod:Clone()
    local information = instance.Information
    local indexWidth = game:GetService("TextService"):GetTextSize(tbpos, 18, "SourceSans", constants.textWidth).X + 8    

    information.Icon.Image = "http://www.roblox.com/asset/?id=5538723428"
    information.Icon.ImageColor3 = Color3.fromRGB(139, 190, 255)
    information.Label.TextColor3 = Color3.fromRGB(139, 190, 255)

    information.Index.Text = tbpos

    information.Index.Size = UDim2.new(0, indexWidth, 0, 20)
    information.Label.Size = UDim2.new(1, -(indexWidth + 20), 1, 0)
    information.Icon.Position = UDim2.new(0, indexWidth, 0, 2)
    information.Label.Position = UDim2.new(0, indexWidth + 20, 0, 0)
    information.Label.Text = (toString(index)=="" and "Empty String" or toString(index))
    if toString(index)=="" then
        information.Label.TextColor3=oh.Constants.Syntax["unnamed_env"]
    end

    ListButton.new(instance, environmentList):SetRightCallback(function()
        selected.selectedEnv={index=index, value=value, numindex=tbpos, Instance=Instance}
        selected.selectedEnvironmentLog=instance
    end)
end

-- Log Object

local Log = {}

function Log.new(moduleScript)
    local log = {}
    local moduleInstance = moduleScript.Instance
    local button = Assets.ModuleLog:Clone()
    local listButton = ListButton.new(button, moduleList)
    local moduleName=moduleInstance.Name
    
    button.Name = moduleInstance.Name
    button:FindFirstChild("Name").Text = moduleInstance.Name
    button.Protos.Text = #moduleScript.Protos
    button.Constants.Text = #moduleScript.Constants

    listButton:SetCallback(function()
        if selectedLog ~= log then
            protosList:Clear()
            constantsList:Clear()
            environmentList:Clear()
            
            Page.Query.Visible=false
            Page.Results.Visible=false
            Page.Information.Visible=false
            Info.Visible=true

            local nameLength = game:GetService("TextService"):GetTextSize(moduleName, 18, "SourceSans", constants.textWidth).X + 20
            
            InfoScript.Label.Text = moduleName
            InfoScript.Label.Size = UDim2.new(0, nameLength, 0, 20)
            InfoScript.Position = UDim2.new(1, -nameLength, 0, 0)

            for i,v in pairs(moduleScript.Protos) do
                createProto(i, v, moduleScript.Instance)
            end 

            for i,v in pairs(moduleScript.Constants) do
                createConstant(i, v, moduleScript.Instance)
            end

            local num=1
            for i,v in pairs(moduleScript.Environment) do
                createEnvironment(i, v, num, moduleScript.Instance)
                num+=1
            end

            InfoSource.ResultScroll.ResultStatus.Text=moduleScript.Source

            selectedLog = log
        end
    end)

    listButton:SetRightCallback(function()
        selectedLog = log
    end)

    moduleLogs[moduleInstance] = log

    log.ModuleScript = moduleScript
    log.Button = listButton
    return log
end

-- UI Functionality

local function addModules(query)
    moduleList:Clear()
    moduleLogs = {}

    for _moduleInstance, moduleScript in pairs(Methods.Scan(query)) do
        Log.new(moduleScript)
    end

    moduleList:Recalculate()
end

Search.FocusLost:Connect(function(returned)
    if returned then
        addModules(Search.Text)
        Search.Text = ""
    end
end)

Refresh.MouseButton1Click:Connect(function()
    addModules()
end)

Info.Back.MouseButton1Click:Connect(function()
    Info.Visible = false
    Page.Query.Visible = true
    Page.Results.Visible = true
    Page.Information.Visible = true
end)

addModules()

local selectedSection = InfoSource
local selectedSectionButton = Info.Options.Clip.Content.Source
local animationCache = {}

for _i, sectionButton in pairs(Info.Options.Clip.Content:GetChildren()) do
    if sectionButton:IsA("TextButton") then
        local label = sectionButton.Label
        local enterAnimation = game:GetService("TweenService"):Create(label, constants.fadeLength, { TextTransparency = 0 })
        local leaveAnimation = game:GetService("TweenService"):Create(label, constants.fadeLength, { TextTransparency = 0.2 })

        sectionButton.MouseButton1Click:Connect(function()
            local section = Info.Sections:FindFirstChild(sectionButton.Name)
            animationCache[selectedSectionButton].leave:Play()
            
            selectedSection.Visible = false
            section.Visible = true
            
            selectedSection = section
            selectedSectionButton = sectionButton

        end)

        sectionButton.MouseEnter:Connect(function()
            if selectedSectionButton ~= sectionButton then
                enterAnimation:Play()
            end
        end)

        sectionButton.MouseLeave:Connect(function()
            if selectedSectionButton ~= sectionButton then
                leaveAnimation:Play()
            end
        end)

        animationCache[sectionButton] = {
            enter = enterAnimation,
            leave = leaveAnimation
        }
    end
end

return ModuleScanner