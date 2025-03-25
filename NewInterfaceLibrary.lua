-- [ Exploit Variables ] --
local cloneref = cloneref or function(o) return o end
local protectgui = protectgui or syn and syn.protect_gui
local setclipboard = setclipboard or toclipboard or set_clipboard or syn and syn.write_clipboard or Clipboard and Clipboard.set
-- [ Services ] --
local CoreGui = cloneref(game:GetService("CoreGui"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local RS = cloneref(game:GetService("RunService"))
local StarterGui = game:GetService("StarterGui")
local UIS = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TweenService = cloneref(game:GetService("TweenService"))
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Lighting = cloneref(game:GetService("Lighting"))
-- [ Variables ] --
--LocalPlayer
repeat task.wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
-- Interface
local NotificationGUI
local InsetSize = 0
-- Script Variables
local IsMobile = table.find({Enum.Platform.IOS, Enum.Platform.Android}, UIS:GetPlatform())
local IsStudio = RS:IsStudio()
local SandboxWorkspace = {"folder","workspace",{}}
local LibraryBuildErrorDebounce = false
local CheckingForKeybind = false
local WindowLoaded = false
local UniqueID = 0
local Objects
-- Data
local notifications = {}
local buildErrorCount = {}
local connections = {}
local a = 0
local hiddenProperties = {
	"Class";
	"ClassName";
	"IgnoreList";
	"Instance";
	"UniqueID";
	"Flag";
}
local Library = {
	Flags = {};
	Elements = {};
	Keybinds = {};
	Themes = {
		InfluencedInstances = {};
		Colors = {
			PrimaryColor = Color3.fromRGB(33,33,33);
			SecondaryColor = Color3.fromRGB(25,25,25);
			TertiaryColor = Color3.fromRGB(20,20,20);
			QuaternaryColor = Color3.fromRGB(13,13,13);
		}
	};
	Settings = {
		ConfigurationSaving = {
			Enabled = false;
			FolderName = "configs"; -- Folder for all script configuration files. Keep it unique to prevent other scripts from overwriting this file.
			PlaceId = false -- (Optional) Only saves configurations for specific PlaceId
		};
		MenuButton = {
			Title = "Library";
			UseIcons = false; -- (Optional) Uses Icon on the menu button instead of title
			IconId = 0; -- IconId shown on the button
			HoverIconId = 0; -- IconId shown when user hovers over the button. Set to nil for no HoverIcon.
			Position = UDim2.new(0.5,0,0,18);
			AnchorPoint = Vector2.new(0.5,0.5);
			Draggable = true; -- (Optional)
		};
	}
}
-- Configuration Folders
local LibraryFolder = "^-^"
local ConfigurationFolder = LibraryFolder.."/Configurations"
local KeyFolder = LibraryFolder.."/Keys"
local DiscordInvitesFile = LibraryFolder.."/DiscordInvites.json"
local LocalConfigurationFolder = nil
local LocalConfigurationSubFolder = nil
local LocalConfigurationSubFolderName = nil
-- Tweens
local Linear20 = TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
local Linear30 = TweenInfo.new(0.3,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
local Linear35 = TweenInfo.new(0.35,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
local Linear60 = TweenInfo.new(0.6,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
local QuadIn20 = TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,0,false,0)
local QuadOut20 = TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,0,false,0)
local QuadOut40 = TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)
local QuadOut45 = TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)
local QuadOut60 = TweenInfo.new(0.6,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)
local QuadInOut5 = TweenInfo.new(0.05,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,0,false,0)
local QuadInOut50 = TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,0,false,0)
-- [ Functions ] --
function GenerateRandomString()
	local str = ""
	for _ = 1,20,1 do
		local char
		local chartype = math.random(1,3)
		if chartype == 1 then
			char = string.char(math.random(48,57))
		elseif chartype == 2 then
			char = string.char(math.random(65,90))
		elseif chartype == 3 then
			char = string.char(math.random(97,122))
		end
		str = str..char
	end
	return str
end
function tableConcat(t1,t2)
	for i = 1, #t2, 1 do
		table.insert(t1,t2[i])
	end
	return t1
end
function PlaySound(id)
	local sound = Instance.new("Sound", workspace)
	sound.SoundId = "rbxassetid://"..tostring(id)
	sound.PlayOnRemove = true
	sound:Destroy()
end
function UpdateNotificationLayout()
	local yoffset = 0
	for i, v in notifications do
		yoffset += v.Y
		TweenService:Create(v.I,QuadOut45,{Position = UDim2.new(1,-v.X,1,-yoffset - (v.sY - v.Y))}):Play()
	end
end
function MakeDraggable(draggable,Frame,scalelerp,controlelement)
	local scaleparent = Frame.Parent
	if not scaleparent or not scaleparent:IsA("GuiBase2d") then return end
	if not controlelement then controlelement = Frame end
	if controlelement and not controlelement:IsA("GuiObject") then return end
	for _, v in connections do
		if typeof(v) == "table" and v[1] == "Drag" and v[2] == Frame then
			v[3]:Disconnect()
			v[4]:Disconnect()
		end
	end
	if draggable then
		a += 1
		local b = a
		local dragging
		local startpos
		local lastmousepos
		local lastgoalpos
		local prevpos
		local function Lerp(a, b, m)
			return a + (b - a) * m
		end
		local function Scale(a, b, c)
			return (b - a)/c
		end
		connections[b] = {"Drag",Frame,
			controlelement.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					startpos = Frame.AbsolutePosition
					lastmousepos = UIS:GetMouseLocation()
					local inputchanged
					inputchanged = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
							inputchanged:Disconnect()
						end
					end)
				end
			end),
			RS.RenderStepped:Connect(function(dt)
				if not startpos then return end;
				if not dragging and lastgoalpos then
					prevpos = Frame.AbsolutePosition
					if scalelerp then
						Frame.Position = UDim2.new(Lerp(Frame.Position.X.Scale, Scale((scaleparent.AbsolutePosition.X - Frame.AbsoluteSize.X * Frame.AnchorPoint.X),lastgoalpos.X - Frame.Position.X.Offset,scaleparent.AbsoluteSize.X), dt * 8), Frame.Position.Y.Offset, Lerp(Frame.Position.Y.Scale, Scale((scaleparent.AbsolutePosition.Y - Frame.AbsoluteSize.Y * Frame.AnchorPoint.Y),lastgoalpos.Y - Frame.Position.Y.Offset,scaleparent.AbsoluteSize.Y), dt * 8), Frame.Position.Y.Offset)
					else
						Frame.Position = UDim2.new(Frame.Position.X.Scale, Lerp(Frame.Position.X.Offset, lastgoalpos.X - ((scaleparent.AbsolutePosition.X - Frame.AbsoluteSize.X * Frame.AnchorPoint.X)) - Frame.Position.X.Scale * scaleparent.AbsoluteSize.X, dt * 8), Frame.Position.Y.Scale, Lerp(Frame.Position.Y.Offset, lastgoalpos.Y - (scaleparent.AbsolutePosition.Y - Frame.AbsoluteSize.Y * Frame.AnchorPoint.Y) - Frame.Position.Y.Scale * scaleparent.AbsoluteSize.Y, dt * 8))
					end
					return
				end
				local delta = lastmousepos - UIS:GetMouseLocation()
				local xGoal = startpos.X - delta.X
				local yGoal = startpos.Y - delta.Y
				lastgoalpos = Vector2.new(xGoal, yGoal)
				if scalelerp then
					Frame.Position = UDim2.new(Lerp(Frame.Position.X.Scale, Scale((scaleparent.AbsolutePosition.X - Frame.AbsoluteSize.X * Frame.AnchorPoint.X),xGoal - Frame.Position.X.Offset,scaleparent.AbsoluteSize.X), dt * 8), Frame.Position.X.Offset, Lerp(Frame.Position.Y.Scale, Scale((scaleparent.AbsolutePosition.Y - Frame.AbsoluteSize.Y * Frame.AnchorPoint.Y),yGoal - Frame.Position.Y.Offset,scaleparent.AbsoluteSize.Y), dt * 8), Frame.Position.Y.Offset)
				else
					Frame.Position = UDim2.new(Frame.Position.X.Scale, Lerp(Frame.Position.X.Offset, xGoal - (scaleparent.AbsolutePosition.X - Frame.AbsoluteSize.X * Frame.AnchorPoint.X) - Frame.Position.X.Scale * scaleparent.AbsoluteSize.X, dt * 8), Frame.Position.Y.Scale, Lerp(Frame.Position.Y.Offset, yGoal - (scaleparent.AbsolutePosition.Y - Frame.AbsoluteSize.Y * Frame.AnchorPoint.Y) - Frame.Position.Y.Scale * scaleparent.AbsoluteSize.Y, dt * 8))
				end
			end)
		}
	end
end
function isHoveringOverObj(obj)
	local tx = obj.AbsolutePosition.X
	local ty = obj.AbsolutePosition.Y
	local bx = tx + obj.AbsoluteSize.X
	local by = ty + obj.AbsoluteSize.Y
	local m = Mouse
	if m.X >= tx and m.Y >= ty and m.X <= bx and m.Y <= by then
		return true
	end
	return false
end
function GetProperty(instance,property)
	local suc, property = pcall(function()
		return instance[property]
	end)
	return suc and property
end
function RobloxNotification(title,msg)
	StarterGui:SetCore("SendNotification",{
		Title = title, -- Required
		Text = msg, -- Required
	})
