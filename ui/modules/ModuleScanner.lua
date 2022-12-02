local ModuleScanner = {}
local Methods = import("modules/ModuleScanner")

if not hasMethods(Methods.RequiredMethods) then
	return ModuleScanner
end

local List, ListButton = import("ui/controls/List")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://11389137937").Base.Body.Pages.ModuleScanner
local Assets = import("rbxassetid://10924729710").ModuleScanner
local Info = Page.Info

local InfoList = Page.List
local Query = InfoList.Query
local Search = Query.Search
local Refresh = Query.Refresh
local Results = InfoList.Results.Clip.Content

local moduleList = List.new(Results)
local moduleLogs = {}
local selectedLog
local constants = {
	fadeLength = TweenInfo.new(0.15),
	textWidth = Vector2.new(133742069, 20),
}

local InfoSource = Info.Sections.Source.ResultScroll.ResultStatus
local InfoScript = Info.ScriptObject
local InfoReturn = Info.Sections.ReturnValue.ResultScroll.ResultStatus

local pathContext = ContextMenuButton.new("rbxassetid://4891705738", "Get Module Path")
moduleList:BindContextMenu(ContextMenu.new({ pathContext }))

-- Log Object

local Log = {}

function Log.new(moduleScript)
	local log = {}
	local moduleInstance = moduleScript.Instance
	local button = Assets.ModuleLog:Clone()
	local listButton = ListButton.new(button, moduleList)
	local moduleName = moduleInstance.Name

	button.Name = moduleInstance.Name
	button:FindFirstChild("Name").Text = moduleInstance.Name
	button.Protos.Text = #moduleScript.Protos
	button.Constants.Text = #moduleScript.Constants

	listButton:SetCallback(function()
		if selectedLog ~= log then
			InfoList.Visible = false
			Info.Visible = true

			local nameLength = game:GetService("TextService")
				:GetTextSize(moduleName, 18, "SourceSans", constants.textWidth).X + 20

			InfoScript.Label.Text = moduleName
			InfoScript.Label.Size = UDim2.new(0, nameLength, 0, 20)
			InfoScript.Position = UDim2.new(1, -nameLength, 0, 0)

			InfoSource.Text = moduleScript.Source
			InfoReturn.Text = dataToString(moduleScript.getReturnValue())

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
	InfoList.Visible = true
end)

addModules()

local selectedSection = InfoSource
local selectedSectionButton = Info.Options.Clip.Content.Source
local animationCache = {}

for _i, sectionButton in pairs(Info.Options.Clip.Content:GetChildren()) do
	if sectionButton:IsA("TextButton") then
		local label = sectionButton.Label
		local enterAnimation = game:GetService("TweenService")
			:Create(label, constants.fadeLength, { TextTransparency = 0 })
		local leaveAnimation = game:GetService("TweenService")
			:Create(label, constants.fadeLength, { TextTransparency = 0.2 })

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
			leave = leaveAnimation,
		}
	end
end

table.insert(oh.LoadedTabs, "ModuleScanner")
return ModuleScanner
