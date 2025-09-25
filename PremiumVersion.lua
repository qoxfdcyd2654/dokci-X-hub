local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local ScriptContext = game:GetService("ScriptContext")

-- Защита от повторной загрузки
if _G.DOKCIX_HUB_LOADED then
    return
end
_G.DOKCIX_HUB_LOADED = true

print("🔥 DokciX Hub Ultimate v12.0 запущен для " .. player.Name)
print("🎮 Специальные функции для Murder Mystery 2 активированы!")

-- Глобальные состояния функций
local Functions = {
    AntiAFK = false,
    NightVision = false,
    SpeedHack = false,
    SpeedValue = 32,
    HighJump = false,
    JumpValue = 75,
    NoClip = false,
    FullBright = false,
    StealthMode = true,
    ESP = false,
    Flight = false,
    FlightSpeed = 50,
    GodMode = false,
    InfiniteYield = false,
    -- MM2 функции
    MM2_ESP = false,
    MM2_RoleESP = false,
    MM2_WeaponESP = false,
    MM2_AutoAvoidMurderer = false,
    MM2_AutoCollectGuns = false,
    -- Новые функции
    AutoFarm = false,
    NoFog = false,
    FPSBoost = false,
    PlayerTeleport = false,
    ViewPlayer = false,
    XRay = false,
    ConsoleEnabled = false
}

-- Таблица для хранения деактиваторов
local ActiveFunctions = {}
local OriginalCollisions = {}
local ESPConnections = {}
local ESPBillboards = {}
local MM2Connections = {}
local Teleporting = false

-- Система консоли
local Console = {
    Messages = {},
    MaxMessages = 50,
    Types = {
        ERROR = Color3.new(1, 0.3, 0.3),
        WARNING = Color3.new(1, 0.8, 0.3),
        INFO = Color3.new(0.4, 0.8, 1),
        SUCCESS = Color3.new(0.3, 1, 0.3)
    }
}

-- Функция добавления сообщения в консоль
function Console:AddMessage(message, messageType)
    table.insert(self.Messages, {
        Text = "[" .. os.date("%H:%M:%S") .. "] " .. message,
        Type = messageType or "INFO",
        Color = self.Types[messageType] or self.Types.INFO
    })
    
    if #self.Messages > self.MaxMessages then
        table.remove(self.Messages, 1)
    end
    
    if self.Frame and self.Frame.Visible then
        self:UpdateDisplay()
    end
end

-- Перехват стандартного print
local originalPrint = print
print = function(...)
    local args = {...}
    local message = table.concat(args, " ")
    Console:AddMessage(message, "INFO")
    originalPrint(...)
end

-- Перехват ошибок
ScriptContext.Error:Connect(function(message, stackTrace, script)
    Console:AddMessage("ОШИБКА: " .. message, "ERROR")
end)

-- Перехват предупреждений
local originalWarn = warn
warn = function(...)
    local args = {...}
    local message = table.concat(args, " ")
    Console:AddMessage("ПРЕДУПРЕЖДЕНИЕ: " .. message, "WARNING")
    originalWarn(...)
end

-- Оптимизация памяти
local function CleanupMemory()
    local counter = 0
    for _, v in pairs(ESPBillboards) do
        if not v or not v.Parent then
            ESPBillboards[_] = nil
            counter = counter + 1
        end
    end
    if counter > 0 then
        print("🗑️ Очищено " .. counter .. " неиспользуемых объектов ESP")
    end
end

-- РЕАЛИЗАЦИИ ОСНОВНЫХ ФУНКЦИЙ
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
        Console:AddMessage("Anti-AFK включен", "SUCCESS")
    elseif ActiveFunctions.AntiAFK then
        pcall(ActiveFunctions.AntiAFK)
        ActiveFunctions.AntiAFK = nil
        Console:AddMessage("Anti-AFK выключен", "INFO")
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
        local originalOutdoorAmbient = Lighting.OutdoorAmbient
        
        pcall(function()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.OutdoorAmbient = Color3.new(0.7, 0.7, 0.7)
        end)
        
        ActiveFunctions.NightVision = function()
            pcall(function()
                Lighting.Brightness = originalBrightness
                Lighting.ClockTime = originalClockTime
                Lighting.FogEnd = originalFogEnd
                Lighting.OutdoorAmbient = originalOutdoorAmbient
            end)
        end
        Console:AddMessage("Ночное зрение включено", "SUCCESS")
    elseif ActiveFunctions.NightVision then
        pcall(ActiveFunctions.NightVision)
        ActiveFunctions.NightVision = nil
        Console:AddMessage("Ночное зрение выключено", "INFO")
    end
    return Functions.NightVision
end

local function ToggleSpeedHack(enable, value)
    if enable == nil then enable = not Functions.SpeedHack end
    if value then Functions.SpeedValue = value end
    if Functions.SpeedHack == enable then return end
    Functions.SpeedHack = enable
    
    local function applySpeed(val)
        pcall(function()
            if player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = val
                end
            end
        end)
    end
    
    if enable then
        applySpeed(Functions.SpeedValue)
        local connection
        connection = player.CharacterAdded:Connect(function(character)
            task.wait(1)
            applySpeed(Functions.SpeedValue)
        end)
        
        ActiveFunctions.SpeedHack = function()
            if connection then
                connection:Disconnect()
            end
            applySpeed(16)
        end
        Console:AddMessage("Скорость x" .. (Functions.SpeedValue/16) .. " включена", "SUCCESS")
    elseif ActiveFunctions.SpeedHack then
        pcall(ActiveFunctions.SpeedHack)
        ActiveFunctions.SpeedHack = nil
        Console:AddMessage("Скорость выключена", "INFO")
    end
    return Functions.SpeedHack
end

