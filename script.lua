local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Защита от повторной инициализации
if player.PlayerGui:FindFirstChild("DokciXHub") then
	player.PlayerGui.DokciXHub:Destroy()
end

-- Цветовая схема
local COLOR_PALETTE = {
	Background = Color3.fromRGB(15, 15, 25),
	Foreground = Color3.fromRGB(25, 25, 40),
	Accent = Color3.fromRGB(0, 180, 180),
	Text = Color3.fromRGB(240, 240, 240),
	Button = Color3.fromRGB(45, 45, 65),
	ButtonHover = Color3.fromRGB(65, 65, 90),
	ButtonActive = Color3.fromRGB(0, 150, 150),
	Error = Color3.fromRGB(220, 80, 80),
	Success = Color3.fromRGB(80, 220, 120)
}

-- Переменные для ESP
local espEnabled = false
local espConnections = {}
local espBillboards = {}

-- Функция для ESP
local function toggleESP()
	espEnabled = not espEnabled

	if espEnabled then
		-- Создаем ESP для всех игроков
		for _, targetPlayer in ipairs(Players:GetPlayers()) do
			if targetPlayer == player or espBillboards[targetPlayer] then continue end

			local function createBillboard(char)
				if not char then return end

				-- Ожидаем появление HumanoidRootPart
				local rootPart = char:WaitForChild("HumanoidRootPart", 2)
				if not rootPart then return end
				
				if espBillboards[targetPlayer] then
					espBillboards[targetPlayer]:Destroy()
				end

				-- Создаем BillboardGui
				local billboard = Instance.new("BillboardGui")
				billboard.Name = targetPlayer.Name .. "_ESP"
				billboard.Size = UDim2.new(0, 200, 0, 50)
				billboard.StudsOffset = Vector3.new(0, 3, 0)
				billboard.AlwaysOnTop = true
				billboard.MaxDistance = 1000
				billboard.Adornee = rootPart
				billboard.Parent = player.PlayerGui.DokciXHub

				-- Текст с именем игрока
				local textLabel = Instance.new("TextLabel")
				textLabel.Size = UDim2.new(1, 0, 1, 0)
				textLabel.BackgroundTransparency = 1
				textLabel.Text = targetPlayer.Name
				textLabel.TextColor3 = COLOR_PALETTE.Success
				textLabel.TextStrokeTransparency = 0
				textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
				textLabel.Font = Enum.Font.GothamBold
				textLabel.TextSize = 16
				textLabel.TextStrokeTransparency = 0.5
				textLabel.Parent = billboard

				-- Индикатор здоровья
				local healthBar = Instance.new("Frame")
				healthBar.Name = "HealthBar"
				healthBar.Size = UDim2.new(0.7, 0, 0.15, 0)
				healthBar.Position = UDim2.new(0.15, 0, 0.85, 0)
				healthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				healthBar.BorderSizePixel = 0
				
				local healthFill = Instance.new("Frame")
				healthFill.Name = "Fill"
				healthFill.Size = UDim2.new(1, 0, 1, 0)
				healthFill.BackgroundColor3 = COLOR_PALETTE.Success
				healthFill.BorderSizePixel = 0
				healthFill.Parent = healthBar
				
				healthBar.Parent = billboard
				
				-- Обновление здоровья
				local humanoid = char:FindFirstChild("Humanoid")
				if humanoid then
					local function updateHealth()
						healthFill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
					end
					updateHealth()
					humanoid.HealthChanged:Connect(updateHealth)
				end

				espBillboards[targetPlayer] = billboard
			end

			-- Обработка текущего персонажа
			if targetPlayer.Character then
				createBillboard(targetPlayer.Character)
			end

			-- Обработка смены персонажа
			espConnections[targetPlayer] = targetPlayer.CharacterAdded:Connect(createBillboard)
			
			-- Обработка выхода игрока
			espConnections[targetPlayer.."_Removing"] = targetPlayer.AncestryChanged:Connect(function(_, parent)
				if parent == nil and espBillboards[targetPlayer] then
					espBillboards[targetPlayer]:Destroy()
					espBillboards[targetPlayer] = nil
				end
			end)
		end

		-- Обработка новых игроков
		espConnections.playerAdded = Players.PlayerAdded:Connect(function(newPlayer)
			espConnections[newPlayer] = newPlayer.CharacterAdded:Connect(function(char)
				if not espEnabled then return end
				createBillboard(char)
			end)
		end)
	else
		-- Удаляем все ESP
		for _, billboard in pairs(espBillboards) do
			billboard:Destroy()
		end

		-- Отключаем соединения
		for _, conn in pairs(espConnections) do
			conn:Disconnect()
		end

		espBillboards = {}
		espConnections = {}
	end
end

-- Создаем GUI
local gui = Instance.new("ScreenGui")
gui.Name = "DokciXHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.3, 0, 0.6, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = COLOR_PALETTE.Foreground
mainFrame.BackgroundTransparency = 0.1
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Parent = gui

-- Добавление стилей
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = COLOR_PALETTE.Accent
stroke.Parent = mainFrame

-- Эффект тени
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Parent = mainFrame

-- Анимация
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint)

