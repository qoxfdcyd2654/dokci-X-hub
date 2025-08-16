local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Создаем GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "DokciXHub"
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0.3, 0, 0.6, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.Visible = false -- Сразу скрываем

-- Анимация появления
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint)

-- Автоматическое создание кнопок
local buttons = {
	{"Скорость x2", function()
		player.Character.Humanoid.WalkSpeed = 32
	end},

	{"Высокий прыжок", function()
		player.Character.Humanoid.JumpHeight = 50
	end},

	{"Ночное зрение", function()
		game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
	end},

	{"Невидимость (клиент)", function()
		for _, part in pairs(player.Character:GetChildren()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 0.8
			end
		end
	end},

	{"Полёт", function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
	end}
}

-- Создаем контейнер для кнопок
local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
scrollFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
scrollFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5

-- Рассчитываем высоту контейнера
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #buttons * 45)

for i, btnData in ipairs(buttons) do
	local button = Instance.new("TextButton", scrollFrame)
	button.Text = btnData[1]
	button.Size = UDim2.new(1, 0, 0, 40)
	button.Position = UDim2.new(0, 0, 0, (i-1)*45)
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14

	button.MouseButton1Click:Connect(btnData[2])
end

-- Кнопка закрытия
local closeButton = Instance.new("TextButton", mainFrame)
closeButton.Text = "X"
closeButton.Size = UDim2.new(0.07, 0, 0.07, 0)
closeButton.Position = UDim2.new(0.93, 0, 0.02, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.new(1, 1, 1)

-- Заголовок
local title = Instance.new("TextLabel", mainFrame)
title.Text = "DOKCI_X HUB v2.0"
title.Size = UDim2.new(0.8, 0, 0.1, 0)
title.Position = UDim2.new(0.1, 0, 0.02, 0)
title.TextColor3 = Color3.new(0, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 18

-- Обработчик горячих клавиш
UIS.InputBegan:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == Enum.KeyCode.F4 then
		mainFrame.Visible = not mainFrame.Visible

		-- Анимация
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

-- Функция закрытия
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

-- Первый запуск
task.wait(1)
mainFrame.Visible = true
mainFrame.Size = UDim2.new(0.01, 0, 0.01, 0)
local tween = TweenService:Create(
	mainFrame,
	tweenInfo,
	{Size = UDim2.new(0.3, 0, 0.6, 0)}
)
tween:Play()
