
-- Variáveis
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ESPEnabled = false -- Controle para ativar/desativar o ESP
local ESPObjects = {} -- Tabela para armazenar ESPs criados

-- Criar Interface Gráfica
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local ToggleButton = Instance.new("TextButton", ScreenGui)

-- Configuração do Botão
ToggleButton.Size = UDim2.new(0, 200, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -100, 0.9, 0)
ToggleButton.Text = "Ativar ESP"
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 20

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
        local function UpdateTracer()
            if ESPEnabled and character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
                local rootPartPos = Camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Base da tela
                tracer.To = Vector2.new(rootPartPos.X, rootPartPos.Y)
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

-- Ativa/Desativa o ESP
local function ToggleESP()
    ESPEnabled = not ESPEnabled
    ToggleButton.Text = ESPEnabled and "Desativar ESP" or "Ativar ESP"

    -- Atualiza visibilidade de todos os ESPs
    for _, espData in pairs(ESPObjects) do
        espData.NameTag.Enabled = ESPEnabled
        espData.Tracer.Visible = ESPEnabled
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

-- Conecta o botão para ativar/desativar o ESP
ToggleButton.MouseButton1Click:Connect(ToggleESP)