local function ToggleHighJump(enable, value)
    if enable == nil then enable = not Functions.HighJump end
    if value then Functions.JumpValue = value end
    if Functions.HighJump == enable then return end
    Functions.HighJump = enable
    
    local function applyJump(val)
        pcall(function()
            if player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = val
                end
            end
        end)
    end
    
    if enable then
        applyJump(Functions.JumpValue)
        local connection
        connection = player.CharacterAdded:Connect(function(character)
            task.wait(1)
            applyJump(Functions.JumpValue)
        end)
        
        ActiveFunctions.HighJump = function()
            if connection then
                connection:Disconnect()
            end
            applyJump(50)
        end
        Console:AddMessage("Высокий прыжок включен", "SUCCESS")
    elseif ActiveFunctions.HighJump then
        pcall(ActiveFunctions.HighJump)
        ActiveFunctions.HighJump = nil
        Console:AddMessage("Высокий прыжок выключен", "INFO")
    end
    return Functions.HighJump
end

local function ToggleNoClip(enable)
    if Functions.NoClip == enable then return end
    Functions.NoClip = enable
    
    if enable then
        pcall(function()
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        OriginalCollisions[part] = part.CanCollide
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        local connection
        connection = player.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            pcall(function()
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        OriginalCollisions[part] = part.CanCollide
                        part.CanCollide = false
                    end
                end
            end)
        end)
        
        local noclipLoop
        noclipLoop = RunService.Stepped:Connect(function()
            if not Functions.NoClip or not player.Character then
                noclipLoop:Disconnect()
                return
            end
            
            pcall(function()
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        end)
        
        ActiveFunctions.NoClip = function()
            if connection then
                connection:Disconnect()
            end
            if noclipLoop then
                noclipLoop:Disconnect()
            end
            
            pcall(function()
                for part, canCollide in pairs(OriginalCollisions) do
                    if part and part.Parent then
                        part.CanCollide = canCollide
                    end
                end
                table.clear(OriginalCollisions)
            end)
        end
        Console:AddMessage("NoClip включен", "SUCCESS")
    elseif ActiveFunctions.NoClip then
        pcall(ActiveFunctions.NoClip)
        ActiveFunctions.NoClip = nil
        Console:AddMessage("NoClip выключен", "INFO")
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
        local originalGlobalShadows = Lighting.GlobalShadows
        
        pcall(function()
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
            Lighting.ColorShift_Top = Color3.new(1, 1, 1)
            Lighting.GlobalShadows = false
        end)
        
        ActiveFunctions.FullBright = function()
            pcall(function()
                Lighting.Ambient = originalAmbient
                Lighting.ColorShift_Bottom = originalColorShiftBottom
                Lighting.ColorShift_Top = originalColorShiftTop
                Lighting.GlobalShadows = originalGlobalShadows
            end)
        end
        Console:AddMessage("FullBright включен", "SUCCESS")
    elseif ActiveFunctions.FullBright then
        pcall(ActiveFunctions.FullBright)
        ActiveFunctions.FullBright = nil
        Console:AddMessage("FullBright выключен", "INFO")
    end
    return Functions.FullBright
end

local function ToggleNoFog(enable)
    if Functions.NoFog == enable then return end
    Functions.NoFog = enable
    
    if enable then
        local originalFogStart = Lighting.FogStart
        local originalFogEnd = Lighting.FogEnd
        
        pcall(function()
            Lighting.FogStart = 100000
            Lighting.FogEnd = 100000
        end)
        
        ActiveFunctions.NoFog = function()
            pcall(function()
                Lighting.FogStart = originalFogStart
                Lighting.FogEnd = originalFogEnd
            end)
        end
        Console:AddMessage("Туман удален", "SUCCESS")
    elseif ActiveFunctions.NoFog then
        pcall(ActiveFunctions.NoFog)
        ActiveFunctions.NoFog = nil
        Console:AddMessage("Туман восстановлен", "INFO")
    end
    return Functions.NoFog
end

local function ToggleStealthMode(enable)
    if Functions.StealthMode == enable then return end
    Functions.StealthMode = enable
    
    if enable then
        Console:AddMessage("Stealth Mode включен", "SUCCESS")
    else
        Console:AddMessage("Stealth Mode выключен", "INFO")
    end
    return Functions.StealthMode
end

local function ToggleESP(enable)
    if Functions.ESP == enable then return end
    Functions.ESP = enable

    if enable then
        local function createESP(targetPlayer)
            if targetPlayer == player then return end
            
            local function createBillboard(char)
                if not char or not Functions.ESP then return end
                
                local rootPart = char:WaitForChild("HumanoidRootPart", 2)
                if not rootPart then return end
                
                if ESPBillboards[targetPlayer] then
                    ESPBillboards[targetPlayer]:Destroy()
                end
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = targetPlayer.Name .. "_ESP"
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.MaxDistance = 1000
                billboard.Adornee = rootPart
                billboard.Parent = CoreGui
                billboard.Enabled = true
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = targetPlayer.Name
                textLabel.TextColor3 = Color3.new(1, 0, 0)
                textLabel.TextStrokeTransparency = 0
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextSize = 14
                textLabel.Parent = billboard
                
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.OutlineColor = Color3.new(1, 0, 0)
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.FillTransparency = 0.8
                highlight.Parent = char
                
                ESPBillboards[targetPlayer] = billboard
            end
            
            if targetPlayer.Character then
                createBillboard(targetPlayer.Character)
            end
            
            ESPConnections[targetPlayer] = targetPlayer.CharacterAdded:Connect(createBillboard)
        end
        
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            createESP(targetPlayer)
        end
        
        ESPConnections.playerAdded = Players.PlayerAdded:Connect(createESP)
        ESPConnections.playerRemoving = Players.PlayerRemoving:Connect(function(plr)
            if ESPBillboards[plr] then
                ESPBillboards[plr]:Destroy()
                ESPBillboards[plr] = nil
            end
        end)
        
        ActiveFunctions.ESP = function()
            for _, conn in pairs(ESPConnections) do
                conn:Disconnect()
            end
            for _, billboard in pairs(ESPBillboards) do
                if billboard then
                    billboard:Destroy()
                end
            end
            table.clear(ESPConnections)
            table.clear(ESPBillboards)
        end
        
        Console:AddMessage("ESP включен", "SUCCESS")
    elseif ActiveFunctions.ESP then
        pcall(ActiveFunctions.ESP)
        ActiveFunctions.ESP = nil
        Console:AddMessage("ESP выключен", "INFO")
    end
    return Functions.ESP
end

local function ToggleFlight(enable, speed)
    if enable == nil then enable = not Functions.Flight end
    if speed then Functions.FlightSpeed = speed end
    if Functions.Flight == enable then return end
    Functions.Flight = enable
    
    if enable then
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local rootPart = character:WaitForChild("HumanoidRootPart")
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 1000
        bodyGyro.D = 100
        bodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.Parent = rootPart
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
        bodyVelocity.Parent = rootPart
        
        local flying = true
        local speed = Functions.FlightSpeed
        
        local flightConnection
        flightConnection = RunService.Heartbeat:Connect(function()
            if not flying or not bodyGyro or not bodyVelocity or not rootPart then
                if flightConnection then flightConnection:Disconnect() end
                return
            end
            
            local camera = workspace.CurrentCamera
            local moveDirection = Vector3.new()
            
            if UIS:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * speed
            end
            
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, speed, 0)
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, speed/2, 0)
            end
            
            bodyVelocity.Velocity = moveDirection
            bodyGyro.CFrame = camera.CFrame
        end)
        
        ActiveFunctions.Flight = function()
            flying = false
            if flightConnection then
                flightConnection:Disconnect()
            end
            if bodyGyro then
                bodyGyro:Destroy()
            end
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
        end
        
        Console:AddMessage("Полёт включен (WASD + Space/Shift), скорость: " .. speed, "SUCCESS")
    elseif ActiveFunctions.Flight then
        pcall(ActiveFunctions.Flight)
        ActiveFunctions.Flight = nil
        Console:AddMessage("Полёт выключен", "INFO")
    end
    return Functions.Flight