end
function LibraryBuildError(name,errormessage)
	task.spawn(function()
		if not buildErrorCount[#buildErrorCount] or buildErrorCount[#buildErrorCount].Name ~= name then
			buildErrorCount[#buildErrorCount+1] = {}
			buildErrorCount[#buildErrorCount].Name = name
			buildErrorCount[#buildErrorCount].Stack = 0
		end
		buildErrorCount[#buildErrorCount].Stack += 1
		warn(errormessage)
		if not LibraryBuildErrorDebounce then
			LibraryBuildErrorDebounce = true
			task.wait()
			for _, build in buildErrorCount do
				RobloxNotification("Error","Failed to run func:"..build.Name.." with "..build.Stack.." invalid arguments. Check Console For More Info.")
			end
			buildErrorCount = {}
			LibraryBuildErrorDebounce = false
		end
	end)
end
function SandboxFindFolder(path)
	if not path then return end
	local directorySplit = path:split("/")
	if #directorySplit <= 0 then return end
	local currentDirectory = SandboxWorkspace
	for i, v in directorySplit do
		currentDirectory = currentDirectory[v]
		if not currentDirectory then return end
	end
	return currentDirectory
end
function CreateMetaTable(properties)
	local mt = {}
	function mt.__index(self,idx)
		if table.find(hiddenProperties,idx) then
			return properties[idx]
		elseif properties[idx] then
			if properties[idx].idx then
				return properties[idx].idx(self,idx)
			end
		else
			return warn(idx.." is not a valid member of "..properties.ClassName)
		end
	end
	function mt.__newindex(self,idx,value)
		if properties[idx] then
			if table.find(hiddenProperties,idx) or properties[idx].readonly then
				return warn(idx.." is a read-only property")
			end
			if properties[idx].type then
				local validtype = table.find(properties[idx].type,typeof(value))
				if not validtype or typeof(value) == "EnumItem" and properties[idx].enumtype ~= value.EnumType then
					return warn(idx.." must be a "..(properties[idx].type == "EnumItem" and "Enum."..tostring(properties[idx].enumtype) or properties[idx].type[1]))
				end
			end
			properties[idx].newidx(self,idx,value)
			if properties.Flag and properties[idx].savetoflags and not table.find(properties.IgnoreList,idx) then
				UpdateFlag(properties.Flag,idx,value)
			end
		else
			return warn(idx.." is not a valid member of "..properties.ClassName)
		end
	end
	return mt
end
function CreateTabSectionModules(TabSection)
	local module = {}
	function module:CreateOptionButton(buttonsettings)
		local Button = {}
		local builderror = false
		if typeof(buttonsettings.ConfigName) ~= "string" then LibraryBuildError("ConfigButton","ConfigName Name is required and must be a string") builderror = true end
		if buttonsettings.Name == nil then buttonsettings.Name = "Button" end
		if typeof(buttonsettings.Name) ~= "string" then LibraryBuildError("ConfigButton","ConfigButton Name must be a string") builderror = true end
		if buttonsettings.RichText == nil then buttonsettings.RichText = false end
		if typeof(buttonsettings.RichText) ~= "boolean" then LibraryBuildError("ConfigButton","ConfigButton RichText must be a boolean") builderror = true end
		if buttonsettings.Callback == nil then buttonsettings.Callback = function() end end
		if typeof(buttonsettings.Callback) ~= "function" then LibraryBuildError("ConfigButton","ConfigButton Callback must be a function") builderror = true end
		if buttonsettings.IgnoreList == nil then buttonsettings.IgnoreList = {} end
		if typeof(buttonsettings.IgnoreList) ~= "table" then LibraryBuildError("ConfigButton","ConfigButton IgnoreList must be a table") builderror = true end
		if TabSection.Configs[buttonsettings.ConfigName] then LibraryBuildError("ConfigButton","Config: "..buttonsettings.ConfigName.." Is Already Taken") builderror = true end
		if builderror then return end
		UniqueID += 1
		-- Variables
		local callbackerroranimationticket = 0
		-- Appearance
		local ConfigButtonElement = Objects.Elements.Button:Clone()
		ConfigButtonElement.Parent = TabSection.Instance.Container
		local ConfigButtonContainer = ConfigButtonElement.Container
		local ConfigButtonName = ConfigButtonContainer.ElementName
		local ConfigButtonGradient = ConfigButtonContainer.UIGradient
		-- Functions
		local function ChangeOverlayColors()
			local color = Library.Themes.Colors.SecondaryColor
			local _,_,v = color:ToHSV()
			if v >= 0.5 then
				ConfigButtonName.TextColor3 = Color3.new(0,0,0)
			else
				ConfigButtonName.TextColor3 = Color3.new(1,1,1)
			end
		end
		function Button:UpdateColors()
			ConfigButtonElement.BackgroundColor3 = Library.Themes.Colors.SecondaryColor
			--ChangeOverlayColors()
		end
		function Button:OnClick(...)
			local suc = Callback(buttonsettings.Callback,...)
			if not suc then
				task.spawn(function()
					task.wait(0.3)
					callbackerroranimationticket += 1
					local currentticket = callbackerroranimationticket
					ConfigButtonName.Text = "Callback Error!"
					TweenService:Create(ConfigButtonElement,Linear30,{BackgroundColor3 = Color3.fromRGB(132,50,50)}):Play()
					task.wait(0.4)
					if currentticket == callbackerroranimationticket then
						ConfigButtonName.Text = Button.Name
						TweenService:Create(ConfigButtonElement,Linear30,{BackgroundColor3 = Library.Themes.Colors.SecondaryColor}):Play()
					end
				end)
			end
			return suc
		end
		-- Properties
		local properties = {
			Class = "TabElementConfig";
			ClassName = "ConfigButton";
			IgnoreList = buttonsettings.IgnoreList;
			Instance = ConfigButtonElement;
			--UniqueID = UniqueID;
			Flag = nil;
			ConfigName = {
				idx = function(self,idx)
					return buttonsettings.ConfigName
				end;
				newidx = function(self,idx,value)
				end;
				type = {"string"};
				readonly = true;
				savetoflags = false;
			};
			Name = {
				idx = function(self,idx)
					return buttonsettings.Name
				end;
				newidx = function(self,idx,value)
					buttonsettings.Name = value
					ConfigButtonName.Text = buttonsettings.Name
				end;
				type = {"string"};
				readonly = false;
				savetoflags = false;
			};
			RichText = {
				idx = function(self,idx)
					return buttonsettings.RichText
				end;
				newidx = function(self,idx,value)
					buttonsettings.RichText = value
					ConfigButtonName.RichText = buttonsettings.RichText
				end;
				type = {"boolean"};
				readonly = false;
				savetoflags = false;
			};
			Callback = {
				idx = function(self,idx)
					return buttonsettings.Callback
				end;
				newidx = function(self,idx,value)
					buttonsettings.Callback = value
				end;
				type = {"function"};
				readonly = false;
				savetoflags = false;
			};
		}
		-- Button Functions
		function Button:GetProperties(...)
			return GetProperties(properties,Button,...)
		end
		-- Metatable
		local mt = CreateMetaTable(properties)
		setmetatable(Button,mt)
		-- Button Main
		ConfigButtonElement.MouseButton1Down:Connect(function()
			ConfigButtonContainer.BackgroundTransparency = 0.5
			ConfigButtonGradient.Rotation = 270
		end)
		ConfigButtonElement.MouseButton1Up:Connect(function()
			ConfigButtonContainer.BackgroundTransparency = 0.75
			ConfigButtonGradient.Rotation = 90
		end)
		ConfigButtonElement.MouseButton1Click:Connect(function()
			Button:OnClick()
		end)
		-- Set Configs
		for i, v in Button:GetProperties(false,function(p) return p.readonly == false end) do
			Button[i] = buttonsettings[i]
		end
		-- Add To Configs
		TabSection.Configs[buttonsettings.ConfigName] = Button
		-- Add To Elements
		table.insert(Library.Elements,Button)
		return Button
	end
	function module:CreateOptionToggle(togglesettings)
		local Toggle = {}
		local builderror = false
		if typeof(togglesettings.ConfigName) ~= "string" then LibraryBuildError("ConfigToggle","ConfigName Name is required and must be a string") builderror = true end
		if togglesettings.Name == nil then togglesettings.Name = "Toggle" end
		if typeof(togglesettings.Name) ~= "string" then LibraryBuildError("ConfigToggle","ConfigToggle Name must be a string") builderror = true end
		if togglesettings.RichText == nil then togglesettings.RichText = false end
		if typeof(togglesettings.RichText) ~= "boolean" then LibraryBuildError("ConfigToggle","ConfigToggle RichText must be a boolean") builderror = true end
		if togglesettings.ActivatedColor == nil then togglesettings.ActivatedColor = Color3.fromRGB(255, 223, 96) end
		if typeof(togglesettings.ActivatedColor) ~= "Color3" then LibraryBuildError("ConfigToggle","ConfigToggle ActivatedColor must be a Color3") builderror = true end
		if togglesettings.CurrentValue == nil then togglesettings.CurrentValue = false end
		if typeof(togglesettings.CurrentValue) ~= "boolean" then LibraryBuildError("ConfigToggle","ConfigToggle CurrentValue must be a boolean") builderror = true end
		if togglesettings.Callback == nil then togglesettings.Callback = function() end end
		if typeof(togglesettings.Callback) ~= "function" then LibraryBuildError("ConfigToggle","ConfigToggle Callback must be a function") builderror = true end
		if togglesettings.IgnoreList == nil then togglesettings.IgnoreList = {} end
		if typeof(togglesettings.IgnoreList) ~= "table" then LibraryBuildError("ConfigToggle","ConfigToggle IgnoreList must be a table") builderror = true end
		if TabSection.Configs[togglesettings.ConfigName] then LibraryBuildError("ConfigToggle","Config: "..togglesettings.ConfigName.." Is Already Taken") builderror = true end
		if builderror then return end
		UniqueID += 1
		-- Variables
		local callbackerroranimationticket = 0
		local ColorChangeTween
		-- Appearance
		local ConfigToggleElement = Objects.Elements.Toggle:Clone()
		ConfigToggleElement.Parent = TabSection.Instance.Container
		local ConfigToggleName = ConfigToggleElement.ElementName
		local ConfigToggleSwitchContainer = ConfigToggleElement.SwitchContainer
		local ConfigToggleSwitch = ConfigToggleSwitchContainer.Switch
		local ConfigToggleSwitchCircle = ConfigToggleSwitch.Circle
		local ConfigToggleSwitchGlow = ConfigToggleSwitch.Glow
		ConfigToggleSwitchGlow.ImageColor3 = togglesettings.ActivatedColor
		local ConfigToggleGradient = ConfigToggleSwitch.UIGradient
		-- Functions
		local function ChangeOverlayColors()
			local color = Library.Themes.Colors.SecondaryColor
			local _,_,v = color:ToHSV()
			if v >= 0.5 then
				ConfigToggleName.TextColor3 = Color3.new(0,0,0)
			else
				ConfigToggleName.TextColor3 = Color3.new(1,1,1)
			end
		end
		function Toggle:UpdateColors()
			ConfigToggleElement.BackgroundColor3 = Library.Themes.Colors.SecondaryColor
			--ChangeOverlayColors()
		end
		function Toggle:OnClick(...)
			local suc = Callback(togglesettings.Callback,...)
			if not suc then
				task.spawn(function()
					task.wait(0.3)
					callbackerroranimationticket += 1
					local currentticket = callbackerroranimationticket
					ConfigToggleName.Text = "Callback Error!"
					TweenService:Create(ConfigToggleElement,Linear30,{BackgroundColor3 = Color3.fromRGB(132,50,50)}):Play()
					task.wait(0.4)
					if currentticket == callbackerroranimationticket then
						ConfigToggleName.Text = Toggle.Name
						TweenService:Create(ConfigToggleElement,Linear30,{BackgroundColor3 = Library.Themes.Colors.SecondaryColor}):Play()
					end
				end)
			end
			return suc
		end
		-- Properties
		local properties = {
			Class = "TabElementConfig";
			ClassName = "ConfigToggle";
			IgnoreList = togglesettings.IgnoreList;
			Instance = ConfigToggleElement;
			--UniqueID = UniqueID;
			Flag = nil;
			ConfigName = {
				idx = function(self,idx)
					return togglesettings.ConfigName
				end;
				newidx = function(self,idx,value)
				end;
				type = {"string"};
				readonly = true;
				savetoflags = false;
			};
			Name = {
				idx = function(self,idx)
					return togglesettings.Name
				end;
				newidx = function(self,idx,value)
					togglesettings.Name = value
					ConfigToggleName.Text = togglesettings.Name
				end;
				type = {"string"};
				readonly = false;
				savetoflags = false;
			};
			RichText = {
				idx = function(self,idx)
					return togglesettings.RichText
				end;
				newidx = function(self,idx,value)
					togglesettings.RichText = value
					ConfigToggleName.RichText = togglesettings.RichText
				end;
				type = {"boolean"};
				readonly = false;
				savetoflags = false;
			};
			CurrentValue = {
				idx = function(self,idx)
					return togglesettings.CurrentValue
				end;
				newidx = function(self,idx,value)
					togglesettings.CurrentValue = value
					ConfigToggleGradient.Enabled = not togglesettings.CurrentValue
					ConfigToggleSwitchGlow.ImageColor3 = Toggle.ActivatedColor
					ColorChangeTween = TweenService:Create(ConfigToggleSwitch,Linear30,{BackgroundColor3 = togglesettings.CurrentValue and Toggle.ActivatedColor or Color3.fromRGB(20,20,20)})
					ColorChangeTween:Play()
					TweenService:Create(ConfigToggleSwitchCircle,QuadOut40,{Position = togglesettings.CurrentValue and UDim2.new(0,14,0.5,0) or UDim2.new(0,2,0.5,0)}):Play()
					TweenService:Create(ConfigToggleSwitchGlow,Linear30,{ImageTransparency = togglesettings.CurrentValue and 0 or 1}):Play()
					TweenService:Create(ConfigToggleSwitch,Linear30,{BackgroundTransparency = togglesettings.CurrentValue and 0 or 0.9}):Play()
				end;
				type = {"boolean"};
				readonly = false;
				savetoflags = true;
			};
			ActivatedColor = {
				idx = function(self,idx)
					return togglesettings.ActivatedColor
				end;
				newidx = function(self,idx,value)
					togglesettings.ActivatedColor = value
					if Toggle.CurrentValue then
						if ColorChangeTween then ColorChangeTween:Cancel() end
						ConfigToggleSwitch.BackgroundColor3 = togglesettings.ActivatedColor
						ConfigToggleSwitchGlow.ImageColor3 = togglesettings.ActivatedColor
					end
				end;
				type = {"Color3"};
				readonly = false;
				savetoflags = false;
			};
			Callback = {
				idx = function(self,idx)
					return togglesettings.Callback
				end;
				newidx = function(self,idx,value)
					togglesettings.Callback = value
				end;
				type = {"function"};
				readonly = false;
				savetoflags = false;
			};
		}
		-- Toggle Functions
		function Toggle:GetProperties(...)
			return GetProperties(properties,Toggle,...)
		end
		-- Metatable
		local mt = CreateMetaTable(properties)
		setmetatable(Toggle,mt)
		-- Toggle Main
		ConfigToggleElement.MouseButton1Click:Connect(function()
			Toggle.CurrentValue = not Toggle.CurrentValue
			Toggle:OnClick(Toggle.CurrentValue)
		end)
		-- Set Configs
		for i, v in Toggle:GetProperties(false,function(p) return p.readonly == false end) do
			Toggle[i] = togglesettings[i]
		end
		-- Add To Configs
		TabSection.Configs[togglesettings.ConfigName] = Toggle
		-- Add To Elements
		table.insert(Library.Elements,Toggle)
		return Toggle
	end
	return module
end
function GetProperties(properties,module,includeHiddenProperties,comp)
	local t = {}
	for i in properties do
		if not table.find(hiddenProperties,i) then
			if not comp or comp(properties[i]) then
				t[i] = module[i]
			end
		elseif includeHiddenProperties then
			t[i] = properties[i]
		end
	end
	return t
end
function RobloxDataTypeToJSON(value) -- Returns a ROBLOX table which converts to JSON without any null values
	if typeof(value) == "Color3" then
		return {typeof(value),{R = value.R,G = value.G,B = value.B}}
	elseif typeof(value) == "EnumItem" then
		return {typeof(value),{EnumType = tostring(value.EnumType),Name = tostring(value.Name)}}
	elseif typeof(value) == "Vector2" then
		return {typeof(value),{X = value.X,Y = value.Y}}
	elseif typeof(value) == "UDim2" then
		return {typeof(value),{XS = value.X.Scale,XO = value.X.Offset,YS = value.Y.Scale,YO = value.Y.Offset}}
	elseif typeof(value) == "table" then
		local tbl = {}
		for i, v in value do
			tbl[i] = RobloxDataTypeToJSON(v)
		end
		return {typeof(value),tbl}
	else
		return {typeof(value),value}
	end
end
function JSONToRobloxDataType(JSON)
	if JSON[1] == "Color3" then
		return Color3.new(JSON[2].R,JSON[2].G,JSON[2].B)
	elseif JSON[1] == "EnumItem" then
		return Enum[JSON[2].EnumType][JSON[2].Name]
	elseif JSON[1] == "Vector2" then
		return Vector2.new(JSON[2].X,JSON[2].Y)
	elseif JSON[1] == "UDim2" then
		return UDim2.new(JSON[2].XS,JSON[2].XO,JSON[2].YS,JSON[2].YO)
	elseif JSON[1] == "table" then
		local tbl = {}
		for i, v in JSON[2] do
			tbl[i] = JSONToRobloxDataType(v)
		end
		return tbl
	else
		return JSON[2]
	end
end
function UpdateFlag(flag,idx,value)
	if not flag then return end
	if not Library.Flags[flag] then
		Library.Flags[flag] = {}
	end
	Library.Flags[flag][idx] = RobloxDataTypeToJSON(value)
end
function LoadConfigurationFile(destination,callbackElements)
	local suc = pcall(function()
		if isfile(destination) then
			local Flags = HttpService:JSONDecode(readfile(destination))
			for _, v in Library.Elements do
				if v.Class == "TabElement" then
					local Flag = v.Flag
					if Flag then
						if Flags[Flag] then
							for i in v:GetProperties(false,function(p) return p.readonly == false end) do
								if Flags[Flag][i] then
									local v2 = JSONToRobloxDataType(Flags[Flag][i])
									v[i] = v2
								end
							end
							if Flags[Flag].Configs then
								for i in Flags[Flag].Configs do
									local config = v.Configs[i]
									if config then
										for i2 in config:GetProperties(false,function(p) return p.readonly == false end) do
											if Flags[Flag].Configs[i][i2] then
												local v2 = JSONToRobloxDataType(Flags[Flag].Configs[i][i2])
												config[i2] = v2
											end
										end
									end
								end
							end
						end
					end
				end
			end
			if callbackElements then
				for _, v in Library.Elements do
					if v.callbackElements and v.CallbackOnFileLoad then
						local args = {}
						if v.CurrentValue then
							args = {v.CurrentValue}
						elseif v.CurrentColor then
							args = {v.CurrentColor}
						elseif v.CurrentOption then
							args = {v.CurrentOption}
						end
						task.spawn(function()
							v:OnClick(table.unpack(args))
						end)
					end
				end
			end
		end
	end)
	if not suc then
		Library:Notify({
			Type = "warning";
			Title = "Error";
			Message = "This configuration file is corrupted.";
		})
	end
end
function Callback(f,...)
	local suc, err = pcall(f,...)
	if not suc then
		warn(err)
	end
	return suc
end
function GetColorLuminosityDependent(color,darkcolor,brightcolor)
	local _,_,v = color:ToHSV()
	return v >= 0.5 and brightcolor or darkcolor
end
function OpenColorEditor(title,callback,args)
	local options = {
		Color = Color3.new(1,1,1);
		Alpha = 1;
		RainbowMode = false;
		RainbowSpeed = 1
	}
	if args then
		for i, v in args do
			if options[i] and typeof(v) == typeof(options[i]) then
				options[i] = v
				if i == "RainbowSpeed" then
					options[i] = math.clamp(v,1,10)
				end
			end
		end
	end
	-- Variables
	local huesliderdragging = false
	local colorframedragging = false
	local renderstepped
	-- ColorPickerGUI
	local ColorPickerGUI = Objects.Window.ColorPickerGUI:Clone()
	ColorPickerGUI.Size = UDim2.new(0, 294*1.2, 0, 210*1.2)
	ColorPickerGUI.GroupTransparency = 1
	local MainWindowFrame = ColorPickerGUI.MainWindow
	local ContainerFrame = MainWindowFrame.Container
	local ColorPickerFrame = ContainerFrame.Color
	local ColorFrame = ColorPickerFrame.Color
	local SelectionCrosshairImage = ColorPickerFrame.SelectionCrosshair
	local SlidersFrame = ContainerFrame.Sliders
	local HueSliderFrame = SlidersFrame.Hue
	local HueSliderValueFrame = HueSliderFrame.HueSlider.Selector
	local AdvancedSlidersFrame = SlidersFrame.RightSection
	local RSliderFrame = AdvancedSlidersFrame.R
	local RValueTextBox = RSliderFrame.Value
	local RValueCircle = RSliderFrame.Slider.Background.Circle
	local GSliderFrame = AdvancedSlidersFrame.G
	local GValueTextBox = GSliderFrame.Value
	local GValueCircle = GSliderFrame.Slider.Background.Circle
	local BSliderFrame = AdvancedSlidersFrame.B
	local BValueTextBox = BSliderFrame.Value
	local BValueCircle = BSliderFrame.Slider.Background.Circle
	local ASliderFrame = AdvancedSlidersFrame.A
	local AValueTextBox = ASliderFrame.Value
	local AValueCircle = ASliderFrame.Slider.Background.Circle
	local TopBarFrame = MainWindowFrame.TopBar
	local TitleTextLabel = TopBarFrame.Title
	TitleTextLabel.Text = title
	local CloseButton = TopBarFrame.Close
	TweenService:Create(ColorPickerGUI,Linear35,{GroupTransparency = 0}):Play()
	TweenService:Create(ColorPickerGUI,QuadOut60,{Size = UDim2.new(0, 294, 0, 210)}):Play()
	local function Close()
		MakeDraggable(false,ColorPickerGUI)
		if renderstepped then
			renderstepped:Disconnect()
		end
		TweenService:Create(ColorPickerGUI,Linear35,{GroupTransparency = 1}):Play()
		TweenService:Create(ColorPickerGUI,QuadOut60,{Size = UDim2.new(0, 294*1.2, 0, 210*1.2)}):Play()
		task.delay(0.6,function()
			ColorPickerGUI:Destroy()
		end)
	end
	local function UpdateRGBSliderValues()
		local R,G,B,A = options.Color.R,options.Color.G,options.Color.B,options.Alpha
		RValueTextBox.Text = math.round(R*255)
		GValueTextBox.Text = math.round(G*255)
		BValueTextBox.Text = math.round(B*255)
		AValueTextBox.Text = math.round(A*255)
		RValueCircle.Position = UDim2.new(R,-6*R,0.5,0)
		GValueCircle.Position = UDim2.new(G,-6*G,0.5,0)
		BValueCircle.Position = UDim2.new(B,-6*B,0.5,0)
		AValueCircle.Position = UDim2.new(A,-6*A,0.5,0)
	end
	local function SliderFunctions(slider,minvalue,maxvalue,slidercallback)
		local SliderValue = slider.Value
		local MainSlider = slider.Slider
		local SliderBackground = MainSlider.Background
		local SliderCircle = SliderBackground.Circle
		MainSlider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local inputchanged
				local renderstepped = RS.RenderStepped:Connect(function()
					local mousepos = UIS:GetMousePosition()
					local scale = (mousepos.X - SliderBackground.AbsolutePosition.X)/SliderBackground.AbsoluteSize.X
					SliderCircle.Position = UDim2.new(scale,-6*scale,0.5,0)
					local value = math.ceil(scale*(maxvalue-minvalue))
					SliderValue.Text = value
					slidercallback(value)
				end)
				inputchanged = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						inputchanged:Disconnect()
						renderstepped:Disconnect()
					end
				end)
			end
		end)
	end
	CloseButton.MouseButton1Click:Connect(Close)
	HueSliderFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			huesliderdragging = true
			local inputchanged
			inputchanged = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					inputchanged:Disconnect()
					huesliderdragging = false
					callback(options.Color.R,options.Color.G,options.Color.B,options.Alpha)
				end
			end)
		end
	end)
	ColorFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			colorframedragging = true
			local inputchanged
			inputchanged = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					inputchanged:Disconnect()
					colorframedragging = false
					callback(options.Color.R,options.Color.G,options.Color.B,options.Alpha)
				end
			end)
		end
	end)
	renderstepped = RS.RenderStepped:Connect(function()
		local h,s,v = options.Color:ToHSV()
		local mousepos = UIS:GetMousePosition()
		if huesliderdragging then
			local scaleY = math.clamp((mousepos.Y - HueSliderFrame.AbsolutePosition.Y)/HueSliderFrame.AbsoluteSize.Y-4,0,1)
			options.Color = Color3.fromHSV(1-scaleY,s,v)
			UpdateRGBSliderValues()
		end
		if colorframedragging then
			local scaleX = math.clamp((mousepos.X - ColorFrame.AbsolutePosition.X)/ColorFrame.AbsoluteSize.X,0,1)
			local scaleY = math.clamp((mousepos.Y - ColorFrame.AbsolutePosition.Y)/ColorFrame.AbsoluteSize.Y,0,1)
			options.Color = Color3.fromHSV(h,scaleX,1-scaleY)
			UpdateRGBSliderValues()
		end
		local h2,s2,v2 = options.Color:ToHSV()
		ColorFrame.BackgroundColor3 = Color3.fromHSV(h2,1,1)
		HueSliderValueFrame.Position = UDim2.new(0.5,0,1-h2,-4*(1-h2))
		SelectionCrosshairImage.Position = UDim2.new(s2,0,1-v2,0)
		SelectionCrosshairImage.ImageColor3 = SelectionCrosshairImage.Position.Y.Scale >= 0.5 and Color3.new(0,0,0) or Color3.new(1,1,1)
	end)
	UpdateRGBSliderValues()
	MakeDraggable(true,ColorPickerGUI)
	SliderFunctions(RSliderFrame,0,255,function(R)
		options.Color = Color3.new(R/255,options.Color.G,options.Color.B)
	end)
	SliderFunctions(GSliderFrame,function(G)
		options.Color = Color3.new(options.Color.R,G/255,options.Color.B)
	end)
	SliderFunctions(BSliderFrame,function(B)
		options.Color = Color3.new(options.Color.R,options.Color.G,B/255)
	end)
	SliderFunctions(ASliderFrame,0,255,function(A)
		options.Alpha = A/255
		UpdateRGBSliderValues()
	end)

