-- Exploit Variables
local cloneref = cloneref or function(o) return o end
local protectgui = protectgui or syn and syn.protect_gui or function() end
local request = request or http_request or syn and syn.request or http and http.request or fluxus and fluxus.request
local setclipboard = setclipboard or toclipboard or set_clipboard or syn and syn.write_clipboard or Clipboard and Clipboard.set
local encrypt = syn and syn.crypt and syn.crypt.encrypt or crypt and crypt.encrypt
local decrypt = syn and syn.crypt and syn.crypt.decrypt or crypt and crypt.decrypt
-- Services
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TweenService = cloneref(game:GetService("TweenService"))
local Players = cloneref(game:GetService("Players"))
-- Variables
repeat task.wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()
local IsStudio = RunService:IsStudio()
local ToggleGUIKeybind = Enum.KeyCode.RightShift
local KeySystemContainer
local KeyVerified = false
local connections = {}
local a = 0
local Notifications = {}
local WindowVisible = false
local executespawn = tick()
local Icons = {
	ButtonIcon = "rbxassetid://81603729114653";
	ToggleIcon = "rbxassetid://99237563194670";
	SliderIcon = "rbxassetid://79793934273507";
	DropdownIcon = "rbxassetid://109783026993824";
	ColorPalleteIcon = "rbxassetid://130634872600990";
	KeybindIcon = "rbxassetid://133055602281232";
	DisabledElementIcon = "rbxassetid://5248916036";
	ErrorIcon = "rbxassetid://102649569795605";
	InfoIcon = "rbxassetid://76316461447556";
	SuccessIcon = "rbxassetid://111469034555385";
	ColorBackgrundIcon = "rbxassetid://132069784511686";
	PreviewImage = "rbxassetid://132267442786910";
	ValueSliderIcon = "rbxassetid://124175884994313";
	ExampleImageIcon = "rbxassetid://111469034555385";
}
local FPSLibrary = {
	Flags = {};
	Elements = {};
	Icons = Icons
}
if IsStudio then
	writefile = function() end
	readfile = function() end
	delfile = function() end
	isfile = function() end
	isfolder = function() end
	makefolder = function() end
	listfiles = function() end
	keypress = function() end
	keyrelease = function() end
end
-- Configuration File
local FPSLibraryFolder = "FPSLibrary"
local ConfigurationFolderName = FPSLibraryFolder.."/Configurations"
local KeyFolderName = FPSLibraryFolder.."/Keys"
local DiscordInvitesFileName = FPSLibraryFolder.."/Discord"
local LocalConfigurationFolderName = nil
local LocalConfigurationSubFolderName = nil
-- Library Interface
local FPSLibraryAssets = IsStudio and game or game:GetObjects("rbxassetid://85069246672248")[1]
local Interface = FPSLibraryAssets:WaitForChild("Interface"):Clone()
if protectgui and FPSLibraryProtectGui == true then
	protectgui(Interface)
end
Interface.Parent = CoreGui
-- Tweens
local Tween32Linear = TweenInfo.new(0.32,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
local TweenIn75Sine = TweenInfo.new(0.75,Enum.EasingStyle.Sine,Enum.EasingDirection.In,0,false,0)
local TweenOut32Sine = TweenInfo.new(0.32,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)
local TweenOut20Sine = TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)
local TweenOut50Sine = TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)
local TweenOut75Sine = TweenInfo.new(0.75,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)
-- Functions
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
function PlaySound(id)
	local sound = Instance.new("Sound", workspace)
	sound.SoundId = "rbxassetid://"..tostring(id)
	sound.PlayOnRemove = true
	sound:Destroy()
end
function UpdateNotificationLayout()
	local yoffset = 0
	for i, v in Notifications do
		yoffset += v.Size.Y.Offset
		local tween = TweenService:Create(v,TweenOut75Sine,{Position = UDim2.new(1,-(v.Size.X.Offset + 20),1,-yoffset-20)})
		tween:Play()
	end
end
function MakeDraggable(draggable,Frame)
	for _, v in connections do
		if typeof(v) == "table" and v[1] == "Drag" and v[2] == Frame then
			v[3]:Disconnect()
			v[4]:Disconnect()
		end
	end
	if draggable == true then
		a += 1
		local b = a
		local dragging
		local startpos
		local lastmousepos
		local lastgoalpos
		local function Lerp(a, b, m)
			return a + (b - a) * m
		end
		connections[b] = {"Drag",Frame,
			Frame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					startpos = Frame.Position
					lastmousepos = UserInputService:GetMouseLocation()
					local inputchanged
					inputchanged = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
							inputchanged:Disconnect()
						end
					end)
				end
			end),
			RunService.RenderStepped:Connect(function(dt)
				if not Frame.Parent then
					connections[b][3]:Disconnect()
					connections[b][4]:Disconnect()
				end
				if not startpos then return end;
				if not dragging and lastgoalpos then
					Frame.Position = UDim2.new(startpos.X.Scale, Lerp(Frame.Position.X.Offset, lastgoalpos.X.Offset, dt * 8), startpos.Y.Scale, Lerp(Frame.Position.Y.Offset, lastgoalpos.Y.Offset, dt * 8))
					return 
				end
				local delta = lastmousepos - UserInputService:GetMouseLocation()
				local xGoal = startpos.X.Offset - delta.X
				local yGoal = startpos.Y.Offset - delta.Y
				lastgoalpos = UDim2.new(startpos.X.Scale, xGoal, startpos.Y.Scale, yGoal)
				Frame.Position = UDim2.new(startpos.X.Scale, Lerp(Frame.Position.X.Offset, xGoal, dt * 8), startpos.Y.Scale, Lerp(Frame.Position.Y.Offset, yGoal, dt * 8))
			end)
		}
	end
end
function CallbackErrorMessage(err)
	FPSLibrary:Notify({
		Type = "error";
		Title = "Error";
		Message = "Callback Error!";
		Duration = 3;
		Actions = {
			ViewConsole = {
				Name = "View Console";
				CloseOnClick = true;
				Callback = function()
					keypress(0x78)
					keyrelease(0x78)
				end
			};
		}
	})
	warn(err)
end
function UpdateCanvasSize(Tab)
	local ElementsContainer = Tab.Instance.Elements.Container
	local tabyoffset = 0
	for i, v in FPSLibrary.Elements do
		if v.Instance.Parent == ElementsContainer then
			tabyoffset += v.Instance.Size.Y.Offset + 6
			if v.ClassName == "SectionParent" then
				local sectionyoffset = 0
				local SectionElementContainer = v.Instance.Dropdown.Container
				for i, v in SectionElementContainer:GetChildren() do
					if v.ClassName ~= "UIListLayout" then
						sectionyoffset += v.Size.Y.Offset + 3
					end
				end
				SectionElementContainer.CanvasSize = UDim2.new(0,0,0,sectionyoffset)
				if v.Opened == true then
					tabyoffset += v.DropdownSizeY - 4
				end
			end
		end
	end
	ElementsContainer.CanvasSize = UDim2.new(0,0,0,tabyoffset)
	--[[
	for i, v in FPSLibrary.Elements do
		if v.ClassName == "Tab" then
			local yoffset = 0
			local ElementsContainer = v.Instance.Elements.Container
			for i, v in FPSLibrary.Elements do
				if v.Instance.Parent == ElementsContainer or v.Instance.Parent == ElementsContainer then
					yoffset += v.Instance.Size.Y.Offset + 6
					if v.ClassName == "SectionParent" and v.Opened then
						yoffset += v.DropdownSizeY - 4
					end
				end
			end
			ElementsContainer.CanvasSize = UDim2.new(0,0,0,yoffset)
		elseif v.ClassName == "SectionParent" then
			local yoffset = 0
			local SectionElementContainer = v.Instance.Dropdown.Container
			for i, v in FPSLibrary.Elements do
				if v.Instance.Parent == SectionElementContainer then
					yoffset += v.Instance.Size.Y.Offset + 3
				end
			end
			SectionElementContainer.CanvasSize = UDim2.new(0,0,0,yoffset)
		end
	end
	]]
end
function ToggleTabVisibility()
	WindowVisible = not WindowVisible
	for i, v in FPSLibrary.Elements do
		if v.ClassName == "Tab" then
			v.Visible = WindowVisible
		end
	end
	if KeySystemContainer then
		TweenService:Create(KeySystemContainer,TweenOut50Sine,{Size = WindowVisible and UDim2.new(0,274,0,199) or UDim2.new(0,274,0,0)}):Play()
	end
	if WindowVisible == false then
		FPSLibrary:Notify({
			Type = "info";
			Title = "Interface Suite";
			Message = "You can press '"..ToggleGUIKeybind.Name.."' to Toggle GUI";
			Duration = 3;
		})
	end