end

local function ToggleGodMode(enable)
    if Functions.GodMode == enable then return end
    Functions.GodMode = enable
    
    if enable then
        local function makeImmortal(character)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.BreakJointsOnDeath = false
                
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanTouch = false
                        part.CanQuery = false
                    end
                end
            end
        end
        
        if player.Character then
            makeImmortal(player.Character)
        end
        
        local connection
        connection = player.CharacterAdded:Connect(makeImmortal)
        
        local touchConnection
        touchConnection = player.Character.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("BasePart") then
                descendant.CanTouch = false
                descendant.CanQuery = false
            end
        end)
        
        ActiveFunctions.GodMode = function()
            if connection then
                connection:Disconnect()
            end
            if touchConnection then
                touchConnection:Disconnect()
            end
            
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanTouch = true
                        part.CanQuery = true
                    end
                end
            end
        end
        
        Console:AddMessage("Бессмертие включено (клиентское)", "SUCCESS")
    elseif ActiveFunctions.GodMode then
        pcall(ActiveFunctions.GodMode)
        ActiveFunctions.GodMode = nil
        Console:AddMessage("Бессмертие выключено", "INFO")
    end
    return Functions.GodMode
end

local function ToggleInfiniteYield(enable)
    if Functions.InfiniteYield == enable then return end
    Functions.InfiniteYield = enable
    
    if enable then
        local success, err = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source', true))()
        end)
        
        if success then
            Console:AddMessage("Infinite Yield успешно загружен", "SUCCESS")
            ActiveFunctions.InfiniteYield = function()
                Console:AddMessage("Infinite Yield нельзя выключить, перезайдите в игру", "WARNING")
            end
        else
            Console:AddMessage("Ошибка загрузки Infinite Yield: " .. err, "ERROR")
            Functions.InfiniteYield = false
        end
    elseif ActiveFunctions.InfiniteYield then
        pcall(ActiveFunctions.InfiniteYield)
        ActiveFunctions.InfiniteYield = nil
        Console:AddMessage("Infinite Yield выключен (требуется перезагрузка)", "INFO")
    end
    return Functions.InfiniteYield
end

local function ToggleXRay(enable)
    if Functions.XRay == enable then return end
    Functions.XRay = enable
    
    if enable then
        local originalTransparency = {}
        
        pcall(function()
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency < 0.5 and part.Name ~= "HumanoidRootPart" then
                    originalTransparency[part] = part.Transparency
                    part.Transparency = 0.5
                end
            end
        end)
        
        ActiveFunctions.XRay = function()
            pcall(function()
                for part, transparency in pairs(originalTransparency) do
                    if part and part.Parent then
                        part.Transparency = transparency
                    end
                end
                table.clear(originalTransparency)
            end)
        end
        Console:AddMessage("X-Ray включен", "SUCCESS")
    elseif ActiveFunctions.XRay then
        pcall(ActiveFunctions.XRay)
        ActiveFunctions.XRay = nil
        Console:AddMessage("X-Ray выключен", "INFO")
    end
    return Functions.XRay
end

local function ToggleFPSBoost(enable)
    if Functions.FPSBoost == enable then return end
    Functions.FPSBoost = enable
    
    if enable then
        local originalGraphicsLevel = settings().Rendering.QualityLevel
        settings().Rendering.QualityLevel = 1
        
        for _, emitter in ipairs(workspace:GetDescendants()) do
            if emitter:IsA("ParticleEmitter") then
                emitter.Enabled = false
            end
        end
        
        ActiveFunctions.FPSBoost = function()
            settings().Rendering.QualityLevel = originalGraphicsLevel
            
            for _, emitter in ipairs(workspace:GetDescendants()) do
                if emitter:IsA("ParticleEmitter") then
                    emitter.Enabled = true
                end
            end
        end
        Console:AddMessage("FPS Boost включен", "SUCCESS")
    elseif ActiveFunctions.FPSBoost then
        pcall(ActiveFunctions.FPSBoost)
        ActiveFunctions.FPSBoost = nil
        Console:AddMessage("FPS Boost выключен", "INFO")
    end
    return Functions.FPSBoost
end

