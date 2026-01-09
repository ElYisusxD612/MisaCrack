-- Misa Premium Local Tools • 2026 Edition
-- Safe • Client-Side Only • Updated: Enero 2026
-- Features: Fly, Noclip, Infinite Jump, ESP (Rainbow), Click TP, Freecam, Watermark, Stats HUD, Fullbright, Anti-Idle, etc.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Misa Premium • 2026",
    LoadingTitle = "Cargando Premium Tools...",
    LoadingSubtitle = "by Misa <3 • Safe Edition",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MisaPremium2026",
        FileName = "Settings"
    },
    KeySystem = false
})

-- Servicios
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace      = game:GetService("Workspace")
local Lighting       = game:GetService("Lighting")
local Stats          = game:GetService("Stats")
local VirtualUser    = game:GetService("VirtualUser")

local LocalPlayer    = Players.LocalPlayer
local Camera         = Workspace.CurrentCamera
local Mouse          = LocalPlayer:GetMouse()

-- Estado global
local Settings = {
    -- Visual / UI
    Theme           = "Dark",           -- Dark / Light / Neon
    Watermark       = true,
    StatsHUD        = true,
    
    -- Movimiento
    WalkSpeed       = 32,
    JumpPower       = 60,
    FlySpeed        = 140,
    InfiniteJump    = false,
    FlyEnabled      = false,
    Noclip          = false,
    ClickTeleport   = false,
    Freecam         = false,
    
    -- Visuales
    FOV             = 70,
    Fullbright      = false,
    
    -- ESP
    ESP_Enabled     = false,
    ESP_TeamCheck   = true,
    ESP_Boxes       = true,
    ESP_Tracers     = true,
    ESP_Rainbow     = false,
    
    -- Extras
    AntiIdle        = true,
}

local Connections = {}
local Drawings    = {}
local ESP_Drawings = {}

-- Watermark flotante
local function CreateWatermark()
    if not Settings.Watermark then return end
    Drawings.Watermark = Drawing.new("Text")
    Drawings.Watermark.Text = "Misa Premium • 2026 • v2.1"
    Drawings.Watermark.Size = 14
    Drawings.Watermark.Color = Color3.fromRGB(180, 140, 255)
    Drawings.Watermark.Outline = true
    Drawings.Watermark.Position = Vector2.new(8, 8)
    Drawings.Watermark.Visible = true
end

-- HUD Stats (FPS, Ping, Pos)
local function UpdateStatsHUD()
    if not Settings.StatsHUD or not Drawings.Stats then return end
    
    local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.016))
    local ping = math.floor(Stats:FindFirstChild("PerformanceStats") 
        and Stats.PerformanceStats.Ping:GetValue() 
        or Stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 999)
    
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local pos = root and string.format("%.1f, %.1f, %.1f", root.Position.X, root.Position.Y, root.Position.Z) or "—"
    
    Drawings.Stats.Text = string.format("FPS: %d   Ping: %dms   XYZ: %s", fps, ping, pos)
end

local function CreateStatsHUD()
    if not Settings.StatsHUD then return end
    Drawings.Stats = Drawing.new("Text")
    Drawings.Stats.Size = 15
    Drawings.Stats.Outline = true
    Drawings.Stats.Position = Vector2.new(8, 28)
    Drawings.Stats.Color = Color3.new(1,1,1)
    Drawings.Stats.Visible = true
    
    table.insert(Connections, RunService.RenderStepped:Connect(UpdateStatsHUD))
end

-- Helpers básicos
local function GetCharacter() return LocalPlayer.Character end
local function GetHumanoid()  return GetCharacter() and GetCharacter():FindFirstChildWhichIsA("Humanoid") end
local function GetRootPart()  return GetCharacter() and GetCharacter():FindFirstChild("HumanoidRootPart") end

local function ApplyMovement()
    local hum = GetHumanoid()
    if hum then
        hum.WalkSpeed = Settings.WalkSpeed
        hum.JumpPower = Settings.JumpPower
    end
end

-- Fly (CFrame)
local flyConnection
local function ToggleFly(state)
    Settings.FlyEnabled = state
    local root = GetRootPart()
    local hum = GetHumanoid()
    if not root or not hum then return end

    if state then
        hum.PlatformStand = true
        flyConnection = RunService.Heartbeat:Connect(function(dt)
            if not Settings.FlyEnabled then return end
            local dir = Vector3.new()
            local cf = Camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W)     then dir = dir + cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S)     then dir = dir - cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A)     then dir = dir - cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D)     then dir = dir + cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            
            if dir.Magnitude > 0 then
                root.CFrame = root.CFrame + (dir.Unit * Settings.FlySpeed * dt)
            end
        end)
        table.insert(Connections, flyConnection)
    else
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        hum.PlatformStand = false
    end
