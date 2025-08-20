
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Защита от повторной загрузки
if _G.DOKCIX_HUB_LOADED then
    return
end
_G.DOKCIX_HUB_LOADED = true

print("🔥 DokciX Hub Pro v9.1 запущен для " .. player.Name)

-- Глобальные состояния функций
local Functions = {
    AntiAFK = false,
    NightVision = false,
    SpeedHack = false,
    HighJump = false,
    NoClip = false,
    FullBright = false,
    StealthMode = true
}

-- Таблица для хранения деактиваторов
local ActiveFunctions = {}
local OriginalCollisions = {}

-- Реализации функций
local function ToggleAntiAFK(enable)
    if Functions.AntiAFK == enable then return end
    Functions.AntiAFK = enable
    
    if enable then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
                task.wait(59)
            end)
        end)
        
        ActiveFunctions.AntiAFK = function()
            if connection then
                connection:Disconnect()
            end
        end
        print("Anti-AFK включен")
    elseif ActiveFunctions.AntiAFK then
        pcall(ActiveFunctions.AntiAFK)
        ActiveFunctions.AntiAFK = nil
        print("Anti-AFK выключен")
    end
    return Functions.AntiAFK
end

local function ToggleNightVision(enable)
    if Functions.NightVision == enable then return end
    Functions.NightVision = enable
    
    if enable then
        local originalBrightness = Lighting.Brightness
        local originalClockTime = Lighting.ClockTime
        local originalFogEnd = Lighting.FogEnd
        
        pcall(function()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 1000
        end)
        
        ActiveFunctions.NightVision = function()
            pcall(function()
                Lighting.Brightness = originalBrightness
                Lighting.ClockTime = originalClockTime
                Lighting.FogEnd = originalFogEnd
            end)
        end
        print("Ночное зрение включено")
    elseif ActiveFunctions.NightVision then
        pcall(ActiveFunctions.NightVision)
        ActiveFunctions.NightVision = nil
        print("Ночное зрение выключено")
    end
    return Functions.NightVision
end

local function ToggleSpeedHack(enable)
    if Functions.SpeedHack == enable then return end
    Functions.SpeedHack = enable
    
    local function applySpeed(value)
        pcall(function()
            if player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = value
                end
            end
        end)
    end
    
    if enable then
        applySpeed(32)
        local connection
        connection = player.CharacterAdded:Connect(function(character)
            task.wait(1)
            applySpeed(32)
        end)
        
        ActiveFunctions.SpeedHack = function()
            if connection then
                connection:Disconnect()
            end
            applySpeed(16)
        end
        print("Скорость x2 включена")
    elseif ActiveFunctions.SpeedHack then
        pcall(ActiveFunctions.SpeedHack)
        ActiveFunctions.SpeedHack = nil
        print("Скорость x2 выключена")
    end
    return Functions.SpeedHack
end

local function ToggleHighJump(enable)
    if Functions.HighJump == enable then return end
    Functions.HighJump = enable
    
    local function applyJump(value)
        pcall(function()
            if player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = value
                end
            end
        end)
    end
    
    if enable then
        applyJump(75)
        local connection
        connection = player.CharacterAdded:Connect(function(character)
            task.wait(1)
            applyJump(75)
        end)
        
        ActiveFunctions.HighJump = function()
            if connection then
                connection:Disconnect()
            end
            applyJump(50)
        end
        print("Высокий прыжок включен")
    elseif ActiveFunctions.HighJump then
        pcall(ActiveFunctions.HighJump)
        ActiveFunctions.HighJump = nil
        print("Высокий прыжок выключен")
    end
    return Functions.HighJump
end

-- ПЕРЕРАБОТАННЫЙ NoClip с гарантированным выключением
local function ToggleNoClip(enable)
    if Functions.NoClip == enable then return end
    Functions.NoClip = enable
    
    if enable then
        -- Сохраняем оригинальные значения коллизий
        pcall(function()
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        OriginalCollisions[part] = part.CanCollide
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        -- Создаем соединение для новых частей
        local connection
        connection = player.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            pcall(function()
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        OriginalCollisions[part] = part.CanCollide
                        part.CanCollide = false
                    end
                end
            end)
        end)
        
        ActiveFunctions.NoClip = function()
            if connection then
                connection:Disconnect()
            end
            
            -- Восстанавливаем оригинальные коллизии
            pcall(function()
                for part, canCollide in pairs(OriginalCollisions) do
                    if part and part.Parent then
                        part.CanCollide = canCollide
                    end
                end
                table.clear(OriginalCollisions)
            end)
        end
        print("NoClip включен")
    elseif ActiveFunctions.NoClip then
        pcall(ActiveFunctions.NoClip)
        ActiveFunctions.NoClip = nil
        print("NoClip выключен")
    end
    return Functions.NoClip
