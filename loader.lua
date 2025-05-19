local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "CanHongSon",
    Icon = 0,
    LoadingTitle = "Loading",
    LoadingSubtitle = "by SonDuBai",
    Theme = "Default",
})

local Tab = Window:CreateTab("Farm", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local standPart = Instance.new("Part")
standPart.Size = Vector3.new(4, 1, 4)
standPart.Anchored = true
standPart.Transparency = 1
standPart.CanCollide = true
standPart.Name = "AutoFarmStand"
standPart.Parent = workspace

local autoFarmEnabled = false
local isDodging = false

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

local function useSkill(skillName, cf, pos)
	local args = {
		skillName,
		cf,
		pos,
		"OnSkill"
	}
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("Skill"):FireServer(unpack(args))
end

local function attackM1()
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

task.spawn(function()
	while true do
		if autoFarmEnabled then
			if not isDodging then
				local mob = getNearestMob()
				if mob and mob:FindFirstChild("HumanoidRootPart") then
					local mobHRP = mob.HumanoidRootPart
					useSkill("Skill1", mobHRP.CFrame, mobHRP.Position)
					task.wait(0.15)
					useSkill("Skill2", mobHRP.CFrame, mobHRP.Position)
					task.wait(0.15)
					useSkill("Skill3", mobHRP.CFrame, mobHRP.Position)
					task.wait(0.15)
				else
					task.wait(0.5)
				end
			else
				task.wait(0.1)
			end
		else
			task.wait(0.5)
		end
	end
end)

local farmConnection = nil

local function startFarm()
	if farmConnection then return end
	farmConnection = RunService.RenderStepped:Connect(function()
		if not autoFarmEnabled then return end

		local mob = getNearestMob()
		if mob and mob:FindFirstChild("HumanoidRootPart") then
			local mobHRP = mob.HumanoidRootPart

			if mob:FindFirstChild("Onskill") and mob.Onskill.Value then
				isDodging = true
				local backPos = mobHRP.CFrame.LookVector * -100
				local dodgePos = mobHRP.Position + backPos
				standPart.CFrame = CFrame.new(dodgePos)
				hrp.CFrame = CFrame.new(dodgePos)
				return
			else
				isDodging = false
			end

			local offset = (-mobHRP.CFrame.LookVector * 7)
			local targetPos = mobHRP.Position + offset
			standPart.CFrame = CFrame.new(targetPos)
			hrp.CFrame = CFrame.new(targetPos, mobHRP.Position)

			attackM1()
		end
	end)
end

local function stopFarm()
	if farmConnection then
		farmConnection:Disconnect()
		farmConnection = nil
	end
	isDodging = false
end

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

