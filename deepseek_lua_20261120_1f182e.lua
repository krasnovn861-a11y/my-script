-- Rivals ESP + Menu (базовый каркас)
-- Для Delta Executor / любого executor с Drawing API

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = false
local ESPObjects = {}

-- Создание Highlight для игрока
local function createESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end
    if not player.Character then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- сквозь стены
    highlight.Parent = player.Character

    ESPObjects[player] = highlight
end

local function removeESP(player)
    if ESPObjects[player] then
        ESPObjects[player]:Destroy()
        ESPObjects[player] = nil
    end
end

-- Обновление при респавне
local function onCharacterAdded(player, character)
    if ESPEnabled and player ~= LocalPlayer then
        task.wait(0.1)
        createESP(player)
    end
end

-- Подписка на всех игроков
for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function(char)
        onCharacterAdded(player, char)
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        onCharacterAdded(player, char)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Меню
local gui = Instance.new("ScreenGui")
gui.Name = "MyMenu"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "My Rivals Menu"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0, 160, 0, 35)
espBtn.Position = UDim2.new(0, 20, 0, 40)
espBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
espBtn.Text = "ESP: OFF"
espBtn.TextColor3 = Color3.new(1, 1, 1)
espBtn.Font = Enum.Font.Gotham
espBtn.TextSize = 13
espBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = espBtn

espBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    espBtn.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
    espBtn.BackgroundColor3 = ESPEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(60, 60, 80)

    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                createESP(player)
            end
        end
    else
        for player, _ in pairs(ESPObjects) do
            removeESP(player)
        end
    end
end)