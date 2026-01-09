-- Crack By Misa <3 | Safe Local Tools | Enero 2026
-- Infinite Jump + Fly + Noclip + HUD + FOV + ESP
-- 100% LOCAL | Limpio | Estable

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Crack By Misa <3 (Safe)",
    LoadingTitle = "Cargando...",
    LoadingSubtitle = "Local Tools - Misa",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MisaCrackSafe",
        FileName = "Config"
    },
    KeySystem = false
})

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- SETTINGS
local Settings = {
    Speed = 50,
    JumpPower = 100,
    FlyEnabled = false,
    FlySpeed = 120,
    InfiniteJump = false,
    Noclip = false,
    FOV = 70,
    ToggleKey = Enum.KeyCode.RightShift,
    EspEnabled = false,
    EspBoxes = true,
    EspLines = true,
    EspColor = Color3.fromRGB(255, 0, 0),
    EspShowId = true
}

local Connections = {}
local EspDrawings = {}

-- HELPERS
local function getChar()
    return LocalPlayer.Character
end

local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChildWhichIsA("Humanoid")
end

local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function applyStats()
    local h = getHumanoid()
    if h then
        h.WalkSpeed = Settings.Speed
        h.JumpPower = Settings.JumpPower
    end
end

local function createEsp(player)
    if player == LocalPlayer or not player.Character then return end
    
    local drawings = {
        Box = Drawing.new("Square"),
        Line = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Id = Drawing.new("Text")
    }
    
    drawings.Box.Thickness = 2
    drawings.Box.Transparency = 1
    drawings.Box.Color = Settings.EspColor
    drawings.Box.Filled = false
    
    drawings.Line.Thickness = 1
    drawings.Line.Transparency = 1
    drawings.Line.Color = Settings.EspColor
    
    drawings.Name.Size = 14
    drawings.Name.Outline = true
    drawings.Name.Color = Color3.new(1,1,1)
    drawings.Name.Text = player.Name
    
    drawings.Id.Size = 12
    drawings.Id.Outline = true
    drawings.Id.Color = Color3.new(0.8,0.8,0.8)
    drawings.Id.Text = "ID: " .. player.UserId
    
    EspDrawings[player] = drawings
end

local function updateEsp()
    for player, drawings in pairs(EspDrawings) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        
        if char and root and head and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                
                local height = (headPos.Y - legPos.Y) / 2
                local width = height / 2
                
                if Settings.EspBoxes then
                    drawings.Box.Visible = true
                    drawings.Box.Size = Vector2.new(width, height * 2)
                    drawings.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height)
                else
                    drawings.Box.Visible = false
                end
                
                if Settings.EspLines then
                    drawings.Line.Visible = true
                    drawings.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    drawings.Line.To = Vector2.new(pos.X, pos.Y)
                else
                    drawings.Line.Visible = false
                end
                
                drawings.Name.Visible = true
                drawings.Name.Position = Vector2.new(pos.X, pos.Y - height - 20)
                
                if Settings.EspShowId then
                    drawings.Id.Visible = true
                    drawings.Id.Position = Vector2.new(pos.X, pos.Y - height - 5)
                else
                    drawings.Id.Visible = false
                end
            else
                drawings.Box.Visible = false
                drawings.Line.Visible = false
                drawings.Name.Visible = false
                drawings.Id.Visible = false
            end
        else
            drawings.Box.Visible = false
            drawings.Line.Visible = false
            drawings.Name.Visible = false
            drawings.Id.Visible = false
        end
    end
end

local function removeEsp(player)
    local drawings = EspDrawings[player]
    if drawings then
        for _, d in pairs(drawings) do
            d:Remove()
        end
        EspDrawings[player] = nil
    end
end

-- TABS
local MoveTab = Window:CreateTab("✈️ Movimiento")
local VisualTab = Window:CreateTab("👁️ Visual")
local ExtraTab = Window:CreateTab("⚙️ Extras")
local EspTab = Window:CreateTab("🔍 ESP")

--------------------------------------------------
-- SPEED
MoveTab:CreateSlider({
    Name = "Speed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = Settings.Speed,
    Callback = function(v)
        Settings.Speed = v
        applyStats()
    end
})

-- JUMP POWER
MoveTab:CreateSlider({
    Name = "Jump Power",
    Range = {10, 300},
    Increment = 5,
    CurrentValue = Settings.JumpPower,
    Callback = function(v)
        Settings.JumpPower = v
        applyStats()
    end
})

--------------------------------------------------
-- INFINITE JUMP
MoveTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v)
        Settings.InfiniteJump = v
        Rayfield:Notify({
            Title = "Infinite Jump",
            Content = v and "Activado" or "Desactivado",
            Duration = 3
        })
    end
})