-- MURDER MYSTERY 2 ФУНКЦИИ
local function GetMM2Role(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return "Innocent" end
    
    local character = targetPlayer.Character
    local backpack = targetPlayer:FindFirstChildOfClass("Backpack")
    
    if character:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
        return "Murderer"
    end
    
    if character:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    
    return "Innocent"
end

local function ToggleMM2_ESP(enable)
    if Functions.MM2_ESP == enable then return end
    Functions.MM2_ESP = enable

    if enable then
        local function createMM2ESP(targetPlayer)
            if targetPlayer == player then return end
            
            local function createBillboard(char)
                if not char or not Functions.MM2_ESP then return end
                
                local rootPart = char:WaitForChild("HumanoidRootPart", 2)
                if not rootPart then return end
                
                local role = GetMM2Role(targetPlayer)
                local color = Color3.new(0, 1, 0)
                
                if role == "Murderer" then
                    color = Color3.new(1, 0, 0)
                elseif role == "Sheriff" then
                    color = Color3.new(0, 0, 1)
                end
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = targetPlayer.Name .. "_MM2_ESP"
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.MaxDistance = 1000
                billboard.Adornee = rootPart
                billboard.Parent = CoreGui
                billboard.Enabled = true
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = targetPlayer.Name .. " (" .. role .. ")"
                textLabel.TextColor3 = color
                textLabel.TextStrokeTransparency = 0
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextSize = 14
                textLabel.Parent = billboard
                
                local highlight = Instance.new("Highlight")
                highlight.Name = "MM2_Highlight"
                highlight.OutlineColor = color
                highlight.FillColor = color
                highlight.FillTransparency = 0.8
                highlight.Parent = char
                
                ESPBillboards[targetPlayer] = {Billboard = billboard, Highlight = highlight}
            end
            
            if targetPlayer.Character then
                createBillboard(targetPlayer.Character)
            end
            
            MM2Connections[targetPlayer] = targetPlayer.CharacterAdded:Connect(createBillboard)
        end
        
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            createMM2ESP(targetPlayer)
        end
        
        MM2Connections.playerAdded = Players.PlayerAdded:Connect(createMM2ESP)
        MM2Connections.playerRemoving = Players.PlayerRemoving:Connect(function(plr)
            if ESPBillboards[plr] then
                if ESPBillboards[plr].Billboard then
                    ESPBillboards[plr].Billboard:Destroy()
                end
                if ESPBillboards[plr].Highlight then
                    ESPBillboards[plr].Highlight:Destroy()
                end
                ESPBillboards[plr] = nil
            end
        end)
        
        MM2Connections.roleUpdater = RunService.Heartbeat:Connect(function()
            if not Functions.MM2_ESP then return end
            
            for targetPlayer, espData in pairs(ESPBillboards) do
                if targetPlayer and targetPlayer.Parent and espData.Billboard and espData.Billboard.Parent then
                    local role = GetMM2Role(targetPlayer)
                    local color = Color3.new(0, 1, 0)
                    
                    if role == "Murderer" then
                        color = Color3.new(1, 0, 0)
                    elseif role == "Sheriff" then
                        color = Color3.new(0, 0, 1)
                    end
                    
                    if espData.Billboard:FindFirstChild("TextLabel") then
                        espData.Billboard.TextLabel.Text = targetPlayer.Name .. " (" .. role .. ")"
                        espData.Billboard.TextLabel.TextColor3 = color
                    end
                    
                    if espData.Highlight then
                        espData.Highlight.OutlineColor = color
                        espData.Highlight.FillColor = color
                    end
                end
            end
        end)
        
        ActiveFunctions.MM2_ESP = function()
            for _, conn in pairs(MM2Connections) do
                conn:Disconnect()
            end
            for _, espData in pairs(ESPBillboards) do
                if espData.Billboard then
                    espData.Billboard:Destroy()
                end
                if espData.Highlight then
                    espData.Highlight:Destroy()
                end
            end
            table.clear(MM2Connections)
            table.clear(ESPBillboards)
        end
        
        Console:AddMessage("MM2 ESP включен (с определением ролей)", "SUCCESS")
    elseif ActiveFunctions.MM2_ESP then
        pcall(ActiveFunctions.MM2_ESP)
        ActiveFunctions.MM2_ESP = nil
        Console:AddMessage("MM2 ESP выключен", "INFO")
    end
    return Functions.MM2_ESP
end

local function ToggleMM2_WeaponESP(enable)
    if Functions.MM2_WeaponESP == enable then return end
    Functions.MM2_WeaponESP = enable
    
    if enable then
        local weaponParts = {}
        
        local function createWeaponESP(weapon)
            if not weapon or not Functions.MM2_WeaponESP then return end
            
            local handle = weapon:FindFirstChild("Handle") or weapon:FindFirstChildOfClass("Part")
            if not handle then return end
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = weapon.Name .. "_ESP"
            billboard.Size = UDim2.new(0, 150, 0, 40)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true
            billboard.MaxDistance = 500
            billboard.Adornee = handle
            billboard.Parent = CoreGui
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = weapon.Name
            textLabel.TextColor3 = Color3.new(1, 1, 0)
            textLabel.TextStrokeTransparency = 0
            textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            textLabel.Font = Enum.Font.GothamBold
            textLabel.TextSize = 12
            textLabel.Parent = billboard
            
            local highlight = Instance.new("Highlight")
            highlight.Name = "Weapon_Highlight"
            highlight.OutlineColor = Color3.new(1, 1, 0)
            highlight.FillColor = Color3.new(1, 1, 0)
            highlight.FillTransparency = 0.9
            highlight.Parent = weapon
            
            weaponParts[weapon] = {Billboard = billboard, Highlight = highlight}
        end
        
        for _, item in ipairs(workspace:GetDescendants()) do
            if (item.Name == "Knife" or item.Name == "Gun") and item:IsA("Model") then
                createWeaponESP(item)
            end
        end
        
        MM2Connections.weaponAdded = workspace.DescendantAdded:Connect(function(descendant)
            if (descendant.Name == "Knife" or descendant.Name == "Gun") and descendant:IsA("Model") then
                createWeaponESP(descendant)
            end
        end)
        
        MM2Connections.weaponRemoved = workspace.DescendantRemoving:Connect(function(descendant)
            if weaponParts[descendant] then
                if weaponParts[descendant].Billboard then
                    weaponParts[descendant].Billboard:Destroy()
                end
                if weaponParts[descendant].Highlight then
                    weaponParts[descendant].Highlight:Destroy()
                end
                weaponParts[descendant] = nil
            end
        end)
        
        ActiveFunctions.MM2_WeaponESP = function()
            if MM2Connections.weaponAdded then
                MM2Connections.weaponAdded:Disconnect()
            end
            if MM2Connections.weaponRemoved then
                MM2Connections.weaponRemoved:Disconnect()
            end
            for _, weaponData in pairs(weaponParts) do
                if weaponData.Billboard then
                    weaponData.Billboard:Destroy()
                end
                if weaponData.Highlight then
                    weaponData.Highlight:Destroy()
                end
            end
            table.clear(weaponParts)
        end
        
        Console:AddMessage("MM2 Weapon ESP включен", "SUCCESS")
    elseif ActiveFunctions.MM2_WeaponESP then
        pcall(ActiveFunctions.MM2_WeaponESP)
        ActiveFunctions.MM2_WeaponESP = nil
        Console:AddMessage("MM2 Weapon ESP выключен", "INFO")
    end
    return Functions.MM2_WeaponESP
end

local function ToggleMM2_AutoAvoidMurderer(enable)
    if Functions.MM2_AutoAvoidMurderer == enable then return end
    Functions.MM2_AutoAvoidMurderer = enable
    
    if enable then
        local avoidConnection
        avoidConnection = RunService.Heartbeat:Connect(function()
            if not Functions.MM2_AutoAvoidMurderer or not player.Character then
                return
            end
            
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            local murderer = nil
            local minDistance = 30
            
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character then
                    local role = GetMM2Role(otherPlayer)
                    if role == "Murderer" then
                        local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if otherRoot then
                            local distance = (humanoidRootPart.Position - otherRoot.Position).Magnitude
                            if distance < minDistance then
                                minDistance = distance
                                murderer = otherPlayer
                            end
                        end
                    end
                end
            end
            
            if murderer and murderer.Character then
                local murdererRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
                if murdererRoot then
                    local direction = (humanoidRootPart.Position - murdererRoot.Position).Unit
                    humanoidRootPart.Velocity = direction * 50
                    
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = 30
                    end
                end
            end
        end)
        
        ActiveFunctions.MM2_AutoAvoidMurderer = function()
            if avoidConnection then
                avoidConnection:Disconnect()
            end
            if player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                end
            end
        end
        
        Console:AddMessage("MM2 Auto Avoid Murderer включен", "SUCCESS")
    elseif ActiveFunctions.MM2_AutoAvoidMurderer then
        pcall(ActiveFunctions.MM2_AutoAvoidMurderer)
        ActiveFunctions.MM2_AutoAvoidMurderer = nil
        Console:AddMessage("MM2 Auto Avoid Murderer выключен", "INFO")
    end
    return Functions.MM2_AutoAvoidMurderer
end

local function ToggleMM2_AutoCollectGuns(enable)
    if Functions.MM2_AutoCollectGuns == enable then return end
    Functions.MM2_AutoCollectGuns = enable
    
    if enable then
        local collectConnection
        collectConnection = RunService.Heartbeat:Connect(function()
            if not Functions.MM2_AutoCollectGuns or not player.Character then
                return
            end
            
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            for _, item in ipairs(workspace:GetDescendants()) do
                if item.Name == "Gun" and item:IsA("Model") then
                    local handle = item:FindFirstChild("Handle") or item:FindFirstChildOfClass("Part")
                    if handle then
                        local distance = (humanoidRootPart.Position - handle.Position).Magnitude
                        
                        if distance < 20 then
                            humanoidRootPart.CFrame = CFrame.new(handle.Position)
                            break
                        end
                    end
                end
            end
        end)
        
        ActiveFunctions.MM2_AutoCollectGuns = function()
            if collectConnection then
                collectConnection:Disconnect()
            end
        end
        
        Console:AddMessage("MM2 Auto Collect Guns включен", "SUCCESS")
    elseif ActiveFunctions.MM2_AutoCollectGuns then
        pcall(ActiveFunctions.MM2_AutoCollectGuns)
        ActiveFunctions.MM2_AutoCollectGuns = nil
        Console:AddMessage("MM2 Auto Collect Guns выключен", "INFO")
    end
    return Functions.MM2_AutoCollectGuns
end

-- Функции телепортации
local function TeleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or Teleporting then
        return false
    end
    
    Teleporting = true
    local targetChar = targetPlayer.Character
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot then
        Teleporting = false
        return false
    end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        Teleporting = false
        return false
    end
    
    local wasNoClip = Functions.NoClip
    if not wasNoClip then
        ToggleNoClip(true)
    end
    
    player.Character:SetPrimaryPartCFrame(CFrame.new(targetRoot.Position + Vector3.new(0, 3, 0)))
    
    if not wasNoClip then
        task.wait(0.5)
        ToggleNoClip(false)
    end
    
    Teleporting = false
    Console:AddMessage("Телепорт к " .. targetPlayer.Name, "SUCCESS")
    return true
end

local function ViewPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        return false
    end
    
    local targetChar = targetPlayer.Character
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    
    if not humanoid then
        return false
    end
    
    workspace.CurrentCamera.CameraSubject = humanoid
    Console:AddMessage("Наблюдение за " .. targetPlayer.Name, "INFO")
    return true
end

local function ResetCamera()
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            workspace.CurrentCamera.CameraSubject = humanoid
            Console:AddMessage("Камера сброшена", "INFO")
        end
    end
end

-- СОЗДАНИЕ ИНТЕРФЕЙСА
local gui = Instance.new("ScreenGui")
gui.Name = "DXH_"..tostring(math.random(10000,99999))
if CoreGui:WaitForChild("RobloxGui") then
    gui.Parent = CoreGui.RobloxGui
else
    gui.Parent = CoreGui
end
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

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

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

local banner = Instance.new("ImageLabel")
banner.Name = "PremiumBanner"
banner.Parent = mainFrame
banner.Size = UDim2.new(1, -20, 0.2, 0)
banner.Position = UDim2.new(0, 10, 0, 10)
banner.BackgroundTransparency = 1
banner.Image = "rbxassetid://14813419671"
banner.ScaleType = Enum.ScaleType.Crop
banner.ZIndex = 2

local title = Instance.new("TextLabel")
title.Text = "DOKCIX HUB ULTIMATE v12.0 | " .. player.Name
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0.2, 5)
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- Иконка консоли
local consoleIcon = Instance.new("TextButton")
consoleIcon.Name = "ConsoleIcon"
consoleIcon.Text = "📟"
consoleIcon.Size = UDim2.new(0, 40, 0, 40)
consoleIcon.Position = UDim2.new(0.02, 0, 0.02, 0)
consoleIcon.Font = Enum.Font.GothamBold
consoleIcon.TextSize = 20
consoleIcon.TextColor3 = Color3.new(1, 1, 1)
consoleIcon.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
consoleIcon.BackgroundTransparency = 0.3
consoleIcon.Parent = mainFrame
consoleIcon.ZIndex = 3

