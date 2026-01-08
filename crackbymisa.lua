-- Crack By Misa <3 - ULTIMATE 2026 (con Fling NoCollision)
-- Compatible Delta v2.703+ | Mobile Optimized | Anti-Byfron ready

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Crack By Misa <3",
   LoadingTitle = "Cargando Crack By Misa <3",
   LoadingSubtitle = "by Misa - 2026 Ultimate",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "CrackByMisa",
      FileName = "MisaUltimateConfig"
   },
   Discord = {Enabled = false},
   KeySystem = false,
   Theme = "Dark"
})

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

-- Variables
local ESPEnabled = false
local ESPObjects = {}
local FlyEnabled = false
local FlySpeed = 50
local SpeedValue = 16
local JumpValue = 50
local SpyTarget = nil
local SpyEnabled = false
local AntiLagEnabled = false
local CopyIDEnabled = false
local PlayerList = {}

-- Update Player List
local function UpdatePlayerList()
   PlayerList = {}
   for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
         table.insert(PlayerList, player.Name)
      end
   end
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()

-- ESP Pro (Drawing API)
local ESPTab = Window:CreateTab("🎯 ESP Pro")

ESPTab:CreateToggle({
   Name = "ESP Activo",
   CurrentValue = false,
   Callback = function(Value)
      ESPEnabled = Value
      if Value then CreateESP() else ClearESP() end
   end,
})

ESPTab:CreateToggle({Name = "🔲 Boxes", CurrentValue = true})
ESPTab:CreateToggle({Name = "📏 Tracers", CurrentValue = true})
ESPTab:CreateToggle({Name = "📛 Nombres + Distancia", CurrentValue = true})

local ESPColor = ESPTab:CreateColorPicker({
   Name = "🌈 Color ESP",
   Color = Color3.fromRGB(255, 0, 0)
})

function ClearESP()
   for _, obj in pairs(ESPObjects) do
      if obj.Box then obj.Box:Remove() end
      if obj.Tracer then obj.Tracer:Remove() end
      if obj.NameTag then obj.NameTag:Remove() end
   end
   ESPObjects = {}
end

function CreateESP()
   ClearESP()
   
   local function AddESP(player)
      if player == LocalPlayer then return end
      local Box = Drawing.new("Square")
      local Tracer = Drawing.new("Line")
      local NameTag = Drawing.new("Text")
      
      Box.Thickness = 2; Box.Filled = false; Box.Transparency = 1
      Tracer.Thickness = 2; Tracer.Transparency = 1
      NameTag.Size = 16; NameTag.Center = true; NameTag.Outline = true; NameTag.Font = 2
      
      table.insert(ESPObjects, {Box=Box, Tracer=Tracer, NameTag=NameTag, Player=player})
   end
   
   for _, p in pairs(Players:GetPlayers()) do AddESP(p) end
   Players.PlayerAdded:Connect(AddESP)
   
   RunService.RenderStepped:Connect(function()
      if not ESPEnabled then return end
      local color = ESPColor.CurrentValue or Color3.fromRGB(255,0,0)
      
      for _, esp in pairs(ESPObjects) do
         local p = esp.Player
         if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local root = p.Character.HumanoidRootPart
            local head = p.Character:FindFirstChild("Head")
            if not head then continue end
            
            local top = root.Position + Vector3.new(0, (head.Size.Y + root.Size.Y)/2, 0)
            local bottom = root.Position - Vector3.new(0, (head.Size.Y + root.Size.Y)/2, 0)
            
            local topPos, onScreenTop = Camera:WorldToViewportPoint(top)
            local bottomPos, onScreenBottom = Camera:WorldToViewportPoint(bottom)
            local rootPos = Camera:WorldToViewportPoint(root.Position)
            
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
            
            if onScreenTop then
               -- Box
               if ESPTab:FindToggle("🔲 Boxes").CurrentValue then
                  esp.Box.Size = Vector2.new(1500 / topPos.Z, topPos.Y - bottomPos.Y)
                  esp.Box.Position = Vector2.new(bottomPos.X - esp.Box.Size.X/2, bottomPos.Y - esp.Box.Size.Y/2)
                  esp.Box.Color = color
                  esp.Box.Visible = true
               else esp.Box.Visible = false end
               
               -- Tracer
               if ESPTab:FindToggle("📏 Tracers").CurrentValue then
                  esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                  esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                  esp.Tracer.Color = color
                  esp.Tracer.Visible = true
               else esp.Tracer.Visible = false end
               
               -- Name
               if ESPTab:FindToggle("📛 Nombres + Distancia").CurrentValue then
                  esp.NameTag.Text = string.format("%s [%.0f studs]", p.Name, dist)
                  esp.NameTag.Position = Vector2.new(topPos.X, topPos.Y - 25)
                  esp.NameTag.Color = Color3.fromRGB(255,255,255)
                  esp.NameTag.Visible = true
               else esp.NameTag.Visible = false end
            else
               esp.Box.Visible = false
               esp.Tracer.Visible = false
               esp.NameTag.Visible = false
            end
         else
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            esp.NameTag.Visible = false
         end
      end
   end)
