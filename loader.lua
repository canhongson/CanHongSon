local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "CanHongSon",
    Icon = 0,
    LoadingTitle = "SieuXe",
    LoadingSubtitle = "by Son Ngoc",
    Theme = "Default",
})

local Tab = Window:CreateTab("Farm", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Nền đứng
local standPart = Instance.new("Part")
standPart.Size = Vector3.new(4, 1, 4)
standPart.Anchored = true
standPart.Transparency = 1
standPart.CanCollide = true
standPart.Name = "AutoFarmStand"
standPart.Parent = workspace

local autoFarmEnabled = false
local isDodging = false
local dodgeSkillEnabled = false

-- Tìm mob gần nhất
local function getNearestMob()
	local nearestMob = nil
	local shortestDistance = math.huge
	for _, mob in pairs(workspace:FindFirstChild("Enemy") and workspace.Enemy:FindFirstChild("Mob") and workspace.Enemy.Mob:GetChildren() or {}) do
		if mob:FindFirstChild("HumanoidRootPart") then
			local dist = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
			if dist < shortestDistance then
				shortestDistance = dist
				nearestMob = mob
			end
		end
	end
	return nearestMob
end

-- Tấn công M1
local function attackM1()
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Dùng kỹ năng
local function attackKey(key)
	VirtualInputManager:SendKeyEvent(true, key, false, game)
	task.wait(0.05)
	VirtualInputManager:SendKeyEvent(false, key, false, game)
end

-- Spam kỹ năng (Z, X, C)
task.spawn(function()
	while true do
		if autoFarmEnabled and not isDodging then
			attackKey("Z")
			task.wait(0.1)
			attackKey("X")
			task.wait(0.1)
			attackKey("C")
		end
		task.wait(0.1)
	end
end)

-- Auto Farm
local farmConnection = nil

local function stopFarm()
	if farmConnection then
		farmConnection:Disconnect()
		farmConnection = nil
	end
end

local function startFarm()
	if farmConnection then return end
	farmConnection = RunService.RenderStepped:Connect(function()
		if not autoFarmEnabled then return end

		local mob = getNearestMob()
		if mob and mob:FindFirstChild("HumanoidRootPart") then
			local mobHRP = mob.HumanoidRootPart

			if dodgeSkillEnabled and mob:FindFirstChild("Onskill") and mob.Onskill.Value then
				isDodging = true
				autoFarmEnabled = false
				stopFarm()

				local backPos = mobHRP.CFrame.LookVector * -100
				local dodgePos = mobHRP.Position + backPos
				standPart.CFrame = CFrame.new(dodgePos)
				hrp.CFrame = CFrame.new(dodgePos)
				return
			end

			if isDodging and (not mob:FindFirstChild("Onskill") or not mob.Onskill.Value) then
				isDodging = false
				if dodgeSkillEnabled then
					autoFarmEnabled = true
					startFarm()
				end
			end

			if not isDodging then
				local offset = (-mobHRP.CFrame.LookVector * 7)
				local targetPos = mobHRP.Position + offset
				standPart.CFrame = CFrame.new(targetPos)
				hrp.CFrame = CFrame.new(targetPos, mobHRP.Position)
				attackM1()
			end
		end
	end)
end

-- Giao diện bật tắt Farm
Tab:CreateToggle({
	Name = "Start Farm",
	CurrentValue = false,
	Flag = "FarmToggle",
	Callback = function(value)
		autoFarmEnabled = value
		if value then
			startFarm()
		else
			stopFarm()
		end
	end,
})

-- Giao diện bật tắt né kỹ năng
Tab:CreateToggle({
	Name = "Dodge Skill",
	CurrentValue = false,
	Flag = "DodgeSkillToggle",
	Callback = function(value)
		dodgeSkillEnabled = value
	end,
})
