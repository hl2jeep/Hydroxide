local InstanceViewer={}
local Methods=import("modules/InstanceViewer")
local selected={}

local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Base = import("rbxassetid://10922275113").Base
local Assets = import("rbxassetid://10924729710").InstanceViewer

local Page = Base.Body.Pages.InstanceViewer
local ServiceList = Page.List
local ResultContent = ServiceList.Results.Clip

local Query=ServiceList.Query
local Refresh=Query.Refresh
local Search=Query.Search

local ServiceList = List.new(ResultContent.Content)
local docsContext=ContextMenuButton.new("rbxassetid://4891705738", "Copy Documentation URL")
ServiceList:BindContextMenu(ContextMenu.new({ docsContext }))

docsContext:SetCallback(function()
    setClipboard("https://developer.roblox.com/en-us/api-reference/class/"..selected.instance.Instance.ClassName)
    MessageBox.Show("Success", ("%s's documentation URL was copied to your clipboard."):format(selected.instance.Instance.Name), MessageType.OK)
end)

-- Log Object
local Log={}
function Log.new(instance)
    local originalInstance=instance.Instance
    local instanceName=originalInstance.Name
    print("addService "..instanceName)
    local button = Assets.ServiceLog:Clone()
    local listButton = ListButton.new(button, ServiceList)

    button.Name = instanceName
    button:FindFirstChild("Name").Text = instanceName
    button.Children.Text = #instance.Children
    button.Descendants.Text = #instance.Descendants
    --Methods.SetToInstanceIcon(button.Icon, originalInstance)

    listButton:SetRightCallback(function()
        selected.instance=instance
    end)
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

Refresh.MouseButton1Click:Connect(function()
    addServices()
end)

addServices()

return InstanceViewer