local consoleIconCorner = Instance.new("UICorner")
consoleIconCorner.CornerRadius = UDim.new(0, 8)
consoleIconCorner.Parent = consoleIcon

local consoleTooltip = Instance.new("TextLabel")
consoleTooltip.Text = "Консоль"
consoleTooltip.Size = UDim2.new(0, 60, 0, 20)
consoleTooltip.Position = UDim2.new(0, 45, 0, 10)
consoleTooltip.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
consoleTooltip.TextColor3 = Color3.new(1, 1, 1)
consoleTooltip.Font = Enum.Font.Gotham
consoleTooltip.TextSize = 12
consoleTooltip.Visible = false
consoleTooltip.Parent = consoleIcon
consoleTooltip.ZIndex = 4

local tooltipCorner = Instance.new("UICorner")
tooltipCorner.CornerRadius = UDim.new(0, 4)
tooltipCorner.Parent = consoleTooltip

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

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollFrame
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 10)

-- Окно консоли
Console.Frame = Instance.new("Frame")
Console.Frame.Name = "ConsoleFrame"
Console.Frame.Parent = gui
Console.Frame.Size = UDim2.new(0.4, 0, 0.5, 0)
Console.Frame.Position = UDim2.new(0.3, 0, 0.25, 0)
Console.Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Console.Frame.BackgroundTransparency = 0.05
Console.Frame.Visible = false
Console.Frame.Active = true
Console.Frame.Draggable = true