end
-- [ Library Functions ] --
function Library:Notify(notificationsettings)
	if not notificationsettings or typeof(notificationsettings) ~= "table" then return end
	-- [ Check Build ] --
	local builderror = false
	if notificationsettings.Title == nil then notificationsettings.Title = "Notification" end
	if typeof(notificationsettings.Title) ~= "string" then LibraryBuildError("Notify","Notify/Title must be a string") builderror = true end
	if notificationsettings.Message == nil then notificationsettings.Message = "Hello World!" end
	if typeof(notificationsettings.Message) ~= "string" then LibraryBuildError("Notify","Notify/Message must be a string") builderror = true end
	if notificationsettings.Icon and typeof(notificationsettings.Icon) ~= "number" then LibraryBuildError("Notify","Notify/Icon must be a number") builderror = true end
	if notificationsettings.Image and typeof(notificationsettings.Image) ~= "number" then LibraryBuildError("Notify","Notify/Image must be a number") builderror = true end
	if notificationsettings.Sound and typeof(notificationsettings.Sound) ~= "number" then LibraryBuildError("Notify","Notify/Sound must be a number") builderror = true end
	if notificationsettings.Duration == nil then notificationsettings.Duration = 5 end
	if typeof(notificationsettings.Duration) ~= "number" then LibraryBuildError("Notify","Notify/Duration must be a number") builderror = true end
	if notificationsettings.Actions == nil then notificationsettings.Actions = {} end
	if typeof(notificationsettings.Actions) ~= "table" then LibraryBuildError("Notify","Notify/Actions must be a table") builderror = true end
	for actionName, actionsettings in notificationsettings.Actions do
		if typeof(actionsettings) ~= "table" then LibraryBuildError("Notify","Notify/Actions/"..actionName.." must be a table") builderror = true end
		if actionsettings.Name == nil then actionsettings.Name = "Action" end
		if typeof(actionsettings.Name) ~= "string" then LibraryBuildError("Notify","Notify/Actions/"..actionName.."/Name must be a string") builderror = true end
		if actionsettings.CloseOnClick == nil then actionsettings.CloseOnClick = false end
		if typeof(actionsettings.CloseOnClick) ~= "boolean" then LibraryBuildError("Notify","Notify/Actions/"..actionName.."/CloseOnClick must be a boolean") builderror = true end
		if actionsettings.Callback == nil then actionsettings.Callback = function() end end
		if typeof(actionsettings.Callback) ~= "function" then LibraryBuildError("Notify","Notify/Actions/"..actionName.."/Callback must be a function") builderror = true end
	end
	if builderror then return end
	-- Variables
	local heartbeat
	local spawn = tick()
	local closing = false
	local actions = 0
	local NotificationPopup = Objects.NotificationPopup:Clone()
	NotificationPopup.Parent = NotificationGUI
	NotificationPopup.Size = notificationsettings.Image and UDim2.new(0,250,0,250) or UDim2.new(0,250,0,150)
	NotificationPopup.Position = notificationsettings.Image and UDim2.new(1,-235,1,-235) or UDim2.new(1,-235,1,-135)
	local CanvasGroup = NotificationPopup.CanvasGroup
	CanvasGroup.GroupTransparency = 1
	local DropShadow = CanvasGroup.DropShadow
	DropShadow.Size = UDim2.new(1,0,1,0)
	local MainWindow = DropShadow.MainWindow
	local MainWindow2 = DropShadow.MainWindow2
	local Image = MainWindow.Image
	Image.Image = notificationsettings.Image or "rbxassetid://0"
	local TopSection = MainWindow.TopSection
	local TopBar = TopSection.TopBar
	local Title = TopBar.Title
	Title.Text = notificationsettings.Title
	Title.Position = notificationsettings.Icon and UDim2.new(0.5,7,0.5,0) or UDim2.new(0.5,0,0.5,0)
	local Icon = TopBar.Logo
	Icon.Image = notificationsettings.Icon or "rbxassetid://0"
	Icon.Position = UDim2.new(0.5,-Title.TextBounds.X/2-8,0.5,0)
	local CloseButton = TopBar.Close
	local MessageLabel = TopSection.BottomBar.Message
	MessageLabel.TextScaled = false
	MessageLabel.TextWrapped = false
	MessageLabel.Text = notificationsettings.Message
	MessageLabel.TextScaled = MessageLabel.TextBounds.X > 540
	MessageLabel.TextWrapped = true
	local BottomBar = MainWindow.BottomBar
	local DurationTimerContainer = BottomBar.Time
	DurationTimerContainer.Visible = true
	local DurationTimer = DurationTimerContainer.Slider
	DurationTimer.Size = UDim2.new(1,0,1,0)
	local ButtonContainer = BottomBar.Container
	ButtonContainer.Position = UDim2.new(0.5,0,0,0)
	ButtonContainer.CanvasSize = UDim2.new(0,0,0,0)
	local ButtonExample = ButtonContainer.ButtonExample
	-- Functions
	local function Close()
		if closing then return end
		closing = true
		CanvasGroup.Parent = NotificationPopup
		MainWindow.Parent = DropShadow
		MainWindow.Size = UDim2.new(1,-21,1,-21)
		DropShadow.Parent = CanvasGroup
		TweenService:Create(NotificationPopup,QuadOut60,{Size = notificationsettings.Image and UDim2.new(0,250,0,250) or UDim2.new(0,250,0,150)}):Play()
		TweenService:Create(NotificationPopup,QuadOut60,{Position = UDim2.new(1,-235,1,NotificationPopup.Position.Y.Offset-15)}):Play()
		TweenService:Create(CanvasGroup,Linear35,{GroupTransparency = 1}):Play()
		if heartbeat then
			heartbeat:Disconnect()
		end
		for i, v in notifications do
			if v.I == NotificationPopup then
				notifications[i] = nil
			end
		end
		UpdateNotificationLayout()
		task.delay(0.6,function()
			NotificationPopup:Destroy()
		end)
	end
	-- Main
	if notificationsettings.Sound then
		PlaySound(notificationsettings.Sound)
	end
	for _, actionsettings in notificationsettings.Actions do
		actions += 1
		local callbackerroranimationticket = 0
		local ButtonExample = ButtonExample:Clone()
		ButtonExample.Parent = ButtonContainer
		ButtonExample.Visible = true
		local Button = ButtonExample.Button
		local ButtonGradient = Button.UIGradient
		local ButtonName = Button.ActionName
		ButtonName.Text = actionsettings.Name
		Button.MouseButton1Down:Connect(function()
			Button.BackgroundColor3 = Color3.fromRGB(230,230,230)
			ButtonGradient.Rotation = 270
		end)
		Button.MouseButton1Up:Connect(function()
			Button.BackgroundColor3 = Color3.fromRGB(255,255,255)
			ButtonGradient.Rotation = 90
		end)
		Button.MouseButton1Click:Connect(function()
			if closing then return end
			local suc = Callback(actionsettings.Callback)
			if not suc then
				task.spawn(function()
					task.wait(0.3)
					callbackerroranimationticket += 1
					local currentticket = callbackerroranimationticket
					ButtonName.Text = "Callback Error!"
					TweenService:Create(Button,Linear30,{BackgroundColor3 = Color3.fromRGB(132,50,50)}):Play()
					task.wait(0.4)
					if currentticket == callbackerroranimationticket then
						ButtonName.Text = actionsettings.Name
						TweenService:Create(Button,Linear30,{BackgroundColor3 = Color3.new(1,1,1)}):Play()
					end
				end)
			end
			if actionsettings.CloseOnClick then return Close() end
		end)
		ButtonContainer.CanvasSize = UDim2.new(0,actions*65,0,0)
	end
	if notificationsettings.Duration ~= math.huge then
		heartbeat = RS.Heartbeat:Connect(function()
			DurationTimer.Size = UDim2.new(1 - (tick() - spawn) / notificationsettings.Duration,0,1,0)
			if spawn + notificationsettings.Duration < tick() then Close() end
		end)
	else
		ButtonContainer.Position = UDim2.new(0.5,0,0,2)
		DurationTimerContainer.Visible = false
	end
	CloseButton.MouseButton1Click:Connect(Close)
	table.insert(notifications,1,{I = NotificationPopup,X = 221,Y = notificationsettings.Image and 207 or 107,sY = notificationsettings.Image and 221 or 121})
	UpdateNotificationLayout()
	-- Animations
	TweenService:Create(NotificationPopup,QuadOut60,{Size = notificationsettings.Image and UDim2.new(0,221,0,221) or UDim2.new(0,221,0,121)}):Play()
	TweenService:Create(NotificationPopup,QuadOut60,{Position = notificationsettings.Image and UDim2.new(1,-221,1,-221) or UDim2.new(1,-221,1,-121)}):Play()
	TweenService:Create(CanvasGroup,Linear35,{GroupTransparency = 0}):Play()
	task.delay(0.35,function()
		if closing then return end
		DropShadow.Parent = NotificationPopup
		MainWindow.Parent = MainWindow2
		MainWindow.Size = UDim2.new(1,0,1,0)
		CanvasGroup.Parent = nil
	end)
end
function Library:LoadConfiguration(dictionary)
	if not dictionary or typeof(dictionary) ~= "table" then return end
	-- [ Check Build ] --
	local builderror = false
	if not dictionary.CallbackElements then dictionary.CallbackElements = false end
	if typeof(dictionary.CallbackElements) ~= "boolean" then LibraryBuildError("LoadConfiguration","LoadConfiguration/CallbackElements must be a boolean") builderror = true end
	if dictionary.FileName and typeof(dictionary.FileName) ~= "string" then LibraryBuildError("LoadConfiguration","LoadConfiguration/FileName must be a string") builderror = true end
	if builderror then return end
	-- Main
	if dictionary.FileName then
		if isfile(LocalConfigurationSubFolder.."/"..dictionary.FileName..".json") then
			LoadConfigurationFile(LocalConfigurationSubFolder.."/"..dictionary.FileName..".json",dictionary.CallbackElements)
		end
	else
		local metafile = LocalConfigurationSubFolder..LocalConfigurationSubFolderName..".meta"
		if isfile(metafile) then
			pcall(function()
				local contents = HttpService:JSONDecode(readfile(metafile))
				if contents.AutoLoad and isfile(contents.AutoLoad) then
					LoadConfigurationFile(contents.AutoLoad,dictionary.CallbackElements)
				end
			end)
		else
			warn("LoadConfiguration: Failed to find metafile")
		end
	end
end
function Library:SaveConfiguration(dictionary)
	if not dictionary or typeof(dictionary) ~= "table" then return end
	-- [ Check Build ] --
	if typeof(dictionary.FileName) ~= "string" then LibraryBuildError("SaveConfiguration","SaveConfiguration/FileName is required and must be a string") return end
	if dictionary.FileName == "" then return end
	-- Main
	if not isfolder or not writefile then return end
	if LocalConfigurationSubFolder and isfolder(LocalConfigurationSubFolder) then
		local suc, err = pcall(function()
			local contents = HttpService:JSONEncode(Library.Flags)
			writefile(LocalConfigurationSubFolder.."/"..dictionary.FileName..".json",contents)
		end)
		if not suc then
			warn("SaveConfiguration: "..err)
		end
	else
		warn("SaveConfiguration: Failed to find LocalConfigurationSubFolder")
	end
