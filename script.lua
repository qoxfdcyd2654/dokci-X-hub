local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Защита от повторной инициализации
if player.PlayerGui:FindFirstChild("DokciXHub") then
	player.PlayerGui.DokciXHub:Destroy()
end

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
			if espBillboards[targetPlayer] then continue end

			local function createBillboard(char)
				if not char then return end

				-- Ожидаем появление HumanoidRootPart
				local rootPart = char:FindFirstChild("HumanoidRootPart")
				if not rootPart then
					rootPart = char:WaitForChild("HumanoidRootPart", 2)
					if not rootPart then return end
				end

				-- Создаем BillboardGui
				local billboard = Instance.new("BillboardGui")
				billboard.Name = targetPlayer.Name .. "_ESP"
				billboard.Size = UDim2.new(0, 200, 0, 50)
				billboard.StudsOffset = Vector3.new(0, 3, 0) -- Высота над головой
				billboard.AlwaysOnTop = true
				billboard.MaxDistance = 1000
				billboard.Adornee = rootPart
				billboard.Parent = player.PlayerGui.DokciXHub

				-- Текст с именем игрока
				local textLabel = Instance.new("TextLabel", billboard)
				textLabel.Size = UDim2.new(1, 0, 1, 0)
				textLabel.BackgroundTransparency = 1
				textLabel.Text = targetPlayer.Name
				textLabel.TextColor3 = Color3.new(1, 0, 0) -- Красный
				textLabel.TextStrokeTransparency = 0
				textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
				textLabel.Font = Enum.Font.GothamBold
				textLabel.TextSize = 14

				espBillboards[targetPlayer] = billboard
			end

			-- Обработка текущего персонажа
			if targetPlayer.Character then
				createBillboard(targetPlayer.Character)
			end

			-- Обработка смены персонажа
			espConnections[targetPlayer] = targetPlayer.CharacterAdded:Connect(createBillboard)
		end

		-- Обработка новых игроков
		espConnections.playerAdded = Players.PlayerAdded:Connect(function(newPlayer)
			espConnections[newPlayer] = newPlayer.CharacterAdded:Connect(function(char)
				if not espEnabled then return end

				local rootPart = char:FindFirstChild("HumanoidRootPart")
				if not rootPart then
					rootPart = char:WaitForChild("HumanoidRootPart", 2)
					if not rootPart then return end
				end

				local billboard = Instance.new("BillboardGui")
				billboard.Name = newPlayer.Name .. "_ESP"
				billboard.Size = UDim2.new(0, 250, 0, 90)
				billboard.StudsOffset = Vector3.new(0, 3, 0)
				billboard.AlwaysOnTop = true
				billboard.MaxDistance = 9999999999
				billboard.Adornee = rootPart
				billboard.Parent = player.PlayerGui.DokciXHub

				local textLabel = Instance.new("TextLabel", billboard)
				textLabel.Size = UDim2.new(1, 0, 1, 0)
				textLabel.BackgroundTransparency = 1
				textLabel.Text = newPlayer.Name
				textLabel.TextColor3 = Color3.new(0.364706, 1, 0.0941176)
				textLabel.TextStrokeTransparency = 0
				textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
				textLabel.Font = Enum.Font.GothamBold
				textLabel.TextSize = 14

				espBillboards[newPlayer] = billboard
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
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "DokciXHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0.9, 0, 0.9, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.2
mainFrame.Visible = false
mainFrame.Active = true

-- Добавление стилей
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 255)

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
			for _, part in ipairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = part.LocalTransparencyModifier == 0.8 and 0 or 0.8
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
local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
scrollFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
scrollFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #buttons * 45)

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.Padding = UDim.new(0, 5)

-- Создание кнопок
for i, btnData in ipairs(buttons) do
	local button = Instance.new("TextButton", scrollFrame)
	button.Text = btnData[1]
	button.Size = UDim2.new(1, 0, 0, 40)
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.AutoButtonColor = false

	local btnCorner = Instance.new("UICorner", button)
	btnCorner.CornerRadius = UDim.new(0, 6)

	button.MouseEnter:Connect(function()
		game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {
			BackgroundColor3 = Color3.fromRGB(80, 80, 100)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {
			BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		}):Play()
	end)

	button.MouseButton1Click:Connect(function()
		btnData[2]()
		game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {
			BackgroundColor3 = Color3.fromRGB(0, 150, 150)
		}):Play()
		task.wait(0.1)
		game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {
			BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		}):Play()
	end)
end

-- Заголовок
local title = Instance.new("TextLabel", mainFrame)
title.Text = "DOKCI_X HUB v2.0"
title.Size = UDim2.new(0.8, 0, 0.1, 0)
title.Position = UDim2.new(0.1, 0, 0.02, 0)
title.TextColor3 = Color3.new(0, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка закрытия
local closeButton = Instance.new("TextButton", mainFrame)
closeButton.Text = "X"
closeButton.Size = UDim2.new(0.07, 0, 0.07, 0)
closeButton.Position = UDim2.new(0.93, 0, 0.02, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.new(1, 1, 1)

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
		Author = "DOKCI_X"
	}
end

-- Адаптация под мобильные устройства
if UIS.TouchEnabled then
	mainFrame.Size = UDim2.new(0.8, 0, 0.7, 0)

	local openButton = Instance.new("TextButton", gui)
	openButton.Text = "Open Menu"
	openButton.Size = UDim2.new(0.2, 0, 0.08, 0)
	openButton.Position = UDim2.new(0.01, 0, 0.01, 0)
	openButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
	openButton.TextColor3 = Color3.new(1, 1, 1)

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
end
