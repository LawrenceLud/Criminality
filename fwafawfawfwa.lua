--[[
    Hub Loader para Roblox Exploit
    
    Este script é responsável por:
    1. Obter o HWID único do dispositivo
    2. Validar a chave com o servidor
    3. Carregar o Templo Hub após verificação
    4. Permitir obtenção de chave via WorkInk
]]

-- Configurações
local CONFIG = {
    API_URL = "https://3e85de6f-a7f1-4473-a8b9-56383a9de229-00-1nh4mmjwdhlwq.janeway.replit.dev", -- Substitua com a URL real onde o código está hospedado
    HUB_NAME = "Templo Hub",
    VERSION = "3.0.0",
    TEMPLO_HUB_URL = "https://raw.githubusercontent.com/LawrenceLud/ProjectBaki3/refs/heads/main/TemploHub.lua"
}

-- Utilitários
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local PlaceId = game.PlaceId

-- Função para obter o ID de hardware único
local function GetHWID()
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    
    -- Combinar com identificadores adicionais para maior segurança
    if identifyexecutor then
        hwid = hwid .. "_" .. identifyexecutor()
    end
    
    -- Adicionar um hash básico para dificultar a adulteração
    local function SimpleHash(str)
        local hash = 0
        for i = 1, #str do
            hash = bit32.bxor(bit32.lshift(hash, 5) - hash, string.byte(str, i))
        end
        return tostring(hash)
    end
    
    return SimpleHash(hwid)
end

