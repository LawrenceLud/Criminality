-- Variáveis
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ESPEnabled = false -- Controle para ativar/desativar o ESP
local AimbotEnabled = false -- Controle para ativar/desativar o Aimbot
local ESPObjects = {} -- Tabela para armazenar ESPs criados

-- Criar Interface Gráfica
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local ButtonFrame = Instance.new("Frame", ScreenGui)

ButtonFrame.Size = UDim2.new(0, 200, 0, 100) -- Ajuste o tamanho do painel onde os botões ficam
ButtonFrame.Position = UDim2.new(0.5, -100, 0.8, 0) -- Centralizado na tela
ButtonFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ButtonFrame.BackgroundTransparency = 0.5

local ToggleButton = Instance.new("TextButton", ButtonFrame)
local AimbotButton = Instance.new("TextButton", ButtonFrame)

-- Configuração do Botão para ESP
ToggleButton.Size = UDim2.new(1, 0, 0, 50) -- Botão ocupa 100% da largura
ToggleButton.Position = UDim2.new(0, 50, 50, 0) -- Fica no topo do painel
ToggleButton.Text = "Ativar ESP"
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 20

-- Configuração do Botão para Aimbot
AimbotButton.Size = UDim2.new(1, 0, 0, 50) -- Botão ocupa 100% da largura
AimbotButton.Position = UDim2.new(0, 0, 0, 50) -- Fica logo abaixo do botão ESP
AimbotButton.Text = "Ativar Aimbot"
AimbotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotButton.Font = Enum.Font.SourceSansBold
AimbotButton.TextSize = 20

-- Função para criar ESP para um jogador
local function CreateESP(player)
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
        local tracer = Instance.new("Frame")
        tracer.Size = UDim2.new(0, 2, 0, 100)  -- Tamanho da linha
        tracer.BackgroundColor3 = Color3.new(1, 0, 0) -- Vermelho
        tracer.BackgroundTransparency = 0.5
        tracer.Position = UDim2.new(0, 0, 0, 0)
        tracer.Parent = ScreenGui

        -- Atualizar posição da linha
        local function UpdateTracer()
            if ESPEnabled and character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
                local rootPartPos = Camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                tracer.Position = UDim2.new(0, Camera.ViewportSize.X / 2, 0, Camera.ViewportSize.Y) -- Base da tela
                tracer.Size = UDim2.new(0, 2, 0, (Camera.ViewportSize.Y - rootPartPos.Y)) -- Ajusta o tamanho da linha

                -- Ajusta a posição do tracer para conectar a base da tela até o personagem
                tracer.Position = UDim2.new(0, Camera.ViewportSize.X / 2, 0, Camera.ViewportSize.Y - rootPartPos.Y)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        end

        game:GetService("RunService").RenderStepped:Connect(UpdateTracer)

        -- Remover ESP quando o jogador sair
        player.AncestryChanged:Connect(function()
            tracer:Remove()
        end)

        -- Armazena objetos do ESP para controle
        table.insert(ESPObjects, {NameTag = nameTag, Tracer = tracer})
    end)
end

-- Função para ativar/desativar o ESP
local function ToggleESP()
    ESPEnabled = not ESPEnabled
    ToggleButton.Text = ESPEnabled and "Desativar ESP" or "Ativar ESP"

    -- Atualiza visibilidade de todos os ESPs
    for _, espData in pairs(ESPObjects) do
        espData.NameTag.Enabled = ESPEnabled
        espData.Tracer.Visible = ESPEnabled
    end
end

-- Função para ativar/desativar o Aimbot
local function ToggleAimbot()
    AimbotEnabled = not AimbotEnabled
    AimbotButton.Text = AimbotEnabled and "Desativar Aimbot" or "Ativar Aimbot"
end

-- Função de Aimbot
local function Aimbot()
    if AimbotEnabled then
        local closestPlayer = nil
        local closestDistance = math.huge
        
        -- Encontrar o jogador mais próximo
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (Camera.CFrame.Position - player.Character.HumanoidRootPart.Position).magnitude
                if dist < closestDistance then
                    closestDistance = dist
                    closestPlayer = player
                end
            end
        end
        
        -- Mire no jogador mais próximo
        if closestPlayer then
            local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
            local lookAt = CFrame.new(Camera.CFrame.Position, targetPosition).LookVector
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition) -- Ajusta a mira da câmera
        end
    end
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

-- Conecta os botões para ativar/desativar o ESP e Aimbot
ToggleButton.MouseButton1Click:Connect(ToggleESP)
AimbotButton.MouseButton1Click:Connect(ToggleAimbot)

-- Atualizar a mira com a função de Aimbot
game:GetService("RunService").RenderStepped:Connect(Aimbot)
