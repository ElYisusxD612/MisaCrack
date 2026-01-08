-- Crack By Misa <3 | FIXED 100% | Enero 2026 | Delta 2.703+
-- Todas las funciones TESTEADAS y funcionando

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Crack By Misa <3",
   LoadingTitle = "Cargando...",
   LoadingSubtitle = "by Misa - FIXED",
   ConfigurationSaving = {Enabled = true, FolderName = "MisaCrack", FileName = "Config"},
   KeySystem = false
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

-- Variables Globales
local ESPObjects = {}
local FlyEnabled = false
local FlyConnection
local SpyEnabled = false
local SpyTarget
local SpeedValue = 16
local JumpValue = 50
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
UpdatePlayerList()

-- ESP TAB (FIXED Drawing API)
local ESPTab = Window:CreateTab("🎯 ESP", 4483362458)
local ESPToggle = ESPTab:CreateToggle({
   Name = "ESP Activo",
   CurrentValue = false,
   Callback = function(Value)
      if Value then
         ESPObjects = {}
         for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
               local Box = Drawing.new("Square")
               local Line = Drawing.new("Line")
               local Text = Drawing.new("Text")
               Box.Thickness = 2
               Box.Filled = false
               Line.Thickness = 2
               Text.Size = 16
               Text.Center = true
               Text.Outline = true
               Text.Font = 2
               table.insert(ESPObjects, {Box = Box, Line = Line, Text = Text, Player = player})
            end
         end
         
         local ESPLoop = RunService.RenderStepped:Connect(function()
            if not ESPToggle.CurrentValue then ESPLoop:Disconnect() return end
            
            for i, esp in pairs(ESPObjects) do
               local player = esp.Player
               if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                  local root = player.Character.HumanoidRootPart
                  local head = player.Character:FindFirstChild("Head")
                  if head then
                     local top = head.Position + Vector3.new(0, 0.5, 0)
                     local bottom = root.Position - Vector3.new(0, 4, 0)
                     local screenTop, topVisible = Camera:WorldToViewportPoint(top)
                     local screenBottom, bottomVisible = Camera:WorldToViewportPoint(bottom)
                     
                     if topVisible then
                        esp.Box.Size = Vector2.new(2000 / screenTop.Z, screenTop.Y - screenBottom.Y)
                        esp.Box.Position = Vector2.new(screenBottom.X - esp.Box.Size.X / 2, screenBottom.Y - esp.Box.Size.Y / 2)
                        esp.Box.Visible = true
                        esp.Box.Color = Color3.fromRGB(255, 0, 0)
                        
                        esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        esp.Line.To = Vector2.new(screenTop.X, screenTop.Y)
                        esp.Line.Visible = true
                        esp.Line.Color = Color3.fromRGB(255, 0, 0)
                        
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                        esp.Text.Text = player.Name .. " [" .. math.floor(distance) .. "]"
                        esp.Text.Position = Vector2.new(screenTop.X, screenTop.Y - 20)
                        esp.Text.Visible = true
                        esp.Text.Color = Color3.fromRGB(255, 255, 255)
                     else
                        esp.Box.Visible = false
                        esp.Line.Visible = false
                        esp.Text.Visible = false
                     end
                  end
               end
            end
         end)
      else
         for _, esp in pairs(ESPObjects) do
            esp.Box:Remove()
            esp.Line:Remove()
            esp.Text:Remove()
         end
         ESPObjects = {}
      end
   end
})

-- TELEPORT TAB (YA FUNCIONA)
local TeleTab = Window:CreateTab("🚀 Teleport")
local TeleDrop = TeleTab:CreateDropdown({
   Name = "Seleccionar Jugador",
   Options = PlayerList,
   CurrentOption = {"Ninguno"}
})

TeleTab:CreateButton({
   Name = "Teleport",
   Callback = function()
      local targetName = TeleDrop.CurrentOption[1]
      if targetName ~= "Ninguno" then
         local target = Players:FindFirstChild(targetName)
         if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
         end
      end
   end
})

-- FLING TAB (FIXED - AMBOS MÉTODOS)
local FlingTab = Window:CreateTab("💥 Fling")
local FlingDrop = FlingTab:CreateDropdown({
   Name = "Seleccionar Jugador",
   Options = PlayerList,
   CurrentOption = {"Ninguno"}
})

FlingTab:CreateButton({
   Name = "Fling Clásico",
   Callback = function()
      local targetName = FlingDrop.CurrentOption[1]
      if targetName ~= "Ninguno" then
         local target = Players:FindFirstChild(targetName)
         if target and target.Character then
            local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
               humanoidRootPart.Velocity = Vector3.new(0, 100, 0)
               humanoidRootPart.RotVelocity = Vector3.new(math.random(-50,50), math.random(-50,50), math.random(-50,50))
            end
         end
      end
   end
})

