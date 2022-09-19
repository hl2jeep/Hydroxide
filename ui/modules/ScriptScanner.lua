local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local ScriptScanner = {}
local Methods = import("modules/ScriptScanner")

if not hasMethods(Methods.RequiredMethods) then
    return ScriptScanner
end

local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://10922275113").Base.Body.Pages.ScriptScanner
local Assets = import("rbxassetid://10924729710").ScriptScanner

local ScriptList = Page.List
local ScriptInfo = Page.Info

local ListQuery = ScriptList.Query
local ListSearch = ListQuery.Search
local ListRefresh = ListQuery.Refresh
local ListResults = ScriptList.Results.Clip.Content

local InfoScript = ScriptInfo.ScriptObject
local InfoBack = ScriptInfo.Back
local InfoOptions = ScriptInfo.Options.Clip.Content
local InfoSections = ScriptInfo.Sections

local InfoSource = InfoSections.Source
local InfoEnvironment = InfoSections.Environment
local InfoProtos = InfoSections.Protos
local InfoConstants = InfoSections.Constants

local EnvironmentResultsClip = InfoEnvironment.Results.Clip
local EnvironmentResults = EnvironmentResultsClip.Content

local ConstantsResultsClip = InfoConstants.Results.Clip
local ConstantsResults = ConstantsResultsClip.Content

local ProtosResultsClip = InfoProtos.Results.Clip
local ProtosResults = ProtosResultsClip.Content

local scriptList = List.new(ListResults)
local protosList = List.new(ProtosResults)
local constantsList = List.new(ConstantsResults)
local environmentList = List.new(EnvironmentResults)

local scriptLogs = {}
local selected = {}

local constants = {
    fadeLength = TweenInfo.new(0.15),
    textWidth = Vector2.new(133742069, 20)
}

local pathContext = ContextMenuButton.new("rbxassetid://4891705738", "Get Script Path")

local copyEnvContext = ContextMenuButton.new("rbxassetid://4891705738", "Copy Env Value")
local copyProtoNameContext = ContextMenuButton.new("rbxassetid://4891705738", "Copy Proto Name")
local copyProtoInfoContext = ContextMenuButton.new(oh.Constants.Types.table, "Copy Proto Info")
local copyConstantValue = ContextMenuButton.new("rbxassetid://4891705738", "Copy Constant Value")
local copyEnvDataTypeContext = ContextMenuButton.new(oh.Constants.Types.userdata, "Copy Env Value Data Type")

environmentList:BindContextMenu(ContextMenu.new({ copyEnvContext }))
protosList:BindContextMenu(ContextMenu.new({ copyProtoNameContext, copyProtoInfoContext }))
constantsList:BindContextMenu(ContextMenu.new({ copyConstantValue }))

scriptList:BindContextMenu(ContextMenu.new({ pathContext }))

pathContext:SetCallback(function()
    local selectedInstance = selected.logContext.LocalScript.Instance

    setClipboard(dataToString(selectedInstance))
    MessageBox.Show("Success", ("%s's path was copied to your clipboard."):format(selectedInstance.Name), MessageType.OK)
end)

copyEnvContext:SetCallback(function()
    local selectedEnv=selected.selectedEnv
    local val=selectedEnv.value
    if val then
        setClipboard(dataToString(val))
    end

    MessageBox.Show("Success", ("%s's value was copied to your clipboard."):format(selectedEnv.index), MessageType.OK)
end)