end

-- Teleport
local TeleTab = Window:CreateTab("🚀 Teleport")

local TeleDrop = TeleTab:CreateDropdown({
   Name = "👥 Seleccionar Jugador",
   Options = PlayerList,
   CurrentOption = {"Ninguno"}
})

TeleTab:CreateButton({
   Name = "✨ Teleport a Jugador",
   Callback = function()
      local tgt = Players:FindFirstChild(TeleDrop.CurrentOption[1])
      if tgt and tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
         LocalPlayer.Character.HumanoidRootPart.CFrame = tgt.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
         Rayfield:Notify({Title="Teleport", Content="Tele a "..tgt.Name, Duration=3})
      end
   end
})

-- Fling Tab (Clásico + NoCollision)
local FlingTab = Window:CreateTab("💥 Fling Pro")

local FlingDrop = FlingTab:CreateDropdown({
   Name = "🎯 Seleccionar Jugador",
   Options = PlayerList,
   CurrentOption = {"Ninguno"}
})

local FlingPower = FlingTab:CreateSlider({
   Name = "💪 Fuerza",
   Range = {100, 8000},
   Increment = 100,
   CurrentValue = 1500
})

-- Fling Clásico
FlingTab:CreateButton({
   Name = "🚀 Fling Clásico (necesita colisión)",
   Callback = function()
      local tgtName = FlingDrop.CurrentOption[1]
      if tgtName == "Ninguno" then return end
      local tgt = Players[tgtName]
      if tgt and tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") then
         local root = tgt.Character.HumanoidRootPart
         local pow = FlingPower.CurrentValue
         root.AssemblyLinearVelocity = Vector3.new(math.random(-pow,pow), pow*1.8, math.random(-pow,pow))
         root.AssemblyAngularVelocity = Vector3.new(math.random(-80,80),math.random(-80,80),math.random(-80,80))
         
         spawn(function()
            for i=1,18 do
               if root.Parent then
                  root.AssemblyLinearVelocity += Vector3.new(math.random(-300,300),600,math.random(-300,300))
               end
               task.wait(0.07)
            end
         end)
         Rayfield:Notify({Title="Fling Clásico", Content="Aplicado a "..tgtName, Duration=4})
      end
   end
})

-- Fling NoCollision (Direct Impulse - para intangibles)
FlingTab:CreateButton({
   Name = "🌌 Fling NoCollision (sin tocar)",
   Callback = function()
      local tgtName = FlingDrop.CurrentOption[1]
      if tgtName == "Ninguno" then return end
      local tgt = Players[tgtName]
      if tgt and tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") then
         local root = tgt.Character.HumanoidRootPart
         local pow = FlingPower.CurrentValue * 1.3  -- Más fuerte sin fricción
         
         root.AssemblyLinearVelocity = Vector3.new(math.random(-pow*0.8,pow*0.8), pow*2.2, math.random(-pow*0.8,pow*0.8))
         root.AssemblyAngularVelocity = Vector3.new(math.random(-120,120),math.random(-120,120),math.random(-120,120))
         
         spawn(function()
            for i=1,24 do
               if root.Parent then
                  root.AssemblyLinearVelocity += Vector3.new(math.random(-pow*0.4,pow*0.4), pow*0.9 + math.random(200,600), math.random(-pow*0.4,pow*0.4))
                  root.AssemblyAngularVelocity += Vector3.new(math.random(-40,40),math.random(-40,40),math.random(-40,40))
               end
               task.wait(0.075)
            end
         end)
         
         Rayfield:Notify({Title="NoCollision Fling", Content=tgtName.." al infinito 🌌", Duration=5})
      else
         Rayfield:Notify({Title="Error", Content="Jugador sin root", Duration=3})
      end
   end
})

-- Movimiento (Fly CFrame, Speed, Jump)
local MoveTab = Window:CreateTab("✈️ Movimiento")