local consoleCorner = Instance.new("UICorner")
consoleCorner.CornerRadius = UDim.new(0, 12)
consoleCorner.Parent = Console.Frame

local consoleShadow = Instance.new("ImageLabel")
consoleShadow.Name = "ConsoleShadow"
consoleShadow.Image = "rbxassetid://5234388158"
consoleShadow.ImageColor3 = Color3.new(0, 0, 0)
consoleShadow.ImageTransparency = 0.8
consoleShadow.ScaleType = Enum.ScaleType.Slice
consoleShadow.SliceCenter = Rect.new(10, 10, 118, 118)
consoleShadow.Size = UDim2.new(1, 20, 1, 20)
consoleShadow.Position = UDim2.new(0, -10, 0, -10)
consoleShadow.BackgroundTransparency = 1
consoleShadow.Parent = Console.Frame
consoleShadow.ZIndex = -1

local consoleTitle = Instance.new("TextLabel")
consoleTitle.Text = "💻 CONSOLE - Системный монитор"
consoleTitle.Font = Enum.Font.GothamBold
consoleTitle.TextSize = 16
consoleTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
consoleTitle.Size = UDim2.new(1, -40, 0, 30)
consoleTitle.Position = UDim2.new(0, 10, 0, 5)
consoleTitle.BackgroundTransparency = 1
consoleTitle.TextXAlignment = Enum.TextXAlignment.Left
consoleTitle.Parent = Console.Frame

local consoleCloseButton = Instance.new("TextButton")
consoleCloseButton.Text = "✕"
consoleCloseButton.Size = UDim2.new(0, 30, 0, 30)
consoleCloseButton.Position = UDim2.new(1, -35, 0, 5)
consoleCloseButton.Font = Enum.Font.GothamBold
consoleCloseButton.TextSize = 18
consoleCloseButton.TextColor3 = Color3.new(1, 1, 1)
consoleCloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
consoleCloseButton.Parent = Console.Frame
consoleCloseButton.ZIndex = 3

local consoleCloseCorner = Instance.new("UICorner")
consoleCloseCorner.CornerRadius = UDim.new(1, 0)
consoleCloseCorner.Parent = consoleCloseButton

local consoleScrollFrame = Instance.new("ScrollingFrame")
consoleScrollFrame.Name = "ConsoleScroll"
consoleScrollFrame.Parent = Console.Frame
consoleScrollFrame.Size = UDim2.new(0.95, 0, 0.8, 0)
consoleScrollFrame.Position = UDim2.new(0.025, 0, 0.1, 0)
consoleScrollFrame.BackgroundTransparency = 1
consoleScrollFrame.ScrollBarThickness = 6
consoleScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
consoleScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
consoleScrollFrame.ZIndex = 2

local consoleListLayout = Instance.new("UIListLayout")
consoleListLayout.Parent = consoleScrollFrame
consoleListLayout.SortOrder = Enum.SortOrder.LayoutOrder
consoleListLayout.Padding = UDim.new(0, 5)

local clearConsoleButton = Instance.new("TextButton")
clearConsoleButton.Text = "🧹 Очистить"
clearConsoleButton.Size = UDim2.new(0, 100, 0, 25)
clearConsoleButton.Position = UDim2.new(0.5, -50, 0.92, 0)
clearConsoleButton.Font = Enum.Font.GothamBold
clearConsoleButton.TextSize = 12
clearConsoleButton.TextColor3 = Color3.new(1, 1, 1)
clearConsoleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
clearConsoleButton.Parent = Console.Frame
clearConsoleButton.ZIndex = 3

local clearConsoleCorner = Instance.new("UICorner")
clearConsoleCorner.CornerRadius = UDim.new(0, 6)
clearConsoleCorner.Parent = clearConsoleButton

