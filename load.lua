--[[
	Prompt Interface Suite
	by Sirius

	shlex | Designing + Programming
	CookieCrumble | Forked UI
]]
-- PromptUI.lua
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
    local info = TweenInfo.new(time or 0.4, easing or Enum.EasingStyle.Exponential, direction or Enum.EasingDirection.Out)
    tweenService:Create(inst, info, props):Play()
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

local function resetButton(btn, connections)
    if btn then
        btn.Visible = false
        btn.Title.Text = ""
        if connections[btn] then
            connections[btn]:Disconnect()
            connections[btn] = nil
        end
    end
end

function PromptUI.Show(data)
    assert(data and type(data) == "table", "Data must be a table")
    assert(data.Title and type(data.Title) == "string", "Missing or invalid Title")
    assert(data.Description and type(data.Description) == "string", "Missing or invalid Description")
    assert(data.Options and type(data.Options) == "table", "Options must be a table")
    assert(#data.Options > 0, "Options table must contain at least one option")

    -- Load GUI
    local gui
    if useStudio then
        gui = script.Parent:FindFirstChild("Prompt")
        if not gui then
            warn("Prompt GUI not found in Studio")
            return
        end
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
            warn("Failed to load GUI asset: " .. tostring(result))
            return
        end
    end

    -- Determine parent
    local parent
    if gethui then
        parent = gethui()
    elseif syn and syn.protect_gui then
        parent = coreGui
        syn.protect_gui(gui)
    elseif coreGui:FindFirstChild("RobloxGui") then
        parent = coreGui.RobloxGui
    else
        parent = coreGui
    end

    gui.Parent = parent
    gui.Enabled = true

    local policy = gui:FindFirstChild("Policy")
    if not policy then
        warn("Policy frame not found in GUI")
        gui:Destroy()
        return
    end

    local primaryBtn = policy.Actions:FindFirstChild("Primary")
    local secondaryBtn = policy.Actions:FindFirstChild("Secondary")
    local tertiaryBtn = policy.Actions:FindFirstChild("Tertiary")
    
    local btnRefs = {primaryBtn, secondaryBtn, tertiaryBtn}
    local connections = {}

    for _, btn in ipairs(btnRefs) do
        resetButton(btn, connections)
    end

    policy.Title.Text = data.Title
    policy.Notice.Text = data.Description
    policy.Notice.TextSize = 18
    if data.Icon then
        local icon = policy:FindFirstChild("Icon")
        if icon then
            icon.Image = "rbxassetid://" .. tostring(data.Icon)
            icon.ImageTransparency = 1
            tween(icon, 0.4, {ImageTransparency = 0})
        end
    end

    for i, option in ipairs(data.Options) do
        if i > 3 then break end 
        local btn = btnRefs[i]
        if btn then
            btn.Visible = true
            btn.Title.Text = option.Text or ("Option " .. i)
            
            connections[btn] = btn.Interact.MouseButton1Click:Connect(function()
                tween(policy, 0.3, {BackgroundTransparency = 1})
                tween(policy, 0.3, {Size = UDim2.new(0, 450, 0, 120)})
                fadeBlur(false)
                gui.Enabled = false
                
                task.delay(0.35, function()
                    PromptUI._lastPosition = policy.Position
                    for _, conn in pairs(connections) do
                        conn:Disconnect()
                    end
                    gui:Destroy()
                    
                    if option.Callback and type(option.Callback) == "function" then
                        pcall(option.Callback)
                    end
                end)
            end)
        end
    end

    policy.BackgroundTransparency = 1
    policy.Size = UDim2.new(0, 450, 0, 120)
    policy.Position = PromptUI._lastPosition or UDim2.new(0.5, -260, 0.5, -75) 
    local existingScale = policy:FindFirstChild("PopupScale")
    if existingScale then
        existingScale:Destroy()
    end

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

    local inputChangedConn = userInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - inputStart
            policy.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    local inputEndedConn = userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            PromptUI._lastPosition = policy.Position
        end
    end)

    gui.AncestryChanged:Connect(function()
        if not gui:IsDescendantOf(game) then
            inputChangedConn:Disconnect()
            inputEndedConn:Disconnect()
            for _, conn in pairs(connections) do
                conn:Disconnect()
            end
        end
    end)

    return gui
end

return PromptUI
