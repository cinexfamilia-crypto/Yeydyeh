-- CONFIG
local TP_INTERVAL = 0.2 -- segundos entre teleports

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "RightHub"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.18, 0.22)
frame.Position = UDim2.fromScale(0.80, 0.35)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.fromScale(0.9, 0.25)
toggle.Position = UDim2.fromScale(0.05, 0.05)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
toggle.TextColor3 = Color3.new(1,1,1)

local box = Instance.new("TextBox", frame)
box.Size = UDim2.fromScale(0.9, 0.25)
box.Position = UDim2.fromScale(0.05, 0.35)
box.PlaceholderText = "Digite 2+ letras"
box.ClearTextOnFocus = false
box.Text = ""
box.Visible = false
box.BackgroundColor3 = Color3.fromRGB(40,40,40)
box.TextColor3 = Color3.new(1,1,1)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.fromScale(0.9, 0.2)
status.Position = UDim2.fromScale(0.05, 0.65)
status.Text = "Status: Idle"
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1,1,1)
status.TextScaled = true

-- LOGIC
local enabled = false
local targetPlayer = nil
local tpConn = nil
local lastTP = 0

local function setInvisible(state)
	local char = LocalPlayer.Character
	if not char then return end
	for _,v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.LocalTransparencyModifier = state and 1 or 0
			v.CanCollide = not state
		end
	end
end

local function findByPartial(partial)
	partial = partial:lower()
	local matches = {}
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Name:lower():find(partial, 1, true) then
			table.insert(matches, p)
		end
	end
	return matches
end

local function startTP()
	if tpConn then tpConn:Disconnect() end
	tpConn = RunService.Heartbeat:Connect(function(dt)
		lastTP += dt
		if lastTP < TP_INTERVAL then return end
		lastTP = 0

		if not enabled or not targetPlayer then return end
		local char = LocalPlayer.Character
		local tchar = targetPlayer.Character
		if char and tchar and char:FindFirstChild("HumanoidRootPart") and tchar:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = tchar.HumanoidRootPart.CFrame * CFrame.new(0,0,-2)
		end
	end)
end

toggle.MouseButton1Click:Connect(function()
	enabled = not enabled
	toggle.Text = enabled and "ON" or "OFF"
	toggle.BackgroundColor3 = enabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
	box.Visible = enabled
	status.Text = enabled and "Status: Aguardando nome" or "Status: Idle"
	if not enabled then
		targetPlayer = nil
		setInvisible(false)
		if tpConn then tpConn:Disconnect() end
	end
end)

box:GetPropertyChangedSignal("Text"):Connect(function()
	if not enabled then return end
	if #box.Text < 2 then
		status.Text = "Status: 2+ letras"
		targetPlayer = nil
		return
	end

	local matches = findByPartial(box.Text)
	if #matches == 0 then
		status.Text = "Status: Ninguém encontrado"
		targetPlayer = nil
	elseif #matches > 1 then
		status.Text = "Status: Ambíguo ("..#matches..")"
		targetPlayer = nil
	else
		targetPlayer = matches[1]
		status.Text = "Status: Alvo "..targetPlayer.Name
		setInvisible(true)
		startTP()
	end
end)

-- SAFETY: reset invisibility on respawn
LocalPlayer.CharacterAdded:Connect(function()
	if enabled then
		task.wait(0.2)
		setInvisible(true)
	end
end)