function Console:UpdateDisplay()
    for _, child in ipairs(consoleScrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    for _, messageData in ipairs(self.Messages) do
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Text = messageData.Text
        messageLabel.TextColor3 = messageData.Color
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextSize = 12
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.TextWrapped = true
        messageLabel.BackgroundTransparency = 1
        messageLabel.Size = UDim2.new(1, 0, 0, 0)
        messageLabel.AutomaticSize = Enum.AutomaticSize.Y
        messageLabel.Parent = consoleScrollFrame
    end
    
    task.wait()
    consoleScrollFrame.CanvasPosition = Vector2.new(0, consoleScrollFrame.AbsoluteCanvasSize.Y)
end

local function ToggleConsole(enable)
    if enable == nil then enable = not Console.Frame.Visible end
    Functions.ConsoleEnabled = enable
    
    if enable then
        Console.Frame.Visible = true
        Console:UpdateDisplay()
        consoleIcon.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        Console:AddMessage("Консоль активирована", "SUCCESS")
    else
        Console.Frame.Visible = false
        consoleIcon.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
end

consoleIcon.MouseButton1Click:Connect(function()
    ToggleConsole()
end)

consoleIcon.MouseEnter:Connect(function()
    consoleTooltip.Visible = true
end)

consoleIcon.MouseLeave:Connect(function()
    consoleTooltip.Visible = false
end)

consoleCloseButton.MouseButton1Click:Connect(function()
    ToggleConsole(false)
end)

clearConsoleButton.MouseButton1Click:Connect(function()
    Console.Messages = {}
    Console:UpdateDisplay()
    Console:AddMessage("Консоль очищена", "INFO")
end)

consoleListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    consoleScrollFrame.CanvasSize = UDim2.new(0, 0, 0, consoleListLayout.AbsoluteContentSize.Y + 10)
end)

-- Функция переключения меню
local function toggleMenu()
    mainFrame.Visible = not mainFrame.Visible
    
    if mainFrame.Visible then
        mainFrame.Size = UDim2.new(0.01, 0, 0.01, 0)
        mainFrame.Visible = true
        
        local tween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.35, 0, 0.7, 0)}
        )
        tween:Play()
    else
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

-- Обработчик F4
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
    
    local stateIndicator = Instance.new("Frame")
    stateIndicator.Size = UDim2.new(0.08, 0, 0.5, 0)
    stateIndicator.Position = UDim2.new(0.9, 0, 0.25, 0)
    stateIndicator.BackgroundColor3 = Functions[name] and Color3.new(0, 1, 0) or Color3.fromRGB(80, 80, 80)
    stateIndicator.BorderSizePixel = 0
    stateIndicator.Parent = buttonFrame
    
    local stateCorner = Instance.new("UICorner")
    stateCorner.CornerRadius = UDim.new(1, 0)
    stateCorner.Parent = stateIndicator
    
    local button = Instance.new("TextButton")
    button.Text = ""
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Parent = buttonFrame
    button.ZIndex = 3
    
    button.MouseButton1Click:Connect(function()
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
        elseif name == "ESP" then
            ToggleESP(newState)
        elseif name == "Flight" then
            ToggleFlight(newState)
        elseif name == "GodMode" then
            ToggleGodMode(newState)
        elseif name == "InfiniteYield" then
            ToggleInfiniteYield(newState)
        elseif name == "NoFog" then
            ToggleNoFog(newState)
        elseif name == "FPSBoost" then
            ToggleFPSBoost(newState)
        elseif name == "XRay" then
            ToggleXRay(newState)
        elseif name == "MM2_ESP" then
            ToggleMM2_ESP(newState)
        elseif name == "MM2_WeaponESP" then
            ToggleMM2_WeaponESP(newState)
        elseif name == "MM2_AutoAvoidMurderer" then
            ToggleMM2_AutoAvoidMurderer(newState)
        elseif name == "MM2_AutoCollectGuns" then
            ToggleMM2_AutoCollectGuns(newState)
        end
        
        stateIndicator.BackgroundColor3 = newState and Color3.new(0, 1, 0) or Color3.fromRGB(80, 80, 80)
    end)
    
    return buttonFrame
end