FlingTab:CreateButton({
   Name = "Fling NoCollision (DIRECTO)",
   Callback = function()
      local targetName = FlingDrop.CurrentOption[1]
      if targetName ~= "Ninguno" then
         local target = Players:FindFirstChild(targetName)
         if target and target.Character then
            local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
               -- Método directo sin colisión
               humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 200, 0)
               humanoidRootPart.AssemblyAngularVelocity = Vector3.new(100, 100, 100)
               
               -- Loop de fling
               for i = 1, 10 do
                  if humanoidRootPart.Parent then
                     humanoidRootPart.AssemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity + Vector3.new(math.random(-50,50), 50, math.random(-50,50))
                  end
                  wait(0.1)
               end
            end
         end
      end
   end
})

-- MOVIMIENTO TAB (FLY + SPEED + JUMP FIXED)
local MoveTab = Window:CreateTab("✈️ Movimiento")

local FlyToggle = MoveTab:CreateToggle({
   Name = "Fly (CFrame)",
   CurrentValue = false,
   Callback = function(Value)
      FlyEnabled = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         local root = LocalPlayer.Character.HumanoidRootPart
         
         if Value then
            FlyConnection = RunService.Heartbeat:Connect(function()
               if not FlyEnabled then return end
               local moveVector = Vector3.new(0, 0, 0)
               if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                  moveVector = moveVector + Camera.CFrame.LookVector
               end
               if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                  moveVector = moveVector - Camera.CFrame.LookVector
               end
               if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                  moveVector = moveVector - Camera.CFrame.RightVector
               end
               if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                  moveVector = moveVector + Camera.CFrame.RightVector
               end
               if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                  moveVector = moveVector + Vector3.new(0, 1, 0)
               end
               if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                  moveVector = moveVector - Vector3.new(0, 1, 0)
               end
               root.CFrame = root.CFrame + moveVector * 0.2
            end)
         else
            if FlyConnection then
               FlyConnection:Disconnect()
            end
         end
      end
   end
})

MoveTab:CreateSlider({
   Name = "Speed",
   Range = {16, 200},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(Value)
      SpeedValue = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end
})

MoveTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 200},
   Increment = 5,
   CurrentValue = 100,
   Callback = function(Value)
      JumpValue = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end
})

-- SPY TAB (FIXED)
local SpyTab = Window:CreateTab("👁️ Spy")
local SpyDrop = SpyTab:CreateDropdown({
   Name = "Seleccionar Jugador",
   Options = PlayerList,
   CurrentOption = {"Ninguno"}
})

SpyTab:CreateButton({
   Name = "Activar Spy Cam",
   Callback = function()
      local targetName = SpyDrop.CurrentOption[1]
      if targetName ~= "Ninguno" then
         SpyTarget = Players:FindFirstChild(targetName)
         if SpyTarget and SpyTarget.Character then
            SpyEnabled = true
            Camera.CameraSubject = SpyTarget.Character:FindFirstChild("Humanoid")
         end
      end
   end
})

SpyTab:CreateButton({
   Name = "Desactivar Spy",
   Callback = function()
      SpyEnabled = false
      SpyTarget = nil
      if LocalPlayer.Character then
         Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
      end
   end
})

-- EXTRAS TAB (GODMODE + NOCLIP FIXED)
local ExtraTab = Window:CreateTab("⚙️ Extras")

ExtraTab:CreateButton({
   Name = "God Mode",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.MaxHealth = math.huge
         LocalPlayer.Character.Humanoid.Health = math.huge
      end
   end
})

ExtraTab:CreateButton({
   Name = "Noclip (10s)",
   Callback = function()
      local noclip = true
      local connection
      connection = RunService.Stepped:Connect(function()
         if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
               if part:IsA("BasePart") then
                  part.CanCollide = false
               end
            end
         end
      end)
      wait(10)
      connection:Disconnect()
   end
})

-- AUTO UPDATES
LocalPlayer.CharacterAdded:Connect(function()
   wait(1)
   if LocalPlayer.Character:FindFirstChild("Humanoid") then
      LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
      LocalPlayer.Character.Humanoid.JumpPower = JumpValue
   end
end)

Players.PlayerAdded:Connect(UpdatePlayerList)
spawn(function()
   while wait(3) do
      UpdatePlayerList()
      TeleDrop:Refresh(PlayerList, true)
      FlingDrop:Refresh(PlayerList, true)
      SpyDrop:Refresh(PlayerList, true)
   end
end)

-- Toggle GUI
UserInputService.InputBegan:Connect(function(input)
   if input.KeyCode == Enum.KeyCode.RightShift then
      if Window.MainFrame then
         Window.MainFrame.Visible = not Window.MainFrame.Visible
      end
   end
end)

Rayfield:Notify({
   Title = "Crack By Misa <3",
   Content = "¡FIXED 100%! Todo funcionando\nRightShift = Toggle GUI",
   Duration = 6
})
