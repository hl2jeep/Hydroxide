local HttpSpy = {}
local Methods = import("modules/HttpSpy")

if not hasMethods(Methods.RequiredMethods) then
	return HttpSpy
end

local List, ListButton = import("ui/controls/List")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://11389137937").Base.Body.Pages.HttpSpy
local Assets = import("rbxassetid://10924729710").HttpSpy

local InfoList = Page.List
local Query = InfoList.Query
local Search = Query.Search
local Refresh = Query.Refresh
local Results = InfoList.Results.Clip.Content

local requestList = List.new(Results)
local selectedLog
local constants = {
	fadeLength = TweenInfo.new(0.15),
	textWidth = Vector2.new(133742069, 20),
}

local bodyContext = ContextMenuButton.new("rbxassetid://4891705738", "Copy Request Body")
requestList:BindContextMenu(ContextMenu.new({ bodyContext }))

-- Log Object

local Log = {}

function Log.new(request)
	local log = {}
	local moduleInstance = request.Instance
	local button = Assets.ModuleLog:Clone()
	local listButton = ListButton.new(button, requestList)

	button.Name = moduleInstance.Name
	button:FindFirstChild("Name").Text = moduleInstance.Name
	button.Headers.Text = #request.Headers

	log.Request = request
	log.Button = listButton
	return log
end

-- UI Functionality

local function addRequests(query)
	requestList:Clear()

	for _index, request in pairs(Methods.Scan(query)) do
		Log.new(request)
	end

	requestList:Recalculate()
end

Search.FocusLost:Connect(function(returned)
	if returned then
		addRequests(Search.Text)
		Search.Text = ""
	end
end)

Refresh.MouseButton1Click:Connect(function()
	addRequests()
end)

addRequests()

table.insert(oh.LoadedTabs, "HttpSpy")
return HttpSpy