local function createTeleportButton(targetPlayer, layoutOrder)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    buttonFrame.BackgroundTransparency = 0.3
    buttonFrame.BorderSizePixel = 0
    buttonFrame.LayoutOrder = layoutOrder
    buttonFrame.ZIndex = 2
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = buttonFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Text = "📌 " .. targetPlayer.Name
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 14
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Size = UDim2.new(0.7, 0, 1, 0)
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.BackgroundTransparency = 1
    textLabel.Parent = buttonFrame
    
    local teleportButton = Instance.new("TextButton")
    teleportButton.Text = "Телепорт"
    teleportButton.Size = UDim2.new(0.25, 0, 0.7, 0)
    teleportButton.Position = UDim2.new(0.72, 0, 0.15, 0)
    teleportButton.Font = Enum.Font.GothamBold
    teleportButton.TextSize = 12
    teleportButton.TextColor3 = Color3.new(1, 1, 1)
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    teleportButton.Parent = buttonFrame
    teleportButton.ZIndex = 3
    
    local viewButton = Instance.new("TextButton")
    viewButton.Text = "Смотреть"
    viewButton.Size = UDim2.new(0.25, 0, 0.7, 0)
    viewButton.Position = UDim2.new(0.48, 0, 0.15, 0)
    viewButton.Font = Enum.Font.GothamBold
    viewButton.TextSize = 12
    viewButton.TextColor3 = Color3.new(1, 1, 1)
    viewButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
    viewButton.Parent = buttonFrame
    viewButton.ZIndex = 3
    
    local teleportCorner = Instance.new("UICorner")
    teleportCorner.CornerRadius = UDim.new(0, 6)
    teleportCorner.Parent = teleportButton
    
    local viewCorner = Instance.new("UICorner")
    viewCorner.CornerRadius = UDim.new(0, 6)
    viewCorner.Parent = viewButton
    
    teleportButton.MouseButton1Click:Connect(function()
        TeleportToPlayer(targetPlayer)
    end)
    
    viewButton.MouseButton1Click:Connect(function()
        ViewPlayer(targetPlayer)
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
            {name = "StealthMode", desc = "Скрывает следы читов", risk = 1},
            {name = "InfiniteYield", desc = "Популярная чит-админка Infinite Yield", risk = 2}
        }
    },
    {
        section = "ПЕРЕДВИЖЕНИЕ",
        items = {
            {name = "SpeedHack", desc = "Увеличивает скорость передвижения", risk = 2},
            {name = "HighJump", desc = "Прыгайте в 3 раза выше", risk = 2},
            {name = "NoClip", desc = "Прохождение сквозь стены", risk = 3},
            {name = "Flight", desc = "Полёт в любом направлении", risk = 3}
        }
    },
    {
        section = "ВИЗУАЛ",
        items = {
            {name = "FullBright", desc = "Убирает темноту полностью", risk = 1},
            {name = "NoFog", desc = "Убирает туман", risk = 1},
            {name = "ESP", desc = "Отображение игроков через стены", risk = 2},
            {name = "XRay", desc = "Видеть сквозь стены", risk = 2},
            {name = "FPSBoost", desc = "Увеличивает FPS", risk = 1}
        }
    },
    {
        section = "ЭКСПЕРИМЕНТАЛЬНЫЕ",
        items = {
            {name = "GodMode", desc = "Клиентское бессмертие", risk = 3}
        }
    },
    {
        section = "MURDER MYSTERY 2",
        items = {
            {name = "MM2_ESP", desc = "ESP с определением ролей (Murderer/Sheriff)", risk = 2},
            {name = "MM2_WeaponESP", desc = "Подсветка оружия на карте", risk = 2},
            {name = "MM2_AutoAvoidMurderer", desc = "Авто-убегание от мурдера", risk = 2},
            {name = "MM2_AutoCollectGuns", desc = "Авто-сбор оружия", risk = 2}
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

-- Добавляем секцию телепортации
local teleportSection = createSection("ТЕЛЕПОРТАЦИЯ", layoutOrder)
teleportSection.Parent = scrollFrame
layoutOrder += 1

for _, targetPlayer in ipairs(Players:GetPlayers()) do
    if targetPlayer ~= player then
        local button = createTeleportButton(targetPlayer, layoutOrder)
        button.Parent = scrollFrame
        layoutOrder += 1
    end
end

local resetCameraButton = Instance.new("TextButton")
resetCameraButton.Text = "Сбросить камеру"
resetCameraButton.Size = UDim2.new(1, 0, 0, 40)
resetCameraButton.Position = UDim2.new(0, 0, 0, 0)
resetCameraButton.Font = Enum.Font.GothamBold
resetCameraButton.TextSize = 14
resetCameraButton.TextColor3 = Color3.new(1, 1, 1)
resetCameraButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
resetCameraButton.LayoutOrder = layoutOrder
resetCameraButton.Parent = scrollFrame
resetCameraButton.ZIndex = 3

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 8)
resetCorner.Parent = resetCameraButton

resetCameraButton.MouseButton1Click:Connect(ResetCamera)

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
                child.Visible = string.find(string.lower(child.TextLabel.Text), searchText) ~= nil
            else
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

-- Экстренное отключение (F8)
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F8 then
        Console:AddMessage("!!! ЭКСТРЕННОЕ ОТКЛЮЧЕНИЕ АКТИВИРОВАНО !!!", "ERROR")
        
        ToggleAntiAFK(false)
        ToggleNightVision(false)
        ToggleSpeedHack(false)
        ToggleHighJump(false)
        ToggleNoClip(false)
        ToggleFullBright(false)
        ToggleStealthMode(false)
        ToggleESP(false)
        ToggleFlight(false)
        ToggleGodMode(false)
        ToggleNoFog(false)
        ToggleFPSBoost(false)
        ToggleXRay(false)
        ToggleMM2_ESP(false)
        ToggleMM2_WeaponESP(false)
        ToggleMM2_AutoAvoidMurderer(false)
        ToggleMM2_AutoCollectGuns(false)
        
        ResetCamera()
        ToggleConsole(false)
        gui:Destroy()
        _G.DOKCIX_HUB_LOADED = false
        
        Console:AddMessage("Все функции отключены, выполняется очистка...", "WARNING")
    end
end)

-- Автоматическая активация при изменении персонажа
player.CharacterAdded:Connect(function(character)
    task.wait(1)
    
    if Functions.SpeedHack then ToggleSpeedHack(true) end
    if Functions.HighJump then ToggleHighJump(true) end
    if Functions.NoClip then ToggleNoClip(true) end
    if Functions.GodMode then ToggleGodMode(true) end
    if Functions.ESP then ToggleESP(true) end
    if Functions.StealthMode then ToggleStealthMode(true) end
    if Functions.MM2_ESP then ToggleMM2_ESP(true) end
    if Functions.MM2_WeaponESP then ToggleMM2_WeaponESP(true) end
    if Functions.MM2_AutoAvoidMurderer then ToggleMM2_AutoAvoidMurderer(true) end
    if Functions.MM2_AutoCollectGuns then ToggleMM2_AutoCollectGuns(true) end
end)

-- Авто-обновление размера
RunService.Heartbeat:Connect(function()
    pcall(function()
        if mainFrame.Visible then
            local mousePos = UIS:GetMouseLocation()
            local distance = (Vector2.new(mainFrame.AbsolutePosition.X, mainFrame.AbsolutePosition.Y) - mousePos).Magnitude
            
            mainFrame.BackgroundTransparency = distance < 150 and 0.05 or 0.15
        end
        
        updateStatusLight()
        
        if math.random(1, 100) == 1 then
            CleanupMemory()
        end
    end)
end)

-- Инициализация Stealth Mode
ToggleStealthMode(true)

-- Начальные сообщения в консоль
Console:AddMessage("DokciX Hub Ultimate v12.0 инициализирован", "SUCCESS")
Console:AddMessage("Игрок: " .. player.Name, "INFO")
Console:AddMessage("Stealth Mode активирован", "SUCCESS")
Console:AddMessage("Нажмите F4 для открытия меню", "INFO")

print("✅ Меню DokciX Hub Ultimate v12.0 успешно загружено!")
print("🔑 Нажмите F4 для открытия меню")
print("📟 Консоль мониторинга активирована")
print("⚡ Все функции готовы к использованию")
print("🔪 Улучшенные функции ММ2 активированы 🔪")
print("🚀 Добавлены новые функции: X-Ray, FPS Boost, Auto Collect Guns")