MoveTab:CreateToggle({
   Name = "🛩️ Fly Pro (CFrame)",
   CurrentValue = false,
   Callback = function(Value)
      FlyEnabled = Value
      if Value then
         local conn
         conn = RunService.Heartbeat:Connect(function(dt)
            if not FlyEnabled or not LocalPlayer.Character then return end
            local root = LocalPlayer.Character.HumanoidRootPart
            local cam = Camera.CFrame
            local move = Vector3.new()
            local spd = FlySpeed * 50 * dt
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
            
            root.CFrame += move * spd
         end)
      end
   end
})

MoveTab:CreateSlider({Name = "⚡ Velocidad Fly", Range = {1,100}, CurrentValue = 5, Callback = function(v) FlySpeed = v end})

MoveTab:CreateSlider({Name = "🏃 Super Speed", Range = {16,500}, CurrentValue = 50, Callback = function(v)
   SpeedValue = v
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
      LocalPlayer.Character.Humanoid.WalkSpeed = v
   end
end})

MoveTab:CreateSlider({Name = "🦘 Super Jump", Range = {50,500}, CurrentValue = 100, Callback = function(v)
   JumpValue = v
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
      LocalPlayer.Character.Humanoid.JumpPower = v
   end
end})

-- Respawn fixes
LocalPlayer.CharacterAdded:Connect(function()
   wait(1)
   if LocalPlayer.Character:FindFirstChild("Humanoid") then
      LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
      LocalPlayer.Character.Humanoid.JumpPower = JumpValue
   end
end)

-- Spy Cam
local SpyTab = Window:CreateTab("👁️ Spy Cam")

local SpyDrop = SpyTab:CreateDropdown({Name = "🎬 Target Spy", Options = PlayerList, CurrentOption = {"Ninguno"}})

SpyTab:CreateButton({
   Name = "▶️ Activar Spy",
   Callback = function()
      local tgt = Players[SpyDrop.CurrentOption[1]]
      if tgt and tgt.Character then
         SpyEnabled = true
         SpyTarget = tgt
         Camera.CameraSubject = tgt.Character:FindFirstChild("Humanoid")
      end
   end
})

SpyTab:CreateButton({
   Name = "⏹️ Desactivar Spy",
   Callback = function()
      SpyEnabled = false
      SpyTarget = nil
      if LocalPlayer.Character then Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid") end
   end
})

RunService.RenderStepped:Connect(function()
   if SpyEnabled and SpyTarget and SpyTarget.Character then
      Camera.CFrame = CFrame.new(SpyTarget.Character.HumanoidRootPart.Position + Vector3.new(5,2,5), SpyTarget.Character.HumanoidRootPart.Position)
   end
end)

-- Extras
local ExtraTab = Window:CreateTab("⚙️ Extras")

ExtraTab:CreateToggle({Name = "📋 Auto Copy ID", CurrentValue = false, Callback = function(v) CopyIDEnabled = v end})

ExtraTab:CreateToggle({Name = "⚡ Anti Lag (Low GFX)", CurrentValue = false, Callback = function(v)
   if v then
      settings().Rendering.QualityLevel = Enum.SavedQualitySetting.Low
      Lighting.GlobalShadows = false
      for _, obj in pairs(Workspace:GetDescendants()) do
         if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic; obj.CastShadow = false end
      end
   else
      settings().Rendering.QualityLevel = Enum.SavedQualitySetting.Automatic
   end
end})

ExtraTab:CreateButton({Name = "❤️ God Mode", Callback = function()
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
      LocalPlayer.Character.Humanoid.MaxHealth = math.huge; LocalPlayer.Character.Humanoid.Health = math.huge
   end
end})

ExtraTab:CreateButton({Name = "👻 Noclip (10s)", Callback = function()
   local conn = RunService.Stepped:Connect(function()
      if LocalPlayer.Character then
         for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
         end
      end
   end)
   wait(10); conn:Disconnect()
end})

-- Auto copy ID
Players.PlayerAdded:Connect(function(p)
   if CopyIDEnabled then setclipboard(tostring(p.UserId)) end
end)

-- Auto refresh dropdowns
spawn(function()
   while wait(4) do
      UpdatePlayerList()
      TeleDrop:Refresh(PlayerList, true)
      FlingDrop:Refresh(PlayerList, true)
      SpyDrop:Refresh(PlayerList, true)
   end
end)

-- Toggle GUI con RightShift
UserInputService.InputBegan:Connect(function(input)
   if input.KeyCode == Enum.KeyCode.RightShift then
      Window.MainFrame.Visible = not Window.MainFrame.Visible
   end
end)

Rayfield:Notify({
   Title = "Crack By Misa <3",
   Content = "¡Ultimate cargado! Incluye Fling NoCollision 🌌\nRightShift para toggle GUI",
   Duration = 6
})

print("Crack By Misa <3 - 2026 Ultimate Loaded 🔥")