end

local function ToggleFullBright(enable)
    if Functions.FullBright == enable then return end
    Functions.FullBright = enable
    
    if enable then
        local originalAmbient = Lighting.Ambient
        local originalColorShiftBottom = Lighting.ColorShift_Bottom
        local originalColorShiftTop = Lighting.ColorShift_Top
        
        pcall(function()
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
            Lighting.ColorShift_Top = Color3.new(1, 1, 1)
        end)
        
        ActiveFunctions.FullBright = function()
            pcall(function()
                Lighting.Ambient = originalAmbient
                Lighting.ColorShift_Bottom = originalColorShiftBottom
                Lighting.ColorShift_Top = originalColorShiftTop
            end)
        end
        print("FullBright включен")
    elseif ActiveFunctions.FullBright then
        pcall(ActiveFunctions.FullBright)
        ActiveFunctions.FullBright = nil
        print("FullBright выключен")
    end
    return Functions.FullBright
end

local function ToggleStealthMode(enable)
    if Functions.StealthMode == enable then return end
    Functions.StealthMode = enable
    
    if enable then
        print("Stealth Mode включен")
    else
        print("Stealth Mode выключен")
    end
    return Functions.StealthMode
end

-- Создаем GUI
local gui = Instance.new("ScreenGui")
gui.Name = "DXH_"..tostring(math.random(10000,99999))
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Основной фрейм меню
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = gui
mainFrame.Size = UDim2.new(0.35, 0, 0.7, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true

-- Скругление углов
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Тень
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Image = "rbxassetid://5234388158"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Parent = mainFrame
shadow.ZIndex = -1

-- Баннер
local banner = Instance.new("ImageLabel")
banner.Name = "PremiumBanner"
banner.Parent = mainFrame
banner.Size = UDim2.new(1, -20, 0.2, 0)
banner.Position = UDim2.new(0, 10, 0, 10)
banner.BackgroundTransparency = 1
banner.Image = "rbxassetid://14813419671"
banner.ScaleType = Enum.ScaleType.Crop
banner.ZIndex = 2

-- Заголовок
local title = Instance.new("TextLabel")
title.Text = "DOKCIX HUB PRO | " .. player.Name
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0.2, 5)
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- Поисковая строка
local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.PlaceholderText = "🔍 Поиск функций..."
searchBox.Size = UDim2.new(0.9, 0, 0, 30)
searchBox.Position = UDim2.new(0.05, 0, 0.25, 0)
searchBox.Parent = mainFrame
searchBox.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.ClearTextOnFocus = false
searchBox.Text = ""
searchBox.ZIndex = 3

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchBox

-- Контейнер для кнопок
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ContentFrame"
scrollFrame.Parent = mainFrame
scrollFrame.Size = UDim2.new(0.95, 0, 0.65, 0)
scrollFrame.Position = UDim2.new(0.025, 0, 0.32, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ZIndex = 2

-- Создаем макет для кнопок
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollFrame
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 10)

-- Функция переключения меню
local function toggleMenu()
    mainFrame.Visible = not mainFrame.Visible
    
    if mainFrame.Visible then
        -- Анимация открытия
        mainFrame.Size = UDim2.new(0.01, 0, 0.01, 0)
        mainFrame.Visible = true
        
        local tween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.35, 0, 0.7, 0)}
        )
        tween:Play()
    else
        -- Анимация закрытия
        local tween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(0.01, 0, 0.01, 0)}
        )
        tween:Play()
        tween.Completed:Wait()
        mainFrame.Visible = false
    end
end

-- ПРОСТОЙ ОБРАБОТЧИК F4
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.F4 then
        toggleMenu()
    end
end)

-- Резервная кнопка открытия
local openBtn = Instance.new("ImageButton")
openBtn.Name = "MenuActivator"
openBtn.Parent = gui
openBtn.Image = "rbxassetid://136032676334555"
openBtn.Size = UDim2.new(0.06, 0, 0.06, 0)
openBtn.Position = UDim2.new(0.93, 0, 0.02, 0)
openBtn.BackgroundTransparency = 1
openBtn.ZIndex = 5

