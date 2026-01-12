-- GODMODE HUB SIMPLES

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromScale(0.25, 0.08)
button.Position = UDim2.fromScale(0.375, 0.02) -- topo, centralizado
button.BackgroundColor3 = Color3.fromRGB(180, 0, 0) -- vermelho OFF
button.TextColor3 = Color3.new(1,1,1)
button.TextScaled = true
button.Text = "GODMODE: OFF"
button.Parent = gui

local godmode = false
local conn

local function applyGodmode(char)
	local hum = char:WaitForChild("Humanoid")

	-- vida infinita
	hum.MaxHealth = math.huge
	hum.Health = math.huge

	-- bloqueia morte
	if conn then conn:Disconnect() end
	conn = hum.HealthChanged:Connect(function()
		if godmode and hum.Health < hum.MaxHealth then
			hum.Health = hum.MaxHealth
		end
	end)
end

local function removeGodmode(char)
	local hum = char:FindFirstChild("Humanoid")
	if hum then
		if conn then conn:Disconnect() end
		hum.MaxHealth = 100
		hum.Health = hum.MaxHealth
	end
end

button.MouseButton1Click:Connect(function()
	godmode = not godmode

	if godmode then
		button.BackgroundColor3 = Color3.fromRGB(0, 170, 0) -- verde ON
		button.Text = "GODMODE: ON"
		if player.Character then
			applyGodmode(player.Character)
		end
	else
		button.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
		button.Text = "GODMODE: OFF"
		if player.Character then
			removeGodmode(player.Character)
		end
	end
end)

player.CharacterAdded:Connect(function(char)
	if godmode then
		applyGodmode(char)
	end
end)

-- ===== AIMBOT MELEE REAL =====

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- BOTÃO
local aimBtn = Instance.new("TextButton")
aimBtn.Size = button.Size
aimBtn.Position = UDim2.fromScale(0.375, 0.11)
aimBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
aimBtn.TextColor3 = Color3.new(1,1,1)
aimBtn.TextScaled = true
aimBtn.Text = "AIMBOT MELEE: OFF"
aimBtn.Parent = gui

local aimbot = false
local conn
local RANGE = 15

-- pega tool equipada
local function getTool()
	local char = player.Character
	if not char then return end
	return char:FindFirstChildOfClass("Tool")
end

-- inimigo mais próximo
local function getTarget()
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local closest, dist = nil, RANGE

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local hum = p.Character:FindFirstChild("Humanoid")
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hum and hrp and hum.Health > 0 then
				local d = (hrp.Position - root.Position).Magnitude
				if d < dist then
					dist = d
					closest = hrp
				end
			end
		end
	end
	return closest
end

local function start()
	if conn then conn:Disconnect() end
	conn = RunService.RenderStepped:Connect(function()
		if not aimbot then return end

		local tool = getTool()
		if not tool then return end

		local target = getTarget()
		if not target then return end

		-- gira personagem
		local char = player.Character
		local root = char:FindFirstChild("HumanoidRootPart")
		root.CFrame = CFrame.lookAt(root.Position, target.Position)

		-- mira câmera
		camera.CFrame = CFrame.lookAt(
			camera.CFrame.Position,
			target.Position
		)

		-- ataca
		pcall(function()
			tool:Activate()
		end)
	end)
end

local function stop()
	if conn then conn:Disconnect() end
end

aimBtn.MouseButton1Click:Connect(function()
	aimbot = not aimbot
	if aimbot then
		aimBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
		aimBtn.Text = "AIMBOT MELEE: ON"
		start()
	else
		aimBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
		aimBtn.Text = "AIMBOT MELEE: OFF"
		stop()
	end
end)