end
function Library:DeleteConfiguration(dictionary)
	if not dictionary or typeof(dictionary) ~= "table" then return end
	-- [ Check Build ] --
	if typeof(dictionary.FileName) ~= "string" then LibraryBuildError("DeleteConfiguration","DeleteConfiguration/FileName is required and must be a string") return end
	if not isfolder or not delfile then return end
	if LocalConfigurationSubFolder and isfolder(LocalConfigurationSubFolder) then
		pcall(function()
			delfile(LocalConfigurationSubFolder.."/"..dictionary.FileName..".json")
		end)
	else
		warn("DeleteConfiguration: Failed to find LocalConfigurationSubFolder")
	end
end
function Library:ListConfigurationFiles(dictionary)
	if not dictionary or typeof(dictionary) ~= "table" then return end
	-- [ Check Build ] --
	if not dictionary.ShowDirectory then dictionary.ShowDirectory = false end
	if typeof(dictionary.ShowDirectory) ~= "boolean" then LibraryBuildError("ListConfigurationFiles","ListConfigurationFiles/ShowDirectory must be a boolean") return end
	-- Main
	if not isfolder or not listfiles then return {} end
	if LocalConfigurationSubFolder and isfolder(LocalConfigurationSubFolder) then
		local files = listfiles(LocalConfigurationSubFolder)
		if not dictionary.ShowDirectory then
			for i, v in files do
				local split = v:split("/")
				local filename = split[#split]:split(".json")[1]
				files[i] = filename:sub(0,#filename-5)
			end
		end
		return files
	else
		warn("ListConfigurationFiles: Failed to find LocalConfigurationSubFolder")
	end
	return {}
end
function Library:AutoLoadFileOnBoot(dictionary)
	if not dictionary or typeof(dictionary) ~= "table" then return end
	if not isfile or not readfile or not writefile then return end
	if LocalConfigurationFolder then
		if LocalConfigurationSubFolder and LocalConfigurationSubFolderName then
			if typeof(dictionary.Toggle) ~= "boolean" then LibraryBuildError("AutoLoadFileOnBoot","AutoLoadFileOnBoot/Toggle must be a boolean") return end
			local newcontent = {}
			local metafile = LocalConfigurationFolder.."/"..LocalConfigurationSubFolderName..".meta"
			if isfile(metafile) then
				local suc, filecontent = pcall(function()
					return HttpService:JSONDecode(readfile(metafile))
				end)
				if not suc then
					warn("AutoLoadFileOnBoot: The metafile is corrupted.")
					return
				end
				newcontent = filecontent
			end
			if dictionary.Toggle then
				if typeof(dictionary.FileName) ~= "string" then
					LibraryBuildError("AutoLoadFileOnBoot","AutoLoadFileOnBoot/FileName must be a string")
					return
				end
				newcontent.AutoLoad = dictionary.FileName
			else
				newcontent.AutoLoad = nil
			end
			writefile(metafile,newcontent)
		else
			warn("AutoLoadFileOnBoot: Failed to find LocalConfigurationSubFolder")
		end
	else
		warn("AutoLoadFileOnBoot: Failed to find LocalConfigurationFolder")
	end
end
function Library:ChangeTheme(dictionary)
	if not dictionary or typeof(dictionary) ~= "table" then return end
	for i, v in dictionary do
		if typeof(v) == "Color3" and Library.Themes.Colors[i] then
			Library.Themes.Colors[i] = v
		end
	end
	for i, v in Library.Themes.InfluencedInstances do
		if typeof(v) == "table" and typeof(v[1]) == "number" and typeof(v[2]) == "string" and typeof(v[3]) == "Instance" and v[3].Parent and Library.Themes.Colors[v[3].Value] and GetProperty(v[3].Parent,v[2]) then
			v[1] = math.clamp(v[1],1,2)
			Library.Themes.InfluencedInstances[i][1] = v[1]
			if not v[3]:GetAttribute("Locked") then
				local color = Library.Themes.Colors[v[3].Value]
				local darkColor = v[3]:GetAttribute("DarkColor") or Color3.new(1,1,1)
				local brightColor = v[3]:GetAttribute("BrightColor") or Color3.new(0,0,0)
				v[3].Parent[v[2]] = v[1] and GetColorLuminosityDependent(color,darkColor,brightColor) or color
			end
		else
			Library.Themes.InfluencedInstances[i] = nil
		end
	end
end
function Library:CreateWindow(windowsettings)
	if WindowLoaded or not windowsettings or typeof(windowsettings) ~= "table" then return end
	local Window = {}
	-- [ Check Build ] --
	local builderror = false
	if windowsettings.Name == nil then windowsettings.Name = "FPSLibrary Interface Suite" end
	if windowsettings.ShowBootScreen == nil then windowsettings.ShowBootScreen = false end
	if typeof(windowsettings.Name) ~= "string" then LibraryBuildError("CreateWindow","Window/Title must be a string") builderror = true end
	if typeof(windowsettings.ShowBootScreen) ~= "boolean" then LibraryBuildError("CreateWindow","Window/ShowBootScreen must be a boolean") builderror = true end
	--Configuration Saving
	if windowsettings.ConfigurationSaving then
		if typeof(windowsettings.ConfigurationSaving) ~= "table" then LibraryBuildError("CreateWindow","Window/ConfigurationSaving must be a table") builderror = true end
		if windowsettings.ConfigurationSaving.Enabled == nil then windowsettings.ConfigurationSaving.Enabled = false end
		if typeof(windowsettings.ConfigurationSaving.Enabled) ~= "boolean" then LibraryBuildError("CreateWindow","Window/ConfigurationSaving/Enabled must be a boolean") builderror = true end
		if windowsettings.ConfigurationSaving.Enabled then
			if windowsettings.ConfigurationSaving.FolderName == nil then LibraryBuildError("CreateWindow","Window/ConfigurtionSaving/FolderName is required") builderror = true end
			if typeof(windowsettings.ConfigurationSaving.FolderName) ~= "string" then LibraryBuildError("CreateWindow","Window/ConfigurationSaving/FolderName must be a string") builderror = true end
			if typeof(windowsettings.ConfigurationSaving.FolderName) == "string" and string.match(windowsettings.ConfigurationSaving.FolderName,"^%s*$") then LibraryBuildError("CreateWindow","Window/ConfigurationSaving/FolderName must not contain whitespaces") builderror = true end
			if windowsettings.ConfigurationSaving.PlaceId and typeof(windowsettings.ConfigurationSaving.PlaceId) ~= "boolean" then LibraryBuildError("CreateWindow","Window/ConfigurationSaving/PlaceId must be a boolean") builderror = true end
		end
	end
	--Interface
	if windowsettings.Interface ~= nil then
		if typeof(windowsettings.Interface) ~= "table" then LibraryBuildError("CreateWindow","Window/Interface must be a table") builderror = true end
		if windowsettings.Interface.ShowTabsOnBoot == nil then windowsettings.Interface.ShowTabsOnBoot = false end
		if typeof(windowsettings.Interface.ShowTabsOnBoot) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Interface/ShowTabsOnBoot must be a boolean") builderror = true end
		if windowsettings.Interface.ToggleGUIKeybind == nil then windowsettings.Interface.ToggleGUIKeybind = Enum.KeyCode.RightShift end
		if typeof(windowsettings.Interface.ToggleGUIKeybind) ~= "EnumItem" or windowsettings.Interface.ToggleGUIKeybind.EnumType ~= Enum.KeyCode then LibraryBuildError("CreateWindow","Window/Interface/ToggleGUIKeybind must be a Enum.KeyCode") builderror = true end
		if windowsettings.Interface.MenuButton ~= nil then
			if typeof(windowsettings.Interface.MenuButton) ~= "table" then LibraryBuildError("CreateWindow","Window/Interface/MenuButton must be a table") builderror = true end
			if windowsettings.Interface.MenuButton.Title == nil then windowsettings.Interface.MenuButton.Title = "Menu" builderror = true end
			if typeof(windowsettings.Interface.MenuButton.Title) ~= "string" then LibraryBuildError("CreateWindow","Window/Interface/MenuButton/Title must be a string") builderror = true end
			if windowsettings.Interface.MenuButton.UseIcons then
				if windowsettings.Interface.MenuButton.IconId == nil then LibraryBuildError("CreateWindow","Window/Interface/MenuButton/IconId is required") builderror = true end
				if typeof(windowsettings.Interface.MenuButton.IconId) ~= "number" then LibraryBuildError("CreateWindow","Window/Interface/MenuButton/IconId must be a number") builderror = true end
				if windowsettings.Interface.MenuButton.HoverIconId ~= nil and typeof(windowsettings.Interface.MenuButton.HoverIconId) ~= "number" then LibraryBuildError("CreateWindow","Window/Interface/MenuButton/HoverIconId must be a number") builderror = true end
			end
			if windowsettings.Interface.MenuButton.Position == nil then LibraryBuildError("CreateWindow","Window/Interface/MenuButton/Position is required") builderror = true end
			if typeof(windowsettings.Interface.MenuButton.Position) ~= "UDim2" then LibraryBuildError("CreateWindow","Window/Interface/MenuButton/Position must be a UDim2") builderror = true end
			if windowsettings.Interface.MenuButton.AnchorPoint == nil then LibraryBuildError("CreateWindow","Window/Interface/MenuButton/AnchorPoint is required") builderror = true end
			if typeof(windowsettings.Interface.MenuButton.AnchorPoint) ~= "Vector2" then LibraryBuildError("CreateWindow","Window/Interface/MenuButton/AnchorPoint must be a Vector2") builderror = true end
			if windowsettings.Interface.MenuButton.Draggable == nil then windowsettings.Interface.MenuButton.Draggable = false end 
			if typeof(windowsettings.Interface.MenuButton.Draggable) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Interface/MenuButton/Draggable must be a boolean") builderror = true end
		else
			LibraryBuildError("CreateWindow","Window/Interface/MenuButton is required")
			builderror = true
		 end
		--Key System
		if windowsettings.Interface.KeySystem then
			if typeof(windowsettings.Interface.KeySystem) ~= "table" then LibraryBuildError("CreateWindow","Window/Interface/KeySystem must be a table") builderror = true end
			if windowsettings.Interface.KeySystem.Enabled == nil then windowsettings.Interface.KeySystem.Enabled = false end
			if typeof(windowsettings.Interface.KeySystem.Enabled) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Interface/KeySystem must be a boolean") builderror = true end
			if windowsettings.Interface.KeySystem.Enabled then
				if windowsettings.Interface.KeySystem.GrabKeyFromSite == false and windowsettings.Interface.KeySystem.Keys == nil then LibraryBuildError("CreateWindow","Window/Interface/KeySystem/Keys is required") builderror = true end
				if windowsettings.Interface.KeySystem.GrabKeyFromSite == false and typeof(windowsettings.Interface.KeySystem.Keys) ~= "table" then LibraryBuildError("CreateWindow","Window/Interface/KeySystem/Keys must be a table") builderror = true end
				if windowsettings.Interface.KeySystem.CaseSensitive ~= nil and typeof(windowsettings.Interface.KeySystem.CaseSensitive) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Interface/KeySystem/CaseSensitive must be a boolean") builderror = true end
				if windowsettings.Interface.KeySystem.RememberKey == nil then windowsettings.Interface.KeySystem.RememberKey = false end
				if typeof(windowsettings.Interface.KeySystem.RememberKey) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Interface/KeySystem/Keys must be a boolean") builderror = true end
				if windowsettings.Interface.KeySystem.RememberKey then
					if windowsettings.Interface.KeySystem.FileName == nil then LibraryBuildError("CreateWindow","Window/Interface/KeySystem/FileName is required") builderror = true end
					if typeof(windowsettings.Interface.KeySystem.FileName) ~= "string" then LibraryBuildError("CreateWindow","Window/Interface/KeySystem/FileName must be a string") builderror = true end
					if windowsettings.Interface.KeySystem.KeyTimeLimit == nil then LibraryBuildError("CreateWindow","Window/Interface/KeySystem/KeyTimeLimit is required") builderror = true end
					if typeof(windowsettings.Interface.KeySystem.KeyTimeLimit) ~= "number" then LibraryBuildError("CreateWindow","Window/Interface/KeySystem/KeyTimeLimit must be a number") builderror = true end
				end
				if windowsettings.Interface.KeySystem.GrabKeyFromSite == nil then windowsettings.Interface.KeySystem.GrabKeyFromSite = false end
				if typeof(windowsettings.Interface.KeySystem.GrabKeyFromSite) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Interface/KeySystem/GrabKeyFromSite must be a boolean") builderror = true end
				if windowsettings.Interface.KeySystem.GrabKeyFromSite then
					if windowsettings.Interface.KeySystem.RedirectURL ~= nil and typeof(windowsettings.Interface.KeySystem.RedirectURL) ~= "string" then LibraryBuildError("CreateWindow","Window/Interface/KeySystem/RedirectURL must be a string") builderror = true end
					if windowsettings.Interface.KeySystem.RAWKeyURL == nil then LibraryBuildError("CreateWindow","Window/Interface/KeySystem/RAWKeyURL is required") builderror = true end
					if typeof(windowsettings.Interface.KeySystem.RAWKeyURL) ~= "string" then LibraryBuildError("CreateWindow","Window/Interface/KeySystem/RAWKeyURL must be a string") builderror = true end
					if windowsettings.Interface.KeySystem.JSONDecode == nil then windowsettings.Interface.KeySystem.JSONDecode = false end
					if typeof(windowsettings.Interface.KeySystem.JSONDecode) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Interface/KeySystem/JSONDecode must be a boolean") builderror = true end
				end
			end
		end
		--Miscellaneous
		if windowsettings.Interface.Miscellaneous ~= nil then
			if typeof(windowsettings.Interface.Miscellaneous) ~= "table" then LibraryBuildError("CreateWindow","Window/Interface/Miscellaneous must be a table") builderror = true end
			if windowsettings.Interface.Miscellaneous.AllowShortcuts == nil then windowsettings.Interface.Miscellaneous.AllowShortcuts = false end
			if typeof(windowsettings.Interface.Miscellaneous.AllowShortcuts) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Interface/Miscellaneous/AllowShortcuts must be a boolean") builderror = true end
			if windowsettings.Interface.Miscellaneous.MobileOnly == nil then windowsettings.Interface.Miscellaneous.MobileOnly = false end
			if typeof(windowsettings.Interface.Miscellaneous.MobileOnly) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Interface/Miscellaneous/MobileOnly must be a boolean") builderror = true end
			if windowsettings.Interface.Miscellaneous.BackgroundBlur == nil then windowsettings.Interface.Miscellaneous.BackgroundBlur = false end
			if typeof(windowsettings.Interface.Miscellaneous.BackgroundBlur) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Interface/Miscellaneous/BackgroundBlur must be a boolean") builderror = true end
			if windowsettings.Interface.Miscellaneous.BlurIntensity == nil then windowsettings.Interface.Miscellaneous.BlurIntensity = 16 end
			if typeof(windowsettings.Interface.Miscellaneous.BlurIntensity) ~= "number" then LibraryBuildError("CreateWindow","Window/Interface/Miscellaneous/BlurIntensity must be a number") builderror = true end
			if windowsettings.Interface.Miscellaneous.TweenBlur == nil then windowsettings.Interface.Miscellaneous.TweenBlur = true end
			if typeof(windowsettings.Interface.Miscellaneous.TweenBlur) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Interface/Miscellaneous/TweenBlur must be a boolean") builderror = true end
			if windowsettings.Interface.Miscellaneous.BlurSpeed == nil then windowsettings.Interface.Miscellaneous.BlurSpeed = 0.45 end
			if typeof(windowsettings.Interface.Miscellaneous.BlurSpeed) ~= "number" then LibraryBuildError("CreateWindow","Window/Interface/Miscellaneous/BlurSpeed must be a number") builderror = true end
			if windowsettings.Interface.Miscellaneous then
				if typeof(windowsettings.Interface.Miscellaneous.Tabs) ~= "table" then LibraryBuildError("CreateWindow","Window/Interface/Miscellaneous/Tabs must be a table") builderror = true end
				if windowsettings.Interface.Miscellaneous.Tabs.TweenFade == nil then windowsettings.Interface.Miscellaneous.Tabs.TweenFade = true end
				if typeof(windowsettings.Interface.Miscellaneous.Tabs.TweenFade) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Interface/Miscellaneous/Tabs/TweenFade must be a boolean") builderror = true end
				if windowsettings.Interface.Miscellaneous.Tabs.FadeSpeed == nil then windowsettings.Interface.Miscellaneous.Tabs.FadeSpeed = 0.35 end
				if typeof(windowsettings.Interface.Miscellaneous.Tabs.FadeSpeed) ~= "number" then LibraryBuildError("CreateWindow","Window/Interface/Miscellaneous/Tabs/FadeSpeed must be a number") builderror = true end
				if windowsettings.Interface.Miscellaneous.Tabs.TweenSize == nil then windowsettings.Interface.Miscellaneous.Tabs.TweenSize = true end
				if typeof(windowsettings.Interface.Miscellaneous.Tabs.TweenSize) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Interface/Miscellaneous/Tabs/TweenSize must be a boolean") builderror = true end
				if windowsettings.Interface.Miscellaneous.Tabs.QuadOutSpeed == nil then windowsettings.Interface.Miscellaneous.Tabs.QuadOutSpeed = 0.6 end
				if typeof(windowsettings.Interface.Miscellaneous.Tabs.QuadOutSpeed) ~= "number" then LibraryBuildError("CreateWindow","Window/Interface/Miscellaneous/Tabs/QuadOutSpeed must be a number") builderror = true end
			end
		end
	else
		LibraryBuildError("CreateWindow","Window/Interface is required") 
		builderror = true
	end
	--Discord
	if windowsettings.Discord then
		if typeof(windowsettings.Discord) ~= "table" then LibraryBuildError("CreateWindow","Window/Discord must be a table") builderror = true end
		if windowsettings.Discord.Enabled == nil then windowsettings.Discord.Enabled = false end
		if typeof(windowsettings.Discord.Enabled) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Discord/Enabled must be a boolean") builderror = true end
		if windowsettings.Discord.Enabled then
			if windowsettings.Discord.PromptBeforeBoot == nil then windowsettings.Discord.PromptBeforeBoot = false end
			if typeof(windowsettings.Discord.PromptBeforeBoot) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Discord/PromptBeforeBoot must be a boolean") builderror = true end
			if windowsettings.Discord.PromptMessage == nil then windowsettings.Discord.PromptMessage = "Join Discord?" end
			if typeof(windowsettings.Discord.PromptMessage) ~= "string" then LibraryBuildError("CreateWindow","Window/Discord/PromptMessage must be a string") builderror = true end
			if windowsettings.Discord.InviteLink == nil then LibraryBuildError("CreateWindow","Window/Discord/InviteLink is required") builderror = true end
			if typeof(windowsettings.Discord.InviteLink) ~= "string" then LibraryBuildError("CreateWindow","Window/Discord/InviteLink must be a string") builderror = true end
			if windowsettings.Discord.RememberJoins == nil then windowsettings.Discord.RememberJoins = false end
			if typeof(windowsettings.Discord.RememberJoins) ~= "boolean" then LibraryBuildError("CreateWindow","Window/Discord/RememberJoins must be a boolean") builderror = true end
		end
	end
	if builderror then return end
	-- [ Create Interface ] --
	local Interface = Objects.Interface:Clone()
	if LibraryProtectGui == true then
		protectgui(Interface)
	end
	Interface.Name = GenerateRandomString()
	Interface.Parent = CoreGui
	local InterfaceTabs = Interface.Tabs
	WindowLoaded = true
	-- [ Intialize Instances ] --
	Interface.DescendantAdded:Connect(function(child)
		if (child.ClassName == "StringValue" or child.ClassName == "ObjectValue") and string.match(child.Name,"Influence") then
			local luminosityInfluence = string.match(child.Name,"LuminosityInfluence")
			local propertyName = luminosityInfluence and string.split(child.Name,"LuminosityInfluence")[1] or string.split(child.Name,"Influence")[1]
			local property = GetProperty(child.Parent,propertyName)
			if property and typeof(property) == "Color3" then
				local darkColor = child:GetAttribute("DarkColor")
				local brightColor = child:GetAttribute("BrightColor")
				local locked = child:GetAttribute("Locked")
				if not darkColor or typeof(darkColor) ~= "Color3" then
					darkColor = Color3.new(1,1,1)
					child:SetAttribute("DarkColor",darkColor) end
				if not brightColor or typeof(brightColor) ~= "Color3" then
					brightColor = Color3.new(0,0,0)
					child:SetAttribute("BrightColor",brightColor) 
				end
				if not locked or typeof(locked) ~= "boolean" then
					locked = false
					child:SetAttribute("Locked",locked) 
				end
				if child.ClassName == "StringValue" and Library.Themes.Colors[child.Value] then
					child.Parent[propertyName] = luminosityInfluence and GetColorLuminosityDependent(Library.Themes.Colors[child.Value],darkColor,brightColor) or Library.Themes.Colors[child.Value]
					table.insert(Library.Themes.InfluencedInstances,{luminosityInfluence and 1 or 2,propertyName,child})
				elseif child.ClassName == "ObjectValue" and child.Value and child.Value.Parent and GetProperty(child.Value,"BackgroundColor3") then
					local bgcolorchanged
					bgcolorchanged = child.Value:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
						if not child.Parent then
							bgcolorchanged:Disconnect()
							return
						end
						child.Parent[propertyName] = luminosityInfluence and GetColorLuminosityDependent(child.Value.BackgroundColor3,darkColor,brightColor) or child.Value.BackgroundColor3
					end)
				end
			end
		end
	end)
	-- [ Variables ] --
	-- Tab Effects
	local BlurEffect = Instance.new("BlurEffect")
	BlurEffect.Size = 0
	local Darken = Instance.new("Frame")
	Darken.BackgroundColor3 = Color3.new(0,0,0)
	-- Variables
	local ToggleTabMenuTicket = 0
	local WindowOpen = true
	local MainMenuOpen = false
	local MenuOpen = false
	local KeyVerified = false
	local KeySystemTimeLimitExceeded = false
	local KeyInputTweenDebounce1 = false
	local KeyInputTweenDebounce2 = false
	local WindowAnimationsFinished = false
	local WindowFullyLoaded = false
	local CheckKeyDebounce = false
	local GetKeyDebounce = false
	local KeySystemVisible = true
	local InterfaceTabsVisible = false
	-- [ Key System ] --
	-- Interface
	local BootScreen = Objects.Window.BootScreen:Clone()
	BootScreen.Parent = Interface
	BootScreen.GroupTransparency = 0
	BootScreen.AnchorPoint = Vector2.new(0.5, 0.5)
	BootScreen.Position = UDim2.new(0.5, 0, 0.5, 0)
	BootScreen.Size = UDim2.new()
	local BootScreenMainWindow = BootScreen.MainWindow
	local BootScreenTitle = BootScreenMainWindow.Title
	BootScreenTitle.TextScaled = true
	BootScreenTitle.Size = UDim2.new(math.huge,0,0,20)
	BootScreenTitle.Text = windowsettings.Name
	BootScreenTitle.Size = UDim2.new(1,BootScreenTitle.TextBounds.X <= 179 and -(229-BootScreenTitle.TextBounds.X) or -30,0,20)
	BootScreenTitle.Position = UDim2.new(0.5, 0, 0.5, 0)
	BootScreenTitle.TextTransparency = 1
	local BootScreenTitleEffect1 = BootScreenTitle["1"]
	BootScreenTitleEffect1.Position = UDim2.new(1,0,0,0)
	local BootScreenTitleEffect2 = BootScreenTitle["2"]
	BootScreenTitleEffect2.Position = UDim2.new(-0.8,0,1,-1)
	local BootScreenClose = BootScreenMainWindow.Close
	local BootScreenCloseIcon = BootScreenClose.CloseIcon
	BootScreenCloseIcon.ImageTransparency = 1
	local BootScreenKeySystem = BootScreenMainWindow.KeySystem
	local BootScreenCheckKeyContainer = BootScreenKeySystem.CheckKeyContainer
	local BootScreenCheckKey = BootScreenCheckKeyContainer.CheckKey
	BootScreenCheckKey.BackgroundTransparency = 1
	BootScreenCheckKey.BackgroundColor3 = Color3.fromRGB(75,75,75) -- 255, 194, 97
	BootScreenCheckKey.Position = UDim2.new()
	BootScreenCheckKey.Interactable = false
	local BootScreenCheckKeyIcon = BootScreenCheckKey.Icon
	BootScreenCheckKeyIcon.ImageTransparency = 1
	local BootScreenThreeDots = BootScreenCheckKey.ThreeDots
	local BootScreenDot1 = BootScreenThreeDots["1"]
	local BootScreenDot2 = BootScreenThreeDots["2"]
	local BootScreenDot3 = BootScreenThreeDots["3"]
	local BootScreenCheckKeyUnderlay = BootScreenCheckKeyContainer.CheckKeyUnderlay
	BootScreenCheckKeyUnderlay.BackgroundTransparency = 1
	BootScreenCheckKeyUnderlay.BackgroundColor3 = Color3.fromRGB(48,48,48) -- 181, 136, 69
	BootScreenCheckKeyUnderlay.Position = UDim2.new(0,0,0,2)
	local BootScreenGetKey = BootScreenCheckKeyContainer.GetKey
	BootScreenGetKey.BackgroundTransparency = 1
	BootScreenGetKey.BackgroundColor3 = Color3.fromRGB(255, 137, 97)
	BootScreenGetKey.Position = UDim2.new()
	BootScreenGetKey.Visible = false
	local BootScreenGetKeyIcon = BootScreenGetKey.Icon
	BootScreenGetKeyIcon.ImageTransparency = 1
	local BootScreenGetKeyUnderlay = BootScreenCheckKeyContainer.GetKeyUnderlay
	BootScreenGetKeyUnderlay.BackgroundTransparency = 1
	BootScreenGetKeyUnderlay.BackgroundColor3 = Color3.fromRGB(181, 97, 69)
	BootScreenGetKeyUnderlay.Position = UDim2.new(0,0,0,2)
	local BootScreenKeyInputContainer = BootScreenKeySystem.KeyInputContainer
	BootScreenKeyInputContainer.BackgroundTransparency = 1
	BootScreenKeyInputContainer.Size = UDim2.new(1,-28,1,0)
	local BootScreenKeyInputStroke = BootScreenKeyInputContainer.UIStroke
	BootScreenKeyInputStroke.Transparency = 1
	local BootScreenKeyInput = BootScreenKeyInputContainer.Key
	BootScreenKeyInput.TextTransparency = 1
	-- Functions
	local function ValidateKey(key)
		local validkey = {}
		if windowsettings.Interface.KeySystem.GrabKeyFromSite then
			local suc, rawkey = pcall(function()
				return game:HttpGet(windowsettings.Interface.KeySystem.RAWKeyURL)
			end)
			if suc then
				if windowsettings.Interface.KeySystem.JSONDecode then
					local suc, decodedkey = pcall(function()
						return HttpService:JSONDecode(rawkey)
					end)
					if suc then
						validkey = decodedkey
					else
						warn("KeySystem: Failed to retrieve key from JSON. The format is incorrect.")
						return false
					end
				else
					validkey = {rawkey}
				end
			else
				warn("KeySystem: Failed to retrieve key from URL. Either the URL is incorrect or the request is invalid.")
				return false
			end
		else
			validkey = windowsettings.Interface.KeySystem.Keys
		end
		if not windowsettings.Interface.KeySystem.CaseSensitive then
			for i, v in validkey do
				validkey[i] = v:lower()
			end
		end
		return table.find(validkey,windowsettings.Interface.KeySystem.CaseSensitive and key or key:lower())
	end
	local function ToggleKeySystem(visible)
		KeySystemVisible = visible
		if visible then
			TweenService:Create(BootScreen,QuadOut60,{Size = UDim2.new(0, 250, 0, 180)}):Play()
			TweenService:Create(BootScreenTitle,QuadOut60,{Size = UDim2.new(1, -50, 0, 20)}):Play()
			TweenService:Create(BootScreen,Linear35,{GroupTransparency = 0}):Play()
		else
			TweenService:Create(BootScreen,QuadOut60,{Size = UDim2.new(0, 250*1.2, 0, 180*1.2)}):Play()
			TweenService:Create(BootScreenTitle,QuadOut60,{Size = UDim2.new(1, -50/1.2, 0, 20*1.2)}):Play()
			TweenService:Create(BootScreen,Linear35,{GroupTransparency = 1}):Play()
		end
	end
	local function ToggleTabMenu(visible)
		if not WindowFullyLoaded then return end
		InterfaceTabsVisible = visible
		ToggleTabMenuTicket += 1
		local currentTicket = ToggleTabMenuTicket
		if InterfaceTabsVisible then
			InterfaceTabs.Size = UDim2.new(1.04,0,1.04,0)
			InterfaceTabs.GroupTransparency = 1
			if windowsettings.Interface.Miscellaneous.Tabs.TweenFade then
				local Info = TweenInfo.new(windowsettings.Interface.Miscellaneous.Tabs.FadeSpeed,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
				TweenService:Create(InterfaceTabs,Info,{GroupTransparency = 0}):Play()
			else
				InterfaceTabs.GroupTransparency = 0
			end
			if windowsettings.Interface.Miscellaneous.Tabs.TweenSize then
				local Info = TweenInfo.new(windowsettings.Interface.Miscellaneous.Tabs.QuadOutSpeed,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)
				TweenService:Create(InterfaceTabs,Info,{Size = UDim2.new(1, 0, 1, 0)}):Play()
			else
				InterfaceTabs.Size = UDim2.new(1,0,1,0)
			end
			if windowsettings.Interface.Miscellaneous.BackgroundBlur then
				BlurEffect.Size = 0
				BlurEffect.Parent = Lighting
				if windowsettings.Interface.Miscellaneous.TweenBlur then
					local Info = TweenInfo.new(windowsettings.Interface.Miscellaneous.BlurSpeed,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
					TweenService:Create(BlurEffect,Info,{Size = windowsettings.Interface.Miscellaneous.BlurIntensity}):Play()
				else
					BlurEffect.Size = windowsettings.Interface.Miscellaneous.BlurIntensity
				end
			else
				BlurEffect.Parent = nil
			end
			task.delay(0.6,function()
				if currentTicket == ToggleTabMenuTicket then
					for _, v in Library.Elements do
						if v.ClassName == "Tab" then
							MakeDraggable(true,v.Instance,true)
						end
					end
				end
			end)
		else
			if windowsettings.Interface.Miscellaneous.Tabs.TweenFade then
				local Info = TweenInfo.new(windowsettings.Interface.Miscellaneous.Tabs.FadeSpeed,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
				TweenService:Create(InterfaceTabs,Info,{GroupTransparency = 1}):Play()
			else
				InterfaceTabs.GroupTransparency = 1
			end
			if windowsettings.Interface.Miscellaneous.Tabs.TweenSize then
				local Info = TweenInfo.new(windowsettings.Interface.Miscellaneous.Tabs.QuadOutSpeed,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)
				TweenService:Create(InterfaceTabs,Info,{Size = UDim2.new(1.04, 0, 1.04, 0)}):Play()
			end
			for _, v in Library.Elements do
				if v.ClassName == "Tab" then
					MakeDraggable(false,v.Instance,true)
				end
			end
			if windowsettings.Interface.Miscellaneous.BackgroundBlur then
				if windowsettings.Interface.Miscellaneous.TweenBlur then
					local Info = TweenInfo.new(windowsettings.Interface.Miscellaneous.BlurSpeed,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
					TweenService:Create(BlurEffect,Info,{Size = 0}):Play()
				else
					BlurEffect.Size = 0
				end
				task.delay(0.35,function()
					if currentTicket == ToggleTabMenuTicket then
						BlurEffect.Parent = nil
					end
				end)
			else
				BlurEffect.Parent = nil
			end
		end
	end
	local function ToggleVisibility()
		WindowOpen = not WindowOpen
		if not KeyVerified then
			ToggleKeySystem(WindowOpen)
		end
		ToggleTabMenu(WindowOpen)
	end
	local function ToggleMainMenu()
		MainMenuOpen = not MainMenuOpen
		if MainMenuOpen then
			
		end
	end
	-- Main
	if windowsettings.Interface.KeySystem then
		if windowsettings.Interface.KeySystem.Enabled then
			if windowsettings.Interface.KeySystem.RememberKey and isfile and isfile(KeyFolder.."/"..windowsettings.Interface.KeySystem.FileName) then
				local suc, contents = pcall(function()
					return HttpService:JSONDecode(readfile(KeyFolder.."/"..windowsettings.Interface.KeySystem.FileName))
				end)
				if suc and typeof(contents.Key) == "string" and typeof(contents.Spawn) == "number" then
					if contents.Spawn + windowsettings.Interface.KeySystem.KeyTimeLimit < tick() then
						KeySystemTimeLimitExceeded = true
					elseif ValidateKey(contents.Key) then
						KeyVerified = true
					end
				end
			end
		else
			KeyVerified = true
		end
	else
		KeyVerified = true
	end
	task.spawn(function()
		if not windowsettings.ShowBootScreen then
			BootScreen:Destroy()
			return
		end
		--Expand Screen
		TweenService:Create(BootScreen,QuadOut60,{Size = UDim2.new(0, 250, 0, 180)}):Play()
		task.wait(0.5)
		--Show Title
		TweenService:Create(BootScreenTitle,Linear35,{TextTransparency = 0}):Play()
		task.wait(0.25)
		--Title Animation
		TweenService:Create(BootScreenTitleEffect1,QuadInOut50,{Position = UDim2.new(-0.8,0,0,0)}):Play()
		TweenService:Create(BootScreenTitleEffect2,QuadInOut50,{Position = UDim2.new(1,0,1,-1)}):Play()
		task.wait(0.5)
		WindowAnimationsFinished = true
		--Check Key Animation
		if windowsettings.Interface.KeySystem and windowsettings.Interface.KeySystem.Enabled then
			-- Animation
			TweenService:Create(BootScreenTitle,QuadOut60,{Position = UDim2.new(0.5, 0, 0.5, -20)}):Play()
			task.wait(0.6)
			TweenService:Create(BootScreenKeyInputContainer,Linear35,{BackgroundTransparency = 0}):Play()
			TweenService:Create(BootScreenKeyInput,Linear35,{TextTransparency = 0}):Play()
			TweenService:Create(BootScreenKeyInputStroke,Linear35,{Transparency = 0}):Play()
			TweenService:Create(BootScreenCheckKey,Linear35,{BackgroundTransparency = 0}):Play()
			TweenService:Create(BootScreenCheckKeyUnderlay,Linear35,{BackgroundTransparency = 0}):Play()
			TweenService:Create(BootScreenCheckKeyIcon,Linear35,{ImageTransparency = 0}):Play()
			TweenService:Create(BootScreenCloseIcon,Linear35,{ImageTransparency = 0}):Play()
			if KeySystemTimeLimitExceeded then
				Library:Notify({
					Type = "info"; -- (Optional) types: error, info, success, (case-sensitive) delete this line or set to nil for normal notification
					Title = windowsettings.Name; -- (Required)
					Message = "KeySystem Time Limit Exceeded. Please enter in your new key provided."; -- (Required)
					Duration = 5; -- (Required)
				})
			end
			if windowsettings.Interface.KeySystem.GrabKeyFromSite and windowsettings.Interface.KeySystem.RedirectURL then
				-- Animation
				BootScreenGetKey.Visible = true
				BootScreenCheckKey.Position = UDim2.new(0,-27,0,0)
				BootScreenCheckKeyUnderlay.Position = UDim2.new(0,-27,0,2)
				BootScreenKeyInputContainer.Size = UDim2.new(1,-55,1,0)
				TweenService:Create(BootScreenGetKey,Linear35,{BackgroundTransparency = 0}):Play()
				TweenService:Create(BootScreenGetKeyUnderlay,Linear35,{BackgroundTransparency = 0}):Play()
				TweenService:Create(BootScreenGetKeyIcon,Linear35,{ImageTransparency = 0}):Play()
				-- Functions
				BootScreenGetKey.MouseButton1Down:Connect(function()
					BootScreenGetKey.Position = UDim2.new(0,0,0,2)
					BootScreenGetKeyUnderlay.Position = UDim2.new(0,0,0,0)
					BootScreenGetKey.BackgroundColor3 = Color3.fromRGB(220, 118, 84)
					BootScreenGetKeyUnderlay.BackgroundColor3 = Color3.fromRGB(151, 81, 57)
				end)
				BootScreenGetKey.MouseButton1Up:Connect(function()
					BootScreenGetKey.Position = UDim2.new(0,0,0,0)
					BootScreenGetKeyUnderlay.Position = UDim2.new(0,0,0,2)
					BootScreenGetKey.BackgroundColor3 = Color3.fromRGB(255, 137, 97)
					BootScreenGetKeyUnderlay.BackgroundColor3 = Color3.fromRGB(181, 97, 69)
				end)
				BootScreenGetKey.MouseButton1Click:Connect(function()
					if GetKeyDebounce then return end
					GetKeyDebounce = true
					if setclipboard then
						setclipboard(windowsettings.Interface.KeySystem.RedirectURL)
						TweenService:Create(BootScreenGetKeyIcon,Linear20,{ImageTransparency = 1}):Play()
						TweenService:Create(BootScreenGetKeyIcon,QuadIn20,{Size = UDim2.new(1,-25,1,-25)}):Play()
						task.wait(0.2)
						BootScreenGetKeyIcon.Image = "rbxassetid://118205021335227"
						TweenService:Create(BootScreenGetKeyIcon,Linear20,{ImageTransparency = 0}):Play()
						TweenService:Create(BootScreenGetKeyIcon,QuadOut20,{Size = UDim2.new(1,-12,1,-12)}):Play()
						task.wait(1)
						TweenService:Create(BootScreenGetKeyIcon,Linear20,{ImageTransparency = 1}):Play()
						TweenService:Create(BootScreenGetKeyIcon,QuadIn20,{Size = UDim2.new(1,-25,1,-25)}):Play()
						task.wait(0.2)
						BootScreenGetKeyIcon.Image = "rbxassetid://112538130870584"
						TweenService:Create(BootScreenGetKeyIcon,Linear20,{ImageTransparency = 0}):Play()
						TweenService:Create(BootScreenGetKeyIcon,QuadOut20,{Size = UDim2.new(1,-12,1,-12)}):Play()
						GetKeyDebounce = false
					else
						Library:Notify({
							Title = windowsettings.Name; -- (Required)
							Message = "URL: "..windowsettings.Interface.KeySystem.RedirectURL; -- (Required)
							Duration = math.huge; -- (Required)
							Actions = { -- (Optional) Delete this line or set to nil for no action buttons
								Close = {
									Name = "Close";
									CloseOnClick = true; -- Will Close Once Callback Has Finished
								};
							}
						})
					end
				end)
			end
			-- Functions
			BootScreenCheckKey.MouseButton1Down:Connect(function()
				BootScreenCheckKey.Position = windowsettings.Interface.KeySystem.GrabKeyFromSite and windowsettings.Interface.KeySystem.RedirectURL and UDim2.new(0,-27,0,2) or UDim2.new(0,0,0,2)
				BootScreenCheckKeyUnderlay.Position = windowsettings.Interface.KeySystem.GrabKeyFromSite and windowsettings.Interface.KeySystem.RedirectURL and UDim2.new(0,-27,0,0) or UDim2.new(0,0,0,0)
				BootScreenCheckKey.BackgroundColor3 = Color3.fromRGB(220, 165, 84)
				BootScreenCheckKeyUnderlay.BackgroundColor3 = Color3.fromRGB(151, 112, 57)
			end)
			BootScreenCheckKey.MouseButton1Up:Connect(function()
				BootScreenCheckKey.Position = windowsettings.Interface.KeySystem.GrabKeyFromSite and windowsettings.Interface.KeySystem.RedirectURL and UDim2.new(0,-27,0,0) or UDim2.new(0,0,0,0)
				BootScreenCheckKeyUnderlay.Position = windowsettings.Interface.KeySystem.GrabKeyFromSite and windowsettings.Interface.KeySystem.RedirectURL and UDim2.new(0,-27,0,2) or UDim2.new(0,0,0,2)
				BootScreenCheckKey.BackgroundColor3 = Color3.fromRGB(255, 194, 97)
				BootScreenCheckKeyUnderlay.BackgroundColor3 = Color3.fromRGB(181, 136, 69)
			end)
			BootScreenCheckKey.MouseButton1Click:Connect(function()
				if CheckKeyDebounce then return end
				CheckKeyDebounce = true
				-- Checking Key Animation
				BootScreenThreeDots.Visible = true
				BootScreenCheckKeyIcon.Visible = false
				BootScreenDot1.Transparency = 0.75
				BootScreenDot2.Transparency = 0.75
				BootScreenDot3.Transparency = 0.75
				local rsdebounce = false
				local renderstepped = RS.RenderStepped:Connect(function()
					if rsdebounce then return end
					rsdebounce = true
					TweenService:Create(BootScreenDot1,Linear30,{BackgroundTransparency = 0}):Play()
					task.wait(0.3)
					TweenService:Create(BootScreenDot1,Linear30,{BackgroundTransparency = 0.75}):Play()
					TweenService:Create(BootScreenDot2,Linear30,{BackgroundTransparency = 0}):Play()
					task.wait(0.3)
					TweenService:Create(BootScreenDot2,Linear30,{BackgroundTransparency = 0.75}):Play()
					TweenService:Create(BootScreenDot3,Linear30,{BackgroundTransparency = 0}):Play()
					task.wait(0.3)
					rsdebounce = false
				end)
				-- Validate Key
				local key = BootScreenKeyInput.Text
				local valid = ValidateKey(key)
				renderstepped:Disconnect()
				BootScreenThreeDots.Visible = false
				BootScreenCheckKeyIcon.Visible = true
				if valid then
					KeyVerified = true
					ToggleKeySystem(false)
					if windowsettings.Interface.KeySystem.RememberKey and writefile then
						local contents = {
							Key = key;
							Spawn = tick();
						}
						writefile(KeyFolder.."/"..windowsettings.KeySystem.FileName,HttpService:JSONEncode(contents))
					end
					task.wait(0.6)
					BootScreen:Destroy()
				else
					-- Incorrect Key Animation
					TweenService:Create(BootScreenKeyInputStroke,Linear35,{Color = Color3.fromRGB(149, 41, 41)}):Play()
					for _ = 1,4,1 do
						TweenService:Create(BootScreenKeyInputContainer,QuadInOut5,{Position = UDim2.new(0,0,0,-3)}):Play()
						task.wait(0.05)
						TweenService:Create(BootScreenKeyInputContainer,QuadInOut5,{Position = UDim2.new(0,0,0,3)}):Play()
						task.wait(0.05)
					end
					TweenService:Create(BootScreenKeyInputContainer,QuadInOut5,{Position = UDim2.new(0,0,0,0)}):Play()
					TweenService:Create(BootScreenKeyInputStroke,Linear35,{Color = Color3.fromRGB(52, 52, 52)}):Play()
				end
				CheckKeyDebounce = false
			end)
			BootScreenKeyInput:GetPropertyChangedSignal("Text"):Connect(function()
				if #BootScreenKeyInput.Text <= 0 then
					BootScreenCheckKey.Interactable = false
					if KeyInputTweenDebounce1 then return end
					KeyInputTweenDebounce2 = false
					KeyInputTweenDebounce1 = true
					TweenService:Create(BootScreenCheckKey,Linear20,{BackgroundColor3 = Color3.fromRGB(75,75,75)}):Play()
					TweenService:Create(BootScreenCheckKeyUnderlay,Linear20,{BackgroundColor3 = Color3.fromRGB(48, 48, 48)}):Play()
					task.wait(0.35)
					KeyInputTweenDebounce1 = false
				else
					BootScreenCheckKey.Interactable = true
					if KeyInputTweenDebounce2 then return end
					KeyInputTweenDebounce1 = false
					KeyInputTweenDebounce2 = true
					TweenService:Create(BootScreenCheckKey,Linear20,{BackgroundColor3 = Color3.fromRGB(255, 194, 97)}):Play()
					TweenService:Create(BootScreenCheckKeyUnderlay,Linear20,{BackgroundColor3 = Color3.fromRGB(181, 136, 69)}):Play()
					task.wait(0.35)
					KeyInputTweenDebounce2 = false
				end
			end)
			BootScreenClose.MouseButton1Click:Connect(function()
				ToggleKeySystem(false)
			end)
		else
			ToggleKeySystem(false)
			task.wait(0.6)
			BootScreen:Destroy()
		end
	end)
	-- [ Window Menu ] --
	local MenuButtonContainer = Objects.MenuButton:Clone()
	MenuButtonContainer.Parent = Interface
	local OpenMenu = MenuButtonContainer.OpenMenu
	local OpenMenuIcon = OpenMenu.Icon
	local OpenMenuName = OpenMenu.OpenMenuName
	local IconsContainer = MenuButtonContainer.IconsContainer
	local Icons = IconsContainer.Icons
	local Separator = Icons.Separator
	local ToggleWindowVisibility = Icons.Visibility
	local ToggleWindowVisibilityIcon = ToggleWindowVisibility.Icon
	local MenuSizeButtonX = 33
	local MenuSizeOpenX = 99
	if windowsettings.Interface.MenuButton.UseIcons then
		OpenMenuIcon.Visible = true
		OpenMenuName.Visible = false
		OpenMenuIcon.Image = windowsettings.Interface.MenuButton.IconId
	else
		OpenMenuIcon.Visible = false
		OpenMenuName.Visible = true
		OpenMenuName.Text = windowsettings.Interface.MenuButton.Title
		if OpenMenuName.TextBounds.X > 29 then
			MenuSizeButtonX = OpenMenuName.TextBounds.X + 4
			MenuSizeOpenX = OpenMenuName.TextBounds.X + 4 + 66
		end
	end
	MenuButtonContainer.AnchorPoint = windowsettings.Interface.MenuButton.AnchorPoint
	MenuButtonContainer.Position = windowsettings.Interface.MenuButton.Position + UDim2.new(0,0,0,InsetSize)
	MenuButtonContainer.Size = UDim2.new(0,MenuSizeButtonX,0,33)
	OpenMenu.Size = UDim2.new(0,MenuSizeButtonX,0,33)
	Separator.Size = UDim2.new(0,MenuSizeButtonX,0,33)
	Icons.Size = UDim2.new(0,MenuSizeOpenX,0,33)
	MakeDraggable(windowsettings.Interface.MenuButton.Draggable,MenuButtonContainer,false,OpenMenu)
	OpenMenu.MouseEnter:Connect(function()
		if windowsettings.Interface.MenuButton.HoverIconId then
			OpenMenuIcon.Image = windowsettings.Interface.MenuButton.HoverIconId
		end
	end)
	OpenMenu.MouseLeave:Connect(function()
		OpenMenuIcon.Image = windowsettings.Interface.MenuButton.IconId
	end)
	OpenMenu.MouseButton1Click:Connect(function()
		MenuOpen = not MenuOpen
		if MenuOpen then
			TweenService:Create(IconsContainer,QuadOut45,{Size = UDim2.new(0, MenuSizeOpenX, 0, 33)}):Play()
		else
			TweenService:Create(IconsContainer,QuadOut45,{Size = UDim2.new(0, MenuSizeButtonX, 0, 33)}):Play()
		end
	end)
	ToggleWindowVisibility.MouseButton1Click:Connect(ToggleVisibility)
	ToggleWindowVisibility.MouseEnter:Connect(function()
		if WindowOpen then
			ToggleWindowVisibilityIcon.Image = "rbxassetid://132804167961657"
		else
			ToggleWindowVisibilityIcon.Image = "rbxassetid://140443291506621"
		end
	end)
	ToggleWindowVisibility.MouseLeave:Connect(function()
		if WindowOpen then
			ToggleWindowVisibilityIcon.Image = "rbxassetid://124749705615391"
		else
			ToggleWindowVisibilityIcon.Image = "rbxassetid://129552231363108"
		end
	end)
	UIS.InputBegan:Connect(function(input, processed)
		if not processed and not CheckingForKeybind and input.KeyCode == windowsettings.Interface.ToggleGUIKeybind then
			ToggleVisibility()
		end
	end)
	-- [ Yield Until Loaded ] --
	while not KeyVerified and not WindowAnimationsFinished do task.wait() end
	WindowFullyLoaded = true
	InterfaceTabs.Visible = true
	ToggleTabMenu(windowsettings.Interface.ShowTabsOnBoot)
	-- [ Configuration Saving ] --
	if windowsettings.ConfigurationSaving and windowsettings.ConfigurationSaving.Enabled then
		if isfolder and makefolder and delfolder and isfile and readfile and writefile and listfiles and delfile then
			local FolderName = windowsettings.ConfigurationSaving.FolderName
			local SubFolderName = "Universal"
			if windowsettings.ConfigurationSaving.PlaceId then
				SubFolderName = tostring(game.PlaceId)
			end
			LocalConfigurationFolder = ConfigurationFolder.."/"..FolderName
			LocalConfigurationSubFolder = LocalConfigurationFolder.."/"..SubFolderName
			LocalConfigurationSubFolderName = SubFolderName
			if not isfolder(LocalConfigurationFolder) then
				makefolder(LocalConfigurationFolder)
			end
			if not isfolder(LocalConfigurationSubFolder) then
				makefolder(LocalConfigurationSubFolder)
			end
		else
			Library:Notify({
				Type = "warning";
				Title = windowsettings.Name;
				Message = 'Your executor does not support ConfigurationSaving. Check Console For More Info';
			})
			warn('missing file functions')
		end
	end
	-- [ Window Functions ] --
	function Window:CreateTab(tabsettings)
		local Tab = {}
		-- [ Check Build ] --
		local builderror = false
		if tabsettings.Title == nil then tabsettings.Title = "MainTab" end
		if typeof(tabsettings.Title) ~= "string" then LibraryBuildError("CreateTab","Tab Title must be a string") builderror = true end
		if tabsettings.Subtitle and typeof(tabsettings.Subtitle) ~= "string" then LibraryBuildError("CreateTab","Tab Subtitle must be a string") builderror = true end
		if tabsettings.Opened == nil then tabsettings.Opened = false end
		if typeof(tabsettings.Opened) ~= "boolean" then LibraryBuildError("CreateTab","Tab Opened must be a boolean") builderror = true end
		if tabsettings.Visible == nil then tabsettings.Visible = true end
		if typeof(tabsettings.Visible) ~= "boolean" then LibraryBuildError("CreateTab","Tab Visible must be a boolean") builderror = true end
		if tabsettings.TitleRichText == nil then tabsettings.TitleRichText = false end
		if typeof(tabsettings.TitleRichText) ~= "boolean" then LibraryBuildError("CreateTab","Tab TitleRichText must be a boolean") builderror = true end
		if tabsettings.SubtitleRichText == nil then tabsettings.SubtitleRichText = false end
		if typeof(tabsettings.SubtitleRichText) ~= "boolean" then LibraryBuildError("CreateTab","Tab SubtitleRichText must be a boolean") builderror = true end
		if tabsettings.Icon == nil then tabsettings.Icon = 0 end
		if typeof(tabsettings.Icon) ~= "number" then LibraryBuildError("CreateTab","Tab IconId must be a number") builderror = true end
		if tabsettings.SizeY == nil then tabsettings.SizeY = 250 end
		if typeof(tabsettings.SizeY) ~= "number" then LibraryBuildError("CreateTab","Tab SizeY must be a number") builderror = true end
		if tabsettings.MaxSizeY == nil then tabsettings.MaxSizeY = 250 end
		if typeof(tabsettings.MaxSizeY) ~= "number" then LibraryBuildError("CreateTab","Tab MaxSizeY must be a number") builderror = true end
		if tabsettings.ElementDependent == nil then tabsettings.ElementDependent = true end
		if typeof(tabsettings.ElementDependent) ~= "boolean" then LibraryBuildError("CreateTab","Tab ElementDependent must be a boolean") builderror = true end
		if tabsettings.Position == nil then tabsettings.Position = UDim2.new() end
		if typeof(tabsettings.Position) ~= "Vector2" then LibraryBuildError("CreateTab","Tab Position must be a Vector2") builderror = true end
		if tabsettings.Flag == "" then tabsettings.Flag = nil end
		if tabsettings.Flag and typeof(tabsettings.Flag) ~= "string" then LibraryBuildError("CreateTab","Tab Flag must be a string") builderror = true end
		if tabsettings.IgnoreList == nil then tabsettings.IgnoreList = {} end
		if typeof(tabsettings.IgnoreList) ~= "table" then LibraryBuildError("CreateTab","Tab IgnoreList must be a table") builderror = true end
		if builderror then return end
		UniqueID += 1
		-- Variables
		local LayoutOrder = 0
		-- Appearance
		local TabElement = Objects.Window.TabContainer:Clone()
		TabElement.Parent = InterfaceTabs
		local TabMain = TabElement.MainTab
		local TabTitle = TabMain.Title
		local TabSubtitle = TabMain.Subtitle
		local TabIcon = TabMain.Icon
		local TabDropdownToggle = TabMain.DropdownToggle
		local TabElementDropdown = TabElement.Dropdown
		local TabElementContainer = TabElementDropdown.Container
		-- Tab Properties
		local properties = {
			Class = "InteractiveLayout";
			ClassName = "Tab";
			IgnoreList = tabsettings.IgnoreList;
			Instance = TabElement;
			--UniqueID = UniqueID;
			Flag = tabsettings.Flag;
			Title = {
				idx = function(self,idx)
					return tabsettings.Title
				end;
				newidx = function(self,idx,value)
					tabsettings.Title = value
					TabTitle.Text = tabsettings.Title
				end;
				type = {"string"};
				readonly = false;
				savetoflags = false;
			};
			Subtitle = {
				idx = function(self,idx)
					return tabsettings.Subtitle
				end;
				newidx = function(self,idx,value)
					tabsettings.Subtitle = value
					if value == nil or value == "" then
						TabTitle.Position = UDim2.new(0.5,2,0,7)
						TabSubtitle.Text = ""
					else
						TabTitle.Position = UDim2.new(0.5,2,0,4)
						TabSubtitle.Text = value
					end
				end;
				type = {"string","nil"};
				readonly = false;
				savetoflags = false;
			};
			TitleRichText = {
				idx = function(self,idx)
					return tabsettings.TitleRichText
				end;
				newidx = function(self,idx,value)
					tabsettings.TitleRichText = value
					TabTitle.RichText = tabsettings.TitleRichText
				end;
				type = {"boolean"};
				readonly = false;
				savetoflags = false;
			};
			SubtitleRichText = {
				idx = function(self,idx)
					return tabsettings.SubtitleRichText
				end;
				newidx = function(self,idx,value)
					tabsettings.SubtitleRichText = value
					TabSubtitle.RichText = tabsettings.SubtitleRichText
				end;
				type = {"boolean"};
				readonly = false;
				savetoflags = false;
			};
			Opened = {
				idx = function(self,idx)
					return tabsettings.Opened
				end;
				newidx = function(self,idx,value)
					tabsettings.Opened = value
					if tabsettings.Opened then
						TweenService:Create(TabElement,QuadOut60,{Size = UDim2.new(0, 132, 0, Tab.SizeY+40)}):Play()
						TweenService:Create(TabElementDropdown,QuadOut60,{Size = UDim2.new(0, 120, 0, Tab.SizeY+14)}):Play()
						TweenService:Create(TabDropdownToggle,Linear35,{Rotation = 180}):Play()
					else
						TweenService:Create(TabElement,QuadOut60,{Size = UDim2.new(0, 132, 0, 40)}):Play()
						TweenService:Create(TabElementDropdown,QuadOut60,{Size = UDim2.new(0, 120, 0, 14)}):Play()
						TweenService:Create(TabDropdownToggle,Linear35,{Rotation = 0}):Play()
					end
				end;
				type = {"boolean"};
				readonly = false;
				savetoflags = true;
			};
			Visible = {
				idx = function(self,idx)
					return tabsettings.Visible
				end;
				newidx = function(self,idx,value)
					tabsettings.Visible = value
					TabElement.Visible = tabsettings.Visible
				end;
				type = {"boolean"};
				readonly = false;
				savetoflags = true;
			};
			Icon = {
				idx = function(self,idx)
					return tabsettings.Icon
				end;
				newidx = function(self,idx,value)
					tabsettings.Icon = value
					if tabsettings.Icon then
						TabIcon.Image = "rbxassetid://"..tabsettings.Icon
						TabTitle.Position = UDim2.new(0.5,2,0,7)
						TabTitle.Size = UDim2.new(1,-49,0,14)
						TabSubtitle.Position = UDim2.new(0.5,2,0,15)
						TabSubtitle.Size = UDim2.new(1,-49,0,10)
					else
						TabIcon.Image = "rbxassetid://0"
						TabTitle.Position = UDim2.new(0.5,-8,0,7)
						TabTitle.Size = UDim2.new(1,-30,0,14)
						TabSubtitle.Position = UDim2.new(0.5,-8,0,15)
						TabSubtitle.Size = UDim2.new(1,-30,0,10)
					end
				end;
				type = {"number","nil"};
				readonly = false;
				savetoflags = false;
			};
			SizeY = {
				idx = function(self,idx)
					return tabsettings.SizeY
				end;
				newidx = function(self,idx,value)
					tabsettings.SizeY = math.clamp(value,0,Tab.MaxSizeY)
					if Tab.Opened then
						TabElementDropdown.Size = UDim2.new(0, 120, 0, tabsettings.SizeY+14)
					end
				end;
				type = {"number"};
				readonly = false;
				savetoflags = false;
			};
			MaxSizeY = {
				idx = function(self,idx)
					return tabsettings.MaxSizeY
				end;
				newidx = function(self,idx,value)
					tabsettings.MaxSizeY = value
					Tab.SizeY = math.clamp(value,0,tabsettings.MaxSizeY)
				end;
				type = {"number"};
				readonly = false;
				savetoflags = false;
			};
			ElementDependent = {
				idx = function(self,idx)
					return tabsettings.ElementDependent
				end;
				newidx = function(self,idx,value)
					tabsettings.ElementDependent = value
					if tabsettings.ElementDependent then
						local count = 0
						for i, v in TabElementContainer:GetChildren() do
							if v.Name == "Section" then
								count += 28
							end
						end
						Tab.SizeY = count
					end
				end;
				type = {"boolean"};
				readonly = false;
				savetoflags = false;
			};
			Position = {
				idx = function(self,idx)
					return tabsettings.Position
				end;
				newidx = function(self,idx,value)
					tabsettings.Position = value
					TabElement.Position = UDim2.new(tabsettings.Position.X/InterfaceTabs.AbsoluteSize.X,0,(tabsettings.Position.Y + InsetSize)/InterfaceTabs.AbsoluteSize.Y,0)
				end;
				type = {"Vector2"};
				readonly = false;
				savetoflags = true;
			};
		}
		-- Tab Functions
		function Tab:GetProperties(...)
			return GetProperties(properties,Tab,...)
		end
		function Tab:CreateTabSection(tabsectionsettings)

		end
		function Tab:CreateTabButton(tabbuttonsettings)

		end
		function Tab:CreateTabToggle(tabtogglesttings)
			local Toggle = {}
			-- [ Check Build ] --
			local builderror = false
			if tabtogglesttings.Name == nil then tabtogglesttings.Name = "Toggle" end
			if typeof(tabtogglesttings.Name) ~= "string" then LibraryBuildError("CreateTabToggle","TabToggle Name must be a string") builderror = true end
			if tabtogglesttings.RichText == nil then tabtogglesttings.RichText = false end
			if typeof(tabtogglesttings.RichText) ~= "boolean" then LibraryBuildError("CreateTabToggle","TabToggle RichText must be a boolean") builderror = true end
			if tabtogglesttings.Opened == nil then tabtogglesttings.Opened = false end
			if typeof(tabtogglesttings.Opened) ~= "boolean" then LibraryBuildError("CreateTabToggle","TabToggle Opened must be a boolean") builderror = true end
			tabtogglesttings.SizeY = 0
			if typeof(tabtogglesttings.SizeY) ~= "number" then LibraryBuildError("CreateTabToggle","TabToggle SizeY must be a number") builderror = true end
			if tabtogglesttings.EnableKeybinds == nil then tabtogglesttings.EnableKeybinds = false end
			if typeof(tabtogglesttings.EnableKeybinds) ~= "boolean" then LibraryBuildError("CreateTabToggle","TabToggle EnableKeybinds must be a boolean") builderror = true end
			if tabtogglesttings.CurrentKeybind and typeof(tabtogglesttings.CurrentKeybind) ~= "EnumItem" or tabtogglesttings.CurrentKeybind.EnumType ~= Enum.KeyCode then LibraryBuildError("CreateTabToggle","TabToggle CurrentKeybind must be a Enum.KeyCode") builderror = true end
			if tabtogglesttings.CurrentValue == nil then tabtogglesttings.CurrentValue = false end
			if typeof(tabtogglesttings.CurrentValue) ~= "boolean" then LibraryBuildError("CreateTabToggle","TabToggle CurrentValue must be a boolean") builderror = true end
			if tabtogglesttings.ActivatedColor == nil then tabtogglesttings.ActivatedColor = Color3.fromRGB(255, 223, 96) end
			if typeof(tabtogglesttings.ActivatedColor) ~= "Color3" then LibraryBuildError("CreateTabToggle","TabToggle ActivatedColor must be a Color3") builderror = true end
			if tabtogglesttings.Callback == nil then tabtogglesttings.Callback = function() end end
			if typeof(tabtogglesttings.Callback) ~= "function" then LibraryBuildError("CreateTabToggle","TabToggle Callback must be a function") builderror = true end
			if tabtogglesttings.CallbackOnFileLoad == nil then tabtogglesttings.CallbackOnFileLoad = true end
			if typeof(tabtogglesttings.CallbackOnFileLoad) ~= "boolean" then LibraryBuildError("CreateTabToggle","TabToggle CallbackOnFileLoad must be a boolean") builderror = true end
			if tabtogglesttings.Flag == "" then tabtogglesttings.Flag = nil end
			if tabtogglesttings.Flag and typeof(tabtogglesttings.Flag) ~= "string" then LibraryBuildError("CreateTabToggle","TabToggle Flag must be a string") builderror = true end
			if tabtogglesttings.IgnoreList == nil then tabtogglesttings.IgnoreList = {} end
			if typeof(tabtogglesttings.IgnoreList) ~= "table" then LibraryBuildError("CreateTabToggle","TabToggle IgnoreList must be a table") builderror = true end
			if builderror then return end
			UniqueID += 1
			-- Variables
			local CurrentLayoutOrder
			local callbackerroranimationticket = 0
			local ColorChangeTween
			local ConfigsFlag = {}
			local Configs = {}
			-- Appearance
			local TabToggleElement = Objects.Elements.Section:Clone()
			TabToggleElement.Parent = TabElementContainer
			local TabToggleSeparator = Objects.Elements.SectionSeparator:Clone()
			TabToggleSeparator.Parent = TabElementContainer
			local TabToggleName = TabToggleElement.ElementName
			TabToggleName.Size = UDim2.new(1,-31,1,-14)
			TabToggleName.Position = UDim2.new(0,9,0.5,0)
			local TabToggleKeybindButton = TabToggleElement.KeybindButton
			local TabToggleCurrentKeybind = TabToggleElement.CurrentKeybind
			local TabToggleDropdownIcon = TabToggleElement.DropdownIcon
			local TabToggleKeybindIcon = TabToggleElement.KeybindIcon
			TabToggleKeybindIcon.Visible = tabtogglesttings.EnableKeybinds
			local TabToggleIcon = TabToggleElement.Icon
			TabToggleIcon.Visible = false
			local TabToggleElementsContainer = TabToggleElement.Container
			local TabToggleDropdownToggle = TabToggleElement.DropdownButton
			-- Functions
			local function ChangeOverlayColors()
				local color = Toggle.CurrentValue and Toggle.ActivatedColor or Library.Themes.Colors.PrimaryColor
				local _,_,v = color:ToHSV()
				if v >= 0.5 then
					TabToggleName.TextColor3 = Color3.new(0,0,0)
					TabToggleCurrentKeybind.TextColor3 = Color3.new(0,0,0)
					TabToggleKeybindIcon.ImageColor3 = Color3.new(0,0,0)
					TabToggleDropdownIcon.ImageColor3 = Color3.new(0,0,0)
					TabToggleIcon.ImageColor3 = Color3.new(0,0,0)
				else
					TabToggleName.TextColor3 = Color3.new(1,1,1)
					TabToggleCurrentKeybind.TextColor3 = Color3.new(1,1,1)
					TabToggleKeybindIcon.ImageColor3 = Color3.new(1,1,1)
					TabToggleDropdownIcon.ImageColor3 = Color3.new(1,1,1)
					TabToggleIcon.ImageColor3 = Color3.new(1,1,1)
				end
			end
			function Toggle:OnClick(...)
				local suc = Callback(tabtogglesttings.Callback,...)
				if not suc then
					task.spawn(function()
						task.wait(0.3)
						callbackerroranimationticket += 1
						local currentticket = callbackerroranimationticket
						TabToggleName.Text = "Callback Error!"
						TweenService:Create(TabToggleElement,Linear30,{BackgroundColor3 = Color3.fromRGB(132,50,50)}):Play()
						task.wait(0.4)
						if currentticket == callbackerroranimationticket then
							TabToggleName.Text = Toggle.Name
							if Toggle.CurrentValue then
								TweenService:Create(TabToggleElement,Linear30,{BackgroundColor3 = Toggle.ActivatedColor}):Play()
							else
								TweenService:Create(TabToggleElement,Linear30,{BackgroundColor3 = Library.Themes.Colors.PrimaryColor}):Play()
							end
						end
					end)
				end
				return suc
			end
			function Toggle:UpdateColors()
				TabToggleElement.BackgroundColor3 = Toggle.CurrentValue and Toggle.ActivatedColor or Library.Themes.Colors.PrimaryColor
				--ChangeOverlayColors()
			end
			-- Properties
			local properties = {
				Class = "TabElement";
				ClassName = "TabToggle";
				IgnoreList = tabtogglesttings.IgnoreList;
				Instance = TabToggleElement;
				--UniqueID = UniqueID;
				Flag = tabtogglesttings.Flag;
				Name = {
					idx = function(self,idx)
						return tabtogglesttings.Name
					end;
					newidx = function(self,idx,value)
						tabtogglesttings.Name = value
						TabToggleName.Text = tabtogglesttings.Name
					end;
					type = {"string"};
					readonly = false;
					savetoflags = false;
				};
				RichText = {
					idx = function(self,idx)
						return tabtogglesttings.RichText
					end;
					newidx = function(self,idx,value)
						tabtogglesttings.RichText = value
						TabToggleName.RichText = tabtogglesttings.RichText
					end;
					type = {"boolean"};
					readonly = false;
					savetoflags = false;
				};
				Opened = {
					idx = function(self,idx)
						return tabtogglesttings.Opened
					end;
					newidx = function(self,idx,value)
						if value == tabtogglesttings.Opened then return end
						tabtogglesttings.Opened = value
						if tabtogglesttings.Opened then
							TweenService:Create(TabToggleSeparator,QuadOut40,{Size = UDim2.new(0, 120, 0, Toggle.SizeY)}):Play()
							TweenService:Create(TabToggleElementsContainer,QuadOut40,{Size = UDim2.new(1, 0, 0, Toggle.SizeY)}):Play()
							TabElementContainer.CanvasSize += UDim2.new(0, 0, 0, Toggle.SizeY)
						else
							TweenService:Create(TabToggleSeparator,QuadOut40,{Size = UDim2.new(0, 120, 0, 0)}):Play()
							TweenService:Create(TabToggleElementsContainer,QuadOut40,{Size = UDim2.new(1, 0, 0, 0)}):Play()
							TabElementContainer.CanvasSize -= UDim2.new(0, 0, 0, Toggle.SizeY)
						end
					end;
					type = {"boolean"};
					readonly = false;
					savetoflags = true;
				};
				SizeY = {
					idx = function(self,idx)
						return tabtogglesttings.SizeY
					end;
					newidx = function(self,idx,value)
						tabtogglesttings.SizeY = value
						TabToggleElementsContainer.CanvasSize = UDim2.new(0, 120, 0, tabtogglesttings.SizeY)
					end;
					type = {"number"};
					readonly = false;
					savetoflags = false;
				};
				EnableKeybinds = {
					idx = function(self,idx)
						return tabtogglesttings.EnableKeybinds
					end;
					newidx = function(self,idx,value)
						tabtogglesttings.EnableKeybinds = value
						TabToggleName.Size = tabtogglesttings.EnableKeybinds and (Toggle.CurrentKeybind and UDim2.new(1,-61,1,-14) or UDim2.new(1,-42,1,-14)) or UDim2.new(1,-31,1,-14)
						TabToggleCurrentKeybind.Visible = tabtogglesttings.EnableKeybinds and Toggle.CurrentKeybind
						TabToggleCurrentKeybind.Text = tabtogglesttings.EnableKeybinds and Toggle.CurrentKeybind and Toggle.CurrentKeybind.Name or ""
						TabToggleKeybindIcon.Visible = not CheckingForKeybind and tabtogglesttings.EnableKeybinds and not Toggle.CurrentKeybind
						TabToggleKeybindButton.Visible = tabtogglesttings.EnableKeybinds
					end;
					type = {"boolean"};
					readonly = false;
					savetoflags = false;
				};
				CurrentKeybind = {
					idx = function(self,idx)
						return tabtogglesttings.CurrentKeybind
					end;
					newidx = function(self,idx,value)
						tabtogglesttings.CurrentKeybind = value
						TabToggleName.Size = Toggle.EnableKeybinds and (tabtogglesttings.CurrentKeybind and UDim2.new(1,-61,1,-14) or UDim2.new(1,-42,1,-14)) or UDim2.new(1,-31,1,-14)
						TabToggleCurrentKeybind.Visible = Toggle.EnableKeybinds and tabtogglesttings.CurrentKeybind
						TabToggleCurrentKeybind.Text = Toggle.EnableKeybinds and tabtogglesttings.CurrentKeybind and tabtogglesttings.CurrentKeybind.Name or ""
						TabToggleKeybindIcon.Visible = not CheckingForKeybind and Toggle.EnableKeybinds and not tabtogglesttings.CurrentKeybind
						TabToggleKeybindButton.Visible = tabtogglesttings.EnableKeybinds
					end;
					type = {"EnumItem","nil"};
					enumtype = Enum.KeyCode;
					readonly = false;
					savetoflags = true;
				};
				CurrentValue = {
					idx = function(self,idx)
						return tabtogglesttings.CurrentValue
					end;
					newidx = function(self,idx,value)
						TabToggleElement:SetAttribute("Locked",value)
						tabtogglesttings.CurrentValue = value
						ColorChangeTween = TweenService:Create(TabToggleElement,Linear30,{BackgroundColor3 = tabtogglesttings.CurrentValue and Toggle.ActivatedColor or Library.Themes.Colors.PrimaryColor})
						ColorChangeTween:Play()
						--task.delay(0.15,function()
							--ChangeOverlayColors()
						--end)
					end;
					type = {"boolean"};
					readonly = false;
					savetoflags = true;
				};
				ActivatedColor = {
					idx = function(self,idx)
						return tabtogglesttings.ActivatedColor
					end;
					newidx = function(self,idx,value)
						tabtogglesttings.ActivatedColor = value
						if Toggle.CurrentValue then
							if ColorChangeTween then ColorChangeTween:Cancel() end
							TabToggleElement.BackgroundColor3 = tabtogglesttings.ActivatedColor
							--ChangeOverlayColors()
						end
					end;
					type = {"Color3","nil"};
					readonly = false;
					savetoflags = false;
				};
				Callback = {
					idx = function(self,idx)
						return tabtogglesttings.Callback
					end;
					newidx = function(self,idx,value)
						tabtogglesttings.Callback = value
					end;
					type = {"function"};
					readonly = false;
					savetoflags = false;
				};
				Configs = {
					idx = function(self,idx)
						local configs = {}
						local mt = {}
						mt.__index = function(self,idx)
							return Configs[idx]
						end
						mt.__newindex = function(self,idx,value)
							Configs[idx] = value
							ConfigsFlag[idx] = value:GetProperties(false,function(p) return p.savetoflags == true end)
							UpdateFlag(tabtogglesttings.Flag,"Configs",ConfigsFlag)
							Toggle.SizeY += 14
						end
						setmetatable(configs,mt)
						return configs
					end;
					newidx = function(self,idx,value)
					end;
					type = {"table"};
					readonly = true;
					savetoflags = false;
				};
			}
			-- Tab Toggle Functions
			local module = CreateTabSectionModules(Toggle)
			for i, v in module do
				Toggle[i] = v
			end
			function Toggle:GetProperties(...)
				return GetProperties(properties,Toggle,...)
			end
			-- Metatable
			local mt = CreateMetaTable(properties)
			setmetatable(Toggle,mt)
			-- TabToggle Main
			TabToggleDropdownToggle.MouseButton1Click:Connect(function()
				Toggle.Opened = not Toggle.Opened
			end)
			TabToggleElement.MouseButton1Click:Connect(function()
				Toggle.CurrentValue = not Toggle.CurrentValue
				Toggle:OnClick(Toggle.CurrentValue)
			end)
			TabToggleKeybindButton.MouseButton1Click:Connect(function()
				if not Toggle.EnableKeybinds or CheckingForKeybind then return end
				if windowsettings.Interface.Miscellaneous.AllowShortcuts and not UIS.KeyboardEnabled and (not windowsettings.Interface.Miscellaneous.MobileOnly or IsMobile) then
					
				else
					CheckingForKeybind = true
					TabToggleKeybindIcon.Visible = false
					TabToggleCurrentKeybind.Visible = true
					local spawn1 = 0
					local dots = 0
					local heartbeat
					local inputbegan
					local mousedown
					local function Disconnect()
						inputbegan:Disconnect()
						heartbeat:Disconnect()
						mousedown:Disconnect()
						task.wait()
						CheckingForKeybind = false
					end
					heartbeat = RS.Heartbeat:Connect(function()
						if spawn1 + 1/3 < tick() then
							dots += 1
							if dots > 3 then
								dots = 1
							end
							TabToggleCurrentKeybind.Text = string.rep(".",dots)
							spawn1 = tick()
						end
					end)
					inputbegan = UIS.InputBegan:Connect(function(input, processed)
						if not processed and input.KeyCode ~= Enum.KeyCode.Unknown then
							Disconnect()
							Toggle.CurrentKeybind = input.KeyCode
						end
					end)
					mousedown = Mouse.Button1Down:Connect(function()
						if not isHoveringOverObj(TabToggleElement) then
							Disconnect()
							Toggle.CurrentKeybind = nil
						end
					end)
				end
			end)
			UIS.InputBegan:Connect(function(input, processed)
				if not processed and not CheckingForKeybind and Toggle.EnableKeybinds and input.KeyCode == Toggle.CurrentKeybind then
					Toggle.CurrentValue = not Toggle.CurrentValue
					Toggle:OnClick(Toggle.CurrentValue)
				end
			end)
			-- Change Tab CanvasSize
			TabElementContainer.CanvasSize += UDim2.new(0, 0, 0, 28)
			-- Change Layout Order
			LayoutOrder += 1
			CurrentLayoutOrder = LayoutOrder
			TabToggleElement.LayoutOrder = CurrentLayoutOrder * 2 - 1
			TabToggleSeparator.LayoutOrder = CurrentLayoutOrder * 2
			-- Set Configs
			for i, v in Toggle:GetProperties(false,function(p) return p.readonly == false end) do
				Toggle[i] = tabtogglesttings[i]
			end
			-- Add To Elements
			table.insert(Library.Elements,Toggle)
			return Toggle
		end
		-- Metatable
		local mt = CreateMetaTable(properties)
		setmetatable(Tab,mt)
		-- Tab Main
		MakeDraggable(true,TabElement,true)
		TabDropdownToggle.MouseButton1Click:Connect(function()
			Tab.Opened = not Tab.Opened
		end)
		-- Set Configs
		for i, v in Tab:GetProperties(false,function(p) return p.readonly == false end) do
			Tab[i] = tabsettings[i]
		end
		-- Add To Elements
		table.insert(Library.Elements,Tab)
		return Tab
	end
	return Window
end
-- [ GetObjects ] --
Objects = IsStudio and ReplicatedStorage:FindFirstChild("Main") or game:GetObjects("rbxassetid://94310517022580")[1]
-- [ Check Studio ] --
if IsStudio then
	writefile = function(path,contents)
		if typeof(path) ~= "string" or typeof(contents) ~= "string" then error("") end
		local pathSplit = path:split("/")
		local fileName = pathSplit[#pathSplit]
		if string.match(fileName,"^%s*$") then error("") end
		local reversePath = path:reverse()
		local lastSlash = reversePath:find("/")
		local directory = lastSlash and reversePath:sub(lastSlash+1,#reversePath):reverse()
		local folder = SandboxFindFolder(directory)
		if folder then
			folder[fileName] = contents
		end
	end
	readfile = function() end
	delfile = function() end
	isfile = function() end
	isfolder = function() end
	makefolder = function(path)
		
	end
	delfolder = function() end
	listfiles = function() end
	keypress = function() end
	keyrelease = function() end
	protectgui = function() end
	request = function() end
end
-- [ Create Notification GUI ] --
NotificationGUI = Objects.NotificationGUI:Clone()
if LibraryProtectGui == true then
	if not protectgui then
		RobloxNotification("Error","Failed to Load Library, Your executor is unsupported. Missing function 'protectgui'")
		return warn("missing function 'protectgui'")
	end
	protectgui(NotificationGUI)
end
NotificationGUI.Name = GenerateRandomString()
NotificationGUI.Parent = CoreGui
-- [ Set InsetSize Variable ] --
local InterfaceNoInset = Instance.new("ScreenGui", PlayerGui)
InsetSize = Camera.ViewportSize.Y - InterfaceNoInset.AbsoluteSize.Y
InterfaceNoInset:Destroy()
-- [ Create Library Folders ] --
if isfolder then
	if not isfolder(LibraryFolder) then
		makefolder(LibraryFolder)
	end
	if not isfolder(KeyFolder) then
		makefolder(KeyFolder)
	end
end
if isfile and writefile then
	if not isfile(DiscordInvitesFile) then
		writefile(DiscordInvitesFile,"[]")
	end
end
return Library