end
function RippleEffects(Button)
	local ripplecontainer = Button:WaitForChild("RippleContainerFrame")
	local function tweenInRipple(rippleeffect)
		task.spawn(function()
			local Info = TweenInfo.new(0.9,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
			local Goals = {Size = UDim2.new(0, 200, 0, 200)}
			local Tween = TweenService:Create(rippleeffect, Info, Goals)
			Tween:Play()
		end)
	end
	local function fadeOutRipple(rippleeffect)
		task.spawn(function()
			local Info = TweenInfo.new(0.6,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
			local goal = {ImageTransparency = 1}
			local Tween = TweenService:Create(rippleeffect, Info, goal)
			Tween:Play()
			task.wait(1)
			rippleeffect:Destroy()
		end)
	end
	Button.MouseButton1Down:Connect(function()
		local button1up
		local rippleeffect = Instance.new("ImageLabel", ripplecontainer)
		rippleeffect.Name = "RippleEffect"
		rippleeffect.Position = UDim2.new(0,mouse.X - Button.AbsolutePosition.X,0,mouse.Y - Button.AbsolutePosition.Y)
		rippleeffect.ZIndex = ripplecontainer.ZIndex + 1
		rippleeffect.AnchorPoint = Vector2.new(0.5, 0.5)
		rippleeffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		rippleeffect.BackgroundTransparency = 1
		rippleeffect.Image = "rbxassetid://266543268"
		rippleeffect.ImageColor3 = Color3.fromRGB(0, 0, 0)
		rippleeffect.ImageTransparency = 0.8
		tweenInRipple(rippleeffect)
		button1up = Button.MouseButton1Up:Once(function()
			fadeOutRipple(rippleeffect)
		end)
		task.wait(4)
		button1up:Disconnect()
		fadeOutRipple(rippleeffect)
	end)
end
function UpdateElementTip(enabled,element,tip,duration)
	for _, v in connections do
		if typeof(v) == "table" and v[1] == "Tip" and v[2] == element then
			v[3]:Disconnect()
		end
	end
	if enabled == true and tip and typeof(tip) == "string" then
		a += 1
		local b = a
		connections[b] = {"Tip",element,element.MouseEnter:Connect(function()
			local spawn = tick()
			local tipobject = FPSLibraryAssets:WaitForChild("Tip"):Clone()
			tipobject.Parent = Interface
			local renderstepped
			local function UpdateTipPosition()
				tipobject.Text = tip
				tipobject.Size = UDim2.new(0,tipobject.TextBounds.X + 4,0,tipobject.TextBounds.Y + 2)
				tipobject.Position = UDim2.new(0,mouse.X,0,mouse.Y)
				if spawn + duration < tick() then
					tipobject:Destroy()
					renderstepped:Disconnect()
				end
			end
			UpdateTipPosition()
			renderstepped = RunService.RenderStepped:Connect(UpdateTipPosition)
			element.MouseLeave:Once(function()
				tipobject:Destroy()
				renderstepped:Disconnect()
			end)
		end)}
	end
end
function Callback(f,...)
	local suc, err = pcall(f,...)
	if suc == false then
		CallbackErrorMessage(err)
	end
end
function UpdateFlags(dictionary)
	for i, v in dictionary do
		if not dictionary.IgnoreList or i ~= "IgnoreList" and not table.find(dictionary.IgnoreList,i) then
			FPSLibrary.Flags[dictionary.Flag][i] = v
		end
	end
end
function BlendColors(bg,bgalpha,fg,fgalpha)
	local ralpha = 1 - (1 - fgalpha) * (1 - bgalpha)
	local c = Color3.new(
		fg.R * fgalpha / ralpha + bg.R * bgalpha * (1 - fgalpha) / ralpha,
		fg.G * fgalpha / ralpha + bg.G * bgalpha * (1 - fgalpha) / ralpha,
		fg.B * fgalpha / ralpha+ bg.B * bgalpha * (1 - fgalpha) / ralpha
	)
	return c
end
function isHoveringOverObj(obj)
	local tx = obj.AbsolutePosition.X
	local ty = obj.AbsolutePosition.Y
	local bx = tx + obj.AbsoluteSize.X
	local by = ty + obj.AbsoluteSize.Y
	local m = mouse
	if m.X >= tx and m.Y >= ty and m.X <= bx and m.Y <= by then
		return true
	end
	return false
end
function LoadFile(destination,callback)
	local suc = pcall(function()
		local contents = HttpService:JSONDecode(readfile(destination))
		for idx in FPSLibrary.Elements do
			local flagName = FPSLibrary.Elements[idx].Flag
			if flagName then
				if contents[flagName] then
					for property, value in contents[flagName] do
						FPSLibrary.Elements[idx][property] = value
					end
					if callback == true and FPSLibrary.Elements[idx].Callback then
						local args = {}
						if FPSLibrary.Elements[idx].CurrentValue then
							args = {FPSLibrary.Elements[idx].CurrentValue}
						elseif FPSLibrary.Elements[idx].CurrentColor then
							args = {FPSLibrary.Elements[idx].CurrentColor}
						elseif FPSLibrary.Elements[idx].CurrentOption then
							args = {FPSLibrary.Elements[idx].CurrentOption}
						elseif FPSLibrary.Elements[idx].CurrentKeybind then
							args = {FPSLibrary.Elements[idx].CurrentKeybind}
						end
						task.spawn(FPSLibrary.Elements[idx].Callback,table.unpack(args))
					end
				else
					FPSLibrary:Notify({
						Type = "error";
						Title = "Error";
						Message = "Unable to find '"..flagName.. "' in the current configuration file";
					})
				end
			end
		end
	end)
	if suc == false then
		FPSLibrary:Notify({
			Type = "error";
			Title = "Error";
			Message = "This configuration file is corrupted or lost.";
		})
	end
end
-- Module Functions
function FPSLibrary:Notify(settings)
	task.spawn(function()
		if typeof(settings.Title) ~= "string" then return warn("Title is required and must be a string") end
		if typeof(settings.Message) ~= "string" then return warn("Message is required and must be a string") end
		if settings.Type ~= nil and settings.Type ~= "error" and settings.Type ~= "info" and settings.Type ~= "success" then return warn('Notification Type must be: "error","info","success"') end
		if settings.Icon ~= nil and typeof(settings.Icon) ~= "number" then return warn("IconId must be a number") end
		if settings.Image ~= nil and typeof(settings.Image) ~= "number" then return warn("ImageId must be a number") end
		if settings.Sound ~= nil and typeof(settings.Sound) ~= "number" then return warn("SoundId must be a number") end
		if typeof(settings.Duration) ~= "number" then return warn("Duration is required and must be a number") end
		if settings.Action and typeof(settings.Actions) ~= "table" then return warn("Actions must be a table") end
		settings.Title = settings.Title
		settings.Message = settings.Message
		settings.Sound = settings.Sound ~= nil and settings.Sound or settings.Type == "error" and 2865228021 or settings.Type == "info" and 3398620867 or settings.Type == "success" and 3450794184
		settings.Duration = settings.Duration
		local NotificationExample = FPSLibraryAssets:WaitForChild("NotificationExample"):Clone()
		local Container = NotificationExample:WaitForChild("Container")
		local Title = Container:WaitForChild("Title")
		local Message = Container:WaitForChild("Message")
		local TopIcon = Container:WaitForChild("TopIcon")
		local ImageIcon = Container:WaitForChild("NotificationImage")
		local Image = Container:WaitForChild("Image")
		local ActionButtonsContainer = Container:WaitForChild("ActionButtons"):WaitForChild("Container")
		local DurationTimerContainer = Container:WaitForChild("SliderFrame")
		local DurationTimerBackground = DurationTimerContainer:WaitForChild("Slider")
		local DurationTimer = DurationTimerBackground:WaitForChild("Frame")
		local TweenInPosition = settings.Image and UDim2.new(1,-260,1,-225) or UDim2.new(1,-220,1,-95)
		NotificationExample.Parent = Interface
		NotificationExample.Position = settings.Image and UDim2.new(1,0,1,-225) or UDim2.new(1,0,1,-95)
		NotificationExample.Size = settings.Image and UDim2.new(0,240,0,210) or UDim2.new(0,200,0,75)
		Container.BackgroundColor3 = settings.Type == "error" and Color3.fromRGB(81, 49, 49) or settings.Type == "info" and Color3.fromRGB(49, 49, 81) or settings.Type == "success" and Color3.fromRGB(49, 81, 49) or Color3.fromRGB(81, 81, 81)
		Title.Text = settings.Title
		Message.Text = settings.Message
		Message.TextWrapped = false
		Message.TextScaled = false
		local messagesizex = settings.Icon and 114 or 160
		local messagesizey = 12 + 12 * math.ceil(Message.TextBounds.X/messagesizex)
		Message.TextWrapped = true
		Message.TextScaled = messagesizey > 36
		Message.Size = UDim2.new(0,messagesizex,0,math.clamp(messagesizey,0,36))
		TopIcon.Image = settings.Type == "error" and "rbxassetid://102649569795605" or settings.Type == "info" and "rbxassetid://76316461447556" or settings.Type == "success" and "rbxassetid://111469034555385" or "rbxassetid://0"
		ImageIcon.Image = settings.Icon or "rbxassetid://0"
		Image.Size = settings.Image and UDim2.new(0,130,0,130) or UDim2.new(0,130,0,0)
		Image.Image = settings.Image or "rbxassetid://0"
		DurationTimerContainer.Visible = settings.Duration ~= math.huge
		DurationTimerBackground.BackgroundColor3 = settings.Type == "error" and Color3.fromRGB(58, 35, 35) or settings.Type == "info" and Color3.fromRGB(35, 35, 58) or settings.Type == "success" and Color3.fromRGB(35, 58, 35) or Color3.fromRGB(58, 58, 58)
		local Spawn = tick()
		local closing = false
		local heartbeat = RunService.RenderStepped:Connect(function()
			DurationTimer.Size = UDim2.new(1 - (tick() - Spawn) / settings.Duration,0,1,0)
		end)
		local function CloseNotification()
			task.spawn(function()
				if closing == false then
					closing = true
					table.remove(Notifications,table.find(Notifications,NotificationExample))
					UpdateNotificationLayout()
					TweenService:Create(NotificationExample,TweenIn75Sine,{Position = UDim2.new(1,0,1,NotificationExample.Position.Y.Offset)}):Play()
					task.wait(0.75)
					NotificationExample:Destroy()
					heartbeat:Disconnect()
				end
			end)
		end
		if settings.Actions then
			for _, actionsettings in settings.Actions do
				local Button = FPSLibraryAssets:WaitForChild("Button"):Clone()
				Button.Parent = ActionButtonsContainer
				local ButtonNameLabel = Button:WaitForChild("NameTextLabel")
				ButtonNameLabel.Text = actionsettings.Name
				ButtonNameLabel.Size = UDim2.new(1,0,1,0)
				Button:WaitForChild("Icon"):Destroy()
				RippleEffects(Button)
				Button.MouseButton1Click:Connect(function()
					if closing == false then
						if actionsettings.CloseOnClick == true then
							CloseNotification()
						end
						if actionsettings.Callback and typeof(actionsettings.Callback) == "function" then
							Callback(actionsettings.Callback)
						end
					end
				end)
			end
		end
		if settings.Sound ~= nil then
			PlaySound(settings.Sound)
		end
		TweenService:Create(NotificationExample,TweenOut75Sine,{Position = TweenInPosition}):Play()
		table.insert(Notifications,1,NotificationExample)
		UpdateNotificationLayout()
		task.delay(settings.Duration,CloseNotification)
	end)
end
function FPSLibrary:SaveConfiguration(filename)
	if typeof(filename) == "string" and filename ~= "" and LocalConfigurationFolderName ~= nil and LocalConfigurationSubFolderName ~= nil and isfolder(ConfigurationFolderName) == true and isfolder(ConfigurationFolderName.."/"..LocalConfigurationFolderName) == true and isfolder(ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName) == true then
		local suc, err = pcall(function()
			local spawn = tick()
			local canwritefile = true
			if isfile(ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName.."/"..filename) == true then
				canwritefile = false
				FPSLibrary:Notify({
					Type = "info";
					Title = "Configuration";
					Message = "There is already a file named '"..filename.."'. Do you wish to overwrite it?";
					Duration = 5;
					Actions = {
						Yes = {
							Name = "Yes";
							CloseOnClick = true;
							Callback = function()
								canwritefile = true
							end
						};
						No = {
							Name = "No";
							CloseOnClick = true;
							Callback = function()
							end
						}
					}
				})
			end
			if canwritefile == false then
				repeat task.wait() until canwritefile or spawn + 5 < tick()
				if canwritefile == false then return end
			end
			writefile(ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName.."/"..filename,HttpService:JSONEncode(FPSLibrary.Flags))
		end)
		if suc == false then
			FPSLibrary:Notify({
				Type = "error";
				Title = "Error";
				Message = "An unexpected error occured while saving configuration. Please try again.";
			})
		end
	end
end
function FPSLibrary:LoadConfiguration(filename,callback)
	if callback ~= nil and typeof(callback) ~= "boolean" then return warn("Argument #2 must be a boolean") end
	if typeof(filename) == "string" and filename ~= "" then
		if LocalConfigurationFolderName ~= nil and LocalConfigurationSubFolderName ~= nil and isfolder(ConfigurationFolderName) and isfolder(ConfigurationFolderName.."/"..LocalConfigurationFolderName) and isfolder(ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName) and isfile(ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName.."/"..filename) then
			LoadFile(ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName.."/"..filename,callback)
		end
	elseif filename == nil then
		local metafolder = ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName..".meta"
		if isfile(metafolder) == true then
			local suc = pcall(function()
				local contents = HttpService:JSONDecode(readfile(metafolder))
				if contents.AutoLoad == true and isfile(contents.AutoLoad) == true then
					LoadFile(contents.AutoLoad,callback)
				end
			end)
			if suc == false then
				FPSLibrary:Notify({
					Type = "error";
					Title = "Error";
					Message = "Unable to boot load the configuration file. The metafolder file is corrupted or lost.";
				})
			end
		end
	end
end
function FPSLibrary:DeleteConfiguration(filename)
	if typeof(filename) == "string" and filename ~= "" and LocalConfigurationFolderName ~= nil and LocalConfigurationSubFolderName ~= nil and isfolder(ConfigurationFolderName) == true and isfolder(ConfigurationFolderName.."/"..LocalConfigurationFolderName) == true and isfolder(ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName) == true and isfile(ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName.."/"..filename) == true then
		local suc = pcall(function()
			delfile(ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName.."/"..filename)
		end)
		if suc == false then
			FPSLibrary:Notify({
				Type = "error";
				Title = "Error";
				Message = "Failed to find Configuration File";
			})
		end
	end
end
function FPSLibrary:ListConfigurationFiles()
	if LocalConfigurationFolderName ~= nil and isfolder(ConfigurationFolderName) == true and isfolder(ConfigurationFolderName.."/"..LocalConfigurationFolderName) == true and isfolder(ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName) == true then
		local files = listfiles(ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName)
		for i, v in files do
			local split = v:split("/")
			files[i] = split[#split]
		end
		return files
	end
	return {}
end
function FPSLibrary:AutoLoadFileOnBoot(autoloadfile,filename)
	if LocalConfigurationFolderName ~= nil and LocalConfigurationSubFolderName ~= nil and isfolder(ConfigurationFolderName) == true and isfolder(ConfigurationFolderName.."/"..LocalConfigurationFolderName) == true and isfolder(ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName) == true then
		local suc = pcall(function()
			local contents = {}
			local metafolder = ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName..".meta"
			if isfile(metafolder) == true then
				pcall(function()
					contents = HttpService:JSONDecode(readfile(metafolder))
				end)
			end
			if autoloadfile == true then
				if typeof(filename) == "string" then
					if isfile(ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName.."/"..filename) == true then
						contents.AutoLoad = ConfigurationFolderName.."/"..LocalConfigurationFolderName.."/"..LocalConfigurationSubFolderName.."/"..filename
					else
						FPSLibrary:Notify({
							Type = "error";
							Title = "Error";
							Message = "This configuration file doesn't exist.";
						})
					end
				end
			else
				contents.AutoLoad = nil
			end
			writefile(metafolder,HttpService:JSONEncode(contents))
		end)
		if suc == false then
			FPSLibrary:Notify({
				Type = "error";
				Title = "Error";
				Message = "This configuration file is corrupted.";
			})
		end
	end
end
function FPSLibrary:BootWindow(windowsettings)
	if windowsettings.KeySystem.LoadingTitle and typeof(windowsettings.KeySystem.LoadingTitle) ~= "string" then return warn("LoadingTitle must be a string") end
	if windowsettings.KeySystem.WindowVisible and typeof(windowsettings.KeySystem.WindowVisible) ~= "boolean" then return warn("WindowVisible must be a boolean") end
	local Window = {}
	if windowsettings.ToggleInterface ~= nil and typeof(windowsettings.ToggleInterface) == "table" and windowsettings.ToggleInterface.Enabled ~= nil and windowsettings.ToggleInterface.Enabled == true then
		if windowsettings.ToggleInterface.KeyboardCheck ~= nil and typeof(windowsettings.ToggleInterface.KeyboardCheck) ~= "boolean" then return warn("KeyboardCheck must be a boolean") end
		if windowsettings.ToggleInterface.Title ~= nil and typeof(windowsettings.ToggleInterface.Title) ~= "string" then return warn("Title must be a string") end
		if windowsettings.ToggleInterface.UseIcon ~= nil and typeof(windowsettings.ToggleInterface.UseIcon) ~= "boolean" then return warn("UseIcon must be a boolean") end
		if windowsettings.ToggleInterface.UseIcon == true and typeof(windowsettings.ToggleInterface.Icon) ~= "number" then return warn("IconId must be a number") end
		if windowsettings.ToggleInterface.BackgroundColor ~= nil and typeof(windowsettings.ToggleInterface.BackgroundColor) ~= "Color3" then return warn("BackgroundColor must be a Color3") end
		if windowsettings.ToggleInterface.Position ~= nil and typeof(windowsettings.ToggleInterface.Position) ~= "UDim2" then return warn("Position must be a UDim2") end
		if windowsettings.ToggleInterface.AnchorPoint ~= nil and typeof(windowsettings.ToggleInterface.AnchorPoint) ~= "Vector2" then return warn("AnchorPoint must be a Vector2") end
		if windowsettings.ToggleInterface.Draggable ~= nil and typeof(windowsettings.ToggleInterface.Draggable) ~= "boolean" then return warn("Draggable must be a boolean") end
		if windowsettings.ToggleInterface.ShowAfterKeySystem ~= nil and typeof(windowsettings.ToggleInterface.ShowAfterKeySystem) ~= "boolean" then return warn("ShowAfterKeySystem must be a boolean") end
		local MenuToggleButton
		if windowsettings.ToggleInterface.UseIcon == true then
			MenuToggleButton = FPSLibraryAssets:WaitForChild("MenuToggleIcon"):Clone()
			MenuToggleButton.Image = "rbxassetid://"..tostring(windowsettings.ToggleInterface.Icon)
		else
			MenuToggleButton = FPSLibraryAssets:WaitForChild("MenuToggleButton"):Clone()
			MenuToggleButton.Text = windowsettings.ToggleInterface.Title or "Toggle GUI"
			MenuToggleButton.Size = UDim2.new(0,MenuToggleButton.TextBounds.X <= 83 and 112 or MenuToggleButton.TextBounds.X + 29,0,48)
		end
		MenuToggleButton.BackgroundColor3 = windowsettings.ToggleInterface.BackgroundColor or Color3.new(0,0,0)
		MenuToggleButton.Parent = Interface
		MenuToggleButton.Position = windowsettings.ToggleInterface.UseIcon == false and (windowsettings.ToggleInterface.Position ~= nil and windowsettings.ToggleInterface.Position or UDim2.new(1,-18 - MenuToggleButton.Size.X.Offset,0,18)) or UDim2.new(1,-62,0,18)
		MenuToggleButton.AnchorPoint = windowsettings.ToggleInterface.AnchorPoint ~= nil and windowsettings.ToggleInterface.AnchorPoint or Vector2.new(0,0)
		MenuToggleButton.Visible = (windowsettings.ToggleInterface.KeyboardCheck == nil or windowsettings.ToggleInterface.KeyboardCheck == false) or UserInputService.KeyboardEnabled
		MakeDraggable(windowsettings.ToggleInterface.Draggable == nil or windowsettings.ToggleInterface.Draggable,MenuToggleButton)
		MenuToggleButton.MouseButton1Click:Connect(function()
			ToggleTabVisibility()
		end)
		if windowsettings.ToggleInterface.KeyboardCheck == true then
			UserInputService:GetPropertyChangedSignal("KeyboardEnabled"):Connect(function()
				MenuToggleButton.Visible = UserInputService.KeyboardEnabled
			end)
		end
		if windowsettings.ToggleInterface.ShowAfterKeySystem == nil or windowsettings.ToggleInterface.ShowAfterKeySystem == true then
			MenuToggleButton.Parent = nil
			task.spawn(function()
				repeat task.wait() until KeyVerified
				MenuToggleButton.Parent = Interface
			end)
		end
	end
	if windowsettings.ToggleGUIKeybind ~= nil then
		if typeof(windowsettings.ToggleGUIKeybind) ~= "EnumItem" or windowsettings.ToggleGUIKeybind.EnumType ~= Enum.KeyCode then return warn("ToggleGUIKeybind must be a Enum.KeyCode") end
		ToggleGUIKeybind = windowsettings.ToggleGUIKeybind
	end
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed == false and input.KeyCode == ToggleGUIKeybind then
			ToggleTabVisibility()
		end
	end)
	if windowsettings.KeySystem ~= nil and typeof(windowsettings.KeySystem) == "table" and windowsettings.KeySystem.Enabled ~= nil and windowsettings.KeySystem.Enabled == true then
		if typeof(windowsettings.KeySystem.Title) ~= "string" then return warn("Title is required and must be a string") end
		if typeof(windowsettings.KeySystem.Keys) ~= "table" then return warn("Keys is required and must be a table") end
		if windowsettings.KeySystem.EncryptKey ~= nil and typeof(windowsettings.KeySystem.EncryptKey) ~= "boolean" then return warn("EncryptKey must be a boolean") end
		if windowsettings.KeySystem.EncryptKey == true and typeof(windowsettings.KeySystem.CypherKey) ~= "string" then return warn("CypherKey is required and must be a string") end
		if windowsettings.KeySystem.RememberKey ~= nil and typeof(windowsettings.KeySystem.RememberKey) ~= "boolean" then return warn("RememberKey must be a boolean") end
		if windowsettings.KeySystem.RememberKey == true and typeof(windowsettings.KeySystem.FileName) ~= "string" then return warn("FileName is required and must be a string") end
		if windowsettings.KeySystem.RememberKey == true and typeof(windowsettings.KeySystem.KeyTimeLimit) ~= "number" then return warn("KeyTimeLimit is required and must be a number") end
		if windowsettings.KeySystem.GrabKeyFromSite ~= nil and typeof(windowsettings.KeySystem.GrabKeyFromSite) ~= "boolean" then return warn("GrabKeyFromSite must be a boolean") end
		if windowsettings.KeySystem.GrabKeyFromSite == true and typeof(windowsettings.KeySystem.WebsiteURL) ~= "string" then return warn("WebsiteURL is required and must be a string") end
		if windowsettings.KeySystem.GrabKeyFromSite == true and typeof(windowsettings.KeySystem.KeyRAWURL) ~= "string" then return warn("KeyRAWURL is required and must be a string") end
		if windowsettings.KeySystem.GrabKeyFromSite == true and windowsettings.KeySystem.JSONDecode ~= nil and typeof(windowsettings.KeySystem.JSONDecode) ~= "boolean" then return warn("JSONDecode must be a boolean") end
		KeySystemContainer = FPSLibraryAssets:WaitForChild("KeySystem"):Clone()
		KeySystemContainer.Parent = Interface
		KeySystemContainer.Size = UDim2.new(0,274,0,0)
		TweenService:Create(KeySystemContainer,TweenOut50Sine,{Size = UDim2.new(0,274,0,199)}):Play()
		MakeDraggable(true,KeySystemContainer)
		local KeySystemInterface = KeySystemContainer:WaitForChild("Frame")
		local KeySystemTitle = KeySystemInterface:WaitForChild("Title")
		KeySystemTitle.Text = windowsettings.KeySystem.Title
		local CloseButton = KeySystemInterface:WaitForChild("ImageButton")
		local TextBox = KeySystemInterface:WaitForChild("TextBox")
		local CheckKeyButton = FPSLibraryAssets:WaitForChild("Button"):Clone()
		local CheckKeyName = CheckKeyButton:WaitForChild("NameTextLabel")
		CheckKeyButton.Parent = KeySystemInterface
		CheckKeyButton.AnchorPoint = Vector2.new(0.5, 0.5)
		CheckKeyButton.Position = UDim2.new(0.5, 0, 0.5, 27)
		CheckKeyButton.Size = UDim2.new(0, 75, 0, 20)
		CheckKeyName.Text = "Authenticate"
		CheckKeyName.Size = UDim2.new(1,0,1,0)
		CheckKeyName.Position = UDim2.new(0,0,0,0)
		CheckKeyName.TextScaled = false
		CheckKeyButton:WaitForChild("Icon"):Destroy()
		if windowsettings.KeySystem.GrabKeyFromSite == true then
			local GetKeyButton = FPSLibraryAssets:WaitForChild("Button"):Clone()
			local GetKeyName = GetKeyButton:WaitForChild("NameTextLabel")
			local GetKeyButtonOutline = GetKeyButton:WaitForChild("UIStroke")
			GetKeyButton.Parent = KeySystemInterface
			GetKeyButton.BackgroundColor3 = Color3.fromRGB(149, 119, 54)
			GetKeyButton.AnchorPoint = Vector2.new(0.5, 0.5)
			GetKeyButton.Position = UDim2.new(0.5, 0, 0.5, 51)
			GetKeyButton.Size = UDim2.new(0, 75, 0, 20)
			GetKeyButton.BackgroundColor3 = Color3.fromRGB(149, 119, 54)
			GetKeyButton.Position = UDim2.new(0,0,0,0)
			GetKeyButton.TextScaled = false
			GetKeyButtonOutline.BackgroundColor3 = Color3.fromRGB(83, 66, 30)
			GetKeyName.Text = "Get Key"
			GetKeyName.Size = UDim2.new(1,0,1,0)
			GetKeyButton:WaitForChild("Icon"):Destroy()
			RippleEffects(GetKeyButton)
			GetKeyButton.MouseButton1Click:Connect(function()
				if setclipboard ~= nil then
					setclipboard(windowsettings.KeySystem.WebsiteURL)
					FPSLibrary:Notify({
						Type = "success";
						Title = windowsettings.KeySystem.Title;
						Message = "Link copied to clipboard!";
						Duration = 3;
					})
				else
					FPSLibrary:Notify({
						Type = "info";
						Title = windowsettings.KeySystem.Title;
						Message = 'URL: "'..windowsettings.KeySystem.WebsiteURL..'"';
						Duration = math.huge;
						Actions = {
							Close = {
								Name = "Close";
								CloseOnClick = true;
								Callback = function()
								end
							}
						}
					})
				end
			end)
		end
		local function VerifyKey(enteredkey)
			local suc, keys = pcall(function()
				return windowsettings.KeySystem.GrabKeyFromSite == true and (windowsettings.KeySystem.JSONDecode == true and HttpService:JSONDecode(game:HttpGet(windowsettings.KeySystem.KeyRAWURL)) or {game:HttpGet(windowsettings.KeySystem.KeyRAWURL)}) or windowsettings.KeySystem.Keys
			end)
			if suc == true and keys ~= nil then
				for _, key in keys do
					if key == enteredkey then
						return true
					end
				end
			else
				FPSLibrary:Notify({
					Type = "error";
					Title = windowsettings.KeySystem.Title;
					Message = "Failed To Obtain Key. Please check if the format is correct.";
					Duration = 5;
					Actions = {}
				})
			end
			return false
		end
		RippleEffects(CheckKeyButton)
		CheckKeyButton.MouseButton1Click:Connect(function()
			local verified = VerifyKey(TextBox.Text)
			if verified == true then
				KeyVerified = true
				FPSLibrary:Notify({
					Type = "success";
					Title = windowsettings.KeySystem.Title;
					Message = "Correct Key!";
					Duration = 3;
				})
				if windowsettings.KeySystem.RememberKey == true then
					local suc = pcall(function()
						local key = TextBox.Text
						local spawn = tostring(tick())
						local encrypted = windowsettings.KeySystem.EncryptKey
						if windowsettings.KeySystem.Encrypt == true then
							if #windowsettings.KeySystem.CypherKey < 16 then
								return FPSLibrary:Notify({
									Type = "error";
									Title = windowsettings.KeySystem.Title;
									Message = "Cypher Key Length Must Be 16 Or More";
									Duration = 3;
								})
							elseif encrypt == nil then
								return FPSLibrary:Notify({
									Type = "error";
									Title = windowsettings.KeySystem.Title;
									Message = "Your executor is unsupported. Missing function 'encrypt'. Your key has not been saved.";
									Duration = 3;
								})
							else
								key = encrypt(key,windowsettings.KeySystem.CypherKey)
								spawn = encrypt(spawn,windowsettings.KeySystem.CypherKey)
							end
						end
						if key ~= nil and spawn ~= nil then
							local contents = {
								Key = key;
								Spawn = spawn
							}
							writefile(KeyFolderName.."/"..windowsettings.KeySystem.FileName,HttpService:JSONEncode(contents))
						end
					end)
					if suc == false then
						FPSLibrary:Notify({
							Type = "error";
							Title = windowsettings.KeySystem.Title;
							Message = windowsettings.KeySystem.Title.." ran into an error. Your key has not been saved.";
							Duration = 5;
						})
					end
				end
			else
				FPSLibrary:Notify({
					Type = "error";
					Title = windowsettings.KeySystem.Title;
					Message = "Invalid Key!";
					Duration = 3;
				})
			end
		end)
		CloseButton.MouseButton1Click:Connect(function()
			TweenService:Create(KeySystemContainer,TweenOut50Sine,{Size = UDim2.new(0,274,0,0)}):Play()
			task.wait(0.5)
			KeySystemContainer:Destroy()
		end)
		if windowsettings.KeySystem.RememberKey == true and isfile(KeyFolderName.."/"..windowsettings.KeySystem.FileName) == true then
			local suc, err = pcall(function()
				local contents = HttpService:JSONDecode(readfile(KeyFolderName.."/"..windowsettings.KeySystem.FileName))
				if contents.Key ~= nil and contents.Spawn ~= nil and contents.Encrypted ~= nil then
					local decryptedkey
					local decryptedspawn
					if contents.Encrypted == true then
						if #windowsettings.KeySystem.CypherKey < 16 then
							return FPSLibrary:Notify({
								Type = "error";
								Title = windowsettings.KeySystem.Title;
								Message = "Cypher Key Length Must Be 16 Or More";
								Duration = 5;
							})
						elseif decrypt == nil then
							return FPSLibrary:Notify({
								Type = "error";
								Title = windowsettings.KeySystem.Title;
								Message = "Your executor is unsupported. Missing function 'decrypt'. Please re-enter your key";
								Duration = 5;
							})
						else
							decryptedkey = decrypt(contents.Key,windowsettings.KeySystem.CypherKey)
							decryptedspawn = decrypt(contents.Spawn,windowsettings.KeySystem.CypherKey)
						end
					end
					if decryptedkey ~= nil and decryptedspawn ~= nil and tonumber(decryptedspawn) ~= nil then
						if tonumber(decryptedspawn) + windowsettings.KeySystem.KeyTimeLimit > tick() then
							local verified = VerifyKey(contents.Key)
							if verified == true then
								KeyVerified = true
							else
								FPSLibrary:Notify({
									Type = "error";
									Title = windowsettings.KeySystem.Title;
									Message = "Key not authenticated. Try again.";
									Duration = 3;
								})
							end
						else
							FPSLibrary:Notify({
								Type = "info";
								Title = windowsettings.KeySystem.Title;
								Message = "Your key has expired. Please re-enter your key.";
								Duration = 3;
							})
						end
					else
						FPSLibrary:Notify({
							Type = "error";
							Title = windowsettings.KeySystem.Title;
							Message = "Unable to verify key. Your key system file is corrupted.";
							Duration = 3;
						})
					end
				end
			end)
			if suc == false then
				FPSLibrary:Notify({
					Type = "error";
					Title = "Error";
					Message = "An Unexpected Error Occurred While Checking Key.";
				})
			end
		end
		repeat task.wait() until KeyVerified == true
		KeySystemContainer:Destroy()
	else
		KeyVerified = true
	end
	task.spawn(function()
		local BootAnimation = FPSLibraryAssets:WaitForChild("LibraryBootAnimation"):Clone()
		BootAnimation.Parent = Interface
		local Line1 = BootAnimation:WaitForChild("Line1")
		local Line2 = BootAnimation:WaitForChild("Line2")
		local TitleName = BootAnimation:WaitForChild("TitleName")
		TitleName.Text = windowsettings.LoadingTitle ~= nil and windowsettings.LoadingTitle or "FPSLibrary Interface Suite"
		TweenService:Create(Line1,TweenOut75Sine,{Position = UDim2.new(0.5,TitleName.TextBounds.X/2 + 8,0,0)}):Play()
		TweenService:Create(Line2,TweenOut75Sine,{Position = UDim2.new(0.5,-TitleName.TextBounds.X/2 - 8,0,0)}):Play()
		TweenService:Create(TitleName,TweenOut75Sine,{Size = UDim2.new(0,TitleName.TextBounds.X + 8,1,0)}):Play()
		task.wait(1.25)
		TweenService:Create(Line1,TweenIn75Sine,{Position = UDim2.new(0.5,0,0,0)}):Play()
		TweenService:Create(Line2,TweenIn75Sine,{Position = UDim2.new(0.5,0,0,0)}):Play()
		TweenService:Create(TitleName,TweenIn75Sine,{Size = UDim2.new(0,0,1,0)}):Play()
		task.wait(0.75)
		BootAnimation:Destroy()
	end)
	local suc = pcall(function()
		if windowsettings.ConfigurationSaving ~= nil and typeof(windowsettings.ConfigurationSaving) == "table" and windowsettings.ConfigurationSaving.Enabled == true then
			if typeof(windowsettings.ConfigurationSaving.FolderName) ~= "string" then return warn("FolderName is required and must be a string") end
			local FolderName = windowsettings.ConfigurationSaving.FolderName
			local SubFolderName = "Universal"
			if windowsettings.ConfigurationSaving.PlaceId == true then
				SubFolderName = tostring(game.PlaceId)
			end
			if isfolder(ConfigurationFolderName.."/"..FolderName) == false then
				makefolder(ConfigurationFolderName.."/"..FolderName)
			end
			if isfolder(ConfigurationFolderName.."/"..FolderName.."/"..SubFolderName) == false then
				makefolder(ConfigurationFolderName.."/"..FolderName.."/"..SubFolderName)
			end
			LocalConfigurationFolderName = FolderName
			LocalConfigurationSubFolderName = SubFolderName
		end
	end)
	if suc == false then
		FPSLibrary:Notify({
			Type = "error";
			Title = "Configuration";
			Message = "An Unexpected Error Occurred While Loading Configurations";
		})
	end
	if windowsettings.WindowVisible then WindowVisible = true end
	function Window:CreateTab(tabsettings)
		-- Tab Setttings
		tabsettings.Title = tabsettings.Title ~= nil and tabsettings.Title or "Title"
		tabsettings.Subtitle = tabsettings.Subtitle ~= nil and tabsettings.Subtitle or "Subtitle"
		tabsettings.TitleRichText = tabsettings.TitleRichText ~= nil and tabsettings.TitleRichText
		tabsettings.SubtitleRichText = tabsettings.SubtitleRichText ~= nil and tabsettings.SubtitleRichText
		tabsettings.Image = tabsettings.Image ~= nil and tabsettings.Image or 0
		tabsettings.SizeY = tabsettings.SizeY ~= nil and tabsettings.SizeY or 300
		tabsettings.MaxSizeY = tabsettings.MaxSizeY ~= nil and tabsettings.MaxSizeY or 300
		tabsettings.Opened = tabsettings.Opened ~= nil and tabsettings.Opened
		tabsettings.CanvasSizeY = tabsettings.CanvasSizeY or 0
		tabsettings.Visible = tabsettings.Visible == nil or tabsettings.Visible
		tabsettings.Position = tabsettings.Position ~= nil and tabsettings.Position or UDim2.new(0,20,0,20)
		tabsettings.Flag = tabsettings.Flag ~= "" and tabsettings.Flag or nil
		tabsettings.IgnoreList = tabsettings.IgnoreList ~= nil and tabsettings.IgnoreList or {}
		if typeof(tabsettings.Title) ~= "string" then return warn("Title must be a string") end
		if typeof(tabsettings.Subtitle) ~= "string" then return warn("Subtitle must be a string") end
		if typeof(tabsettings.TitleRichText) ~= "boolean" then return warn("TitleRichText must be a boolean") end
		if typeof(tabsettings.SubtitleRichText) ~= "boolean" then return warn("SubtitleRichText must be a boolean") end
		if typeof(tabsettings.Image) ~= "number" then return warn("Image must be a number") end
		if typeof(tabsettings.SizeY) ~= "number" then return warn("SizeY must be a number") end
		if typeof(tabsettings.MaxSizeY) ~= "number" then return warn("MaxSizeY must be a number") end
		if typeof(tabsettings.Opened) ~= "boolean" then return warn("Opened must be a boolean") end
		if typeof(tabsettings.CanvasSizeY) ~= "number" then return warn("CanvasSizeY must be a number") end
		if typeof(tabsettings.Visible) ~= "boolean" then return warn("Visible must be a boolean") end
		if typeof(tabsettings.Position) ~= "UDim2" then return warn("Position must be a UDim2") end
		if tabsettings.Flag ~= nil and typeof(tabsettings.Flag) ~= "string" then return warn("Flag must be a string") end
		if typeof(tabsettings.IgnoreList) ~= "table" then return warn("IgnoreList must be a table") end
		-- Module
		local TabModule = {}
		local mt = {}
		-- Variables
		local layoutorder = 0
		local canupdateflags = false
		-- Tab
		local TabContainer = FPSLibraryAssets:WaitForChild("Tab"):Clone()
		TabContainer.Parent = Interface
		TabContainer.Size = UDim2.new(0,112,0,0)
		TabContainer.Position = tabsettings.Position - UDim2.new(0,2,0,2)
		TweenService:Create(TabContainer,TweenOut50Sine,{Size = UDim2.new(0,112,0,tabsettings.Opened == true and tabsettings.SizeY + 37 or 37)}):Play()
		local DropShadow = TabContainer:WaitForChild("DropShadow")
		local Tab = TabContainer:WaitForChild("Frame")
		local Title = Tab:WaitForChild("Title")
		local Subtitle = Tab:WaitForChild("Subtitle")
		local Icon = Tab:WaitForChild("ImageLabel")
		local MinimizeButton = Tab:WaitForChild("ArrowImageButton")
		local ElementsFrame = Tab:WaitForChild("Elements")
		local ElementsContainer = ElementsFrame:WaitForChild("Container")
		ElementsFrame.Size = tabsettings.Opened == true and UDim2.new(1,0,0,tabsettings.SizeY + 10) or UDim2.new(1,0,0,10)
		MinimizeButton.Rotation = tabsettings.Opened == true and 0 or 180
		-- Metatable Functions
		function mt.__newindex(self, idx, value)
			if idx == "Title" then
				if typeof(value) ~= "string" then return warn("Title must be a string") end
				tabsettings.Title = value
				Title.Text = tabsettings.Title
			elseif idx == "Subtitle" then
				if typeof(value) ~= "string" then return warn("Subtitle must be a string") end
				tabsettings.Subtitle = value
				Subtitle.Text = tabsettings.Subtitle
			elseif idx == "TitleRichText" then
				if typeof(value) ~= "boolean" then return warn("TitleRichText must be a boolean") end
				tabsettings.TitleRichText = value
				Title.RichText = tabsettings.TitleRichText
			elseif idx == "SubtitleRichText" then
				if typeof(value) ~= "boolean" then return warn("SubtitleRichText must be a boolean") end
				tabsettings.SubtitleRichText = value
				Subtitle.RichText = tabsettings.SubtitleRichText
			elseif idx == "Image" then
				if typeof(value) ~= "number" then return warn("Image must be a number") end
				tabsettings.Image = "rbxassetid://"..tostring(value)
				Icon.Image = tabsettings.Image
			elseif idx == "SizeY" then
				if typeof(value) ~= "number" then return warn("SizeY must be a number") end
				tabsettings.SizeY = math.clamp(value,100,tabsettings.MaxSizeY)
				if tabsettings.Opened then
					TweenService:Create(ElementsFrame,TweenOut75Sine,{Size = UDim2.new(1,0,0,tabsettings.SizeY + 10)}):Play()
				end
			elseif idx == "MaxSizeY" then
				if typeof(value) ~= "number" then return warn("MaxSizeY must be a number") end
				tabsettings.MaxSizeY = value >= 100 and value or 100
				if tabsettings.SizeY > tabsettings.MaxSizeY then
					TabModule.SizeY = tabsettings.MaxSizeY
				end
			elseif idx == "Position" then
				if typeof(value) ~= "UDim2" then return warn("Position must be a UDim2") end
				tabsettings.Position = value
				TweenService:Create(TabContainer,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = tabsettings.Position}):Play()
				MakeDraggable(false,TabContainer)
				MakeDraggable(true,TabContainer)
			elseif idx == "Opened" then
				if typeof(value) ~= "boolean" then return warn("Opened must be a boolean") end
				tabsettings.Opened = value
				if tabsettings.Opened then
					TweenService:Create(ElementsFrame,TweenOut75Sine,{Size = UDim2.new(1,0,0,tabsettings.SizeY + 10)}):Play()
					TweenService:Create(TabContainer,TweenOut75Sine,{Size = UDim2.new(0,112,0,tabsettings.SizeY + 37)}):Play()
					TweenService:Create(DropShadow,TweenOut75Sine,{Size = UDim2.new(0,112,0,tabsettings.SizeY + 37)}):Play()
					TweenService:Create(MinimizeButton,TweenOut32Sine,{Rotation = 0}):Play()
				else
					TweenService:Create(ElementsFrame,TweenOut75Sine,{Size = UDim2.new(1,0,0,10)}):Play()
					TweenService:Create(TabContainer,TweenOut75Sine,{Size = UDim2.new(0,112,0,37)}):Play()
					TweenService:Create(DropShadow,TweenOut75Sine,{Size = UDim2.new(0,112,0,37)}):Play()
					TweenService:Create(MinimizeButton,TweenOut32Sine,{Rotation = 180}):Play()
				end
			elseif idx == "CanvasSizeY" then
				if typeof(value) ~= "number" then return warn("CanvasSizeY must be a number") end
				tabsettings.CanvasSizeY = value
				ElementsContainer.CanvasSize = UDim2.new(0,0,0,tabsettings.CanvasSizeY)
			elseif idx == "Visible" then
				if typeof(value) ~= "boolean" then return warn("Visible must be a boolean") end
				tabsettings.Visible = value
				local size
				if tabsettings.Visible then
					if tabsettings.Opened then
						size = UDim2.new(0,112,0,tabsettings.SizeY + 37)
					else
						size = UDim2.new(0,112,0,37)
					end
				else
					size = UDim2.new(0,112,0,0)
				end
				TweenService:Create(TabContainer,TweenOut75Sine,{Size = size}):Play()
			elseif idx == "IgnoreList" then
				if typeof(value) ~= "table" then return warn("IgnoreList must be a table") end
				tabsettings.IgnoreList = value
			else
				return
			end
			if tabsettings.Flag ~= nil and canupdateflags == true then
				UpdateFlags(tabsettings)
			end
		end
		function mt.__index(self, idx)
			if idx == "Title" then
				return tabsettings.Title
			elseif idx == "Subtitle" then
				return tabsettings.Subtitle
			elseif idx == "TitleRichText" then
				return tabsettings.TitleRichText
			elseif idx == "SubtitleRichText" then
				return tabsettings.SubtitleRichText
			elseif idx == "SizeY" then
				return tabsettings.SizeY
			elseif idx == "MaxSizeY" then
				return tabsettings.MaxSizeY
			elseif idx == "Position" then
				return tabsettings.Position
			elseif idx == "Opened" then
				return tabsettings.Opened
			elseif idx == "CanvasSizeY" then
				return tabsettings.CanvasSizeY
			elseif idx == "Visible" then
				return tabsettings.Visible
			elseif idx == "Instance" then
				return Tab
			elseif idx == "ClassName" then
				return "Tab"
			elseif idx == "Flag" then
				return tabsettings.Flag
			elseif idx == "IgnoreList" then
				return tabsettings.IgnoreList
			else
				return
			end
		end
		-- Tab Main
		MakeDraggable(true,TabContainer)
		MinimizeButton.MouseButton1Click:Connect(function()
			TabModule.Opened = not tabsettings.Opened
		end)
		function TabModule:CreateButton(buttonsettings)
			-- Tab Settings
			buttonsettings.Name = buttonsettings.Name ~= nil and buttonsettings.Name or "Button"
			buttonsettings.RichText = buttonsettings.RichText ~= nil and buttonsettings.RichText or false
			buttonsettings.SectionParent = buttonsettings.SectionParent ~= nil and buttonsettings.SectionParent or nil
			buttonsettings.Callback = buttonsettings.Callback ~= nil and buttonsettings.Callback or function() end
			buttonsettings.Active = buttonsettings.Active == nil or buttonsettings.Active
			buttonsettings.Visible = buttonsettings.Visible == nil or buttonsettings.Visible
			buttonsettings.Tip = buttonsettings.Tip ~= "" and buttonsettings.Tip or nil
			buttonsettings.TipDuration = buttonsettings.TipDuration ~= nil and buttonsettings.TipDuration or 5
			if typeof(buttonsettings.Name) ~= "string" then return warn("Name must be a string") end
			if typeof(buttonsettings.RichText) ~= "boolean" then return warn("RichText must be a boolean") end
			if (typeof(buttonsettings.SectionParent) ~= "table" or buttonsettings.SectionParent.ClassName ~= "SectionParent") and buttonsettings.SectionParent ~= nil then return warn("SectionParent must be a SectionParentIdentifier") end
			if typeof(buttonsettings.Callback) ~= "function" then return warn("Callback must be a function") end
			if typeof(buttonsettings.Active) ~= "boolean" then return warn("Active must be a boolean") end
			if typeof(buttonsettings.Visible) ~= "boolean" then return warn("Visible must be a boolean") end
			if typeof(buttonsettings.Tip) ~= "string" and buttonsettings.Tip ~= nil then return warn("Tip must be a string") end
			if typeof(buttonsettings.TipDuration) ~= "number" then return warn("TipDuration must be a number") end
			-- Button
			local ButtonElement = FPSLibraryAssets:WaitForChild("Button"):Clone()
			local ElementIcon = ButtonElement:WaitForChild("Icon")
			local Fade = ButtonElement:WaitForChild("Fade")
			local ButtonNameLabel = ButtonElement:WaitForChild("NameTextLabel")
			local ButtonModule = {}
			local mt = {}
			-- Metatable Functions
			function mt.__index(self,idx)
				if idx == "Name" then
					return buttonsettings.Name
				elseif idx == "RichText" then
					return buttonsettings.RichText
				elseif idx == "SectionParent" then
					return buttonsettings.SectionParent
				elseif idx == "Callback" then
					return buttonsettings.Callback
				elseif idx == "Active" then
					return buttonsettings.Active
				elseif idx == "Visible" then
					return buttonsettings.Visible
				elseif idx == "Tip" then
					return buttonsettings.Tip
				elseif idx == "TipDuration" then
					return buttonsettings.TipDuration
				elseif idx == "Instance" then
					return ButtonElement
				elseif idx == "ClassName" then
					return "ButtonElement"
				else
					return
				end
			end
			function mt.__newindex(self,idx,value)
				if idx == "Name" then
					if typeof(value) ~= "string" then return end
					buttonsettings.Name = tostring(value)
					ButtonNameLabel.Text = buttonsettings.Name
				elseif idx == "RichText" then
					if typeof(value) ~= "boolean" then return end
					buttonsettings.RichText = value
					ButtonNameLabel.RichText = buttonsettings.RichText
				elseif idx == "SectionParent" then
					if (typeof(value) ~= "table" or value.ClassName ~= "SectionParent") and value ~= nil then return end
					buttonsettings.SectionParent = value and value.ClassName == "SectionParent" and value or TabModule
					ButtonElement.Parent = value and value.ClassName == "SectionParent" and value.Instance.Dropdown.Container or ElementsContainer
					UpdateCanvasSize(TabModule)
				elseif idx == "Active" then
					if typeof(value) ~= "boolean" then return end
					buttonsettings.Active = value
					ButtonElement.Interactable = buttonsettings.Active
					if buttonsettings.Active then
						Fade.Transparency = 1
						ElementIcon.ImageTransparency = 1
						ElementIcon.ImageColor3 = Color3.fromRGB(84,84,84)
						ButtonNameLabel.Size = UDim2.new(1,0,1,0)
						ButtonNameLabel.Position = UDim2.new(0,0,0,0)
					else
						Fade.Transparency = 0.75
						ElementIcon.ImageTransparency = 0
						ElementIcon.Image = Icons.DisabledElementIcon
						ElementIcon.ImageColor3 = Color3.fromRGB(32,32,32)
						ButtonNameLabel.Size = UDim2.new(1,-10,1,0)
						ButtonNameLabel.Position = UDim2.new(0,10,0,0)
					end
				elseif idx == "Visible" then
					if typeof(value) ~= "boolean" then return end
					buttonsettings.Visible = value
					ButtonElement.Visible = buttonsettings.Visible
					UpdateCanvasSize(TabModule)
				elseif idx == "Tip" then
					if typeof(value) ~= "string" and value ~= nil then return end
					buttonsettings.Tip = value ~= nil and tostring(value) or value
					UpdateElementTip(value ~= nil,ButtonElement,buttonsettings.Tip,buttonsettings.TipDuration)
				elseif idx == "TipDuration" then
					if typeof(value) ~= "number" then return end
					buttonsettings.TipDuration = value
					UpdateElementTip(buttonsettings.Tip ~= nil,ButtonElement,buttonsettings.Tip,buttonsettings.TipDuration)
				else
					return
				end
			end
			-- Button Main
			RippleEffects(ButtonElement)
			ButtonElement.MouseButton1Click:Connect(function()
				if buttonsettings.Callback and buttonsettings.Active then
					Callback(buttonsettings.Callback)
				end
			end)
			layoutorder += 2
			ButtonElement.LayoutOrder = layoutorder
			-- Set Metatable
			setmetatable(ButtonModule,mt)
			-- Elements Table
			table.insert(FPSLibrary.Elements,ButtonModule)
			-- Set Configs
			ButtonModule.Name = buttonsettings.Name
			ButtonModule.RichText = buttonsettings.RichText
			ButtonModule.SectionParent = buttonsettings.SectionParent
			ButtonModule.Callback = buttonsettings.Callback
			ButtonModule.Active = buttonsettings.Active
			ButtonModule.Visible = buttonsettings.Visible
			ButtonModule.Tip = buttonsettings.Tip
			ButtonModule.TipDuration = buttonsettings.TipDuration
			-- Return Module
			return ButtonModule
		end
		function TabModule:CreateToggle(togglesettings)
			togglesettings.Name = togglesettings.Name or "Toggle"
			togglesettings.RichText = togglesettings.RichText or false
			togglesettings.ActivatedColor = togglesettings.ActivatedColor or Color3.fromRGB(255, 206, 92)
			togglesettings.SectionParent = togglesettings.SectionParent or nil
			togglesettings.CurrentValue = togglesettings.CurrentValue or false
			togglesettings.Flag = togglesettings.Flag ~= "" and togglesettings.Flag or nil
			togglesettings.IgnoreList = togglesettings.IgnoreList or {}
			togglesettings.Callback = togglesettings.Callback or function() end
			togglesettings.Active = togglesettings.Active == nil or togglesettings.Active
			togglesettings.Visible = togglesettings.Visible == nil or togglesettings.Visible
			togglesettings.Tip = togglesettings.Tip ~= "" and togglesettings.Tip or nil
			togglesettings.TipDuration = togglesettings.TipDuration or 5
			if typeof(togglesettings.Name) ~= "string" then return end
			if typeof(togglesettings.RichText) ~= "boolean" then return end
			if typeof(togglesettings.ActivatedColor) ~= "Color3" then return end
			if (typeof(togglesettings.SectionParent) ~= "table" or togglesettings.SectionParent.ClassName ~= "SectionParent") and togglesettings.SectionParent ~= nil then return end
			if typeof(togglesettings.CurrentValue) ~= "boolean" then return end
			if togglesettings.Flag ~= nil and typeof(togglesettings.Flag) ~= "string" then return end
			if typeof(togglesettings.IgnoreList) ~= "table" then return end
			if typeof(togglesettings.Callback) ~= "function" then return end
			if typeof(togglesettings.Active) ~= "boolean" then return end
			if typeof(togglesettings.Visible) ~= "boolean" then return end
			if typeof(togglesettings.Tip) ~= "string" and togglesettings.Tip ~= nil then return end
			if typeof(togglesettings.TipDuration) ~= "number" then return end
			-- Toggle
			local ToggleElement = FPSLibraryAssets:WaitForChild("Toggle"):Clone()
			local ElementIcon = ToggleElement:WaitForChild("Icon")
			local Fade = ToggleElement:WaitForChild("Fade")
			local ToggleNameLabel = ToggleElement:WaitForChild("NameTextLabel")
			local SwitchBackground = ToggleElement:WaitForChild("Switch")
			local SwitchCircle = SwitchBackground:WaitForChild("Circle")
			local SwitchGlow = SwitchBackground:WaitForChild("Glow")
			local ToggleModule = {}
			local mt = {}
			-- Variables
			local canupdateflags = false
			-- Metatable Functions
			function mt.__index(self,idx)
				if idx == "Name" then
					return togglesettings.Name
				elseif idx == "RichText" then
					return togglesettings.RichText
				elseif idx == "ActivatedColor" then
					return togglesettings.ActivatedColor
				elseif idx == "SectionParent" then
					return togglesettings.SectionParent
				elseif idx == "CurrentValue" then
					return togglesettings.CurrentValue
				elseif idx == "Flag" then
					return togglesettings.Flag
				elseif idx == "Callback" then
					return togglesettings.Callback
				elseif idx == "IgnoreList" then
					return togglesettings.IgnoreList
				elseif idx == "Active" then
					return togglesettings.Active
				elseif idx == "Visible" then
					return togglesettings.Visible
				elseif idx == "Tip" then
					return togglesettings.Tip
				elseif idx == "TipDuration" then
					return togglesettings.TipDuration
				elseif idx == "Instance" then
					return ToggleElement
				elseif idx == "ClassName" then
					return "ToggleElement"
				else
					return
				end
			end
			function mt.__newindex(self,idx,value)
				if idx == "Name" then
					if typeof(value) ~= "string" then return end
					togglesettings.Name = tostring(value)
					ToggleNameLabel.Text = togglesettings.Name
				elseif idx == "RichText" then
					if typeof(value) ~= "boolean" then return end
					togglesettings.RichText = value
					ToggleNameLabel.RichText = togglesettings.RichText
				elseif idx == "ActivatedColor" then
					if typeof(value) ~= "Color3" then return end
					togglesettings.ActivatedColor = value
					if togglesettings.CurrentValue then
						TweenService:Create(SwitchBackground,TweenOut32Sine,{BackgroundColor3 = togglesettings.ActivatedColor}):Play()
					end
				elseif idx == "SectionParent" then
					if (typeof(value) ~= "table" or value.ClassName ~= "SectionParent") and value ~= nil then return end
					togglesettings.SectionParent = value and value.ClassName == "SectionParent" and value or TabModule
					ToggleElement.Parent = value and value.ClassName == "SectionParent" and value.Instance.Dropdown.Container or ElementsContainer
					UpdateCanvasSize(TabModule)
				elseif idx == "CurrentValue" then
					if typeof(value) ~= "boolean" then return end
					togglesettings.CurrentValue = value
					if togglesettings.CurrentValue then
						TweenService:Create(SwitchCircle,TweenOut32Sine,{Position = UDim2.new(0,14,0.5,0)}):Play()
						TweenService:Create(SwitchGlow,TweenOut32Sine,{ImageTransparency = 0}):Play()
						TweenService:Create(SwitchGlow,TweenOut32Sine,{ImageColor3 = togglesettings.ActivatedColor}):Play()
						TweenService:Create(SwitchBackground,TweenOut32Sine,{BackgroundColor3 = togglesettings.ActivatedColor}):Play()
					else
						TweenService:Create(SwitchCircle,TweenOut32Sine,{Position = UDim2.new(0,2,0.5,0)}):Play()
						TweenService:Create(SwitchGlow,TweenOut32Sine,{ImageTransparency = 1}):Play()
						TweenService:Create(SwitchGlow,TweenOut32Sine,{ImageColor3 = Color3.fromRGB(54, 54, 54)}):Play()
						TweenService:Create(SwitchBackground,TweenOut32Sine,{BackgroundColor3 = Color3.fromRGB(54, 54, 54)}):Play()
					end
				elseif idx == "IgnoreList" then
					if typeof(value) ~= "table" then return end
					togglesettings.IgnoreList = value
				elseif idx == "Active" then
					if typeof(value) ~= "boolean" then return end
					togglesettings.Active = value
					ToggleElement.Interactable = togglesettings.Active
					if togglesettings.Active then
						Fade.Transparency = 1
						ElementIcon.ImageColor3 = Color3.fromRGB(84,84,84)
						ElementIcon.ImageTransparency = 1
						ToggleNameLabel.Size = UDim2.new(1,-23,1,0)
						ToggleNameLabel.Position = UDim2.new(0,0,0,0)
					else
						Fade.Transparency = 0.75
						ElementIcon.ImageTransparency = 0
						ElementIcon.ImageColor3 = Color3.fromRGB(32,32,32)
						ElementIcon.Image = Icons.DisabledElementIcon
						ToggleNameLabel.Size = UDim2.new(1,-33,1,0)
						ToggleNameLabel.Position = UDim2.new(0,10,0,0)
					end
				elseif idx == "Visible" then
					if typeof(value) ~= "boolean" then return end
					togglesettings.Visible = value
					ToggleElement.Visible = togglesettings.Visible
					UpdateCanvasSize(TabModule)
				elseif idx == "Tip" then
					if typeof(value) ~= "string" and value ~= nil then return end
					togglesettings.Tip = value ~= nil and tostring(value) or value
					UpdateElementTip(value ~= nil,ToggleElement,togglesettings.Tip,togglesettings.TipDuration)
				elseif idx == "TipDuration" then
					if typeof(value) ~= "number" then return end
					togglesettings.TipDuration = value
					UpdateElementTip(togglesettings.Tip ~= nil,ToggleElement,togglesettings.Tip,togglesettings.TipDuration)
				else
					return
				end
				if togglesettings.Flag and canupdateflags then
					UpdateFlags(togglesettings)
				end
			end
			-- Toggle Main
			layoutorder += 2
			ToggleElement.LayoutOrder = layoutorder
			RippleEffects(ToggleElement)
			ToggleElement.MouseButton1Click:Connect(function()
				ToggleModule.CurrentValue = not ToggleModule.CurrentValue
				if togglesettings.Callback and togglesettings.Active then
					Callback(togglesettings.Callback,togglesettings.CurrentValue)
				end
			end)
			-- Set Metatable
			setmetatable(ToggleModule,mt)
			-- Elements Table
			table.insert(FPSLibrary.Elements,ToggleModule)
			-- Set Configs
			ToggleModule.Name = togglesettings.Name
			ToggleModule.RichText = togglesettings.RichText
			ToggleModule.ActivatedColor = togglesettings.ActivatedColor
			ToggleModule.SectionParent = togglesettings.SectionParent
			ToggleModule.CurrentValue = togglesettings.CurrentValue
			ToggleModule.Callback = togglesettings.Callback
			ToggleModule.IgnoreList = togglesettings.IgnoreList
			ToggleModule.Active = togglesettings.Active
			ToggleModule.Visible = togglesettings.Visible
			ToggleModule.Tip = togglesettings.Tip
			ToggleModule.TipDuration = togglesettings.TipDuration
			-- Update Flags
			if togglesettings.Flag then
				FPSLibrary.Flags[togglesettings.Flag] = {}
				canupdateflags = true
				UpdateFlags(togglesettings)
			end
			-- Return Module
			return ToggleModule
		end
		function TabModule:CreateSlider(slidersettings)
			slidersettings.Name = slidersettings.Name or "Slider"
			slidersettings.RichText = slidersettings.RichText or false
			slidersettings.ScrollBarRichText = slidersettings.ScrollBarRichText or false
			slidersettings.SliderColor = slidersettings.SliderColor or Color3.fromRGB(255,206,92)
			slidersettings.BlendColors = slidersettings.BlendColors or false
			slidersettings.MinColor = slidersettings.MinColor or Color3.fromRGB(255,92,92)
			slidersettings.MaxColor = slidersettings.MaxColor or Color3.fromRGB(255,206,92)
			slidersettings.SectionParent = slidersettings.SectionParent or nil
			slidersettings.MinValue = slidersettings.MinValue or 0
			slidersettings.MaxValue = slidersettings.MaxValue or 100
			slidersettings.CurrentValue = slidersettings.CurrentValue or 0
			slidersettings.Increment = slidersettings.Increment or 1
			slidersettings.FormatString = slidersettings.FormatString ~= "" and slidersettings.FormatString or "%d"
			slidersettings.CallbackOnRelease = slidersettings.CallbackOnRelease or false
			slidersettings.Flag = slidersettings.Flag ~= "" and slidersettings.Flag or nil
			slidersettings.IgnoreList = slidersettings.IgnoreList or {}
			slidersettings.Callback = slidersettings.Callback or function() end
			slidersettings.Active = slidersettings.Active == nil or slidersettings.Active
			slidersettings.Visible = slidersettings.Visible == nil or slidersettings.Visible
			slidersettings.Tip = slidersettings.Tip ~= "" and slidersettings.Tip or nil
			slidersettings.TipDuration = slidersettings.TipDuration or 5
			if typeof(slidersettings.Name) ~= "string" then return end
			if typeof(slidersettings.RichText) ~= "boolean" then return end
			if typeof(slidersettings.ScrollBarRichText) ~= "boolean" then return end
			if typeof(slidersettings.SliderColor) ~= "Color3" then return end
			if typeof(slidersettings.BlendColors) ~= "boolean" then return end
			if typeof(slidersettings.MinColor) ~= "Color3" then return end
			if typeof(slidersettings.MaxColor) ~= "Color3" then return end
			if (typeof(slidersettings.SectionParent) ~= "table" or slidersettings.SectionParent.ClassName ~= "SectionParent") and slidersettings.SectionParent ~= nil then return end
			if typeof(slidersettings.MinValue) ~= "number" then return end
			if typeof(slidersettings.MaxValue) ~= "number" then return end
			if typeof(slidersettings.CurrentValue) ~= "number" then return end
			if typeof(slidersettings.Increment) ~= "number" then return end
			if typeof(slidersettings.FormatString) ~= "string" then return end
			if typeof(slidersettings.CallbackOnRelease) ~= "boolean" then return end
			if slidersettings.Flag ~= nil and typeof(slidersettings.Flag) ~= "string" then return end
			if typeof(slidersettings.IgnoreList) ~= "table" then return end
			if typeof(slidersettings.Callback) ~= "function" then return end
			if typeof(slidersettings.IgnoreList) ~= "table" then return end
			if typeof(slidersettings.Active) ~= "boolean" then return end
			if typeof(slidersettings.Visible) ~= "boolean" then return end
			if typeof(slidersettings.Tip) ~= "string" and slidersettings.Tip ~= nil then return end
			if typeof(slidersettings.TipDuration) ~= "number" then return end
			if slidersettings.MinValue > slidersettings.MaxValue then slidersettings.MinValue = slidersettings.MaxValue end
			if slidersettings.Increment <= 0 then return end
			-- Slider
			local SliderElement = FPSLibraryAssets:WaitForChild("Slider"):Clone()
			local ElementIcon = SliderElement:WaitForChild("Icon")
			local Fade = SliderElement:WaitForChild("Fade")
			local SliderNameLabel = SliderElement:WaitForChild("NameTextLabel")
			local SliderBackground = SliderElement:WaitForChild("SliderSection"):WaitForChild("SliderBackground")
			local Slider = SliderBackground:WaitForChild("Slider")
			local Glow = Slider:WaitForChild("Glow")
			local ValueTextLabel = SliderBackground:WaitForChild("Value")
			local SliderModule = {}
			local mt = {}
			-- Variables
			local canupdateflags = false
			-- Functions
			local function SliderBlendColors()
				SliderModule.SliderColor = BlendColors(
					slidersettings.MinColor,((slidersettings.MaxValue-slidersettings.MinValue) - (slidersettings.CurrentValue - slidersettings.MinValue))/(slidersettings.MaxValue-slidersettings.MinValue),
					slidersettings.MaxColor,((slidersettings.MaxValue-slidersettings.MinValue) - (slidersettings.MaxValue - slidersettings.CurrentValue))/(slidersettings.MaxValue-slidersettings.MinValue)
				)
			end
			-- Metatable Functions
			function mt.__index(self,idx)
				if idx == "Name" then
					return slidersettings.Name
				elseif idx == "RichText" then
					return slidersettings.RichText
				elseif idx == "ScrollBarRichText" then
					return slidersettings.ScrollBarRichText
				elseif idx == "SliderColor" then
					return slidersettings.SliderColor
				elseif idx == "BlendColors" then
					return slidersettings.BlendColors
				elseif idx == "MinColor" then
					return slidersettings.MinColor
				elseif idx == "MaxColor" then
					return slidersettings.MaxColor
				elseif idx == "SectionParent" then
					return slidersettings.SectionParent
				elseif idx == "MinValue" then
					return slidersettings.MinValue
				elseif idx == "MaxValue" then
					return slidersettings.MaxValue
				elseif idx == "CurrentValue" then
					return slidersettings.CurrentValue
				elseif idx == "Increment" then
					return slidersettings.Increment
				elseif idx == "FormatString" then
					return slidersettings.FormatString
				elseif idx == "CallbackOnRelease" then
					return slidersettings.CallbackOnRelease
				elseif idx == "Flag" then
					return slidersettings.Flag
				elseif idx == "IgnoreList" then
					return slidersettings.IgnoreList
				elseif idx == "Callback" then
					return slidersettings.Callback
				elseif idx == "Active" then
					return slidersettings.Active
				elseif idx == "Visible" then
					return slidersettings.Visible
				elseif idx == "Tip" then
					return slidersettings.Tip
				elseif idx == "TipDuration" then
					return slidersettings.TipDuration
				elseif idx == "Instance" then
					return SliderElement
				elseif idx == "ClassName" then
					return "SliderElement"
				else
					return
				end
			end
			function mt.__newindex(self,idx,value)
				if idx == "Name" then
					if typeof(value) ~= "string" then return end
					slidersettings.Name = tostring(value)
					SliderNameLabel.Text = slidersettings.Name
				elseif idx == "RichText" then
					if typeof(value) ~= "boolean" then return end
					slidersettings.RichText = value
					SliderNameLabel.RichText = slidersettings.RichText
				elseif idx == "ScrollBarRichText" then
					if typeof(value) ~= "boolean" then return end
					slidersettings.ScrollBarRichText = value
					ValueTextLabel.RichText = slidersettings.ScrollBarRichText
				elseif idx == "SliderColor" then
					if typeof(value) ~= "Color3" then return end
					slidersettings.SliderColor = value
					Slider.BackgroundColor3 = slidersettings.SliderColor
					Glow.ImageColor3 = slidersettings.SliderColor
				elseif idx == "BlendColors" then
					if typeof(value) ~= "boolean" then return end
					slidersettings.BlendColors = value
					if slidersettings.BlendColors then
						SliderBlendColors()
					else
						SliderModule.SliderColor = slidersettings.SliderColor
					end
				elseif idx == "MinColor" then
					if typeof(value) ~= "Color3" then return end
					slidersettings.MinColor = value
					if slidersettings.BlendColors then
						SliderBlendColors()
					end
				elseif idx == "MaxColor" then
					if typeof(value) ~= "Color3" then return end
					slidersettings.MaxColor = value
					if slidersettings.BlendColors then
						SliderBlendColors()
					end
				elseif idx == "SectionParent" then
					if (typeof(value) ~= "table" or value.ClassName ~= "SectionParent") and value ~= nil then return end
					slidersettings.SectionParent = value and value.ClassName == "SectionParent" and value or TabModule
					SliderElement.Parent = value and value.ClassName == "SectionParent" and value.Instance.Dropdown.Container or ElementsContainer
					UpdateCanvasSize(TabModule)
				elseif idx == "MinValue" then
					if typeof(value) ~= "number" then return end
					slidersettings.MinValue = slidersettings.MinValue <= slidersettings.MaxValue and slidersettings.MinValue or slidersettings.MaxValue
				elseif idx == "MaxValue" then
					if typeof(value) ~= "number" then return end
					slidersettings.MaxValue = slidersettings.MaxValue >= slidersettings.MinValue and slidersettings.MaxValue or slidersettings.MinValue
				elseif idx == "CurrentValue" then
					if typeof(value) ~= "number" then return end
					local dp = tostring(slidersettings.Increment):split(".")[2]
					dp = dp and #dp or 0
					local val = math.clamp(tonumber(string.format("%."..dp.."f",value)),slidersettings.MinValue,slidersettings.MaxValue)
					ValueTextLabel.Text = slidersettings.FormatString ~= "" and string.format(slidersettings.FormatString,val) or tostring(val)
					slidersettings.CurrentValue = val
					TweenService:Create(Slider,TweenOut20Sine,{Size = UDim2.new(slidersettings.CurrentValue / slidersettings.MaxValue,0,1,0)}):Play()
					Glow.ImageTransparency = slidersettings.CurrentValue == slidersettings.MinValue and 1 or 0
					if slidersettings.BlendColors then
						SliderBlendColors()
					end
				elseif idx == "IgnoreList" then
					if typeof(value) ~= "table" then return end
					slidersettings.IgnoreList = value
				elseif idx == "Increment" then
					if typeof(value) ~= "number" then return end
					slidersettings.Increment = value
				elseif idx == "FormatString" then
					if typeof(value) ~= "string" then return end
					slidersettings.FormatString = value
				elseif idx == "CallbackOnRelease" then
					if typeof(value) ~= "boolean" then return end
					slidersettings.CallbackOnRelease = value
				elseif idx == "Active" then
					if typeof(value) ~= "boolean" then return end
					slidersettings.Active = value
					SliderElement.Interactable = slidersettings.Active
					if slidersettings.Active then
						Fade.Transparency = 1
						ElementIcon.ImageTransparency = 1
						ElementIcon.ImageColor3 = Color3.fromRGB(84,84,84)
						SliderNameLabel.Size = UDim2.new(1,0,0.5,0)
						SliderNameLabel.Position = UDim2.new(0,0,0,0)
					else
						Fade.Transparency = 0.75
						ElementIcon.ImageTransparency = 0
						ElementIcon.ImageColor3 = Color3.fromRGB(32,32,32)
						ElementIcon.Image = Icons.DisabledElementIcon
						SliderNameLabel.Size = UDim2.new(1,-10,0.5,0)
						SliderNameLabel.Position = UDim2.new(0,10,0,0)
					end
				elseif idx == "Visible" then
					if typeof(value) ~= "boolean" then return end
					slidersettings.Visible = value
					SliderElement.Visible = slidersettings.Visible
					UpdateCanvasSize(TabModule)
				elseif idx == "Tip" then
					if typeof(value) ~= "string" and value ~= nil then return end
					slidersettings.Tip = value ~= nil and tostring(value) or value
					UpdateElementTip(value ~= nil,SliderElement,slidersettings.Tip,slidersettings.TipDuration)
				elseif idx == "TipDuration" then
					if typeof(value) ~= "number" then return end
					slidersettings.TipDuration = value
					UpdateElementTip(slidersettings.Tip ~= nil,SliderElement,slidersettings.Tip,slidersettings.TipDuration)
				else
					return
				end
				if slidersettings.Flag and canupdateflags then
					UpdateFlags(slidersettings)
				end
			end
			-- Slider Main
			layoutorder += 2
			SliderElement.LayoutOrder = layoutorder
			SliderElement.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					local renderstepped
					local inputchanged
					renderstepped = RunService.RenderStepped:Connect(function()
						local startpos = SliderBackground.AbsolutePosition.X
						local endpos = startpos + SliderBackground.AbsoluteSize.X
						local proportion = math.clamp((mouse.X - startpos)/(endpos - startpos),0,1)
						SliderModule.CurrentValue = math.floor((slidersettings.MaxValue * proportion) / slidersettings.Increment) * slidersettings.Increment + slidersettings.MinValue
						if not slidersettings.CallbackOnRelease then
							Callback(slidersettings.Callback,slidersettings.CurrentValue)
						end
					end)
					inputchanged = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							task.spawn(Callback,slidersettings.Callback,slidersettings.CurrentValue)
							renderstepped:Disconnect()
							inputchanged:Disconnect()
						end
					end)
				end
			end)
			-- Set Metatable
			setmetatable(SliderModule,mt)
			-- Elements Table
			table.insert(FPSLibrary.Elements,SliderModule)
			-- Set Configs
			SliderModule.Name = slidersettings.Name
			SliderModule.RichText = slidersettings.RichText
			SliderModule.ScrollBarRichText = slidersettings.ScrollBarRichText
			SliderModule.SliderColor = slidersettings.SliderColor
			SliderModule.BlendColors = slidersettings.BlendColors
			SliderModule.MinColor = slidersettings.MinColor
			SliderModule.MaxColor = slidersettings.MaxColor
			SliderModule.SectionParent = slidersettings.SectionParent
			SliderModule.MinValue = slidersettings.MinValue
			SliderModule.MaxValue = slidersettings.MaxValue
			SliderModule.CurrentValue = slidersettings.CurrentValue
			SliderModule.IgnoreList = slidersettings.IgnoreList
			SliderModule.Increment = slidersettings.Increment
			SliderModule.FormatString = slidersettings.FormatString
			SliderModule.CallbackOnRelease = slidersettings.CallbackOnRelease
			SliderModule.Flag = slidersettings.Flag
			SliderModule.Callback = slidersettings.Callback
			SliderModule.Active = slidersettings.Active
			SliderModule.Visible = slidersettings.Visible
			SliderModule.Tip = slidersettings.Tip
			SliderModule.TipDuration = slidersettings.TipDuration
			-- Update Flags
			if slidersettings.Flag then
				FPSLibrary.Flags[slidersettings.Flag] = {}
				canupdateflags = true
				UpdateFlags(slidersettings)
			end
			-- Return Module
			return SliderModule
		end
		function TabModule:CreateDropdown(dropdownsettings)
			-- Tab Settings
			dropdownsettings.Name = dropdownsettings.Name or "Dropdown"
			dropdownsettings.RichText = dropdownsettings.RichText or false
			dropdownsettings.Options = dropdownsettings.Options or {}
			dropdownsettings.CurrentOption = dropdownsettings.CurrentOption or {}
			dropdownsettings.SelectedColor = dropdownsettings.SelectedColor or Color3.fromRGB(121, 152, 255)
			dropdownsettings.MinOptions = dropdownsettings.MinOptions or 0
			dropdownsettings.MaxOptions = dropdownsettings.MaxOptions or 1
			dropdownsettings.SectionParent = dropdownsettings.SectionParent or nil
			dropdownsettings.Flag = dropdownsettings.Flag ~= "" and dropdownsettings.Flag or nil
			dropdownsettings.Callback = dropdownsettings.Callback or function() end
			dropdownsettings.IgnoreList = dropdownsettings.IgnoreList or {}
			dropdownsettings.Active = dropdownsettings.Active == nil or dropdownsettings.Active
			dropdownsettings.Visible = dropdownsettings.Visible == nil or dropdownsettings.Visible
			dropdownsettings.Tip = dropdownsettings.Tip ~= "" and dropdownsettings.Tip or nil
			dropdownsettings.TipDuration = dropdownsettings.TipDuration or 5
			if typeof(dropdownsettings.Name) ~= "string" then return end
			if typeof(dropdownsettings.RichText) ~= "boolean" then return end
			if typeof(dropdownsettings.Options) ~= "table" then return end
			if typeof(dropdownsettings.CurrentOption) ~= "table" then return end
			if typeof(dropdownsettings.SelectedColor) ~= "Color3" then return end
			if typeof(dropdownsettings.MinOptions) ~= "number" then return end
			if dropdownsettings.MinOptions < 0 then return end
			dropdownsettings.MinOptions = math.floor(dropdownsettings.MinOptions)
			if typeof(dropdownsettings.SelectedColor) ~= "Color3" then return end
			if typeof(dropdownsettings.MaxOptions) ~= "number" then return end
			if dropdownsettings.MaxOptions < 1 then return end
			dropdownsettings.MaxOptions = math.ceil(dropdownsettings.MaxOptions)
			if dropdownsettings.MinOptions > dropdownsettings.MaxOptions then return end
			if (typeof(dropdownsettings.SectionParent) ~= "table" or dropdownsettings.SectionParent.ClassName ~= "SectionParent") and dropdownsettings.SectionParent ~= nil then return end
			if dropdownsettings.Flag ~= nil and typeof(dropdownsettings.Flag) ~= "string" then return end
			if typeof(dropdownsettings.Callback) ~= "function" then return end
			if typeof(dropdownsettings.IgnoreList) ~= "table" then return end
			if typeof(dropdownsettings.Active) ~= "boolean" then return end
			if typeof(dropdownsettings.Visible) ~= "boolean" then return end
			if typeof(dropdownsettings.Tip) ~= "string" and dropdownsettings.Tip ~= nil then return end
			if typeof(dropdownsettings.TipDuration) ~= "number" then return end
			-- Dropdown
			local DropdownElement = FPSLibraryAssets:WaitForChild("Dropdown"):Clone()
			local ElementIcon = DropdownElement:WaitForChild("Icon")
			local Fade = DropdownElement:WaitForChild("Fade")
			local DropdownNameLabel = DropdownElement:WaitForChild("NameTextLabel")
			local CurrentOptionLabel = DropdownElement:WaitForChild("CurrentOptionTextLabel")
			local DropdownModule = {}
			local mt = {}
			-- Variables
			local opened = false
			local canupdateflags = false
			-- Metatable Functions
			function mt.__index(self,idx)
				if idx == "Name" then
					return dropdownsettings.Name
				elseif idx == "RichText" then
					return dropdownsettings.RichText
				elseif idx == "Options" then
					return dropdownsettings.Options
				elseif idx == "CurrentOption" then
					return dropdownsettings.CurrentOption
				elseif idx == "SelectedColor" then
					return dropdownsettings.SelectedColor
				elseif idx == "MaxOptions" then
					return dropdownsettings.MaxOptions
				elseif idx == "CallbackOnSelect" then
					return dropdownsettings.CallbackOnSelect
				elseif idx == "SectionParent" then
					return dropdownsettings.SectionParent
				elseif idx == "Flag" then
					return dropdownsettings.Flag
				elseif idx == "IgnoreList" then
					return dropdownsettings.IgnoreList
				elseif idx == "Callback" then
					return dropdownsettings.Callback
				elseif idx == "Active" then
					return dropdownsettings.Active
				elseif idx == "Visible" then
					return dropdownsettings.Visible
				elseif idx == "Tip" then
					return dropdownsettings.Tip
				elseif idx == "TipDuration" then
					return dropdownsettings.TipDuration
				elseif idx == "Instance" then
					return DropdownElement
				elseif idx == "ClassName" then
					return "DropdownElement"
				else
					return
				end
			end
			function mt.__newindex(self,idx,value)
				if idx == "Name" then
					if typeof(value) ~= "string" then return end
					dropdownsettings.Name = tostring(value)
					DropdownNameLabel.Text = dropdownsettings.Name
				elseif idx == "RichText" then
					if typeof(value) ~= "boolean" then return end
					dropdownsettings.RichText = value
					DropdownNameLabel.RichText = dropdownsettings.RichText
				elseif idx == "Options" then
					if typeof(value) ~= "table" then return end
					dropdownsettings.Options = value
				elseif idx == "CurrentOption" then
					if typeof(value) ~= nil and typeof(value) ~= "table" then return end
					dropdownsettings.CurrentOption = value or {}
					local str = ""
					local len = #dropdownsettings.CurrentOption
					for i, v in dropdownsettings.CurrentOption do
						if i < len then
							str = str..tostring(v)..", "
						else
							str = str..tostring(v)
						end
					end
					if len <= 0 then
						str = "n/a"
					end
					CurrentOptionLabel.Text = str
				elseif idx == "SelectedColor" then
					if typeof(value) ~= "Color3" then return end
					dropdownsettings.SelectedColor = value
				elseif idx == "MaxOptions" then
					if typeof(value) ~= "boolean" then return end
					dropdownsettings.MaxOptions = value
				elseif idx == "CallbackOnSelect" then
					if typeof(value) ~= "boolean" then return end
					dropdownsettings.CallbackOnSelect = value
				elseif idx == "SectionParent" then
					if (typeof(value) ~= "table" or value.ClassName ~= "SectionParent") and value ~= nil then return end
					dropdownsettings.SectionParent = value and value.ClassName == "SectionParent" and value or TabModule
					DropdownElement.Parent = value and value.ClassName == "SectionParent" and value.Instance.Dropdown.Container or ElementsContainer
					UpdateCanvasSize(TabModule)
				elseif idx == "IgnoreList" then
					if typeof(value) ~= "table" then return end
					dropdownsettings.IgnoreList = value
				elseif idx == "Active" then
					if typeof(value) ~= "boolean" then return end
					dropdownsettings.Active = value
					DropdownElement.Interactable = dropdownsettings.Active
					if dropdownsettings.Active then
						Fade.Transparency = 1
						ElementIcon.ImageTransparency = 1
						ElementIcon.ImageColor3 = Color3.fromRGB(84,84,84)
						DropdownNameLabel.Size = UDim2.new(0,68,0.5,0)
						DropdownNameLabel.Position = UDim2.new(0,0,0,0)
					else
						Fade.Transparency = 0.75
						ElementIcon.ImageTransparency = 0
						ElementIcon.ImageColor3 = Color3.fromRGB(32,32,32)
						ElementIcon.Image = Icons.DisabledElementIcon
						DropdownNameLabel.Size = UDim2.new(0,58,0.5,0)
						DropdownNameLabel.Position = UDim2.new(0,10,0,0)
					end
				elseif idx == "Visible" then
					if typeof(value) ~= "boolean" then return end
					dropdownsettings.Visible = value
					DropdownElement.Visible = dropdownsettings.Visible
					UpdateCanvasSize(TabModule)
				elseif idx == "Tip" then
					if typeof(value) ~= "string" and value ~= nil then return end
					dropdownsettings.Tip = value ~= nil and tostring(value) or value
					UpdateElementTip(value ~= nil,DropdownElement,dropdownsettings.Tip,dropdownsettings.TipDuration)
				elseif idx == "TipDuration" then
					if typeof(value) ~= "number" then return end
					dropdownsettings.TipDuration = value
					UpdateElementTip(dropdownsettings.Tip ~= nil,DropdownElement,dropdownsettings.Tip,dropdownsettings.TipDuration)
				else
					return
				end
				if dropdownsettings.Flag and canupdateflags then
					UpdateFlags(dropdownsettings)
				end
			end
			-- Dropdown Main
			layoutorder += 2
			DropdownElement.LayoutOrder = layoutorder
			RippleEffects(DropdownElement)
			DropdownElement.MouseButton1Click:Connect(function()
				if opened then return end
				opened = true
				local options = {}
				local renderstepped
				local mousedown
				local size = #dropdownsettings.Options
				local OptionsLayout = FPSLibraryAssets:WaitForChild("OptionsLayout"):Clone()
				OptionsLayout.Parent = Interface
				OptionsLayout.Size = UDim2.new(0,80,0,0)
				OptionsLayout.CanvasSize = UDim2.new(0,80,0,size * 12)
				TweenService:Create(OptionsLayout,TweenOut50Sine,{Size = UDim2.new(0,80,0,size <= 9 and size * 12 or 108)}):Play()
				local OptionExample = OptionsLayout:WaitForChild("Example")
				local function UpdateCurrentOptions()
					local currentoptions = {}
					for i, v in options do
						if v[2] then
							table.insert(currentoptions,i)
						end
					end
					DropdownModule.CurrentOption = currentoptions
					task.spawn(Callback,dropdownsettings.Callback,dropdownsettings.CurrentOption)
				end
				local function CountEnabledOptions()
					local count = 0
					for i, v in options do
						if v[2] then
							count += 1
						end
					end
					return count
				end
				local function Close()
					UpdateCurrentOptions()
					mousedown:Disconnect()
					opened = false
					TweenService:Create(OptionsLayout,TweenOut50Sine,{Size = UDim2.new(0,80,0,0)}):Play()
					task.wait(0.5)
					renderstepped:Disconnect()
					OptionsLayout:Destroy()
				end
				for i, v in dropdownsettings.Options do
					local Option = OptionExample:Clone()
					Option.Name = "Option #"..i
					Option.Parent = OptionsLayout
					Option.Visible = true
					Option.Text = tostring(v)
					local value = false
					if table.find(dropdownsettings.CurrentOption,v) then value = true end
					options[v] = {Option,value}
					Option.MouseButton1Click:Connect(function()
						if not opened then return end
						value = not value
						options[v] = {Option,value}
						local enabledoptions = CountEnabledOptions()
						if dropdownsettings.MaxOptions ~= 1 and enabledoptions > dropdownsettings.MaxOptions then
							value = false
							PlaySound(138090596)
						elseif enabledoptions < dropdownsettings.MinOptions then
							value = true
							PlaySound(138090596)
						end
						options[v] = {Option,value}
						if dropdownsettings.MaxOptions == 1 then
							for i2 in options do
								if i2 ~= v then
									options[i2][2] = false
								end
							end
							Close()
						elseif dropdownsettings.CallbackOnSelect then
							UpdateCurrentOptions()
						end
					end)
				end
				renderstepped = RunService.RenderStepped:Connect(function()
					OptionsLayout.Position = UDim2.new(0,DropdownElement.AbsolutePosition.X,0,DropdownElement.AbsolutePosition.Y + 24)
					for i, v in options do
						if v[2] then
							options[i][1].TextColor3 = Color3.fromRGB(121, 152, 255)
						else
							options[i][1].TextColor3 = Color3.fromRGB(255, 255, 255)
						end
					end
				end)
				mousedown = mouse.Button1Down:Connect(function()
					if not isHoveringOverObj(TabContainer) then
						Close()
					end
				end)
			end)
			-- Set Metatable
			setmetatable(DropdownModule,mt)
			-- Elements Table
			table.insert(FPSLibrary.Elements,DropdownModule)
			-- Set Configs
			DropdownModule.Name = dropdownsettings.Name
			DropdownModule.RichText = dropdownsettings.RichText
			DropdownModule.Options = dropdownsettings.Options
			DropdownModule.CurrentOption = dropdownsettings.CurrentOption
			DropdownModule.SelectedColor = dropdownsettings.SelectedColor
			DropdownModule.SectionParent = dropdownsettings.SectionParent
			DropdownModule.IgnoreList = dropdownsettings.IgnoreList
			DropdownModule.Callback = dropdownsettings.Callback
			DropdownModule.Active = dropdownsettings.Active
			DropdownModule.Visible = dropdownsettings.Visible
			DropdownModule.Tip = dropdownsettings.Tip
			DropdownModule.TipDuration = dropdownsettings.TipDuration
			-- Update Flags
			if dropdownsettings.Flag then
				FPSLibrary.Flags[dropdownsettings.Flag] = {}
				canupdateflags = true
				UpdateFlags(dropdownsettings)
			end
			-- Return Module
			return DropdownModule
		end
		function TabModule:CreateInput(textboxsettings)
			textboxsettings.Name = textboxsettings.Name or "Input"
			textboxsettings.PlaceholderText = textboxsettings.PlaceholderText or "Type anything here!"
			textboxsettings.ClearTextOnFocus = textboxsettings.ClearTextOnFocus or false
			textboxsettings.RichText = textboxsettings.RichText or false
			textboxsettings.CharacterLimit = textboxsettings.CharacterLimit or 20
			textboxsettings.SectionParent = textboxsettings.SectionParent or nil
			textboxsettings.CurrentValue = textboxsettings.CurrentValue or false
			textboxsettings.Flag = textboxsettings.Flag ~= "" and textboxsettings.Flag or nil
			textboxsettings.Callback = textboxsettings.Callback or function() end
			textboxsettings.IgnoreList = textboxsettings.IgnoreList or {}
			textboxsettings.Active = textboxsettings.Active == nil or textboxsettings.Active
			textboxsettings.Visible = textboxsettings.Visible == nil or textboxsettings.Visible
			textboxsettings.Tip = textboxsettings.Tip ~= "" and textboxsettings.Tip or nil
			textboxsettings.TipDuration = textboxsettings.TipDuration or 5
			if typeof(textboxsettings.Name) ~= "string" then return end
			if typeof(textboxsettings.PlaceholderText) ~= "string" then return end
			if typeof(textboxsettings.ClearTextOnFocus) ~= "boolean" then return end
			if typeof(textboxsettings.RichText) ~= "boolean" then return end
			if typeof(textboxsettings.CharacterLimit) ~= "number" then return end
			if (typeof(textboxsettings.SectionParent) ~= "table" or textboxsettings.SectionParent.ClassName ~= "SectionParent") and textboxsettings.SectionParent ~= nil then return end
			if typeof(textboxsettings.CurrentValue) ~= "string" then return end
			if textboxsettings.Flag ~= nil and typeof(textboxsettings.Flag) ~= "string" then return end
			if typeof(textboxsettings.Callback) ~= "function" then return end
			if typeof(textboxsettings.IgnoreList) ~= "table" then return end
			if typeof(textboxsettings.Active) ~= "boolean" then return end
			if typeof(textboxsettings.Visible) ~= "boolean" then return end
			if typeof(textboxsettings.Tip) ~= "string" and textboxsettings.Tip ~= nil then return end
			if typeof(textboxsettings.TipDuration) ~= "number" then return end
			-- Input
			local TextBoxElement = FPSLibraryAssets:WaitForChild("TextBox"):Clone()
			local TextBox = TextBoxElement:WaitForChild("TextBox")
			local ElementIcon = TextBox:WaitForChild("Icon")
			local TextBoxNameLabel = TextBoxElement:WaitForChild("NameTextLabel")
			local TextBoxModule = {}
			local mt = {}
			-- Variables
			local canupdateflags = false
			-- Functions
			local function TextBoxCallback()
				local text = textboxsettings.CurrentValue
				if textboxsettings.NumbersOnly then
					text = tonumber(textboxsettings.CurrentValue)
				end
				Callback(textboxsettings.Callback,text)
			end
			-- Metatable Functions
			function mt.__index(self,idx)
				if idx == "Name" then
					return textboxsettings.Name
				elseif idx == "PlaceholderText" then
					return textboxsettings.PlaceholderText
				elseif idx == "RichText" then
					return textboxsettings.RichText
				elseif idx == "CharacterLimit" then
					return textboxsettings.CharacterLimit
				elseif idx == "ClearTextOnFocus" then
					return textboxsettings.ClearTextOnFocus
				elseif idx == "SectionParent" then
					return textboxsettings.SectionParent
				elseif idx == "CurrentValue" then
					return textboxsettings.CurrentValue
				elseif idx == "Flag" then
					return textboxsettings.Flag
				elseif idx == "Callback" then
					return textboxsettings.Callback
				elseif idx == "IgnoreList" then
					return textboxsettings.IgnoreList
				elseif idx == "Active" then
					return textboxsettings.Active
				elseif idx == "Visible" then
					return textboxsettings.Visible
				elseif idx == "Tip" then
					return textboxsettings.Tip
				elseif idx == "TipDuration" then
					return textboxsettings.TipDuration
				elseif idx == "Instance" then
					return TextBoxElement
				elseif idx == "ClassName" then
					return "InputElement"
				else
					return
				end
			end
			function mt.__newindex(self,idx,value)
				if idx == "Name" then
					if typeof(value) ~= "string" then return end
					textboxsettings.Name = tostring(value)
					TextBoxNameLabel.Text = textboxsettings.Name
				elseif idx == "PlaceholderText" then
					if typeof(value) ~= "string" then return end
					textboxsettings.PlaceholderText = tostring(value)
					TextBox.PlaceholderText = textboxsettings.Active and textboxsettings.PlaceholderText or ""
				elseif idx == "RichText" then
					if typeof(value) ~= "boolean" then return end
					textboxsettings.RichText = value
					TextBoxNameLabel.RichText = textboxsettings.RichText
					TextBox.RichText = textboxsettings.RichText
				elseif idx == "CharacterLimit" then
					if typeof(value) ~= "number" then return end
					textboxsettings.CharacterLimit = value
				elseif idx == "ClearTextOnFocus" then
					if typeof(value) ~= "boolean" then return end
					textboxsettings.ClearTextOnFocus = value
					TextBox.ClearTextOnFocus = textboxsettings.ClearTextOnFocus
				elseif idx == "SectionParent" then
					if (typeof(value) ~= "table" or value.ClassName ~= "SectionParent") and value ~= nil then return end
					textboxsettings.SectionParent = value and value.ClassName == "SectionParent" and value or TabModule
					TextBoxElement.Parent = value and value.ClassName == "SectionParent" and value.Instance.Dropdown.Container or ElementsContainer
					UpdateCanvasSize(TabModule)
				elseif idx == "CurrentValue" then
					if typeof(value) ~= "string" then return end
					textboxsettings.CurrentValue = value
					TextBox.Text = textboxsettings.CurrentValue
				elseif idx == "IgnoreList" then
					if typeof(value) ~= "table" then return end
					textboxsettings.IgnoreList = value
				elseif idx == "Active" then
					if typeof(value) ~= "boolean" then return end
					textboxsettings.Active = value
					TextBox.Interactable = textboxsettings.Active
					if textboxsettings.Active then
						TextBox.PlaceholderText = textboxsettings.PlaceholderText
						ElementIcon.ImageColor3 = Color3.fromRGB(84,84,84)
						ElementIcon.ImageTransparency = 1
					else
						TextBox.PlaceholderText = ""
						ElementIcon.ImageTransparency = 0
						ElementIcon.ImageColor3 = Color3.fromRGB(32,32,32)
						ElementIcon.Image = Icons.DisabledElementIcon
					end
				elseif idx == "Visible" then
					if typeof(value) ~= "boolean" then return end
					textboxsettings.Visible = value
					TextBoxElement.Visible = textboxsettings.Visible
					UpdateCanvasSize(TabModule)
				elseif idx == "Tip" then
					if typeof(value) ~= "string" and value ~= nil then return end
					textboxsettings.Tip = value ~= nil and tostring(value) or value
					UpdateElementTip(value ~= nil,TextBoxElement,textboxsettings.Tip,textboxsettings.TipDuration)
				elseif idx == "TipDuration" then
					if typeof(value) ~= "number" then return end
					textboxsettings.TipDuration = value
					UpdateElementTip(textboxsettings.Tip ~= nil,TextBoxElement,textboxsettings.Tip,textboxsettings.TipDuration)
				else
					return
				end
				if textboxsettings.Flag and canupdateflags then
					UpdateFlags(textboxsettings)
				end
			end
			-- Input Main
			layoutorder += 2
			TextBoxElement.LayoutOrder = layoutorder
			TextBox.FocusLost:Connect(function()
				TextBoxModule.CurrentValue = TextBox.Text
				TextBoxCallback()
			end)
			TextBox:GetPropertyChangedSignal("Text"):Connect(function()
				if TextBox.Text == "" then return end
				if textboxsettings.NumbersOnly then
					TextBox.Text = TextBox.Text:gsub("%D+","") 
				end
				if textboxsettings.CharacterLimit then
					TextBox.Text = TextBox.Text:sub(1,textboxsettings.CharacterLimit)
				end
			end)
			-- Set Metatable
			setmetatable(TextBoxModule,mt)
			-- Elements Table
			table.insert(FPSLibrary.Elements,TextBoxModule)
			-- Set Configs
			TextBoxModule.Name = textboxsettings.Name
			TextBoxModule.PlaceholderText = textboxsettings.PlaceholderText
			TextBoxModule.NumbersOnly = textboxsettings.NumbersOnly
			TextBoxModule.RichText = textboxsettings.RichText
			TextBoxModule.CharacterLimit = textboxsettings.CharacterLimit
			TextBoxModule.ClearTextOnFocus = textboxsettings.ClearTextOnFocus
			TextBoxModule.SectionParent = textboxsettings.SectionParent
			TextBoxModule.Callback = textboxsettings.Callback
			TextBoxModule.IgnoreList = textboxsettings.IgnoreList
			TextBoxModule.Active = textboxsettings.Active
			TextBoxModule.Visible = textboxsettings.Visible
			TextBoxModule.Tip = textboxsettings.Tip
			TextBoxModule.TipDuration = textboxsettings.TipDuration
			-- Update Flags
			if textboxsettings.Flag then
				FPSLibrary.Flags[textboxsettings.Flag] = {}
				canupdateflags = true
				UpdateFlags(textboxsettings)
			end
			-- Return Module
			return TextBoxModule
		end
		function TabModule:CreateColorPicker(colorpickersettings)
			-- Tab Settings
			colorpickersettings.Name = colorpickersettings.Name or "Button"
			colorpickersettings.RichText = colorpickersettings.RichText or false
			colorpickersettings.CurrentColor = colorpickersettings.CurrentColor or Color3.fromRGB(255, 206, 92)
			colorpickersettings.CallbackOnRelease = colorpickersettings.CallbackOnRelease or false
			colorpickersettings.EnableRainbowMode = colorpickersettings.EnableRainbowMode or false
			colorpickersettings.Rainbow = colorpickersettings.Rainbow or false
			colorpickersettings.RainbowSpeed = colorpickersettings.RainbowSpeed or 1
			colorpickersettings.RainbowSaturation = colorpickersettings.RainbowSaturation or 163
			colorpickersettings.RainbowBrightness = colorpickersettings.RainbowBrightness or 255
			colorpickersettings.RainbowCallback = colorpickersettings.RainbowCallback or false
			colorpickersettings.SectionParent = colorpickersettings.SectionParent or nil
			colorpickersettings.Flag = colorpickersettings.Flag ~= "" and colorpickersettings.Flag or nil
			colorpickersettings.Callback = colorpickersettings.Callback or function() end
			colorpickersettings.Active = colorpickersettings.Active == nil or colorpickersettings.Active
			colorpickersettings.Visible = colorpickersettings.Visible == nil or colorpickersettings.Visible
			colorpickersettings.Tip = colorpickersettings.Tip ~= "" and colorpickersettings.Tip or nil
			colorpickersettings.TipDuration = colorpickersettings.TipDuration or 5
			if typeof(colorpickersettings.Name) ~= "string" then return end
			if typeof(colorpickersettings.RichText) ~= "boolean" then return end
			if typeof(colorpickersettings.CurrentColor) ~= "Color3" then return end
			if typeof(colorpickersettings.CallbackOnRelease) ~= "boolean" then return end
			if typeof(colorpickersettings.EnableRainbowMode) ~= "boolean" then return end
			if typeof(colorpickersettings.Rainbow) ~= "boolean" then return end
			if typeof(colorpickersettings.RainbowSpeed) ~= "number" then return end
			if typeof(colorpickersettings.RainbowSaturation) ~= "number" or colorpickersettings.RainbowSaturation > 255 then return end
			if typeof(colorpickersettings.RainbowBrightness) ~= "number" or colorpickersettings.RainbowBrightness > 255 then return end
			if typeof(colorpickersettings.RainbowCallback) ~= "boolean" then return end
			if (typeof(colorpickersettings.SectionParent) ~= "table" or colorpickersettings.SectionParent.ClassName ~= "SectionParent") and colorpickersettings.SectionParent ~= nil then return end
			if colorpickersettings.Flag ~= nil and typeof(colorpickersettings.Flag) ~= "string" then return end
			if typeof(colorpickersettings.Callback) ~= "function" then return end
			if typeof(colorpickersettings.Active) ~= "boolean" then return end
			if typeof(colorpickersettings.Visible) ~= "boolean" then return end
			if typeof(colorpickersettings.Tip) ~= "string" and colorpickersettings.Tip ~= nil then return end
			if typeof(colorpickersettings.TipDuration) ~= "number" then return end
			-- Variables
			local ColorPickerElement = FPSLibraryAssets:WaitForChild("ColorPicker"):Clone()
			local ElementIcon = ColorPickerElement:WaitForChild("Icon")
			local Fade = ColorPickerElement:WaitForChild("Fade")
			local ColorPickerNameLabel = ColorPickerElement:WaitForChild("NameTextLabel")
			local ColorFrame = ColorPickerElement:WaitForChild("ColorFrame")
			local Glow = ColorFrame:WaitForChild("Glow")
			Glow.ImageTransparency = 0
			local opened = false
			local canupdateflags = false
			local oldcolor
			local ColorPickerModule = {}
			local renderstepped
			local mt = {}
			-- Metatable Functions
			function mt.__index(self,idx)
				if idx == "Name" then
					return colorpickersettings.Name
				elseif idx == "RichText" then
					return colorpickersettings.RichText
				elseif idx == "CurrentColor" then
					return colorpickersettings.CurrentColor
				elseif idx == "CallbackOnRelease" then
					return colorpickersettings.CallbackOnRelease
				elseif idx == "EnableRainbowMode" then
					return colorpickersettings.EnableRainbowMode
				elseif idx == "Rainbow" then
					return colorpickersettings.Rainbow
				elseif idx == "RainbowSpeed" then
					return colorpickersettings.RainbowSpeed
				elseif idx == "RainbowSaturation" then
					return colorpickersettings.RainbowSaturation
				elseif idx == "RainbowBrightness" then
					return colorpickersettings.RainbowBrightness
				elseif idx == "RainbowCallback" then
					return colorpickersettings.RainbowCallback
				elseif idx == "SectionParent" then
					return colorpickersettings.SectionParent
				elseif idx == "Callback" then
					return colorpickersettings.Callback
				elseif idx == "Active" then
					return colorpickersettings.Active
				elseif idx == "Visible" then
					return colorpickersettings.Visible
				elseif idx == "Tip" then
					return colorpickersettings.Tip
				elseif idx == "TipDuration" then
					return colorpickersettings.TipDuration
				elseif idx == "Instance" then
					return ColorPickerElement
				elseif idx == "ClassName" then
					return "ColorPickerElement"
				elseif idx == "Flag" then
					return colorpickersettings.Flag
				else
					return
				end
			end
			function mt.__newindex(self,idx,value)
				if idx == "Name" then
					if typeof(value) ~= "string" then return end
					colorpickersettings.Name = tostring(value)
					ColorPickerNameLabel.Text = colorpickersettings.Name
				elseif idx == "RichText" then
					if typeof(value) ~= "boolean" then return end
					colorpickersettings.RichText = value
					ColorPickerNameLabel.RichText = colorpickersettings.RichText
				elseif idx == "CurrentColor" then
					if typeof(value) ~= "Color3" then return end
					colorpickersettings.CurrentColor = value
					Glow.ImageColor3 = colorpickersettings.CurrentColor
					ColorFrame.BackgroundColor3 = colorpickersettings.CurrentColor
				elseif idx == "CallbackOnRelease" then
					if typeof(value) ~= "boolean" then return end
					colorpickersettings.CallbackOnRelease = value
				elseif idx == "EnableRainbowMode" then
					if typeof(value) ~= "boolean" then return end
					colorpickersettings.EnableRainbowMode = value
				elseif idx == "Rainbow" then
					if typeof(value) ~= "boolean" then return end
					colorpickersettings.Rainbow = value
					if renderstepped then
						renderstepped:Disconnect()
					end
					if colorpickersettings.Rainbow then
						renderstepped = RunService.RenderStepped:Connect(function()
							local time = tick() - executespawn
							local hue = time * colorpickersettings.RainbowSpeed - math.floor(time * colorpickersettings.RainbowSpeed)
							ColorPickerModule.CurrentColor = Color3.fromHSV(hue,colorpickersettings.RainbowSaturation/255,colorpickersettings.RainbowBrightness/255)
							if colorpickersettings.RainbowCallback then
								task.spawn(Callback,colorpickersettings.Callback,colorpickersettings.CurrentColor)
							end
						end)
					end
				elseif idx == "RainbowSpeed" then
					if typeof(value) ~= "number" then return end
					colorpickersettings.RainbowSpeed = value
				elseif idx == "RainbowSaturation" then
					if typeof(value) ~= "number" then return end
					colorpickersettings.RainbowSaturation = value
				elseif idx == "RainbowBrightness" then
					if typeof(value) ~= "number" then return end
					colorpickersettings.RainbowBrightness = value
				elseif idx == "RainbowCallback" then
					if typeof(value) ~= "boolean" then return end
					colorpickersettings.RainbowCallback = value
				elseif idx == "SectionParent" then
					if (typeof(value) ~= "table" or value.ClassName ~= "SectionParent") and value ~= nil then return end
					colorpickersettings.SectionParent = value and value.ClassName == "SectionParent" and value or TabModule
					ColorPickerElement.Parent = value and value.ClassName == "SectionParent" and value.Instance.Dropdown.Container or ElementsContainer
					UpdateCanvasSize(TabModule)
				elseif idx == "Active" then
					if typeof(value) ~= "boolean" then return end
					colorpickersettings.Active = value
					ColorPickerElement.Interactable = colorpickersettings.Active
					if colorpickersettings.Active then
						Fade.Transparency = 1
						ElementIcon.ImageTransparency = 1
						ElementIcon.ImageColor3 = Color3.fromRGB(11, 9, 9)
					else
						Fade.Transparency = 0.75
						ElementIcon.ImageTransparency = 0
						ElementIcon.ImageColor3 = Color3.fromRGB(32,32,32)
						ElementIcon.Image = Icons.DisabledElementIcon
					end
				elseif idx == "Visible" then
					if typeof(value) ~= "boolean" then return end
					colorpickersettings.Visible = value
					ColorPickerElement.Visible = colorpickersettings.Visible
					UpdateCanvasSize(TabModule)
				elseif idx == "Tip" then
					if typeof(value) ~= "string" and value ~= nil then return end
					colorpickersettings.Tip = value ~= nil and tostring(value) or value
					UpdateElementTip(value ~= nil,ColorPickerElement,colorpickersettings.Tip,colorpickersettings.TipDuration)
				elseif idx == "TipDuration" then
					if typeof(value) ~= "number" then return end
					colorpickersettings.TipDuration = value
					UpdateElementTip(colorpickersettings.Tip ~= nil,ColorPickerElement,colorpickersettings.Tip,colorpickersettings.TipDuration)
				else
					return
				end
				if colorpickersettings.Flag and canupdateflags then
					UpdateFlags(colorpickersettings)
				end
			end
			-- ColorPicker Main
			RippleEffects(ColorPickerElement)
			ColorPickerElement.MouseButton1Click:Connect(function()
				if opened then return end
				opened = true
				local hue,sat,val = colorpickersettings.CurrentColor:ToHSV()
				local heartbeat
				local mousedown
				local size = colorpickersettings.EnableRainbowMode and 108 or 93
				local ColorPicker = FPSLibraryAssets:WaitForChild("ColorPickerFrame"):Clone()
				ColorPicker.Parent = Interface
				ColorPicker.Size = UDim2.new(0,97,0,0)
				TweenService:Create(ColorPicker,TweenOut50Sine,{Size = UDim2.new(0,97,0,size)}):Play()
				local Container = ColorPicker:WaitForChild("Container")
				local ColorPaletteFrame = Container:WaitForChild("Color")
				local ColorSelectionCursor = ColorPaletteFrame:WaitForChild("SelectionCursor")
				local ValueSlider = Container:WaitForChild("Value")
				local ValueSliderArrow = ValueSlider:WaitForChild("Arrow")
				local ColorCodeTextbox = Container:WaitForChild("ColorCode")
				local RainbowToggle = Container:WaitForChild("RainbowToggle")
				local SwitchBackground = RainbowToggle:WaitForChild("Switch")
				local SwitchCircle = SwitchBackground:WaitForChild("Circle")
				local SwitchGlow = SwitchBackground:WaitForChild("Glow")
				ColorSelectionCursor.Position = UDim2.new(1-hue,0,1-sat,0)
				ValueSliderArrow.Position = UDim2.new(0,4,1-val,0)
				local function ChangeColor()
					ColorSelectionCursor.Position = UDim2.new(1-hue,0,1-sat,0)
					ValueSliderArrow.Position = UDim2.new(0,4,1-val,0)
					if not colorpickersettings.Rainbow then
						ColorPickerModule.CurrentColor = Color3.fromHSV(hue,sat,val)
						if not colorpickersettings.CallbackOnRelease then
							task.spawn(Callback,colorpickersettings.Callback,colorpickersettings.CurrentColor)
						end
					end
				end
				if colorpickersettings.Rainbow then
					SwitchBackground.BackgroundColor3 = Color3.fromRGB(255, 107, 107)
					SwitchCircle.Position = UDim2.new(0,16,0.5,0)
					SwitchGlow.ImageTransparency = 0
				end
				ColorPaletteFrame.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						local renderstepped
						renderstepped = RunService.RenderStepped:Connect(function()
							hue = math.clamp((ColorPaletteFrame.AbsolutePosition.X + 72 - mouse.X) / 72,0,1)
							sat = math.clamp((ColorPaletteFrame.AbsolutePosition.Y + 72 - mouse.Y) / 72,0,1)
							ChangeColor()
						end)
						local inputchanged
						inputchanged = input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								inputchanged:Disconnect()
								renderstepped:Disconnect()
								Callback(colorpickersettings.Callback,colorpickersettings.CurrentColor)
							end
						end)
					end
				end)
				ValueSlider.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						local renderstepped
						renderstepped = RunService.RenderStepped:Connect(function()
							val = math.clamp((ValueSlider.AbsolutePosition.Y + 72 - mouse.Y) / 72,0,1)
							ChangeColor()
						end)
						local inputchanged
						inputchanged = input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								inputchanged:Disconnect()
								renderstepped:Disconnect()
								Callback(colorpickersettings.Callback,colorpickersettings.CurrentColor)
							end
						end)
					end
				end)
				RainbowToggle.MouseButton1Click:Connect(function()
					ColorPickerModule.Rainbow = not colorpickersettings.Rainbow
					if colorpickersettings.Rainbow then
						oldcolor = colorpickersettings.CurrentColor
						TweenService:Create(SwitchCircle,TweenOut32Sine,{Position = UDim2.new(0,16,0.5,0)}):Play()
						TweenService:Create(SwitchGlow,TweenOut32Sine,{ImageTransparency = 0}):Play()
						TweenService:Create(SwitchBackground,TweenOut32Sine,{BackgroundColor3 = Color3.fromRGB(255, 107, 107)}):Play()
					else
						ColorPickerModule.CurrentColor = oldcolor
						TweenService:Create(SwitchCircle,TweenOut32Sine,{Position = UDim2.new(0,3,0.5,0)}):Play()
						TweenService:Create(SwitchGlow,TweenOut32Sine,{ImageTransparency = 1}):Play()
						TweenService:Create(SwitchBackground,TweenOut32Sine,{BackgroundColor3 = Color3.fromRGB(31, 31, 31)}):Play()
					end
				end)
				local function Close()
					mousedown:Disconnect()
					opened = false
					TweenService:Create(ColorPicker,TweenOut50Sine,{Size = UDim2.new(0,97,0,0)}):Play()
					task.wait(0.5)
					heartbeat:Disconnect()
					ColorPicker:Destroy()
				end
				heartbeat = RunService.Heartbeat:Connect(function()
					if colorpickersettings.Rainbow then
						local time = tick() - executespawn
						local hue = time * colorpickersettings.RainbowSpeed - math.floor(time * colorpickersettings.RainbowSpeed)
						local _,_,val = SwitchBackground.BackgroundColor3:ToHSV()
						SwitchBackground.BackgroundColor3 = Color3.fromHSV(hue,163/255,val)
						SwitchGlow.ImageColor3 = Color3.fromHSV(hue,163/255,1)
					end
					ColorPicker.Position = UDim2.new(0,ColorPickerElement.AbsolutePosition.X,0,ColorPickerElement.AbsolutePosition.Y + 12)
				end)
				mousedown = mouse.Button1Down:Connect(function()
					if not isHoveringOverObj(TabContainer) then
						Close()
					end
				end)
			end)
			layoutorder += 2
			ColorPickerElement.LayoutOrder = layoutorder
			-- Set Metatable
			setmetatable(ColorPickerModule,mt)
			-- Elements Table
			table.insert(FPSLibrary.Elements,ColorPickerModule)
			-- Set Configs
			ColorPickerModule.Name = colorpickersettings.Name
			ColorPickerModule.RichText = colorpickersettings.RichText
			ColorPickerModule.CurrentColor = colorpickersettings.CurrentColor
			ColorPickerModule.CallbackOnRelease = colorpickersettings.CallbackOnRelease
			ColorPickerModule.EnableRainbowMode = colorpickersettings.EnableRainbowMode
			ColorPickerModule.Rainbow = colorpickersettings.Rainbow
			ColorPickerModule.RainbowSpeed = colorpickersettings.RainbowSpeed
			ColorPickerModule.RainbowSaturation = colorpickersettings.RainbowSaturation
			ColorPickerModule.RainbowBrightness = colorpickersettings.RainbowBrightness
			ColorPickerModule.RainbowCallback = colorpickersettings.RainbowCallback
			ColorPickerModule.SectionParent = colorpickersettings.SectionParent
			ColorPickerModule.Flag = colorpickersettings.Flag
			ColorPickerModule.Callback = colorpickersettings.Callback
			ColorPickerModule.Active = colorpickersettings.Active
			ColorPickerModule.Visible = colorpickersettings.Visible
			ColorPickerModule.Tip = colorpickersettings.Tip
			ColorPickerModule.TipDuration = colorpickersettings.TipDuration
			-- Update Flags
			if colorpickersettings.Flag then
				FPSLibrary.Flags[colorpickersettings.Flag] = {}
				canupdateflags = true
				UpdateFlags(colorpickersettings)
			end
			-- Return Module
			return ColorPickerModule
		end
		function TabModule:CreateKeybind(keybindsettings)
			-- Tab Settings
			keybindsettings.Name = keybindsettings.Name or "Keybind"
			keybindsettings.RichText = keybindsettings.RichText or false
			keybindsettings.CurrentKeybind = keybindsettings.CurrentKeybind or Enum.KeyCode.E
			keybindsettings.HoldToInteract = keybindsettings.HoldToInteract or false
			keybindsettings.SectionParent = keybindsettings.SectionParent or nil
			keybindsettings.Flag = keybindsettings.Flag ~= "" and keybindsettings.Flag or nil
			keybindsettings.Callback = keybindsettings.Callback or function() end
			keybindsettings.Active = keybindsettings.Active == nil or keybindsettings.Active
			keybindsettings.Visible = keybindsettings.Visible == nil or keybindsettings.Visible
			keybindsettings.Tip = keybindsettings.Tip ~= "" and keybindsettings.Tip or nil
			keybindsettings.TipDuration = keybindsettings.TipDuration or 5
			if typeof(keybindsettings.Name) ~= "string" then return end
			if typeof(keybindsettings.RichText) ~= "boolean" then return end
			if typeof(keybindsettings.CurrentKeybind) ~= "EnumItem" or keybindsettings.CurrentKeybind.EnumType ~= Enum.KeyCode then return end
			if typeof(keybindsettings.HoldToInteract) ~= "boolean" then return end
			if (typeof(keybindsettings.SectionParent) ~= "table" or keybindsettings.SectionParent.ClassName ~= "SectionParent") and keybindsettings.SectionParent ~= nil then return end
			if keybindsettings.Flag ~= nil and typeof(keybindsettings.Flag) ~= "string" then return end
			if typeof(keybindsettings.Callback) ~= "function" then return end
			if typeof(keybindsettings.Active) ~= "boolean" then return end
			if typeof(keybindsettings.Visible) ~= "boolean" then return end
			if typeof(keybindsettings.Tip) ~= "string" and keybindsettings.Tip ~= nil then return end
			if typeof(keybindsettings.TipDuration) ~= "number" then return end
			-- Variables
			local KeybindElement = FPSLibraryAssets:WaitForChild("Keybind"):Clone()
			local ElementIcon = KeybindElement:WaitForChild("Icon")
			local Fade = KeybindElement:WaitForChild("Fade")
			local KeybindNameLabel = KeybindElement:WaitForChild("NameTextLabel")
			local KeybindFrame = KeybindElement:WaitForChild("KeybindFrame")
			local KeybindText = KeybindFrame:WaitForChild("Keybind")
			local CheckingForKey = false
			local canupdateflags = false
			local KeybindModule = {}
			local mt = {}
			-- Metatable Functions
			function mt.__index(self,idx)
				if idx == "Name" then
					return keybindsettings.Name
				elseif idx == "RichText" then
					return keybindsettings.RichText
				elseif idx == "CurrentKeybind" then
					return keybindsettings.CurrentKeybind
				elseif idx == "HoldToInteract" then
					return keybindsettings.HoldToInteract
				elseif idx == "SectionParent" then
					return keybindsettings.SectionParent
				elseif idx == "Callback" then
					return keybindsettings.Callback
				elseif idx == "Active" then
					return keybindsettings.Active
				elseif idx == "Visible" then
					return keybindsettings.Visible
				elseif idx == "Tip" then
					return keybindsettings.Tip
				elseif idx == "TipDuration" then
					return keybindsettings.TipDuration
				elseif idx == "Instance" then
					return KeybindElement
				elseif idx == "Flag" then
					return keybindsettings.Flag
				elseif idx == "ClassName" then
					return "KeybindElement"
				else
					return
				end
			end
			function mt.__newindex(self,idx,value)
				if idx == "Name" then
					if typeof(value) ~= "string" then return end
					keybindsettings.Name = tostring(value)
					KeybindNameLabel.Text = keybindsettings.Name
				elseif idx == "RichText" then
					if typeof(value) ~= "boolean" then return end
					keybindsettings.RichText = value
					KeybindNameLabel.RichText = keybindsettings.RichText
				elseif idx == "CurrentKeybind" then
					if value ~= nil and (typeof(value) ~= "EnumItem" or value.EnumType ~= Enum.KeyCode) then return end
					keybindsettings.CurrentKeybind = value
					KeybindText.Text = value and value.Name or ""
				elseif idx == "HoldToInteract" then
					if typeof(value) ~= "boolean" then return end
					keybindsettings.HoldToInteract = value
				elseif idx == "SectionParent" then
					if (typeof(value) ~= "table" or value.ClassName ~= "SectionParent") and value ~= nil then return end
					keybindsettings.SectionParent = value and value.ClassName == "SectionParent" and value or TabModule
					KeybindElement.Parent = value and value.ClassName == "SectionParent" and value.Instance.Dropdown.Container or ElementsContainer
					UpdateCanvasSize(TabModule)
				elseif idx == "Active" then
					if typeof(value) ~= "boolean" then return end
					keybindsettings.Active = value
					KeybindElement.Interactable = keybindsettings.Active
					if keybindsettings.Active then
						Fade.Transparency = 1
						ElementIcon.ImageTransparency = 1
						ElementIcon.ImageColor3 = Color3.fromRGB(84,84,84)
					else
						Fade.Transparency = 0.75
						ElementIcon.ImageTransparency = 0
						ElementIcon.ImageColor3 = Color3.fromRGB(32,32,32)
						ElementIcon.Image = Icons.DisabledElementIcon
					end
				elseif idx == "Visible" then
					if typeof(value) ~= "boolean" then return end
					keybindsettings.Visible = value
					KeybindElement.Visible = keybindsettings.Visible
					UpdateCanvasSize(TabModule)
				elseif idx == "Tip" then
					if typeof(value) ~= "string" and value ~= nil then return end
					keybindsettings.Tip = value ~= nil and tostring(value) or value
					UpdateElementTip(value ~= nil,KeybindElement,keybindsettings.Tip,keybindsettings.TipDuration)
				elseif idx == "TipDuration" then
					if typeof(value) ~= "number" then return end
					keybindsettings.TipDuration = value
					UpdateElementTip(keybindsettings.Tip ~= nil,KeybindElement,keybindsettings.Tip,keybindsettings.TipDuration)
				else
					return
				end
				if keybindsettings.Flag and canupdateflags then
					UpdateFlags(keybindsettings)
				end
			end
			-- Keybind Main
			RippleEffects(KeybindElement)
			KeybindElement.MouseButton1Down:Connect(function()
				if CheckingForKey then return end
				CheckingForKey = true
				local spawn1 = 0
				local dots = 0
				local renderstepped
				local mousedown
				local inputbegan
				local function Disconnect()
					renderstepped:Disconnect()
					inputbegan:Disconnect()
					mousedown:Disconnect()
					task.wait()
					CheckingForKey = false
				end
				renderstepped = RunService.RenderStepped:Connect(function()
					if spawn1 + 1/3 < tick() then
						dots += 1
						if dots > 3 then
							dots = 1
						end
						KeybindText.Text = string.rep(".",dots)
						spawn1 = tick()
					end
				end)
				inputbegan = UserInputService.InputBegan:Connect(function(input, processed)
					if not processed then
						if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= ToggleGUIKeybind then
							KeybindModule.CurrentKeybind = input.KeyCode
							Disconnect()
						end
					end
				end)
				mousedown = mouse.Button1Down:Connect(function()
					if not isHoveringOverObj(TabContainer) then
						KeybindModule.CurrentKeybind = nil
						Disconnect()
					end
				end)
				KeybindElement.MouseButton1Up:Once(function()
					if keybindsettings.HoldToInteract then
						KeybindModule.CurrentKeybind = nil
						Disconnect()
					end
				end)
			end)
			UserInputService.InputBegan:Connect(function(input, processed)
				if not processed and not CheckingForKey and input.KeyCode == keybindsettings.CurrentKeybind then
					task.spawn(Callback,keybindsettings.Callback)
				end
			end)
			layoutorder += 2
			KeybindElement.LayoutOrder = layoutorder
			-- Set Metatable
			setmetatable(KeybindModule,mt)
			-- Elements Table
			table.insert(FPSLibrary.Elements,KeybindModule)
			-- Set Configs
			KeybindModule.Name = keybindsettings.Name
			KeybindModule.RichText = keybindsettings.RichText
			KeybindModule.SectionParent = keybindsettings.SectionParent
			KeybindModule.Callback = keybindsettings.Callback
			KeybindModule.Active = keybindsettings.Active
			KeybindModule.Visible = keybindsettings.Visible
			KeybindModule.Tip = keybindsettings.Tip
			KeybindModule.TipDuration = keybindsettings.TipDuration
			-- Update Flags
			if keybindsettings.Flag then
				FPSLibrary.Flags[keybindsettings.Flag] = {}
				canupdateflags = true
				UpdateFlags(keybindsettings)
			end
			-- Return Module
			return KeybindModule
		end
		function TabModule:CreateSection(Name,DropdownSizeY,Opened,Visible)
			Name = Name or "Container"
			DropdownSizeY = DropdownSizeY or 60
			Opened = Opened or false
			Visible = Visible == nil or Visible
			if typeof(Name) ~= "string" then return end
			if typeof(DropdownSizeY) ~= "number" or DropdownSizeY < 0 then return end
			if typeof(Opened) ~= "boolean" then return end
			if typeof(Visible) ~= "boolean" then return end
			-- Variables
			local SectionContainer = FPSLibraryAssets:WaitForChild("SectionContainer"):Clone()
			SectionContainer.Parent = ElementsContainer
			local NameTextLabel = SectionContainer:WaitForChild("NameTextLabel")
			local SectionMinimizeButton = SectionContainer:WaitForChild("ArrowImageButton")
			SectionMinimizeButton.Rotation = Opened and 0 or 180
			local Dropdown = SectionContainer:WaitForChild("Dropdown")
			local Spacing = SectionContainer:WaitForChild("Spacing"):Clone()
			Spacing.Parent = ElementsContainer
			local SectionElementContainer = Dropdown:WaitForChild("Container")
			local SectionModule = {}
			local mt = {}
			-- Metatable Functions
			function mt.__index(self,idx)
				if idx == "Name" then
					return Name
				elseif idx == "DropdownSizeY" then
					return DropdownSizeY
				elseif idx == "Opened" then
					return Opened
				elseif idx == "Visible" then
					return Visible
				elseif idx == "Instance" then
					return SectionContainer
				elseif idx == "ClassName" then
					return "SectionParent"
				end
			end
			function mt.__newindex(self,idx,value)
				if idx == "Name" then
					if typeof(value) ~= "string" then return end
					Name = value
					NameTextLabel.Text = Name
				elseif idx == "DropdownSizeY" then
					if typeof(value) ~= "number" then return end
					DropdownSizeY = value
				elseif idx == "Opened" then
					if typeof(value) ~= "boolean" then return end
					Opened = value
					if Opened then
						TweenService:Create(Dropdown,TweenOut50Sine,{Size = UDim2.new(1,0,0,DropdownSizeY - 1)}):Play()
						TweenService:Create(Spacing,TweenOut50Sine,{Size = UDim2.new(1,0,0,DropdownSizeY - 3)}):Play()
						TweenService:Create(SectionMinimizeButton,TweenOut32Sine,{Rotation = 0}):Play()
					else
						TweenService:Create(Dropdown,TweenOut50Sine,{Size = UDim2.new(1,0,0,0)}):Play()
						TweenService:Create(Spacing,TweenOut50Sine,{Size = UDim2.new(1,0,0,0)}):Play()
						TweenService:Create(SectionMinimizeButton,TweenOut32Sine,{Rotation = 180}):Play()
					end
					UpdateCanvasSize(TabModule)
				elseif idx == "Visible" then
					if typeof(value) ~= "boolean" then return end
					Visible = value
					SectionContainer.Visible = Visible
					UpdateCanvasSize(TabModule)
				end
			end
			-- Section Main
			SectionMinimizeButton.MouseButton1Click:Connect(function()
				SectionModule.Opened = not Opened
			end)
			layoutorder += 2
			SectionContainer.LayoutOrder = layoutorder
			Spacing.LayoutOrder = layoutorder + 1
			-- Set Metatable
			setmetatable(SectionModule,mt)
			-- Elements Table
			table.insert(FPSLibrary.Elements,SectionModule)
			-- Set Configs
			SectionModule.Name = Name
			SectionModule.DropdownSizeY = DropdownSizeY
			SectionModule.Opened = Opened
			-- Return Module
			return SectionModule
		end
		function TabModule:CreateSeparator(Text,SectionParent,Visible)
			Text = Text or "This is a separator"
			SectionParent = SectionParent or nil
			Visible = Visible == nil or Visible
			if typeof(Text) ~= "string" then return end
			if (typeof(SectionParent) ~= "table" or SectionParent.ClassName ~= "SectionParent") and SectionParent ~= nil then return end
			if typeof(Visible) ~= "boolean" then return end
			-- Variables
			local Separator = FPSLibraryAssets:WaitForChild("Separator"):Clone()
			local SeparatorModule = {}
			local mt = {}
			-- Metatable Functions
			function mt.__index(self,idx)
				if idx == "Text" then
					return Text
				elseif idx == "SectionParent" then
					return SectionParent
				elseif idx == "Visible" then
					return Visible
				elseif idx == "Instance" then
					return Separator
				elseif idx == "ClassName" then
					return "Separator"
				end
			end
			function mt.__newindex(self,idx,value)
				if idx == "Text" then
					if typeof(value) ~= "string" then return end
					Text = value
					Separator.Text = Text
				elseif idx == "SectionParent" then
					if (typeof(value) ~= "table" or value.ClassName ~= "SectionParent") and value ~= nil then return end
					SectionParent = value and value.ClassName == "SectionParent" and value or TabModule
					Separator.Parent = value and value.ClassName == "SectionParent" and value.Instance.Dropdown.Container or ElementsContainer
					UpdateCanvasSize(TabModule)
				elseif idx == "Visible" then
					if typeof(value) ~= "boolean" then return end
					Visible = value
					Separator.Visible = Visible
					UpdateCanvasSize(TabModule)
				end
			end
			-- Section Main
			layoutorder += 2
			Separator.LayoutOrder = layoutorder
			-- Set Metatable
			setmetatable(SeparatorModule,mt)
			-- Elements Table
			table.insert(FPSLibrary.Elements,SeparatorModule)
			-- Set Configs
			SeparatorModule.Text = Text
			SeparatorModule.SectionParent = SectionParent
			SeparatorModule.Visible = Visible
			-- Return Module
			return SeparatorModule
		end
		function TabModule:CreateParagraph(Title,Content,SectionParent,Visible)
			Title = Title or "This is a paragraph"
			Content = Content or "This is content"
			SectionParent = SectionParent or nil
			Visible = Visible == nil or Visible
			if typeof(Title) ~= "string" then return end
			if typeof(Content) ~= "string" then return end
			if (typeof(SectionParent) ~= "table" or SectionParent.ClassName ~= "SectionParent") and SectionParent ~= nil then return end
			if typeof(Visible) ~= "boolean" then return end
			-- Variables
			local Paragraph = FPSLibraryAssets:WaitForChild("Paragraph"):Clone()
			local TitleLabel = Paragraph:WaitForChild("Title")
			local ContentLabel = Paragraph:WaitForChild("Content")
			local ParagraphModule = {}
			local mt = {}
			-- Metatable Functions
			function mt.__index(self,idx)
				if idx == "Title" then
					return Title
				elseif idx == "Content" then
					return Content
				elseif idx == "SectionParent" then
					return SectionParent
				elseif idx == "Visible" then
					return Visible
				elseif idx == "Instance" then
					return Paragraph
				elseif idx == "ClassName" then
					return "Paragraph"
				end
			end
			function mt.__newindex(self,idx,value)
				if idx == "Title" then
					if typeof(value) ~= "string" then return end
					Title = value
					TitleLabel.Text = Title
				elseif idx == "Content" then
					if typeof(value) ~= "string" then return end
					Content = value
					ContentLabel.TextWrapped = false
					ContentLabel.TextScaled = false
					ContentLabel.Text = Content
					Paragraph.Size = UDim2.new(0,80,0,24 + 12 * math.ceil(ContentLabel.TextBounds.X/80))
					ContentLabel.TextWrapped = true
				elseif idx == "SectionParent" then
					if (typeof(value) ~= "table" or value.ClassName ~= "SectionParent") and value ~= nil then return end
					SectionParent = value and value.ClassName == "SectionParent" and value or TabModule
					Paragraph.Parent = value and value.ClassName == "SectionParent" and value.Instance.Dropdown.Container or ElementsContainer
					UpdateCanvasSize(TabModule)
				elseif idx == "Visible" then
					if typeof(value) ~= "boolean" then return end
					Visible = value
					Paragraph.Visible = Visible
					UpdateCanvasSize(TabModule)
				end
			end
			-- Section Main
			layoutorder += 2
			Paragraph.LayoutOrder = layoutorder
			-- Set Metatable
			setmetatable(ParagraphModule,mt)
			-- Elements Table
			table.insert(FPSLibrary.Elements,ParagraphModule)
			-- Set Configs
			ParagraphModule.Title = Title
			ParagraphModule.Content = Content
			ParagraphModule.SectionParent = SectionParent
			ParagraphModule.Visible = Visible
			-- Return Module
			return ParagraphModule
		end
		-- Set Metatable
		setmetatable(TabModule,mt)
		-- Elements Table
		table.insert(FPSLibrary.Elements,TabModule)
		-- Set Configs
		TabModule.Title =  tabsettings.Title
		TabModule.Subtitle = tabsettings.Subtitle
		TabModule.TitleRichText = tabsettings.TitleRichText
		TabModule.SubtitleRichText = tabsettings.SubtitleRichText
		TabModule.SizeY = tabsettings.SizeY
		TabModule.MaxSizeY = tabsettings.MaxSizeY
		TabModule.Opened = tabsettings.Opened
		TabModule.CanvasSizeY = tabsettings.CanvasSizeY
		TabModule.Visible = tabsettings.Visible
		TabModule.Position = tabsettings.Position
		TabModule.Flag = tabsettings.Flag
		TabModule.IgnoreList = tabsettings.IgnoreList
		-- Update Flags
		if tabsettings.Flag then
			FPSLibrary.Flags[tabsettings.Flag] = {}
			canupdateflags = true
			UpdateFlags(tabsettings)
		end
		-- Return Module
		return TabModule
	end
	function Window:AddElementTip(Element,Tip,Duration)
		if typeof(Element) ~= "table" or Element.ClassName == "Tab" or typeof(Tip) ~= "string" or Duration ~= nil and typeof(Duration) ~= "number" then return end
		Element.Tip = Tip
		Element.TipDuration = Duration
	end
	function Window:RemoveElementTip(Element)
		if typeof(Element) ~= "table" or Element.ClassName == "Tab" then return end
		Element.Tip = nil
	end
	function Window:ActivateElement(Element)
		if typeof(Element) ~= "table" or Element.ClassName == "Tab" then return end
		Element.Active = true
	end
	function Window:DeactivateElement(Element)
		if typeof(Element) ~= "table" or Element.ClassName == "Tab" then return end
		Element.Active = false
	end
	function Window:ShowElement(Element)
		if typeof(Element) ~= "table" or Element.ClassName == "Tab" then return end
		Element.Visible = true
	end
	function Window:HideElement(Element)
		if typeof(Element) ~= "table" or Element.ClassName == "Tab" then return end
		Element.Visible = false
	end
	function Window:OrganizeTabs(x,y,padding)
		for i, v in FPSLibrary.Elements do
			if v.ClassName == "Tab" then
				v.Position = UDim2.new(0,x+(i-1)*112+(i > 1 and (padding-12)*(i-1) or 0),0,y)
			end
		end
	end
	function Window:PromptDiscordInvite()
		if windowsettings.Discord and windowsettings.Discord.Enabled and windowsettings.Discord.InviteLink then
			pcall(function()
				if request then
					request({
						Url = 'http://127.0.0.1:6463/rpc?v=1';
						Method = 'POST';
						Headers = {
							['Content-Type'] = 'application/json';
							Origin = 'https://discord.com'
						};
						Body = HttpService:JSONEncode({
							cmd = 'INVITE_BROWSER';
							nonce = HttpService:GenerateGUID(false);
							args = {code = windowsettings.Discord.InviteLink}
						})
					})
					local contents = HttpService:JSONDecode(readfile(DiscordInvitesFileName))
					if windowsettings.Discord.RememberJoins and not table.find(contents,windowsettings.Discord.InviteLink) then -- We do logic this way so if the developer changes this setting, the user still won't be prompted, only new users
						table.insert(contents,windowsettings.Discord.InviteLink)
						writefile(DiscordInvitesFileName,contents)
					end
				end
			end)
		end
	end
	return Window
end
Interface.Name = GenerateRandomString()
if not isfolder(FPSLibraryFolder) then
	makefolder(FPSLibraryFolder)
end
if not isfolder(KeyFolderName) then
	makefolder(KeyFolderName)
end
if not isfile(DiscordInvitesFileName) then
	writefile(DiscordInvitesFileName,"[]")
end
if not isfolder(ConfigurationFolderName) then
	makefolder(ConfigurationFolderName)
end
return FPSLibrary
