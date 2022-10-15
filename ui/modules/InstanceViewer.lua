local InstanceViewer = {}
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local Methods = import("modules/InstanceViewer")
local selected = {}

local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Base = import("rbxassetid://10922275113").Base
local Assets = import("rbxassetid://10924729710").InstanceViewer

local Page = Base.Body.Pages.InstanceViewer
local InstanceInfo = Page.Info
local Buttons = InstanceInfo.Buttons
local serviceList = Page.List
local ResultContent = serviceList.Results.Clip

local Query = serviceList.Query
local Refresh = Query.Refresh
local Search = Query.Search
local Back = InstanceInfo.Back

local InstanceProperties = InstanceInfo.Properties
local InstanceMethods = InstanceInfo.Methods
local InstanceDescendants = InstanceInfo.Descendants

local animationCache = {}
local icons = {
	Property = "rbxassetid://4666593882",
	Method = "rbxassetid://4666593447",
	Instance = "rbxassetid://4666594723",
}
local constants = {
	fadeLength = TweenInfo.new(0.15),
	textWidth = Vector2.new(133742069, 20),
}

local instanceCache = {
	--[[
        [workspace.Test]={
            Properties={},
            Methods={},
            Descendants={
                ["hi"]={
                    Properties={},
                    Methods={},
                    Descendants={}
                }
            }
        }
        ]]
}

local ServiceList = List.new(ResultContent.Content)
local instanceProperties = List.new(InstanceProperties)
local instanceMethods = List.new(InstanceMethods)
local instanceDescendants = List.new(InstanceDescendants)
local docsContext = ContextMenuButton.new("rbxassetid://4891705738", "Copy Documentation URL")
ServiceList:BindContextMenu(ContextMenu.new({ docsContext }))

docsContext:SetCallback(function()
	setClipboard("https://developer.roblox.com/en-us/api-reference/class/" .. selected.instance.Instance.ClassName)
	MessageBox.Show(
		"Success",
		("%s's documentation URL was copied to your clipboard."):format(selected.instance.Instance.Name),
		MessageType.OK
	)
end)

local function createProperties(index, value, tbnum)
	local log = Assets.InstanceLog:Clone()
	local information = log.Information
	local indexWidth = TextService:GetTextSize(index, 18, "SourceSans", constants.textWidth).X + 8

	information.Index.Text = tbnum
	information.Icon.Image = icons.Property

	information.Index.Size = UDim2.new(0, indexWidth, 0, 20)
	information.Label.Size = UDim2.new(1, -(indexWidth + 20), 1, 0)
	information.Icon.Position = UDim2.new(0, indexWidth, 0, 2)
	information.Label.Position = UDim2.new(0, indexWidth + 20, 0, 0)

	information.Label.Text = index

	ListButton.new(log, instanceProperties):SetRightCallback(function()
		selected.selectedBtn = { index = index, value = value, log = log, num = tbnum }
		selected.selectedType = "Property"
	end)
end

local function createMethods(index, value, tbnum)
	local log = Assets.InstanceLog:Clone()
	local information = log.Information
	local indexWidth = TextService:GetTextSize(index, 18, "SourceSans", constants.textWidth).X + 8

	information.Index.Text = tbnum
	information.Icon.Image = icons.Method

	information.Index.Size = UDim2.new(0, indexWidth, 0, 20)
	information.Label.Size = UDim2.new(1, -(indexWidth + 20), 1, 0)
	information.Icon.Position = UDim2.new(0, indexWidth, 0, 2)
	information.Label.Position = UDim2.new(0, indexWidth + 20, 0, 0)

	information.Label.Text = index

	ListButton.new(log, instanceMethods):SetRightCallback(function()
		selected.selectedBtn = { index = index, value = value, log = log, num = tbnum }
		selected.selectedType = "Method"
	end)
end

local function createDescendants(index, value, tbnum)
	local log = Assets.InstanceLog:Clone()
	local information = log.Information
	local indexWidth = TextService:GetTextSize(index, 18, "SourceSans", constants.textWidth).X + 8

	information.Index.Text = tbnum
	information.Icon.Image = icons.Instance

	information.Index.Size = UDim2.new(0, indexWidth, 0, 20)
	information.Label.Size = UDim2.new(1, -(indexWidth + 20), 1, 0)
	information.Icon.Position = UDim2.new(0, indexWidth, 0, 2)
	information.Label.Position = UDim2.new(0, indexWidth + 20, 0, 0)

	information.Label.Text = index

	ListButton.new(log, instanceDescendants):SetRightCallback(function()
		selected.selectedBtn = { index = index, value = value, log = log, num = tbnum }
		selected.selectedType = "Descendant"
	end)
end

-- Log Object
local Log = {}
function Log.new(instance)
	local log = {}
	local originalInstance = instance.Instance
	local instanceName = originalInstance.Name
	local button = Assets.ServiceLog:Clone()
	local listButton = ListButton.new(button, ServiceList)

	button.Name = instanceName
	button:FindFirstChild("Name").Text = originalInstance.ClassName
	button.Methods.Text = #Methods.GetInstanceMethods(originalInstance)
	button.Descendants.Text = #instance.Descendants
	button.Icon.Image = "rbxassetid://4800244808"

	listButton:SetCallback(function()
		if selected.scriptLog ~= log then
			instanceDescendants:Clear()
			instanceMethods:Clear()
			instanceProperties:Clear()

			InstanceInfo.Visible = true
			serviceList.Visible = false

			local num = 1
			for i, v in pairs(Methods.GetInstanceProperties(originalInstance)) do
				createProperties(i, v, num)
				num += 1
			end

			local num = 1
			for i, v in pairs(Methods.GetInstanceMethods(originalInstance)) do
				createMethods(i, v, num)
				num += 1
			end

			local num = 1
			for i, v in pairs(instance.Descendants) do
				createDescendants(i, v, num)
				num += 1
			end

			selected.scriptLog = log
		end
	end)

	listButton:SetRightCallback(function()
		selected.instance = instance
	end)
	log.Instance = instance
	log.Button = listButton
end

-- UI Functionality

local function addServices(query)
	ServiceList:Clear()

	for _instance, service in pairs(Methods.Scan(query)) do
		Log.new(service)
	end

	ServiceList:Recalculate()
end

Search.FocusLost:Connect(function(returned)
	if returned then
		addServices(Search.Text)
		Search.Text = ""
	end
end)

Back.MouseButton1Click:Connect(function()
	instanceDescendants:Clear()
	instanceMethods:Clear()
	instanceProperties:Clear()

	InstanceInfo.Visible = false
	serviceList.Visible = true
end)

Refresh.MouseButton1Click:Connect(function()
	addServices()
end)

addServices()

local selectedSection = InfoSections.Properties
local selectedSectionButton = Buttons.Properties

for _i, sectionButton in pairs(Buttons:GetChildren()) do
	if sectionButton:IsA("ImageButton") then
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
			leave = leaveAnimation,
		}
	end
end
return InstanceViewer
