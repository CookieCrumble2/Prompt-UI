--[[
	Prompt Interface Suite
	by Sirius

	shlex | Designing + Programming
	CookieCrumble | Forked UI
]]
local PromptUI = {}
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local tweenService = game:GetService("TweenService")
local lighting = game:GetService("Lighting")
local userInputService = game:GetService("UserInputService")

local useStudio = runService:IsStudio()
local soundId = "rbxassetid://9118823104"
local guiAssetId = "rbxassetid://97206084643256"

local cachedGUI = nil
PromptUI._lastPosition = nil

local function tween(inst, time, props, easing, direction)
	tweenService:Create(inst, TweenInfo.new(time or 0.4, easing or Enum.EasingStyle.Exponential, direction or Enum.EasingDirection.Out), props):Play()
end

local blur = lighting:FindFirstChild("PromptUIBlur") or Instance.new("BlurEffect")
blur.Name = "PromptUIBlur"
blur.Size = 0
blur.Parent = lighting

local function fadeBlur(on)
	tween(blur, 0.3, {Size = on and 20 or 0})
	if not on then
		task.delay(0.4, function()
			if blur.Size == 0 then
				blur:Destroy()
			end
		end)
	end
end

local function playSound(parent)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.7
	sound.PlayOnRemove = true
	sound.Parent = parent
	sound:Destroy()
end

function PromptUI.Show(data)
	assert(data.Title and data.Description, "Missing Title or Description")
	assert(data.Options and type(data.Options) == "table", "Options must be a table")

	local gui
	if useStudio then
		gui = script.Parent:FindFirstChild("Prompt")
	elseif cachedGUI then
		gui = cachedGUI:Clone()
	else
		local success, result = pcall(function()
			return game:GetObjects(guiAssetId)[1]
		end)
		if success and result then
			cachedGUI = result
			gui = cachedGUI:Clone()
		else
			warn("Failed to load GUI asset")
			return
		end
	end

	local parent
	if gethui then
		parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(gui)
		parent = coreGui
	elseif coreGui:FindFirstChild("RobloxGui") then
		parent = coreGui.RobloxGui
	else
		parent = coreGui
	end

	gui.Parent = parent
	gui.Enabled = true

	local policy = gui.Policy
	local primaryBtn = policy.Actions.Primary
	local secondaryBtns = {policy.Actions.Secondary, policy.Actions:FindFirstChild("Tertiary")}
	local connections = {}

	local function resetButton(btn)
		if btn then
			btn.Visible = false
			btn.Title.Text = ""
			if connections[btn] then
				connections[btn]:Disconnect()
				connections[btn] = nil
			end
		end
	end

	resetButton(primaryBtn)
	for _, btn in ipairs(secondaryBtns) do resetButton(btn) end

	policy.Title.Text = data.Title
	policy.Notice.Text = data.Description
	policy.Notice.TextSize = 18

	if data.Icon and policy:FindFirstChild("Icon") then
		local icon = policy.Icon
		icon.Image = "rbxassetid://" .. tostring(data.Icon)
		icon.ImageTransparency = 1
		tween(icon, 0.4, {ImageTransparency = 0})
	end

	local options = data.Options
	local btnRefs = {primaryBtn, unpack(secondaryBtns)}
	for i, option in ipairs(options) do
		if btnRefs[i] then
			local btn = btnRefs[i]
			btn.Visible = true
			btn.Title.Text = option.Text
			connections[btn] = btn.Interact.MouseButton1Click:Connect(function()
				tween(policy, 0.3, {BackgroundTransparency = 1})
				tween(policy, 0.3, {Size = UDim2.new(0, 450, 0, 120)})
				fadeBlur(false)
				gui.Enabled = false
				task.delay(0.35, function()
					coroutine.wrap(function()
						PromptUI._lastPosition = policy.Position
						gui:Destroy()
						if option.Callback then pcall(option.Callback) end
					end)()
				end)
			end)
		end
	end

	policy.BackgroundTransparency = 1
	policy.Size = UDim2.new(0, 450, 0, 120)
	policy.Position = PromptUI._lastPosition or UDim2.new(0.5, -260, 0.5, -75) -- center if not dragged yet

	local scale = Instance.new("UIScale")
	scale.Name = "PopupScale"
	scale.Scale = 0.8
	scale.Parent = policy
	tween(scale, 0.3, {Scale = 1}, Enum.EasingStyle.Back)

	tween(policy, 0.4, {BackgroundTransparency = 0})
	tween(policy, 0.4, {Size = UDim2.new(0, 520, 0, 150)}, Enum.EasingStyle.Quint)

	fadeBlur(true)

	if data.Sound ~= false then
		playSound(gui)
	end

	local dragging, dragInput, startPos, inputStart
	policy.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			inputStart = input.Position
			startPos = policy.Position
		end
	end)

	policy.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	userInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - inputStart
			policy.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	userInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			PromptUI._lastPosition = policy.Position
		end
	end)

	return gui
end

return PromptUI
