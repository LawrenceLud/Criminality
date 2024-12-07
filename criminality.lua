-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Configurações iniciais
local aimAtPart = "Head" -- Focar na cabeça
local wallCheckEnabled = true
local targetNPCs = false
local espEnabled = false
local aimbotEnabled = false

-- Funções Gerais
local function createESP(target)
    if target and not target:FindFirstChild("ESPLine") then
        local line = Instance.new("BillboardGui")
        line.Parent = target
        line.Name = "ESPLine"
        line.AlwaysOnTop = true
        line.Size = UDim2.new(0, 200, 0, 50)
        line.Adornee = target

        local label = Instance.new("TextLabel", line)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = target.Name
        label.TextColor3 = Color3.new(1, 0, 0)
        label.TextScaled = true
    end
end

local function toggleESP(state)
    espEnabled = state
    if espEnabled then
        RunService.RenderStepped:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    createESP(player.Character)
                end
            end

            if targetNPCs then
                for _, npc in pairs(workspace:GetDescendants()) do
                    if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                        createESP(npc)
                    end
                end
            end
        end)
    else
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("ESPLine") then
                obj.ESPLine:Destroy()
            end
        end
    end
end

local function getClosestTargetToCursor()
    local screenSize = Camera.ViewportSize
    local centerOfScreen = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    local nearestTarget = nil
    local shortestDistance = math.huge

    local function checkTarget(target)
        if target and target:IsA("Model") and target:FindFirstChild("Humanoid") and target:FindFirstChild(aimAtPart) then
            local targetPart = target[aimAtPart]
            local screenPosition, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

            if onScreen then
                local distanceToCursor = (Vector2.new(screenPosition.X, screenPosition.Y) - centerOfScreen).Magnitude

                if distanceToCursor < shortestDistance then
                    if wallCheckEnabled then
                        local rayDirection = (targetPart.Position - Camera.CFrame.Position).Unit * 1000
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

                        local raycastResult = workspace:Raycast(Camera.CFrame.Position, rayDirection, raycastParams)

                        if raycastResult and raycastResult.Instance:IsDescendantOf(target) then
                            shortestDistance = distanceToCursor
                            nearestTarget = target
                        end
                    else
                        shortestDistance = distanceToCursor
                        nearestTarget = target
                    end
                end
            end
        end
    end

    -- Verificar jogadores
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            checkTarget(player.Character)
        end
    end

    -- Verificar NPCs
    if targetNPCs then
        for _, npc in pairs(workspace:GetDescendants()) do
            checkTarget(npc)
        end
    end

    return nearestTarget
end

local function lookAt(targetPosition)
    if targetPosition then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
    end
end

local function aimAtTarget()
    RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then return end

        local closestTarget = getClosestTargetToCursor()
        if closestTarget and closestTarget:FindFirstChild(aimAtPart) then
            local targetPart = closestTarget[aimAtPart]
            lookAt(targetPart.Position)
        end
    end)
end

-- Interface Gráfica
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
MainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
MainFrame.BorderSizePixel = 0

local ESPButton = Instance.new("TextButton", MainFrame)
ESPButton.Size = UDim2.new(1, 0, 0.5, 0)
ESPButton.Text = "Toggle ESP"
ESPButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
ESPButton.TextColor3 = Color3.new(1, 1, 1)
ESPButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    toggleESP(espEnabled)
end)

local AimbotButton = Instance.new("TextButton", MainFrame)
AimbotButton.Size = UDim2.new(1, 0, 0.5, 0)
AimbotButton.Position = UDim2.new(0, 0, 0.5, 0)
AimbotButton.Text = "Toggle Aimbot"
AimbotButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
AimbotButton.TextColor3 = Color3.new(1, 1, 1)
AimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        aimAtTarget()
    end
end)