copyEnvDataTypeContext:SetCallback(function()
    local selectedEnv=selected.selectedEnv
    local val=selectedEnv.value
    if val then
        setClipboard(userdataValue(val))
    end
    MessageBox.Show("Success", 
        ("%s's value data type was copied to your clipboard."):format(selectedEnv.index),
        MessageType.OK
    )
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

local function createProto(index, value, Instance)
    local instance = Assets.ProtoPod:Clone()
    local information = instance.Information
    local functionName = getInfo(value).name or ''
    local indexWidth = TextService:GetTextSize(index, 18, "SourceSans", constants.textWidth).X + 8

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
    local indexWidth = TextService:GetTextSize(index, 18, "SourceSans", constants.textWidth).X + 8    

    information.Index.Text = index

    information.Index.Size = UDim2.new(0, indexWidth, 0, 20)
    information.Label.Size = UDim2.new(1, -(indexWidth + 20), 1, 0)
    information.Icon.Position = UDim2.new(0, indexWidth, 0, 2)
    information.Label.Position = UDim2.new(0, indexWidth + 20, 0, 0)

    information.Label.Text = value
    
    ListButton.new(instance, constantsList):SetRightCallback(function()
        selected.selectedConstant={index=index, value=value, Instance=Instance}
        selected.selectedConstantLog=instance
    end)
end

local function createEnvironment(index, value, tbpos, Instance)
    local instance = Assets.EnvironmentPod:Clone()
    local information = instance.Information
    local indexWidth = TextService:GetTextSize(tbpos, 18, "SourceSans", constants.textWidth).X + 8    

    information.Icon.Image = (oh.Constants.Types[typeof(value)] or "http://www.roblox.com/asset/?id=5538723428")
    information.Icon.ImageColor3 = Color3.fromRGB(139, 190, 255)
    information.Label.TextColor3 = Color3.fromRGB(139, 190, 255)

    information.Index.Text = tbpos

    information.Index.Size = UDim2.new(0, indexWidth, 0, 20)
    information.Label.Size = UDim2.new(1, -(indexWidth + 20), 1, 0)
    information.Icon.Position = UDim2.new(0, indexWidth, 0, 2)
    information.Label.Position = UDim2.new(0, indexWidth + 20, 0, 0)
    information.Label.Text = toString(index)

    ListButton.new(instance, environmentList):SetRightCallback(function()
        selected.selectedEnv={index=index, value=value, numindex=tbpos, Instance=Instance}
        selected.selectedEnvironmentLog=instance
    end)
end

-- Log Object
local Log = {}

function Log.new(localScript)
    local log = {}
    local scriptInstance = localScript.Instance
    local button = Assets.ScriptLog:Clone()
    local listButton = ListButton.new(button, scriptList)
    local scriptName = scriptInstance.Name

    button.Name = scriptName
    button:FindFirstChild("Name").Text = scriptName
    button.Protos.Text = #localScript.Protos
    button.Constants.Text = #localScript.Constants

    listButton:SetCallback(function()
        if selected.scriptLog ~= log then
            protosList:Clear()
            constantsList:Clear()
            environmentList:Clear()
            
            ScriptList.Visible = false
            ScriptInfo.Visible = true

            local nameLength = TextService:GetTextSize(scriptName, 18, "SourceSans", constants.textWidth).X + 20
            
            InfoScript.Label.Text = scriptName
            InfoScript.Label.Size = UDim2.new(0, nameLength, 0, 20)
            InfoScript.Position = UDim2.new(1, -nameLength, 0, 0)

            for i,v in pairs(localScript.Protos) do
                createProto(i, v, localScript.Instance)
            end 

            for i,v in pairs(localScript.Constants) do
                createConstant(i, v, localScript.Instance)
            end

            local num=1
            for i,v in pairs(localScript.Environment) do
                createEnvironment(i, v, num, localScript.Instance)
                num+=1
            end

            InfoSource.ResultScroll.ResultStatus.Text=localScript.Source

            selected.scriptLog = log
        end
    end)

    listButton:SetRightCallback(function()
        selected.logContext = log
    end)

    scriptLogs[scriptInstance] = log

    log.LocalScript = localScript
    log.Button = listButton
    return log
end

-- UI Functionality

local function addScripts(query)
    scriptList:Clear()
    scriptLogs = {}

    for _instance, localScript in pairs(Methods.Scan(query)) do
        Log.new(localScript)
    end

    scriptList:Recalculate()
end

ListSearch.FocusLost:Connect(function(returned)
    if returned then
        addScripts(ListSearch.Text)
        ListSearch.Text = ""
    end
end)

ListRefresh.MouseButton1Click:Connect(function()
    addScripts()
end)

addScripts()

InfoBack.MouseButton1Click:Connect(function()
    ScriptInfo.Visible = false
    ScriptList.Visible = true
end)

local selectedSection = InfoSource
local selectedSectionButton = InfoOptions.Source
local animationCache = {}

for _i, sectionButton in pairs(InfoOptions:GetChildren()) do
    if sectionButton:IsA("TextButton") then
        local label = sectionButton.Label
        local enterAnimation = TweenService:Create(label, constants.fadeLength, { TextTransparency = 0 })
        local leaveAnimation = TweenService:Create(label, constants.fadeLength, { TextTransparency = 0.2 })

        sectionButton.MouseButton1Click:Connect(function()
            local section = InfoSections:FindFirstChild(sectionButton.Name)
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

return ScriptScanner