end

-- Noclip
local noclipConnection
local function ToggleNoclip(state)
    Settings.Noclip = state
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = GetCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
        table.insert(Connections, noclipConnection)
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    end
end

-- Infinite Jump
table.insert(Connections, UserInputService.JumpRequest:Connect(function()
    if not Settings.InfiniteJump then return end
    local hum = GetHumanoid()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

-- Click Teleport (Mouse Right Click)
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Settings.ClickTeleport and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local unitRay = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {GetCharacter()}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 3000, raycastParams)
        if result and GetRootPart() then
            GetRootPart().CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        end
    end
end))

-- Freecam básico
local freecamConn, originalCamType, originalCFrame
local function ToggleFreecam(state)
    Settings.Freecam = state
    if state then
        originalCamType = Camera.CameraType
        originalCFrame = Camera.CFrame
        Camera.CameraType = Enum.CameraType.Scriptable
        
        freecamConn = RunService.RenderStepped:Connect(function(dt)
            local move = Vector3.new()
            local cf = Camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end
            
            if move.Magnitude > 0 then
                Camera.CFrame += move.Unit * 80 * dt
            end
        end)
        table.insert(Connections, freecamConn)
    else
        if freecamConn then freecamConn:Disconnect() freecamConn = nil end
        Camera.CameraType = originalCamType or Enum.CameraType.Custom
        if originalCFrame then Camera.CFrame = originalCFrame end
    end
end

-- ESP simple (boxes + tracers + rainbow)
local function GetESPColor()
    if Settings.ESP_Rainbow then
        return Color3.fromHSV((tick() * 0.6) % 1, 0.9, 1)
    end
    return Color3.fromRGB(255, 90, 30)
end

local function CreateESP(player)
    if player == LocalPlayer or not player.Character then return end
    
    local drawings = {
        Box    = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name   = Drawing.new("Text")
    }
    
    drawings.Box.Thickness = 1.5
    drawings.Box.Filled = false
    drawings.Box.Transparency = 1
    
    drawings.Tracer.Thickness = 1
    drawings.Tracer.Transparency = 0.85
    
    drawings.Name.Text = player.Name
    drawings.Name.Size = 13
    drawings.Name.Outline = true
    drawings.Name.Center = true
    
    ESP_Drawings[player] = drawings
end

local function UpdateESP()
    for player, d in pairs(ESP_Drawings) do
        local visible = false
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        
        if root and head and hum and hum.Health > 0 and (not Settings.ESP_TeamCheck or player.Team ~= LocalPlayer.Team) then
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                visible = true
                local color = GetESPColor()
                
                local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.6,0))
                local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                local height = math.abs(top.Y - bottom.Y)
                local width = height * 0.5
                
                -- Box
                if Settings.ESP_Boxes then
                    d.Box.Size = Vector2.new(width, height)
                    d.Box.Position = Vector2.new(pos.X - width/2, top.Y)
                    d.Box.Color = color
                    d.Box.Visible = true
                else
                    d.Box.Visible = false
                end
                
                -- Tracer
                if Settings.ESP_Tracers then
                    d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    d.Tracer.To = Vector2.new(pos.X, pos.Y)
                    d.Tracer.Color = color
                    d.Tracer.Visible = true
                else
                    d.Tracer.Visible = false
                end
                
                -- Name
                d.Name.Position = Vector2.new(pos.X, top.Y - 16)
                d.Name.Visible = true
            end
        end
        
        if not visible then
            d.Box.Visible    = false
            d.Tracer.Visible = false
            d.Name.Visible   = false
        end
    end
end

local function ToggleESP(state)
    Settings.ESP_Enabled = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do
            CreateESP(p)
        end
        table.insert(Connections, RunService.RenderStepped:Connect(UpdateESP))
        
        Players.PlayerAdded:Connect(CreateESP)
        Players.PlayerRemoving:Connect(function(p)
            if ESP_Drawings[p] then
                for _, obj in pairs(ESP_Drawings[p]) do obj:Remove() end
                ESP_Drawings[p] = nil
            end
        end)
    else
        for p, drawings in pairs(ESP_Drawings) do
            for _, obj in pairs(drawings) do obj:Remove() end
        end
        ESP_Drawings = {}
    end
end

-- Anti Idle
if Settings.AntiIdle then
    table.insert(Connections, LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end))
end

-- Fullbright
local function ToggleFullbright(state)
    Settings.Fullbright = state
    if state then
        Lighting.Brightness = 1.5
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 99999
        Lighting.Ambient = Color3.fromRGB(180,180,180)
    else
        -- Reset básico (valores por defecto aproximados)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.fromRGB(0,0,0)
    end