-- Infinite Jump Logic
UserInputService.JumpRequest:Connect(function()
    if not Settings.InfiniteJump then return end
    local h = getHumanoid()
    if h then
        h:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--------------------------------------------------
-- FLY (CFRAME)
local flyConn
MoveTab:CreateToggle({
    Name = "Fly (CFrame)",
    CurrentValue = false,
    Callback = function(v)
        Settings.FlyEnabled = v
        local root = getRoot()
        local hum = getHumanoid()
        if not root or not hum then return end

        if v then
            hum.PlatformStand = true
            flyConn = RunService.Heartbeat:Connect(function(dt)
                local cam = Camera
                local dir = Vector3.zero

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

                if dir.Magnitude > 0 then
                    root.CFrame += dir.Unit * Settings.FlySpeed * dt
                end
            end)
            table.insert(Connections, flyConn)
        else
            if flyConn then flyConn:Disconnect() end
            hum.PlatformStand = false
        end
    end
})

MoveTab:CreateSlider({
    Name = "Fly Speed",
    Range = {50, 1000},
    Increment = 10,
    CurrentValue = Settings.FlySpeed,
    Callback = function(v)
        Settings.FlySpeed = v
    end
})

--------------------------------------------------
-- NOCLIP
local noclipConn
ExtraTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        Settings.Noclip = v
        if v then
            noclipConn = RunService.Stepped:Connect(function()
                local c = getChar()
                if c then
                    for _,p in pairs(c:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                        end
                    end
                end
            end)
            table.insert(Connections, noclipConn)
        else
            if noclipConn then noclipConn:Disconnect() end
        end
    end
})

--------------------------------------------------
-- FOV
VisualTab:CreateSlider({
    Name = "Camera FOV",
    Range = {50, 120},
    Increment = 1,
    CurrentValue = Settings.FOV,
    Callback = function(v)
        Settings.FOV = v
        Camera.FieldOfView = v
    end
})

--------------------------------------------------
-- HUD
local hud, hudConn
VisualTab:CreateToggle({
    Name = "HUD Local",
    CurrentValue = false,
    Callback = function(v)
        if v then
            hud = Drawing.new("Text")
            hud.Size = 16
            hud.Outline = true
            hud.Position = Vector2.new(10,10)
            hud.Color = Color3.new(1,1,1)
            hudConn = RunService.RenderStepped:Connect(function()
                local r = getRoot()
                if r then
                    hud.Text = string.format(
                        "Pos: %.1f %.1f %.1f\nVel: %.1f",
                        r.Position.X, r.Position.Y, r.Position.Z,
                        r.Velocity.Magnitude
                    )
                end
            end)
            table.insert(Connections, hudConn)
        else
            if hud then hud:Remove() end
            if hudConn then hudConn:Disconnect() end
        end
    end
})

--------------------------------------------------
-- ESP TOGGLE
local espConn
EspTab:CreateToggle({
    Name = "ESP Enabled",
    CurrentValue = false,
    Callback = function(v)
        Settings.EspEnabled = v
        if v then
            for _, player in pairs(Players:GetPlayers()) do
                createEsp(player)
            end
            espConn = RunService.RenderStepped:Connect(updateEsp)
            table.insert(Connections, espConn)
            Players.PlayerAdded:Connect(createEsp)
            Players.PlayerRemoving:Connect(removeEsp)
        else
            if espConn then espConn:Disconnect() end
            for player in pairs(EspDrawings) do
                removeEsp(player)
            end
        end
        Rayfield:Notify({
            Title = "ESP",
            Content = v and "Activado" or "Desactivado",
            Duration = 3
        })
    end
})

-- ESP OPTIONS
EspTab:CreateToggle({
    Name = "Show Boxes",
    CurrentValue = true,
    Callback = function(v)
        Settings.EspBoxes = v
    end
})

EspTab:CreateToggle({
    Name = "Show Lines",
    CurrentValue = true,
    Callback = function(v)
        Settings.EspLines = v
    end
})

EspTab:CreateToggle({
    Name = "Show User ID",
    CurrentValue = true,
    Callback = function(v)
        Settings.EspShowId = v
    end
})

EspTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Settings.EspColor,
    Callback = function(v)
        Settings.EspColor = v
        for _, drawings in pairs(EspDrawings) do
            drawings.Box.Color = v
            drawings.Line.Color = v
        end
    end
})

--------------------------------------------------
-- AUTO APPLY ON RESPAWN
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyStats()
    Camera.FieldOfView = Settings.FOV
end)

--------------------------------------------------
-- TOGGLE GUI
UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Settings.ToggleKey and Window.MainFrame then
        Window.MainFrame.Visible = not Window.MainFrame.Visible
    end
end)

--------------------------------------------------
-- UNLOAD
ExtraTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        for _,c in pairs(Connections) do
            pcall(function() c:Disconnect() end)
        end
        Connections = {}
        if hud then hud:Remove() end
        for player in pairs(EspDrawings) do
            removeEsp(player)
        end
        local h = getHumanoid()
        if h then
            h.PlatformStand = false
            h.WalkSpeed = 16
            h.JumpPower = 50
        end
        Rayfield:Notify({
            Title = "Unload",
            Content = "Script descargado correctamente",
            Duration = 4
        })
    end
})

--------------------------------------------------
Rayfield:Notify({
    Title = "Crack By Misa <3",
    Content = "Infinite Jump activo | RightShift = Toggle GUI | ESP Agregado",
    Duration = 6
})
