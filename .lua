-- LUCK HUB - ALL IN ONE
-- Funciona apenas se o jogo for mal protegido

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

-- UI
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.ResetOnSpawn = false

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.fromScale(0.3, 0.07)
btn.Position = UDim2.fromScale(0.35, 0.05)
btn.Text = "LUCK HUB: OFF"
btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
btn.TextScaled = true
btn.Draggable = true
btn.Active = true

-- Estados
local enabled = false
local oldRandom = math.random
local rollThread
local hooked = false

-- 1️⃣ Forçar math.random
local function forceRandom()
	math.random = function(a,b)
		if b then return b end
		if a then return a end
		return 1
	end
end

local function restoreRandom()
	math.random = oldRandom
end

-- 2️⃣ Hook genérico de funções RNG locais
local function hookRNG()
	if hooked then return end
	hooked = true

	for _,v in pairs(getgc(true)) do
		if typeof(v) == "function" then
			local info = debug.getinfo(v)
			if info.name and string.lower(info.name):find("random") then
				hookfunction(v, function(...)
					return 1 -- força melhor resultado comum
				end)
			end
		end
	end
end

-- 3️⃣ Auto spam de Remotes suspeitos
local function autoRoll()
	rollThread = task.spawn(function()
		while enabled do
			for _,obj in pairs(ReplicatedStorage:GetDescendants()) do
				if obj:IsA("RemoteEvent") then
					local name = string.lower(obj.Name)
					if name:find("roll") or name:find("spin") or name:find("gacha") or name:find("luck") then
						pcall(function()
							obj:FireServer()
						end)
					end
				end
			end
			task.wait(0.3)
		end
	end)
end

-- Toggle
btn.MouseButton1Click:Connect(function()
	enabled = not enabled

	if enabled then
		btn.Text = "LUCK HUB: ON"
		btn.BackgroundColor3 = Color3.fromRGB(0,150,0)

		forceRandom()
		hookRNG()
		autoRoll()
	else
		btn.Text = "LUCK HUB: OFF"
		btn.BackgroundColor3 = Color3.fromRGB(150,0,0)

		restoreRandom()
	end
end)