-- Система перетаскивания
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Кнопки функций
local buttons = {
	{"Скорость x2", function()
		if player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = humanoid.WalkSpeed == 16 and 32 or 16
			end
		end
	end},
	
	{"Высокий прыжок", function()
		if player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.JumpHeight = humanoid.JumpHeight == 50 and 7.2 or 50
			end
		end
	end},
	
	{"Ночное зрение", function()
		local lighting = game:GetService("Lighting")
		lighting.Ambient = lighting.Ambient == Color3.new(1, 1, 1) 
			and Color3.new(0.5, 0.5, 0.5) 
			or Color3.new(1, 1, 1)
	end},
	
	{"Невидимость (клиент)", function()
		if player.Character then
			local transparency = 0.8
			for _, part in ipairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					transparency = part.LocalTransparencyModifier == 0.8 and 0 or 0.8
					break
				end
			end
			
			for _, part in ipairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = transparency
				end
			end
		end
	end},
	
	{"Полёт", function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
	end},
	
	{"Бессмертие", function()
		if player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			end
		end
	end},
	
	{"Infinite Yield", function()
		loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
	end},
	
	{"ESP", function()
		toggleESP()
	end}
}

-- Контейнер для кнопок
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
scrollFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5
scrollFrame.ScrollBarImageColor3 = COLOR_PALETTE.Accent
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #buttons * 50)
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scrollFrame

-- Создание кнопок
for i, btnData in ipairs(buttons) do
	local button = Instance.new("TextButton")
	button.Text = btnData[1]
	button.Size = UDim2.new(1, 0, 0, 42)
	button.BackgroundColor3 = COLOR_PALETTE.Button
	button.TextColor3 = COLOR_PALETTE.Text
	button.Font = Enum.Font.GothamSemibold
	button.TextSize = 15
	button.AutoButtonColor = false
	button.Parent = scrollFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = button

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Thickness = 1
	btnStroke.Color = COLOR_PALETTE.Accent
	btnStroke.Transparency = 0.7
	btnStroke.Parent = button

	button.MouseEnter:Connect(function()
		game:GetService("TweenService"):Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = COLOR_PALETTE.ButtonHover,
			TextColor3 = COLOR_PALETTE.Accent,
			Size = UDim2.new(1.02, 0, 0, 44)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		game:GetService("TweenService"):Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = COLOR_PALETTE.Button,
			TextColor3 = COLOR_PALETTE.Text,
			Size = UDim2.new(1, 0, 0, 42)
		}):Play()
	end)

	button.MouseButton1Click:Connect(function()
		btnData[2]()
		game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {
			BackgroundColor3 = COLOR_PALETTE.ButtonActive
		}):Play()
		task.wait(0.1)
		game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
			BackgroundColor3 = COLOR_PALETTE.ButtonHover
		}):Play()
	end)
end

-- Заголовок
local title = Instance.new("TextLabel")
title.Text = "DOKCI_X HUB v2.0"
title.Size = UDim2.new(0.8, 0, 0.1, 0)
title.Position = UDim2.new(0.1, 0, 0.02, 0)
title.TextColor3 = COLOR_PALETTE.Accent
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextStrokeTransparency = 0.7
title.Parent = mainFrame

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Text = "×"
closeButton.Size = UDim2.new(0.07, 0, 0.07, 0)
closeButton.Position = UDim2.new(0.93, 0, 0.02, 0)
closeButton.BackgroundColor3 = COLOR_PALETTE.Error
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 24
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
	local tween = TweenService:Create(
		mainFrame,
		tweenInfo,
		{Size = UDim2.new(0.01, 0, 0.01, 0)}
	)

	tween.Completed:Connect(function()
		mainFrame.Visible = false
	end)
	tween:Play()
end)

-- Горячая клавиша
UIS.InputBegan:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == Enum.KeyCode.F4 then
		mainFrame.Visible = not mainFrame.Visible

		if mainFrame.Visible then
			mainFrame.Size = UDim2.new(0.01, 0, 0.01, 0)
			local tween = TweenService:Create(
				mainFrame,
				tweenInfo,
				{Size = UDim2.new(0.3, 0, 0.6, 0)}
			)
			tween:Play()
		end
	end
end)

-- Анти-анализ
if getgenv then
	getgenv().DokciXHub = {
		Version = "2.0",
		Author = "DOKCI_X",
		Protected = true
	}
end

-- Адаптация под мобильные устройства
if UIS.TouchEnabled then
	mainFrame.Size = UDim2.new(0.8, 0, 0.7, 0)

	local openButton = Instance.new("TextButton")
	openButton.Text = "☰"
	openButton.Size = UDim2.new(0.12, 0, 0.08, 0)
	openButton.Position = UDim2.new(0.01, 0, 0.01, 0)
	openButton.BackgroundColor3 = COLOR_PALETTE.Accent
	openButton.TextColor3 = Color3.new(1, 1, 1)
	openButton.Font = Enum.Font.GothamBold
	openButton.TextSize = 24
	openButton.Parent = gui

	local openCorner = Instance.new("UICorner")
	openCorner.CornerRadius = UDim.new(0, 8)
	openCorner.Parent = openButton

	openButton.MouseButton1Click:Connect(function()
		mainFrame.Visible = not mainFrame.Visible
		if mainFrame.Visible then
			mainFrame.Size = UDim2.new(0.01, 0, 0.01, 0)
			local tween = TweenService:Create(
				mainFrame,
				tweenInfo,
				{Size = UDim2.new(0.8, 0, 0.7, 0)}
			)
			tween:Play()
		end
	end)
	
	-- Увеличение кнопки закрытия для мобильных
	closeButton.Size = UDim2.new(0.12, 0, 0.08, 0)
	closeButton.Position = UDim2.new(0.87, 0, 0.02, 0)
end

-- Авто-обновление положения при изменении размера экрана
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	if mainFrame.Visible then
		mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	end
end)