openBtn.MouseButton1Click:Connect(toggleMenu)

-- Индикатор состояния
local statusLight = Instance.new("Frame")
statusLight.Parent = openBtn
statusLight.Size = UDim2.new(0.2, 0, 0.2, 0)
statusLight.Position = UDim2.new(0.8, 0, 0.8, 0)
statusLight.BackgroundColor3 = Color3.new(1, 0, 0)
statusLight.BorderSizePixel = 0
statusLight.ZIndex = 10

local lightCorner = Instance.new("UICorner")
lightCorner.CornerRadius = UDim.new(1, 0)
lightCorner.Parent = statusLight

-- Обновление индикатора
local function updateStatusLight()
    statusLight.BackgroundColor3 = mainFrame.Visible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Text = "X"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Parent = mainFrame
closeButton.ZIndex = 3

closeButton.MouseButton1Click:Connect(toggleMenu)

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

-- Создание секции
local function createSection(titleText, layoutOrder)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 35)
    section.BackgroundTransparency = 1
    section.LayoutOrder = layoutOrder
    section.ZIndex = 2
    
    local label = Instance.new("TextLabel")
    label.Text = "◈ "..titleText
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(0, 180, 255)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    
    return section
end

-- Создание функциональной кнопки
local function createFeatureButton(name, description, riskLevel, layoutOrder)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 60)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
    buttonFrame.BackgroundTransparency = 0.3
    buttonFrame.BorderSizePixel = 0
    buttonFrame.LayoutOrder = layoutOrder
    buttonFrame.ZIndex = 2
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = buttonFrame
    
    -- Индикатор риска
    local riskIndicator = Instance.new("Frame")
    riskIndicator.Size = UDim2.new(0.02, 0, 1, 0)
    riskIndicator.BackgroundColor3 = 
        riskLevel == 1 and Color3.new(0, 1, 0) or
        riskLevel == 2 and Color3.new(1, 1, 0) or
        Color3.new(1, 0, 0)
    riskIndicator.BorderSizePixel = 0
    riskIndicator.Parent = buttonFrame
    
    local riskCorner = Instance.new("UICorner")
    riskCorner.CornerRadius = UDim.new(0, 8)
    riskCorner.Parent = riskIndicator
    
    -- Текстовый контейнер
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(0.95, 0, 1, 0)
    textContainer.Position = UDim2.new(0.03, 0, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = buttonFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = name
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = textContainer
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Text = description
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 12
    descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    descLabel.Size = UDim2.new(1, 0, 0.5, 0)
    descLabel.Position = UDim2.new(0, 0, 0.5, 0)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.BackgroundTransparency = 1
    descLabel.Parent = textContainer
    
    -- Индикатор состояния
    local stateIndicator = Instance.new("Frame")
    stateIndicator.Size = UDim2.new(0.08, 0, 0.5, 0)
    stateIndicator.Position = UDim2.new(0.9, 0, 0.25, 0)
    stateIndicator.BackgroundColor3 = Functions[name] and Color3.new(0, 1, 0) or Color3.fromRGB(80, 80, 80)
    stateIndicator.BorderSizePixel = 0
    stateIndicator.Parent = buttonFrame
    
    local stateCorner = Instance.new("UICorner")
    stateCorner.CornerRadius = UDim.new(1, 0)
    stateCorner.Parent = stateIndicator
    
    -- Кликабельная область
    local button = Instance.new("TextButton")
    button.Text = ""
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Parent = buttonFrame
    button.ZIndex = 3
    
    -- Функционал переключения
    button.MouseButton1Click:Connect(function()
        if name == "InfYield" then
            -- Для InfYield просто загружаем, не меняем состояние
            local success, err = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
            end)
            if success then
                print("InfYield успешно загружен")
            else
                print("Ошибка загрузки InfYield: " .. err)
            end
        else
            local newState = not Functions[name]
            
            if name == "AntiAFK" then
                ToggleAntiAFK(newState)
            elseif name == "NightVision" then
                ToggleNightVision(newState)
            elseif name == "SpeedHack" then
                ToggleSpeedHack(newState)
            elseif name == "HighJump" then
                ToggleHighJump(newState)
            elseif name == "NoClip" then
                ToggleNoClip(newState)
            elseif name == "FullBright" then
                ToggleFullBright(newState)
            elseif name == "StealthMode" then
                ToggleStealthMode(newState)
            end
            
            stateIndicator.BackgroundColor3 = newState and Color3.new(0, 1, 0) or Color3.fromRGB(80, 80, 80)
        end
    end)
    
    return buttonFrame
