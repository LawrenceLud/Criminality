-- Configurações
local aimbotEnabled = false -- Toggle para ativar/desativar o aimbot
local aimAtPart = "Head" -- Parte do modelo para mirar
local wallCheckEnabled = true -- Verificar se o alvo está visível
local targetNPCs = false -- Mirar em NPCs além de jogadores
local aimKey = Enum.UserInputType.MouseButton2 -- Tecla para ativar o aimbot (M2)
local FOVRadius = 100 -- Raio do círculo de FOV
local showFOV = true -- Mostrar o círculo de FOV

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variáveis Locais
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Desenhar o Círculo do FOV
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.NumSides = 64
fovCircle.Radius = FOVRadius
fovCircle.Filled = false
fovCircle.Transparency = 1
fovCircle.Color = Color3.fromRGB(255, 255, 255) -- Cor do círculo
fovCircle.Visible = showFOV

-- Atualizar a posição do Círculo do FOV
RunService.RenderStepped:Connect(function()
    if showFOV then
        fovCircle.Position = UserInputService:GetMouseLocation()
    end
end)

-- Função para obter o alvo mais próximo ao centro da mira dentro do FOV
local function getClosestTargetToCursor()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

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

                -- Verificar se está dentro do FOV
                if distanceToCursor <= FOVRadius and distanceToCursor < shortestDistance then
                    if wallCheckEnabled then
                        local rayDirection = (targetPart.Position - Camera.CFrame.Position).Unit * 1000
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterDescendantsInstances = {character}
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

    -- Verificar NPCs, se habilitado
    if targetNPCs then
        for _, npc in pairs(workspace:GetDescendants()) do
            checkTarget(npc)
        end
    end

    return nearestTarget
end

-- Função para mirar no alvo
local function lookAt(targetPosition)
    if targetPosition then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
    end
end

-- Aimbot Loop
local function aimAtTarget()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then
            connection:Disconnect()
            return
        end

        local closestTarget = getClosestTargetToCursor()
        if closestTarget and closestTarget:FindFirstChild(aimAtPart) then
            local targetPart = closestTarget[aimAtPart]
            lookAt(targetPart.Position)
        end
    end)
end

-- Controle do Aimbot com Tecla
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == aimKey then
        aimbotEnabled = true
        aimAtTarget()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == aimKey then
        aimbotEnabled = false
    end
end)
