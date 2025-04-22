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

local useStudio = runService:IsStudio()
local soundId = "rbxassetid://5419098673"
local guiAssetId = "rbxassetid://97206084643256" -- make sure this model is public!

local function tween(inst, time, props, easing, direction)
	tweenService:Create(inst, TweenInfo.new(time or 0.4, easing or Enum.EasingStyle.Exponential, direction or Enum.EasingDirection.Out), props):Play()
end

local function fadeBlur(on)
	local blur = lighting:FindFirstChild("PromptUIBlur") or Instance.new("BlurEffect", lighting)
	blur.Name = "PromptUIBlur"
	blur.Size = on and 0 or 20
	tween(blur, 0.4, {Size = on and 20 or 0})
	if not on then
		task.delay(0.5, function() blur:Destroy() end)
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

	local gui = useStudio and script.Parent:FindFirstChild("Prompt") or game:GetObjects(guiAssetId)[1]
	gui.Enabled = false

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
				fadeBlur(false)
				task.delay(0.3, function()
					gui:Destroy()
					if option.Callback then option.Callback() end
				end)
			end)
		end
	end

	policy.BackgroundTransparency = 1
	policy.Size = UDim2.new(0, 450, 0, 120)

	local scale = Instance.new("UIScale")
	scale.Name = "PopupScale"
	scale.Scale = 0.8
	scale.Parent = policy
	tween(scale, 0.35, {Scale = 1}, Enum.EasingStyle.Back)

	tween(policy, 0.4, {BackgroundTransparency = 0})
	tween(policy, 0.6, {Size = UDim2.new(0, 520, 0, 150)}, Enum.EasingStyle.Quint)

	fadeBlur(true)
	playSound(gui)

	return gui
end

return PromptUI
