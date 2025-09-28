local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera


local FOV_RADIUS = 150
local ESPEnabled = false
local FOVEnabled = false
local AutoAimEnabled = false
local KillAuraEnabled = false
local AUTO_FIRE_ENABLED = false
local FIRE_COOLDOWN = 0.2
local lastFire = 0
local REMOTE = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootGun")


local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "SafeFOVGui"
FOVGui.ResetOnSpawn = false
FOVGui.Parent = player:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
FOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = FOVGui

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255,50,50)
stroke.Parent = FOVCircle

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1,0)
corner.Parent = FOVCircle


local ESP_FOLDER = workspace:FindFirstChild("SafeESPFolder") or Instance.new("Folder")
ESP_FOLDER.Name = "SafeESPFolder"
ESP_FOLDER.Parent = workspace
local ESP_LABELS = {}

local function isEnemy(pl)
    if pl == player then return false end
    if not pl.Character or pl.Character.Parent ~= workspace then return false end
    local hum = pl.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if pl.Team and player.Team and pl.Team == player.Team then return false end
    return true
end

local function createBillboardFor(pl)
    local head = pl.Character:FindFirstChild("Head")
    if not head then return nil end
    local b = Instance.new("BillboardGui")
    b.Name = "SafeESPLabel"
    b.Adornee = head
    b.Size = UDim2.new(0,140,0,28)
    b.AlwaysOnTop = true
    b.Parent = ESP_FOLDER

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = pl.Name
    lbl.TextScaled = true
    lbl.Font = Enum.Font.SourceSansSemibold
    lbl.TextColor3 = Color3.fromRGB(255,120,120)
    lbl.TextStrokeTransparency = 0
    lbl.Parent = b
    return b
end

local function removeBillboard(pl)
    if ESP_LABELS[pl] then
        pcall(function() ESP_LABELS[pl]:Destroy() end)
        ESP_LABELS[pl] = nil
    end
end

local function inFOV(pos)
    local screenPos, onScreen = camera:WorldToViewportPoint(pos)
    if not onScreen then return false end
    local mousePos = Vector2.new(player:GetMouse().X, player:GetMouse().Y)
    return (Vector2.new(screenPos.X,screenPos.Y)-mousePos).Magnitude <= FOV_RADIUS
end

local function findNearestTarget()
    local best,bestDist = nil, math.huge
    local origin = camera.CFrame.Position
    for _, pl in ipairs(Players:GetPlayers()) do
        if isEnemy(pl) then
            local head = pl.Character:FindFirstChild("Head")
            local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
            local hum = pl.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health>0 and (head or hrp) then
                local targetPart = head or hrp
                if inFOV(targetPart.Position) then
                    local d = (targetPart.Position - origin).Magnitude
                    if d < bestDist then
                        bestDist = d
                        best = targetPart
                    end
                end
            end
        end
    end
    return best
end

local function tryFire(targetPart)
    if not targetPart then return end
    local now = tick()
    if now - lastFire < FIRE_COOLDOWN then return end
    local origin = camera.CFrame.Position
    local aimPos = targetPart.Position + Vector3.new(0,0.6,0)
    REMOTE:FireServer(origin, aimPos, targetPart, (origin+aimPos)/2)
    lastFire = now
end


local mouseDown = false
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then mouseDown = true end
    if input.KeyCode == Enum.KeyCode.F then
        AUTO_FIRE_ENABLED = not AUTO_FIRE_ENABLED
        print("Auto Fire toggled:", AUTO_FIRE_ENABLED)
    end
end)
UserInputService.InputEnded:Connect(function(input,gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then mouseDown = false end
end)


RunService.RenderStepped:Connect(function()
    local mouse = player:GetMouse()
    -- Update FOV
    FOVCircle.Visible = FOVEnabled
    if FOVEnabled then
        FOVCircle.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
        FOVCircle.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
    end


    if ESPEnabled then
        for _, pl in ipairs(Players:GetPlayers()) do
            if isEnemy(pl) then
                if not ESP_LABELS[pl] then
                    ESP_LABELS[pl] = createBillboardFor(pl)
                else
                    local head = pl.Character:FindFirstChild("Head")
                    if head then ESP_LABELS[pl].Adornee = head end
                end
            else
                removeBillboard(pl)
            end
        end
    else
        for k,_ in pairs(ESP_LABELS) do removeBillboard(k) end
    end

    if AutoAimEnabled then
        local target = findNearestTarget()
        if target then
            local mousePos = camera:WorldToViewportPoint(target.Position)
        end
    end

    if KillAuraEnabled or mouseDown or AUTO_FIRE_ENABLED then
        local target = findNearestTarget()
        if target then tryFire(target) end
    end
end)


local Rayfield
pcall(function() Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))() end)

if Rayfield then
    local Window = Rayfield:CreateWindow({
        Name = "CanHongSon",
        LoadingTitle = "Loading",
        LoadingSubtitle = "by SonDuBai",
        Theme = "Default"
    })

    local Tab = Window:CreateTab("Visuals", 4483362458)
    Tab:CreateToggle({Name="ESP ", CurrentValue=false, Flag="safe_esp", Callback=function(v) ESPEnabled=v end})
    Tab:CreateToggle({Name="FOV", CurrentValue=false, Flag="safe_fov", Callback=function(v) FOVEnabled=v end})
    Tab:CreateSlider({Name="FOV Radius", Range={20,800}, Increment=5, Suffix="px", CurrentValue=FOV_RADIUS, Flag="fov_radius", Callback=function(val) FOV_RADIUS=val FOVCircle.Size=UDim2.new(0,FOV_RADIUS*2,0,FOV_RADIUS*2) end})
    Tab:CreateToggle({Name="Auto Aim ", CurrentValue=false, Flag="auto_aim", Callback=function(v) AutoAimEnabled=v end})
    Tab:CreateToggle({Name="Kill Aura (PC ONLY)", CurrentValue=false, Flag="kill_aura", Callback=function(v) KillAuraEnabled=v end})
end