end

-- Список функций
local features = {
    {
        section = "БАЗОВЫЕ ФУНКЦИИ",
        items = {
            {name = "AntiAFK", desc = "Предотвращает отключение за бездействие", risk = 1},
            {name = "NightVision", desc = "Улучшенная видимость в темноте", risk = 1},
            {name = "InfYield", desc = "Популярная чит-админка Infinite Yield", risk = 2}
        }
    },
    {
        section = "ПЕРЕДВИЖЕНИЕ",
        items = {
            {name = "SpeedHack", desc = "Увеличивает скорость передвижения", risk = 2},
            {name = "HighJump", desc = "Прыгайте в 3 раза выше", risk = 2},
            {name = "NoClip", desc = "Прохождение сквозь стены", risk = 3}
        }
    },
    {
        section = "ВИЗУАЛ",
        items = {
            {name = "FullBright", desc = "Убирает темноту полностью", risk = 1}
        }
    },
    {
        section = "СИСТЕМНЫЕ",
        items = {
            {name = "StealthMode", desc = "Скрывает следы читов", risk = 1}
        }
    }
}

-- Заполняем меню
local layoutOrder = 0
for _, category in ipairs(features) do
    local section = createSection(category.section, layoutOrder)
    section.Parent = scrollFrame
    layoutOrder += 1
    
    for _, feature in ipairs(category.items) do
        local button = createFeatureButton(feature.name, feature.desc, feature.risk, layoutOrder)
        button.Parent = scrollFrame
        layoutOrder += 1
    end
end

-- Обновление размера контента
uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 20)
end)

-- Система поиска
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = string.lower(searchBox.Text)
    
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            if child:FindFirstChild("TextLabel") and child.TextLabel:IsA("TextLabel") then
                -- Это секция
                child.Visible = string.find(string.lower(child.TextLabel.Text), searchText) ~= nil
            else
                -- Это кнопка функции
                local visible = false
                for _, descendant in ipairs(child:GetDescendants()) do
                    if descendant:IsA("TextLabel") and descendant.TextSize > 14 then
                        visible = string.find(string.lower(descendant.Text), searchText) ~= nil
                        break
                    end
                end
                child.Visible = visible
            end
        end
    end
end)

-- Экстренное отключение (F12)
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F12 then
        -- Отключаем все функции
        ToggleAntiAFK(false)
        ToggleNightVision(false)
        ToggleSpeedHack(false)
        ToggleHighJump(false)
        ToggleNoClip(false)
        ToggleFullBright(false)
        ToggleStealthMode(false)
        
        -- Закрываем GUI
        gui:Destroy()
        
        -- Чистим память
        _G.DOKCIX_HUB_LOADED = false
        
        print("🛑 Читы экстренно отключены!")
    end
end)

-- Автоматическая активация при изменении персонажа
player.CharacterAdded:Connect(function(character)
    task.wait(1) -- Ждем загрузки персонажа
    
    -- Повторно активируем функции
    if Functions.SpeedHack then ToggleSpeedHack(true) end
    if Functions.HighJump then ToggleHighJump(true) end
    if Functions.NoClip then ToggleNoClip(true) end
end)

-- Авто-обновление размера
RunService.Heartbeat:Connect(function()
    pcall(function()
        if mainFrame.Visible then
            local mousePos = UIS:GetMouseLocation()
            local distance = (Vector2.new(mainFrame.AbsolutePosition.X, mainFrame.AbsolutePosition.Y) - mousePos).Magnitude
            
            -- Прозрачность при наведении
            mainFrame.BackgroundTransparency = distance < 150 and 0.05 or 0.15
        end
        
        -- Обновляем индикатор статуса
        updateStatusLight()
    end)
end)

-- Инициализация Stealth Mode
ToggleStealthMode(true)

print("✅ Меню DokciX Hub Pro успешно загружено!")
print("🔑 Нажмите F4 для открытия меню")
print("⚡ Все функции готовы к использованию")