end

-- Tabs
local TabMain = Window:CreateTab("Principal", 4483362458)
local TabMove = Window:CreateTab("Movimiento", 4483362458)
local TabVisual = Window:CreateTab("Visuales", 4483362458)
local TabESP = Window:CreateTab("ESP", 4483362458)
local TabExtras = Window:CreateTab("Extras", 4483362458)

-- Controles
TabMain:CreateLabel("Bienvenido • Misa Premium 2026")
TabMain:CreateToggle({Name = "Watermark", CurrentValue = Settings.Watermark, Callback = function(v)
    Settings.Watermark = v
    if v and not Drawings.Watermark then CreateWatermark() end
    if not v and Drawings.Watermark then Drawings.Watermark:Remove() Drawings.Watermark = nil end
end})

TabMain:CreateToggle({Name = "Stats HUD (FPS/Ping)", CurrentValue = Settings.StatsHUD, Callback = function(v)
    Settings.StatsHUD = v
    if v and not Drawings.Stats then CreateStatsHUD() end
    if not v and Drawings.Stats then Drawings.Stats:Remove() Drawings.Stats = nil end
end})

TabMove:CreateSlider({Name = "Walk Speed", Range = {10, 500}, Increment = 1, CurrentValue = Settings.WalkSpeed, Callback = function(v)
    Settings.WalkSpeed = v ApplyMovement()
end})

TabMove:CreateSlider({Name = "Jump Power", Range = {30, 300}, Increment = 5, CurrentValue = Settings.JumpPower, Callback = function(v)
    Settings.JumpPower = v ApplyMovement()
end})

TabMove:CreateToggle({Name = "Infinite Jump", CurrentValue = Settings.InfiniteJump, Callback = function(v) Settings.InfiniteJump = v end})
TabMove:CreateToggle({Name = "Fly (CFrame)", CurrentValue = false, Callback = ToggleFly})
TabMove:CreateSlider({Name = "Fly Speed", Range = {50, 800}, Increment = 10, CurrentValue = Settings.FlySpeed, Callback = function(v) Settings.FlySpeed = v end})
TabMove:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = ToggleNoclip})
TabMove:CreateToggle({Name = "Click Teleport (RMB)", CurrentValue = false, Callback = function(v) Settings.ClickTeleport = v end})
TabMove:CreateToggle({Name = "Freecam", CurrentValue = false, Callback = ToggleFreecam})

TabVisual:CreateSlider({Name = "Field of View", Range = {40, 140}, Increment = 1, CurrentValue = Settings.FOV, Callback = function(v)
    Settings.FOV = v Camera.FieldOfView = v
end})

TabVisual:CreateToggle({Name = "Fullbright", CurrentValue = false, Callback = ToggleFullbright})

TabESP:CreateToggle({Name = "ESP Enabled", CurrentValue = false, Callback = ToggleESP})
TabESP:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) Settings.ESP_TeamCheck = v end})
TabESP:CreateToggle({Name = "Boxes", CurrentValue = true, Callback = function(v) Settings.ESP_Boxes = v end})
TabESP:CreateToggle({Name = "Tracers", CurrentValue = true, Callback = function(v) Settings.ESP_Tracers = v end})
TabESP:CreateToggle({Name = "Rainbow Mode", CurrentValue = false, Callback = function(v) Settings.ESP_Rainbow = v end})

TabExtras:CreateToggle({Name = "Anti Idle / Anti-Kick", CurrentValue = true, Callback = function(v) Settings.AntiIdle = v end})

TabExtras:CreateButton({Name = "Unload Script", Callback = function()
    for _, conn in ipairs(Connections) do pcall(function() conn:Disconnect() end) end
    for _, drawing in pairs(Drawings) do pcall(function() drawing:Remove() end) end
    for _, esp in pairs(ESP_Drawings) do for _, d in pairs(esp) do pcall(function() d:Remove() end) end end
    
    local hum = GetHumanoid()
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum.PlatformStand = false
    end
    Camera.FieldOfView = 70
    Camera.CameraType = Enum.CameraType.Custom
    
    Rayfield:Notify({Title = "Unload", Content = "Script limpiado correctamente", Duration = 5})
    Window:Destroy()
end})

-- Inicialización
CreateWatermark()
CreateStatsHUD()
ApplyMovement()
Camera.FieldOfView = Settings.FOV

-- Auto-apply al respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.4)
    ApplyMovement()
    Camera.FieldOfView = Settings.FOV
end)

Rayfield:Notify({
    Title = "Misa Premium • 2026",
    Content = "Cargado correctamente • RightShift para abrir/cerrar\nMuchas funciones premium activas",
    Duration = 6.5
})

-- Fin del script
