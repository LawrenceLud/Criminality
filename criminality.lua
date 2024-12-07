local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()

local win = lib:Window("Criminality | Templo Hub", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)

local mainTab = win:Tab("Main Tab")

getgenv().Aimbot = nil
getgenv().ESP = nil

-- Toggle para o Aimbot
mainTab:Toggle("Aimbot", false, function(t)
    getgenv().Aimbot = t

    -- Variáveis Locais
    local aimbotEnabled = false
    local aimAtPart = "Head"
    local wallCheckEnabled = true
    local targetNPCs = false
    local aimKey = Enum.UserInputType.MouseButton2

    -- Serviços
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Função para obter o alvo mais próximo ao centro da mira
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

                    if distanceToCursor < shortestDistance then
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
            if aimbotEnabled then
                aimbotEnabled = true
                aimAtTarget()
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == aimKey then
            aimbotEnabled = false
        end
    end)

    -- Loop para desativar aimbot quando o toggle for desmarcado
    while getgenv().Aimbot do
        task.wait(.1)
        aimbotEnabled = getgenv().Aimbot
        if aimbotEnabled then
            aimAtTarget()
        end
    end
end)

-- Toggle para o ESP
mainTab:Toggle("ESP", false, function(t)
    getgenv().ESP = t

    -- Variáveis
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Função para criar ESP para um jogador
    local function CreateESP(player)
        -- Aguarda o Character do jogador
        player.CharacterAdded:Connect(function(character)
            local nameTag = Instance.new("BillboardGui")
            nameTag.Name = "ESPName"
            nameTag.Adornee = character:WaitForChild("HumanoidRootPart")
            nameTag.Size = UDim2.new(0, 150, 0, 30) -- Tamanho ajustado para menor
            nameTag.StudsOffset = Vector3.new(0, 3, 0)
            nameTag.AlwaysOnTop = true

            local nameLabel = Instance.new("TextLabel", nameTag)
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1, 0, 0) -- Vermelho
            nameLabel.TextStrokeTransparency = 0.5
            nameLabel.Text = player.Name
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.TextScaled = true

            nameTag.Parent = character:WaitForChild("HumanoidRootPart")

            -- Linha (tracer)
            local tracer = Drawing.new("Line")
            tracer.Color = Color3.new(1, 0, 0) -- Vermelho
            tracer.Thickness = 2

            -- Atualizar posição da linha
            game:GetService("RunService").RenderStepped:Connect(function()
                if character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
                    local rootPartPos = Camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                    tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Base da tela
                    tracer.To = Vector2.new(rootPartPos.X, rootPartPos.Y)
                    tracer.Visible = getgenv().ESP
                else
                    tracer.Visible = false
                end
            end)

            -- Remover ESP quando o jogador sair
            player.AncestryChanged:Connect(function()
                tracer:Remove()
            end)
        end)
    end

    -- Adiciona ESP para todos os jogadores
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end

    -- ESP para novos jogadores
    Players.PlayerAdded:Connect(function(player)
        CreateESP(player)
    end)
end)

-- Rejoin Button
mainTab:Button("Rejoin", function()
    game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)