-- Função para comunicação com o servidor
local function SendRequest(endpoint, data)
    local success, response = pcall(function()
        return request({
            Url = CONFIG.API_URL .. endpoint,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Accept"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if success and response and response.StatusCode == 200 then
        local jsonSuccess, jsonData = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)
        
        if jsonSuccess then
            return true, jsonData
        end
    end
    
    return false, {
        success = false,
        message = "Falha na conexão com o servidor",
        data = nil
    }
end

-- Função para validar a chave com o servidor
local function ValidateKey(key)
    local data = {
        key = key,
        hwid = GetHWID(),
        username = LocalPlayer.Name,
        place_id = PlaceId
    }
    
    return SendRequest("/api/roblox/authorize", data)
end

-- Função para carregar o Templo Hub
local function LoadTemploHub()
    local success, result = pcall(function()
        return loadstring(game:HttpGet(CONFIG.TEMPLO_HUB_URL))()
    end)
    
    if not success then
        warn("Falha ao carregar o Templo Hub: " .. tostring(result))
        return false
    end
    
    return true
end

-- Interface de usuário para entrada da chave
local function CreateKeyUI()
    -- Criar ScreenGui com proteção
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TemploHubKeySystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Proteção contra detecção
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    end
    
    -- Tente diferentes métodos para adicionar a GUI
    local success = pcall(function()
        if game:GetService("CoreGui") then
            ScreenGui.Parent = game:GetService("CoreGui")
        end
    end)
    
    if not success or not ScreenGui.Parent then
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Frame principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 220)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Arredondar as bordas
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Title.BorderSizePixel = 0
    Title.Font = Enum.Font.GothamBold
    Title.Text = CONFIG.HUB_NAME .. " v" .. CONFIG.VERSION
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Parent = MainFrame
    
    -- Arredondar as bordas do título
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Caixa de texto para a chave
    local KeyInput = Instance.new("TextBox")
    KeyInput.Name = "KeyInput"
    KeyInput.Size = UDim2.new(0.85, 0, 0, 35)
    KeyInput.Position = UDim2.new(0.5, 0, 0.4, 0)
    KeyInput.AnchorPoint = Vector2.new(0.5, 0)
    KeyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    KeyInput.BorderSizePixel = 0
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Insira sua chave..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = MainFrame
    
    -- Arredondar as bordas da caixa de texto
    local KeyInputCorner = Instance.new("UICorner")
    KeyInputCorner.CornerRadius = UDim.new(0, 6)
    KeyInputCorner.Parent = KeyInput
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(0.85, 0, 0, 20)
    Status.Position = UDim2.new(0.5, 0, 0.58, 0)
    Status.AnchorPoint = Vector2.new(0.5, 0)
    Status.BackgroundTransparency = 1
    Status.Font = Enum.Font.Gotham
    Status.Text = "Entre com sua chave para ativar o hub"
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 12
    Status.Parent = MainFrame
    
    -- Botão de ativação
    local ActivateButton = Instance.new("TextButton")
    ActivateButton.Name = "ActivateButton"
    ActivateButton.Size = UDim2.new(0.4, 0, 0, 35)
    ActivateButton.Position = UDim2.new(0.08, 0, 0.7, 0)
    ActivateButton.BackgroundColor3 = Color3.fromRGB(60, 120, 216)
    ActivateButton.BorderSizePixel = 0
    ActivateButton.Font = Enum.Font.GothamBold
    ActivateButton.Text = "Ativar"
    ActivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActivateButton.TextSize = 14
    ActivateButton.AutoButtonColor = true
    ActivateButton.Parent = MainFrame
    
    -- Arredondar as bordas do botão de ativação
    local ActivateButtonCorner = Instance.new("UICorner")
    ActivateButtonCorner.CornerRadius = UDim.new(0, 6)
    ActivateButtonCorner.Parent = ActivateButton
    
    -- Botão para obter chave
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Size = UDim2.new(0.4, 0, 0, 35)
    GetKeyButton.Position = UDim2.new(0.52, 0, 0.7, 0)
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.Font = Enum.Font.GothamBold
    GetKeyButton.Text = "Obter Chave"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 14
    GetKeyButton.AutoButtonColor = true
    GetKeyButton.Parent = MainFrame
    
    -- Arredondar as bordas do botão de obter chave
    local GetKeyButtonCorner = Instance.new("UICorner")
    GetKeyButtonCorner.CornerRadius = UDim.new(0, 6)
    GetKeyButtonCorner.Parent = GetKeyButton
    
    -- Função para atualizar o status
    local function UpdateStatus(text, color)
        Status.Text = text
        Status.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    end
    
    -- Função para obter uma chave através do WorkInk
    local function GetKeyFromWorkInk()
        UpdateStatus("Gerando link...", Color3.fromRGB(255, 255, 100))
        GetKeyButton.Text = "Gerando..."
        GetKeyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        GetKeyButton.AutoButtonColor = false
        
        -- Enviar requisição para obter o link do WorkInk
        local data = {
            hwid = GetHWID()
        }
        
        local success, response = SendRequest("/api/getkey/generate", data)
        
        if success and response.success then
            -- Abrir o link no navegador
            UpdateStatus("Abrindo navegador...", Color3.fromRGB(100, 255, 100))
            
            pcall(function()
                -- Tentar copiar URL para a área de transferência
                if setclipboard then
                    setclipboard(response.data.url)
                end
                
                -- Tentar diferentes métodos para abrir o URL no navegador
                if syn and syn.request then
                    syn.request({
                        Url = response.data.url,
                        Method = "GET"
                    })
                elseif http and http.request then
                    http.request({
                        Url = response.data.url
                    })
                elseif request then
                    request({
                        Url = response.data.url,
                        Method = "GET"
                    })
                elseif KRNL_LOADED and krnl then
                    krnl.request({
                        Url = response.data.url,
                        Method = "GET"
                    })
                elseif getgenv().UWP_BROWSER then -- Fluxus UWP
                    getgenv().UWP_BROWSER(response.data.url)
                else
                    -- Tentativa genérica para outros exploits
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Link Copiado",
                            Text = "Cole no navegador: " .. response.data.url:sub(1, 25) .. "...",
                            Duration = 10
                        })
                    end)
                end
            end)
            
            UpdateStatus("Link copiado! Complete as tarefas para obter sua chave.", Color3.fromRGB(100, 255, 100))
            wait(3)
            UpdateStatus("Cole a chave ao finalizar as tarefas.", Color3.fromRGB(200, 200, 200))
        else
            local errorMsg = "Erro ao gerar link. Tente novamente."
            if response and response.message then
                errorMsg = response.message
            end
            
            UpdateStatus(errorMsg, Color3.fromRGB(255, 100, 100))
        end
        
        wait(1)
        GetKeyButton.Text = "Obter Chave"
        GetKeyButton.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
        GetKeyButton.AutoButtonColor = true
    end
    
    -- Conectar evento ao botão de obter chave
    GetKeyButton.MouseButton1Click:Connect(function()
        GetKeyFromWorkInk()
    end)
    
    -- Lógica do botão de ativação
    ActivateButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        
        if key == "" then
            UpdateStatus("Por favor, insira uma chave válida.", Color3.fromRGB(255, 100, 100))
            return
        end
        
        UpdateStatus("Verificando chave...", Color3.fromRGB(255, 255, 100))
        ActivateButton.Text = "Verificando..."
        ActivateButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        ActivateButton.AutoButtonColor = false
        
        -- Validar a chave
        local success, response = ValidateKey(key)
        
        if success and response.success then
            UpdateStatus("Chave válida! Carregando Templo Hub...", Color3.fromRGB(100, 255, 100))
            
            -- Pequeno delay antes de tentar carregar o hub
            wait(1)
            
            -- Destruir a UI antes de carregar o hub
            ScreenGui:Destroy()
            
            -- Exibir notificação de sucesso
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = CONFIG.HUB_NAME,
                    Text = "Carregando Templo Hub...",
                    Duration = 5
                })
            end)
            
            -- Carregar o Templo Hub
            local loadSuccess = LoadTemploHub()
            
            if not loadSuccess then
                -- Tente novamente, às vezes a primeira tentativa falha
                wait(1)
                LoadTemploHub()
            end
        else
            local errorMsg = "Erro na verificação da chave."
            if response and response.message then
                errorMsg = response.message
            end
            
            UpdateStatus(errorMsg, Color3.fromRGB(255, 100, 100))
            wait(2)
            ActivateButton.Text = "Ativar"
            ActivateButton.BackgroundColor3 = Color3.fromRGB(60, 120, 216)
            ActivateButton.AutoButtonColor = true
        end
    end)
    
    -- Tornar a UI arrastável
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        if not dragging then return end
        
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- Adicionar efeito de fechamento (X)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseButton.TextSize = 16
    CloseButton.Parent = MainFrame
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    return ScreenGui
end

-- Função principal para iniciar o sistema
local function Start()
    print(CONFIG.HUB_NAME .. " v" .. CONFIG.VERSION .. " - Inicializando...")
    
    -- Verificar se estamos no Roblox
    if not game or not game:GetService("Players") then
        warn("Este script só pode ser executado no Roblox")
        return
    end
    
    -- Esperar o jogador carregar se necessário
    if not Players.LocalPlayer then
        LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    else
        LocalPlayer = Players.LocalPlayer
    end
    
    -- Verificar se o executor suporta requisições HTTP
    if not request and not http and not syn then
        warn("Seu executor não suporta requisições HTTP")
        return
    end
    
    -- Mostrar a interface de entrada da chave
    CreateKeyUI()
end

-- Iniciar o script
Start()
