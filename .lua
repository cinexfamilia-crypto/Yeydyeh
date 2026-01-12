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
