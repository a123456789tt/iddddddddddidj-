-- ==================== FAZZETA RIVALS v2.1 (RPG & Fog + Fire & Jump) ====================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")
local MaterialService = game:GetService("MaterialService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- ==================== НАСТРОЙКИ ====================
local Settings = {
    speedEnabled = true,
    currentSpeed = 16,
    flyMode = "V3",
    flySpeedV2 = 60,
    isFlying = false,
    aimbotEnabled = false,
    aimbotDistance = 300,
    aimbotSmoothness = 0.7,
    aimbotTargetPart = "Head",
    aimbotIgnoreWalls = true,
    teamCheck = true,
    antiKatana = true,
    aimbotOnRMB = false,
    aimbotPriorityEnabled = false,
    aimbotPriority = "Closest",
    aimbotRandomPart = false,
    aimbotHeadChance = 70,
    aimbotStayOnTarget = true,
    triggerbotEnabled = false,
    currentTriggerDelay = 150,
    infJumpEnabled = false,
    infJumpPower = 50,
    noclipEnabled = false,
    fovEnabled = false,
    customFOV = 90,
    espEnabled = false,
    espDistance = 1000,
    espBoxEnabled = true,
    espBoxColor = Color3.fromRGB(255, 100, 150),
    espBoxThickness = 2,
    espNameEnabled = true,
    espNameColor = Color3.fromRGB(255, 255, 255),
    espHealthEnabled = true,
    espLevelEnabled = true,
    espLevelColorByRank = true,
    espLevelColor = Color3.fromRGB(255, 255, 255),
    espSkeletonEnabled = false,
    espSkeletonColor = Color3.fromRGB(255, 150, 200),
    tpEnabled = false,
    tpPosition = "Front",
    tpDistance = 2,
    shotgunModeEnabled = false,
    shotgunTPDistance = 5,
    shotgunUpdateRate = 0.1,
    daggerModeEnabled = false,
    daggerParryKey = Enum.KeyCode.Q,
    daggerParryDistance = 15,
    tracerEnabled = false,
    tracerLength = 500,
    tracerDuration = 0.5,
    tracerColor = Color3.new(1, 0.5, 0),
    autoRunEnabled = false,
    rageBotEnabled = false,
    rageAimbot = false,
    rageTriggerbot = false,
    rageWallPen = false,
    rageShootDelay = 150,
    rageHitPart = "Head",
    rageSwitchOnEmpty = false,
    noRecoil = false,
    noSpread = false,
    noFlash = false,
    noSmoke = false,
    rpgBlockEnabled = false,
    rpgBlockSize = 12,
    fogEnabled = false,
    fogDensity = 0.1,
    fogColor = Color3.fromRGB(200, 200, 200),
    hudEnabled = true,
    slideBoostEnabled = false,
    slideBoostPower = 5,
    constantTpUp = false,
    randomTpRadius = 50,
    skyEnabled = false,
    skyColor = Color3.fromRGB(135, 206, 235),
}

-- ==================== FIRE CONTROL (одна кнопка рандома) ====================
local fireEmitters = {}

local function isFireParticle(particle)
    local n = particle.Name:lower()
    return n:find("fire") or n:find("flame") or n:find("ignite") or n:find("burn")
end

local function addFireEmitter(emitter)
    if isFireParticle(emitter) then
        fireEmitters[emitter] = true
    end
end

local function removeFireEmitter(emitter)
    fireEmitters[emitter] = nil
end

for _, v in ipairs(Workspace:GetDescendants()) do
    if v:IsA("ParticleEmitter") then addFireEmitter(v)
    elseif v:IsA("Fire") then addFireEmitter(v) end
end

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ParticleEmitter") or obj:IsA("Fire") then addFireEmitter(obj) end
end)
Workspace.DescendantRemoving:Connect(function(obj)
    if fireEmitters[obj] then removeFireEmitter(obj) end
end)

local function randomizeFireColors()
    for emitter, _ in pairs(fireEmitters) do
        local c1 = Color3.fromRGB(math.random(255), math.random(255), math.random(255))
        local c2 = Color3.fromRGB(math.random(255), math.random(255), math.random(255))
        local c3 = Color3.fromRGB(math.random(255), math.random(255), math.random(255))
        local gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(0.5, c2),
            ColorSequenceKeypoint.new(1, c3)
        })
        if emitter:IsA("ParticleEmitter") then
            emitter.Color = gradient
        elseif emitter:IsA("Fire") then
            emitter.Color = c2
            emitter.SecondaryColor = c3
        end
    end
end

-- ==================== ЗАЩИТА ПОСЛЕ РЕСПАВНА ====================
local protectedPlayers = {}
local function isPlayerProtected(targetPlayer)
    local untilTime = protectedPlayers[targetPlayer]
    return untilTime and os.time() < untilTime
end
task.spawn(function()
    while true do
        task.wait(30)
        local now = os.time()
        for plr, t in pairs(protectedPlayers) do
            if now >= t then protectedPlayers[plr] = nil end
        end
    end
end)
local function onPlayerRespawn(targetPlayer)
    targetPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.5)
        local myRoot = character and character:FindFirstChild("HumanoidRootPart")
        local targetRoot = newChar:FindFirstChild("HumanoidRootPart")
        if myRoot and targetRoot then
            local dist = (targetRoot.Position - myRoot.Position).Magnitude
            if dist <= 2 then
                protectedPlayers[targetPlayer] = os.time() + 90
                print("[FazZzeta] Защита " .. targetPlayer.Name .. " на 90 сек")
            end
        end
    end)
end
for _, plr in ipairs(Players:GetPlayers()) do if plr ~= player then onPlayerRespawn(plr) end end
Players.PlayerAdded:Connect(onPlayerRespawn)

-- ==================== ВСПОМОГАТЕЛЬНЫЕ ====================
local function updateStatus(text) print("[FazZzeta] " .. text) end
local function isEnemy(targetPlayer)
    if targetPlayer == player then return false end
    if _G.FazetaWhitelist and _G.FazetaWhitelist[targetPlayer.Name] then return false end
    if isPlayerProtected(targetPlayer) then return false end
    if not Settings.teamCheck then return true end
    if not targetPlayer.Team then return false end
    if not player.Team then return true end
    return player.Team ~= targetPlayer.Team
end

local function canSee(targetPart)
    if Settings.aimbotIgnoreWalls or (Settings.rageBotEnabled and Settings.rageWallPen) then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 1000
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character, Camera}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(origin, direction, params)
    if result and result.Instance then
        local hit = result.Instance
        local hitChar = hit:FindFirstAncestorOfClass("Model")
        if hitChar and hitChar == targetPart.Parent then return true end
        return false
    end
    return true
end

-- No Recoil / No Spread
local function applyNoRecoilSpread()
    if not Settings.noRecoil and not Settings.noSpread then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        local weaponScript = tool:FindFirstChild("WeaponScript") or tool:FindFirstChild("Client")
        if weaponScript then
            if Settings.noRecoil then
                weaponScript:SetAttribute("RecoilMultiplier", 0)
                weaponScript:SetAttribute("RecoilEnabled", false)
            end
            if Settings.noSpread then
                weaponScript:SetAttribute("SpreadMultiplier", 0)
                weaponScript:SetAttribute("SpreadEnabled", false)
            end
        end
    end
end
RunService.Heartbeat:Connect(applyNoRecoilSpread)

-- No Flash / No Smoke (улучшено)
local function removeFlashSmoke(obj)
    if not obj:IsA("BasePart") and not obj:IsA("ParticleEmitter") and not obj:IsA("Smoke") then return end
    local parentName = obj.Parent and obj.Parent.Name:lower() or ""
    local objName = obj.Name:lower()

    if Settings.noFlash and (objName:find("flash") or parentName:find("flash")) then
        obj:Destroy()
        return
    end

    if Settings.noSmoke then
        if obj:IsA("Smoke") then
            obj:Destroy()
        elseif obj:IsA("BasePart") and (objName:find("smoke") or objName:find("grenade") or parentName:find("smoke") or parentName:find("grenade")) then
            obj:Destroy()
        elseif obj:IsA("ParticleEmitter") and (objName:find("smoke") or parentName:find("smoke") or objName:find("grenade")) then
            obj:Destroy()
        end
    end
end
Workspace.DescendantAdded:Connect(removeFlashSmoke)
for _, v in ipairs(Workspace:GetDescendants()) do removeFlashSmoke(v) end

-- Custom FOV
RunService.RenderStepped:Connect(function()
    if Settings.fovEnabled and Camera then
        Camera.FieldOfView = math.clamp(Settings.customFOV, 30, 120)
    end
end)

-- Fog Control (атмосфера)
local function applyFog()
    if Settings.fogEnabled then
        local density = math.clamp(Settings.fogDensity, 0, 1)
        local fogEnd = math.clamp(500 * (1 - density), 10, 500)
        Lighting.FogStart = 0
        Lighting.FogEnd = fogEnd
        Lighting.FogColor = Settings.fogColor
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
        atmosphere.Parent = Lighting
        atmosphere.Density = density * 0.8
        atmosphere.Color = Settings.fogColor
        atmosphere.Haze = density * 2
        atmosphere.Glare = 0
    else
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then atmosphere:Destroy() end
    end
end
RunService.RenderStepped:Connect(applyFog)

-- Sky (простая замена цвета окружения)
local function applySky()
    if Settings.skyEnabled then
        Lighting.Ambient = Settings.skyColor
        Lighting.OutdoorAmbient = Settings.skyColor
    else
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end
end

-- ==================== AIMBOT ====================
local aimTarget = nil
local aimbotConnection, cameraConnection
local function getTargetPart(char)
    if Settings.rageBotEnabled then
        local part = Settings.rageHitPart == "Head" and char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if part then return part end
    end
    if Settings.aimbotRandomPart then
        local rand = math.random(1, 100)
        if rand <= Settings.aimbotHeadChance then
            return char:FindFirstChild("Head")
        else
            return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        end
    end
    if Settings.aimbotTargetPart == "Head" then
        return char:FindFirstChild("Head")
    else
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    end
end
local function findBestTarget()
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil, nil end
    local myPos = character.HumanoidRootPart.Position
    local candidates = {}
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character and isEnemy(other) then
            local targetChar = other.Character
            local hum = targetChar:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = getTargetPart(targetChar)
                if part and canSee(part) then
                    local dist = (part.Position - myPos).Magnitude
                    if dist <= Settings.aimbotDistance then
                        table.insert(candidates, {player=other, part=part, dist=dist, health=hum.Health})
                    end
                end
            end
        end
    end
    if #candidates == 0 then return nil, nil end
    if not Settings.aimbotPriorityEnabled then
        table.sort(candidates, function(a,b) return a.dist < b.dist end)
        local best = candidates[1]
        return best.player, best.part
    else
        if Settings.aimbotPriority == "Closest" then
            table.sort(candidates, function(a,b) return a.dist < b.dist end)
        elseif Settings.aimbotPriority == "LowHealth" then
            table.sort(candidates, function(a,b) return a.health < b.health end)
        elseif Settings.aimbotPriority == "HighHealth" then
            table.sort(candidates, function(a,b) return a.health > b.health end)
        elseif Settings.aimbotPriority == "Random" then
            local rand = candidates[math.random(1, #candidates)]
            return rand.player, rand.part
        end
        local best = candidates[1]
        return best.player, best.part
    end
end
local function aimAt(part)
    if not Camera or not part then return end
    local targetPos = part.Position
    local newCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    local smooth = Settings.aimbotSmoothness * (0.9 + 0.2*math.random())
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, smooth)
end
local rmbHeld = false
UserInputService.InputBegan:Connect(function(inp,gp) if not gp and inp.UserInputType == Enum.UserInputType.MouseButton2 then rmbHeld = true end end)
UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton2 then rmbHeld = false end end)
function startAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() end
    if cameraConnection then cameraConnection:Disconnect() end
    aimbotConnection = RunService.Heartbeat:Connect(function()
        local active = Settings.aimbotEnabled
        if Settings.aimbotOnRMB then active = active and rmbHeld end
        if active then
            local _, part = findBestTarget()
            if part then
                aimAt(part)
                aimTarget = part
            elseif not Settings.aimbotStayOnTarget then
                aimTarget = nil
            end
        end
    end)
    cameraConnection = Camera:GetPropertyChangedSignal("CFrame"):Connect(function()
        local active = Settings.aimbotEnabled
        if Settings.aimbotOnRMB then active = active and rmbHeld end
        if active and aimTarget and aimTarget.Parent then aimAt(aimTarget) end
    end)
end
local function toggleAimbot(s) Settings.aimbotEnabled = s; if s then startAimbot() else if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection=nil end; if cameraConnection then cameraConnection:Disconnect(); cameraConnection=nil end; aimTarget=nil end end

-- ==================== TRIGGERBOT ====================
local triggerbotConnection, lastShot = nil, 0
local function getTargetFromCam()
    local ray = Camera:ScreenPointToRay(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character, Camera}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local res = Workspace:Raycast(ray.Origin, ray.Direction*1000, params)
    if res and res.Instance then
        local char = res.Instance:FindFirstAncestorOfClass("Model")
        if char and char:FindFirstChild("Humanoid") then
            local plr = Players:GetPlayerFromCharacter(char)
            if plr and isEnemy(plr) then return plr end
        end
    end
    return nil
end
function startTriggerbot()
    if triggerbotConnection then triggerbotConnection:Disconnect() end
    triggerbotConnection = RunService.Heartbeat:Connect(function()
        local active = Settings.triggerbotEnabled or (Settings.rageBotEnabled and Settings.rageTriggerbot)
        if active then
            local target = getTargetFromCam()
            if target then
                local delay = Settings.rageBotEnabled and Settings.rageShootDelay or Settings.currentTriggerDelay
                local now = tick()*1000
                if now - lastShot >= delay then
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
                    task.wait()
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
                    lastShot = now
                end
            end
        end
    end)
end
local function toggleTriggerbot(s) Settings.triggerbotEnabled = s; if s then startTriggerbot() else if triggerbotConnection then triggerbotConnection:Disconnect(); triggerbotConnection=nil end end end

-- ==================== RAGE BOT ====================
local function applyRage()
    if Settings.rageBotEnabled then
        if not Settings.aimbotEnabled and Settings.rageAimbot then toggleAimbot(true) end
        if not Settings.triggerbotEnabled and Settings.rageTriggerbot then toggleTriggerbot(true) end
    end
end
local function toggleRageBot(s) Settings.rageBotEnabled = s; if s then applyRage() else updateStatus("Rage Bot выключен") end end

-- ==================== SPEED, FLY, NOCLIP, INFJUMP ====================
local speedController = nil
local bodyVelocity = nil
local function setupSpeed()
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if not speedController then
        speedController = Instance.new("BodyVelocity")
        speedController.Name = "SpeedController"
        speedController.MaxForce = Vector3.new(1e5, 0, 1e5)
        speedController.P = 1e4
        speedController.Parent = root
    end
end
local function removeSpeed() if speedController then speedController:Destroy(); speedController=nil end end
local function applySpeedState() if Settings.speedEnabled then setupSpeed() else removeSpeed() end end
RunService.Heartbeat:Connect(function()
    if speedController and character and humanoid and not Settings.isFlying then
        local move = humanoid.MoveDirection
        if move.Magnitude > 0.01 then
            speedController.Velocity = move * (Settings.currentSpeed * (0.95+0.1*math.random()))
        else
            speedController.Velocity = Vector3.new(0, speedController.Velocity.Y, 0)
        end
    elseif speedController and Settings.isFlying then
        speedController.Velocity = Vector3.new(0,0,0)
    end
end)
local function toggleSpeed(s) Settings.speedEnabled = s; if s then applySpeedState() else removeSpeed() end end

local function setFlightState(state)
    if state == Settings.isFlying then return end
    Settings.isFlying = state
    if state then
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then
            if not bodyVelocity then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
                bodyVelocity.Parent = root
            end
            humanoid.PlatformStand = true
        end
    else
        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity=nil end
        humanoid.PlatformStand = false
    end
end

local w,a,s,d,space,shift = false,false,false,false,false,false
UserInputService.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.W then w=true
    elseif inp.KeyCode == Enum.KeyCode.A then a=true
    elseif inp.KeyCode == Enum.KeyCode.S then s=true
    elseif inp.KeyCode == Enum.KeyCode.D then d=true
    elseif inp.KeyCode == Enum.KeyCode.Space then space=true
    elseif inp.KeyCode == Enum.KeyCode.LeftShift then shift=true end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.KeyCode == Enum.KeyCode.W then w=false
    elseif inp.KeyCode == Enum.KeyCode.A then a=false
    elseif inp.KeyCode == Enum.KeyCode.S then s=false
    elseif inp.KeyCode == Enum.KeyCode.D then d=false
    elseif inp.KeyCode == Enum.KeyCode.Space then space=false
    elseif inp.KeyCode == Enum.KeyCode.LeftShift then shift=false end
end)
RunService.Heartbeat:Connect(function()
    if Settings.isFlying and bodyVelocity then
        if Settings.flyMode == "V1" then
            bodyVelocity.Velocity = humanoid.MoveDirection * 60
        elseif Settings.flyMode == "V2" then
            bodyVelocity.Velocity = w and Camera.CFrame.LookVector * Settings.flySpeedV2 or Vector3.new(0,0,0)
        elseif Settings.flyMode == "V3" then
            local cf = Camera.CFrame
            local move = Vector3.new(0,0,0)
            if w then move = move + cf.LookVector end
            if s then move = move - cf.LookVector end
            if d then move = move + cf.RightVector end
            if a then move = move - cf.RightVector end
            if space then move = move + cf.UpVector end
            if shift then move = move - cf.UpVector end
            if move.Magnitude > 0 then
                bodyVelocity.Velocity = move.Unit * Settings.flySpeedV2
            else
                bodyVelocity.Velocity = Vector3.zero
            end
        end
    end
end)

-- Slide Boost
local function startSlideBoost()
    if not Settings.slideBoostEnabled then return end
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local hum = character and character:FindFirstChild("Humanoid")
    if not root or not hum then return end
    if hum.MoveDirection.Magnitude < 0.1 then return end
    local speed = Settings.slideBoostPower * 10
    local direction = hum.MoveDirection.Unit
    local boostVel = Instance.new("BodyVelocity")
    boostVel.MaxForce = Vector3.new(1e5,0,1e5)
    boostVel.Velocity = direction * speed
    boostVel.Parent = root
    task.delay(0.5, function()
        boostVel:Destroy()
    end)
end
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.LeftControl and Settings.slideBoostEnabled then
        startSlideBoost()
    end
end)

local function applyNoclip(state)
    if not character then return end
    for _,v in ipairs(character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = not state end end
end
local function toggleNoclip(s) Settings.noclipEnabled = s; applyNoclip(s) end
local function toggleInfJump(s) Settings.infJumpEnabled = s end
UserInputService.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.Space and Settings.infJumpEnabled and humanoid then
        local state = humanoid:GetState()
        if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then root.Velocity = Vector3.new(root.Velocity.X, Settings.infJumpPower, root.Velocity.Z) end
        end
    end
end)

-- ==================== SHOTGUN, DAGGER ====================
local lastShotgunUpdate = 0
local function shotgunLoop()
    if not Settings.shotgunModeEnabled then return end
    if not character or not character.Parent or humanoid.Health <= 0 then return end
    local now = tick()
    if now - lastShotgunUpdate < Settings.shotgunUpdateRate then return end
    lastShotgunUpdate = now
    local _, part = findBestTarget()
    if part then
        local myRoot = character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            myRoot.CFrame = CFrame.new(part.Position - Vector3.new(0, Settings.shotgunTPDistance, 0))
        end
    end
end
RunService.Heartbeat:Connect(shotgunLoop)

local function daggerLoop()
    if not Settings.daggerModeEnabled then return end
    if not character or humanoid.Health <= 0 then return end
    local myRoot = character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and isEnemy(plr) and plr.Character then
            local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local targetHum = plr.Character:FindFirstChild("Humanoid")
            if targetRoot and targetHum and targetHum.Health > 0 then
                local dist = (targetRoot.Position - myRoot.Position).Magnitude
                if dist < Settings.daggerParryDistance then
                    local state = targetHum:GetState()
                    if state == Enum.HumanoidStateType.Attacking or state == Enum.HumanoidStateType.Swimming then
                        VirtualInputManager:SendKeyEvent(true, Settings.daggerParryKey, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Settings.daggerParryKey, false, game)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
end
RunService.Heartbeat:Connect(daggerLoop)

-- ==================== TELEPORT ====================
local tpConnection = nil
local function getNearestEnemy()
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and isEnemy(plr) then
            local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = root
                end
            end
        end
    end
    return nearest
end
local function teleportToEnemy()
    local target = getNearestEnemy()
    if not target then return end
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local offset
    if Settings.tpPosition == "Front" then offset = target.CFrame.LookVector * Settings.tpDistance
    elseif Settings.tpPosition == "Back" then offset = -target.CFrame.LookVector * Settings.tpDistance
    elseif Settings.tpPosition == "Up" then offset = Vector3.new(0, Settings.tpDistance, 0)
    elseif Settings.tpPosition == "Down" then offset = Vector3.new(0, -Settings.tpDistance, 0)
    else offset = Vector3.new(0,0,0) end
    myRoot.CFrame = CFrame.new(target.Position + offset)
end
local function startTP() if tpConnection then tpConnection:Disconnect() end; tpConnection = RunService.Heartbeat:Connect(teleportToEnemy) end
local function stopTP() if tpConnection then tpConnection:Disconnect(); tpConnection=nil end end
local function toggleTP(s) Settings.tpEnabled = s; if s then startTP() else stopTP() end end

-- Random TP вокруг себя
local randomTPConnection = nil
local randomTPActive = false
local function teleportRandomAroundSelf()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        local angle = math.random() * 2 * math.pi
        local radius = Settings.randomTpRadius * math.random()
        local offset = Vector3.new(math.cos(angle)*radius, 0, math.sin(angle)*radius)
        root.CFrame = root.CFrame + offset
    end
end
local function toggleRandomTP(s)
    randomTPActive = s
    if s then
        if randomTPConnection then randomTPConnection:Disconnect() end
        randomTPConnection = RunService.Heartbeat:Connect(function()
            if randomTPActive then teleportRandomAroundSelf(); task.wait(0.1) end
        end)
    else
        if randomTPConnection then randomTPConnection:Disconnect(); randomTPConnection=nil end
    end
end

-- TP 1000 вверх
local function teleportUp()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = root.CFrame + Vector3.new(0, 1000, 0) end
end
local constantUpConnection = nil
local function toggleConstantUp(s)
    Settings.constantTpUp = s
    if s then
        if constantUpConnection then constantUpConnection:Disconnect() end
        constantUpConnection = RunService.Heartbeat:Connect(function()
            teleportUp()
            task.wait(0.05)
        end)
    else
        if constantUpConnection then constantUpConnection:Disconnect(); constantUpConnection=nil end
    end
end

-- ==================== ESP (DRAWING) ====================
local drawingSupported = pcall(function() return Drawing.new("Square") end)
if not drawingSupported then warn("[FazZzeta] Drawing API не поддерживается. ESP отключен.") else print("[FazZzeta] Drawing API доступен.") end

local espObjects = {}
local function getPlayerLevel(plr)
    local leaderstats = plr:FindFirstChild("leaderstats")
    if leaderstats then
        local level = leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("Rank")
        if level and type(level.Value) == "number" then return level.Value end
    end
    local attr = plr:GetAttribute("Level") or plr:GetAttribute("Rank")
    if attr and type(attr) == "number" then return attr end
    return nil
end
local function getLevelColor(level)
    if not level then return Color3.fromRGB(128,128,128) end
    if level <= 50 then return Color3.fromRGB(0,255,0)
    elseif level <= 100 then return Color3.fromRGB(255,255,0)
    elseif level <= 200 then return Color3.fromRGB(255,165,0)
    elseif level <= 350 then return Color3.fromRGB(255,0,0)
    else return Color3.fromRGB(139,69,19) end
end
local function createESP(plr)
    if espObjects[plr] then return end
    if not drawingSupported then return end
    local esp = {}
    if Settings.espBoxEnabled then
        esp.box = Drawing.new("Square")
        esp.box.Thickness = Settings.espBoxThickness
        esp.box.Filled = false
        esp.box.Color = Settings.espBoxColor
        esp.box.Visible = false
    end
    if Settings.espNameEnabled then
        esp.name = Drawing.new("Text")
        esp.name.Size = 16
        esp.name.Center = true
        esp.name.Outline = true
        esp.name.Color = Settings.espNameColor
        esp.name.Visible = false
    end
    if Settings.espHealthEnabled then
        esp.health = Drawing.new("Text")
        esp.health.Size = 14
        esp.health.Outline = true
        esp.health.Visible = false
    end
    if Settings.espLevelEnabled then
        esp.level = Drawing.new("Text")
        esp.level.Size = 14
        esp.level.Center = true
        esp.level.Outline = true
        esp.level.Visible = false
    end
    if Settings.espSkeletonEnabled then
        esp.skeleton = {}
        local bones = {
            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
            {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
            {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
        }
        for i = 1, #bones do
            local line = Drawing.new("Line")
            line.Thickness = 2
            line.Color = Settings.espSkeletonColor
            line.Visible = false
            table.insert(esp.skeleton, {line = line, partA = bones[i][1], partB = bones[i][2]})
        end
    end
    espObjects[plr] = esp
end
local function removeESP(plr)
    local esp = espObjects[plr]
    if not esp then return end
    if esp.box then esp.box:Remove() end
    if esp.name then esp.name:Remove() end
    if esp.health then esp.health:Remove() end
    if esp.level then esp.level:Remove() end
    if esp.skeleton then for _, bone in ipairs(esp.skeleton) do bone.line:Remove() end end
    espObjects[plr] = nil
end
local function updateDrawingESP()
    if not Settings.espEnabled then for plr in pairs(espObjects) do removeESP(plr) end return end
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player or not isEnemy(plr) then removeESP(plr); continue end
        local char = plr.Character
        if not char then removeESP(plr); continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then removeESP(plr); continue end
        if myRoot and (root.Position - myRoot.Position).Magnitude > Settings.espDistance then removeESP(plr); continue end
        createESP(plr)
        local esp = espObjects[plr]
        if not esp then continue end
        local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
        local head = char:FindFirstChild("Head")
        local headPos = head and head.Position or root.Position + Vector3.new(0,2,0)
        local headScreen, headOnScreen = Camera:WorldToViewportPoint(headPos)
        if not rootOnScreen or not headOnScreen then
            if esp.box then esp.box.Visible = false end
            if esp.name then esp.name.Visible = false end
            if esp.health then esp.health.Visible = false end
            if esp.level then esp.level.Visible = false end
            if esp.skeleton then for _, bone in ipairs(esp.skeleton) do bone.line.Visible = false end end
            continue
        end
        local boxHeight = math.abs(headScreen.Y - rootPos.Y) * 1.6
        local boxWidth = boxHeight * 0.6
        local boxX = rootPos.X - boxWidth / 2
        local boxY = rootPos.Y - boxHeight / 2
        if esp.box then
            esp.box.Visible = true
            esp.box.Position = Vector2.new(boxX, boxY)
            esp.box.Size = Vector2.new(boxWidth, boxHeight)
            esp.box.Color = Settings.espBoxColor
            esp.box.Thickness = Settings.espBoxThickness
        end
        if esp.name then
            esp.name.Visible = true
            esp.name.Position = Vector2.new(rootPos.X, boxY - 16)
            esp.name.Text = plr.Name
            esp.name.Color = Settings.espNameColor
        end
        if esp.health then
            esp.health.Visible = true
            esp.health.Position = Vector2.new(boxX + boxWidth + 5, boxY)
            local hpPercent = hum.Health / hum.MaxHealth
            esp.health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
            esp.health.Color = Color3.new(1 - hpPercent, hpPercent, 0)
        end
        if esp.level then
            local level = getPlayerLevel(plr)
            if level then
                esp.level.Text = "LVL " .. tostring(level)
                esp.level.Color = Settings.espLevelColorByRank and getLevelColor(level) or Settings.espLevelColor
            else
                esp.level.Text = "?"
                esp.level.Color = Settings.espLevelColor
            end
            esp.level.Visible = true
            esp.level.Position = Vector2.new(rootPos.X, boxY - (esp.name and 32 or 16))
        end
        if esp.skeleton then
            for _, bone in ipairs(esp.skeleton) do
                local partA = char:FindFirstChild(bone.partA)
                local partB = char:FindFirstChild(bone.partB)
                if partA and partB then
                    local posA, visA = Camera:WorldToViewportPoint(partA.Position)
                    local posB, visB = Camera:WorldToViewportPoint(partB.Position)
                    if visA and visB then
                        bone.line.Visible = true
                        bone.line.From = Vector2.new(posA.X, posA.Y)
                        bone.line.To = Vector2.new(posB.X, posB.Y)
                        bone.line.Color = Settings.espSkeletonColor
                    else bone.line.Visible = false end
                else bone.line.Visible = false end
            end
        end
    end
    for plr in pairs(espObjects) do if not plr.Parent then removeESP(plr) end end
end
local function startESP()
    for _, plr in ipairs(Players:GetPlayers()) do if plr ~= player then createESP(plr) end end
    Players.PlayerAdded:Connect(function(plr) if plr ~= player then createESP(plr) end end)
    Players.PlayerRemoving:Connect(removeESP)
end
local function toggleESP(state)
    Settings.espEnabled = state
    if state then startESP() else for plr in pairs(espObjects) do removeESP(plr) end end
end
if Settings.espEnabled then startESP() end
RunService.RenderStepped:Connect(updateDrawingESP)

-- ==================== HUD (сдвинут вниз, добавлены название и версия) ====================
local hudObjects = {}
local lastFpsUpdate = tick()
local fpsCount = 0
local currentFPS = 60

RunService.RenderStepped:Connect(function()
    if not Settings.hudEnabled then
        for _, obj in pairs(hudObjects) do obj.Visible = false end
        return
    end
    fpsCount = fpsCount + 1
    local now = tick()
    if now - lastFpsUpdate >= 1 then
        currentFPS = math.floor(fpsCount / (now - lastFpsUpdate))
        fpsCount = 0
        lastFpsUpdate = now
    end

    local ping = math.floor(player:GetNetworkPing() * 1000)
    local gameName = "Unknown"
    pcall(function()
        gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)

    -- Цвет пинга
    local pingColor
    if ping <= 50 then pingColor = Color3.fromRGB(0, 255, 0)
    elseif ping <= 100 then pingColor = Color3.fromRGB(255, 255, 0)
    elseif ping <= 200 then pingColor = Color3.fromRGB(255, 165, 0)
    elseif ping <= 400 then pingColor = Color3.fromRGB(255, 0, 0)
    else pingColor = Color3.fromRGB(139, 69, 19)
    end

    local screenHeight = Camera.ViewportSize.Y

    -- Создаём объекты один раз
    if not hudObjects.nick then
        hudObjects.nick = Drawing.new("Text")
        hudObjects.nick.Size = 18; hudObjects.nick.Center = false; hudObjects.nick.Outline = true
        hudObjects.nick.Color = Color3.fromRGB(255,255,255)
    end
    hudObjects.nick.Visible = true
    hudObjects.nick.Position = Vector2.new(10, 50)
    hudObjects.nick.Text = "Player: " .. player.Name

    if not hudObjects.game then
        hudObjects.game = Drawing.new("Text")
        hudObjects.game.Size = 18; hudObjects.game.Center = false; hudObjects.game.Outline = true
        hudObjects.game.Color = Color3.fromRGB(255,255,255)
    end
    hudObjects.game.Visible = true
    hudObjects.game.Position = Vector2.new(10, 75)
    hudObjects.game.Text = "Game: " .. gameName

    if not hudObjects.ping then
        hudObjects.ping = Drawing.new("Text")
        hudObjects.ping.Size = 18; hudObjects.ping.Center = false; hudObjects.ping.Outline = true
    end
    hudObjects.ping.Visible = true
    hudObjects.ping.Position = Vector2.new(10, 100)
    hudObjects.ping.Text = "Ping: " .. ping .. " ms"
    hudObjects.ping.Color = pingColor

    if not hudObjects.fps then
        hudObjects.fps = Drawing.new("Text")
        hudObjects.fps.Size = 18; hudObjects.fps.Center = false; hudObjects.fps.Outline = true
        hudObjects.fps.Color = Color3.fromRGB(255,255,0)
    end
    hudObjects.fps.Visible = true
    hudObjects.fps.Position = Vector2.new(10, 125)
    hudObjects.fps.Text = "FPS: " .. currentFPS

    -- Название и версия в самом низу
    if not hudObjects.title then
        hudObjects.title = Drawing.new("Text")
        hudObjects.title.Size = 20; hudObjects.title.Center = false; hudObjects.title.Outline = true
        hudObjects.title.Color = Color3.fromRGB(180, 0, 255) -- фиолетовый
    end
    hudObjects.title.Visible = true
    hudObjects.title.Position = Vector2.new(10, screenHeight - 45)
    hudObjects.title.Text = "FazZzeta Rivals"

    if not hudObjects.version then
        hudObjects.version = Drawing.new("Text")
        hudObjects.version.Size = 18; hudObjects.version.Center = false; hudObjects.version.Outline = true
        hudObjects.version.Color = Color3.fromRGB(200, 255, 0) -- жёлто-зелёный
    end
    hudObjects.version.Visible = true
    hudObjects.version.Position = Vector2.new(10, screenHeight - 22)
    hudObjects.version.Text = "v2.1"
end)

-- ==================== TRACERS (PART‑BASED) ====================
local TracerFolder = Instance.new("Folder")
TracerFolder.Name = "FazZzetaTracers"
TracerFolder.Parent = Workspace

local function createTracerRay()
    if not Settings.tracerEnabled then return end
    if not Camera then return end
    local startPos = Camera.CFrame.Position
    local direction = Camera.CFrame.LookVector
    local length = Settings.tracerLength
    local rayPart = Instance.new("Part")
    rayPart.Name = "TracerRay"
    rayPart.Anchored = true
    rayPart.CanCollide = false
    rayPart.CanTouch = false
    rayPart.Material = Enum.Material.Neon
    rayPart.Color = Settings.tracerColor
    rayPart.Transparency = 0.3
    rayPart.Size = Vector3.new(0.1, 0.1, length)
    rayPart.CFrame = CFrame.new(startPos + direction * length/2, startPos + direction * length)
    rayPart.Parent = TracerFolder
    task.delay(Settings.tracerDuration, function()
        if rayPart then rayPart:Destroy() end
    end)
end

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        createTracerRay()
    end
end)

-- ==================== RPG DODGE BLOCK ====================
local RPG_Block = { Enabled = Settings.rpgBlockEnabled, ZoneSize = Settings.rpgBlockSize }
local activeRPGZones = {}
local function blockHealing(char)
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum:SetAttribute("RPG_Block_Heal", true)
        local oldHealth = hum.Health
        local conn = hum.HealthChanged:Connect(function(newHealth)
            if newHealth > oldHealth and hum:GetAttribute("RPG_Block_Heal") then hum.Health = oldHealth end
            oldHealth = hum.Health
        end)
        return conn
    end
end
local function onRPGZoneTouched(projectile, zone, otherPart)
    local char = otherPart.Parent
    if not char or not char:IsA("Model") then return end
    local player = Players:GetPlayerFromCharacter(char)
    if not player then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    local oldWalkSpeed, oldJumpPower = hum.WalkSpeed, hum.JumpPower
    hum.WalkSpeed, hum.JumpPower = 0, 0
    local healConn = blockHealing(char)
    local data = { oldWalkSpeed = oldWalkSpeed, oldJumpPower = oldJumpPower, healConn = healConn }
    local touchEndedConn = zone.TouchEnded:Connect(function(part)
        if part.Parent == char then
            hum.WalkSpeed, hum.JumpPower = data.oldWalkSpeed, data.oldJumpPower
            hum:SetAttribute("RPG_Block_Heal", false)
            if data.healConn then data.healConn:Disconnect() end
            touchEndedConn:Disconnect()
        end
    end)
    local projectileRemovedConn = projectile.AncestryChanged:Connect(function()
        if not projectile:IsDescendantOf(Workspace) then
            hum.WalkSpeed, hum.JumpPower = data.oldWalkSpeed, data.oldJumpPower
            hum:SetAttribute("RPG_Block_Heal", false)
            if data.healConn then data.healConn:Disconnect() end
            projectileRemovedConn:Disconnect()
            if zone then zone:Destroy() end
        end
    end)
end
local function onNewProjectile(obj)
    if not RPG_Block.Enabled then return end
    if not obj:IsA("BasePart") then return end
    local name = obj.Name:lower()
    if name:find("rocket") or name:find("projectile") or name:find("rpg") then
        local zone = Instance.new("Part")
        zone.Shape = Enum.PartType.Ball
        zone.Size = Vector3.new(RPG_Block.ZoneSize, RPG_Block.ZoneSize, RPG_Block.ZoneSize)
        zone.CanCollide, zone.Transparency, zone.Anchored, zone.CanTouch = true, 1, false, true
        zone.Parent = Workspace
        local weld = Instance.new("WeldConstraint")
        weld.Part0, weld.Part1, weld.Parent = zone, obj, zone
        zone.Touched:Connect(function(part) onRPGZoneTouched(obj, zone, part) end)
        activeRPGZones[obj] = zone
        obj.AncestryChanged:Connect(function()
            if not obj:IsDescendantOf(Workspace) then
                if activeRPGZones[obj] then activeRPGZones[obj]:Destroy(); activeRPGZones[obj] = nil end
            end
        end)
    end
end
Workspace.DescendantAdded:Connect(onNewProjectile)
for _, v in ipairs(Workspace:GetDescendants()) do onNewProjectile(v) end

-- ==================== SKIN CHANGER ====================
local weaponModels = player.PlayerScripts.Assets.ViewModels.Weapons:GetChildren()
local wrapTextures = player.PlayerScripts.Assets.WrapTextures:GetChildren()
local wrapMaterials = MaterialService.Wraps:GetChildren()
local weaponNames = {} for _,v in ipairs(weaponModels) do table.insert(weaponNames, v.Name) end
local wrapTextureNames = {} local filteredWraps = {} local wrapMaterialNames = {} local wrapVariantList = {}
for _,v in ipairs(wrapTextures) do wrapTextureNames[v.Name]=true end
for _,v in ipairs(wrapMaterials) do wrapMaterialNames[v.Name]=v; if not wrapTextureNames[v.Name] then table.insert(wrapVariantList, v.Name) end end
for _,v in ipairs(wrapTextures) do if not wrapMaterialNames[v.Name] then table.insert(filteredWraps, v.Name) end end
local materialList = {} for _,v in pairs(Enum.Material:GetEnumItems()) do table.insert(materialList, v.Name) end
local function applyWeaponSkin(wn, col, trans, mat, wrapTex, wrapMat, ref, useCol, useTrans, useMat, useWrapTex, useWrapMat, applyAll)
    local weapons = applyAll and weaponModels or {}
    if not applyAll then for _,v in ipairs(weaponModels) do if v.Name==wn then table.insert(weapons, v) end end end
    for _,model in ipairs(weapons) do
        for _,part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency~=1 then
                if useCol then part.Color = col end
                if useTrans then part.Transparency = trans end
                part.Reflectance = ref
                if useWrapMat and wrapMat then
                    part.Material = Enum.Material.Fabric
                    part.MaterialVariant = wrapMat.Name
                    for _,child in ipairs(part:GetChildren()) do if child:IsA("Texture") or child:IsA("Decal") or child:IsA("SurfaceAppearance") then child:Destroy() end end
                else
                    if useMat then part.Material = mat end
                    part.MaterialVariant = ""
                    if useWrapTex and wrapTex then
                        for _,child in ipairs(part:GetChildren()) do if child:IsA("Texture") or child:IsA("Decal") or child:IsA("SurfaceAppearance") then child:Destroy() end end
                        for _,w in ipairs(wrapTextures) do if w.Name==wrapTex then for _,c in ipairs(w:GetChildren()) do if c:IsA("Decal") or c:IsA("Texture") or c:IsA("SurfaceAppearance") then c:Clone().Parent=part end end break end end
                    end
                end
            end
        end
    end
end

-- ==================== GUI FLUENT ====================
local Window = Fluent:CreateWindow({
    Title = "FazZzeta Rivals",
    SubTitle = "v2.1",
    TabWidth = 120,
    Size = UDim2.fromOffset(520, 560),
    Acrylic = false,
    MinimizeKey = Enum.KeyCode.RightShift
})
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    World = Window:AddTab({ Title = "World", Icon = "globe" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "sliders" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "cog" })
}

-- Aimbot Tab
local aimSec = Tabs.Aimbot:AddSection("Aimbot")
aimSec:AddToggle("aimbotToggle", {Title="Aimbot", Default=Settings.aimbotEnabled, Callback=toggleAimbot})
aimSec:AddToggle("aimbotRMBToggle", {Title="Aimbot on RMB Hold", Default=Settings.aimbotOnRMB, Callback=function(v) Settings.aimbotOnRMB=v end})
aimSec:AddSlider("aimbotDistSlider", {Title="Distance", Min=10, Max=10000, Default=Settings.aimbotDistance, Rounding=0, Callback=function(v) Settings.aimbotDistance=v end})
aimSec:AddSlider("aimbotStrengthSlider", {Title="Smoothness", Min=0.1, Max=1, Default=Settings.aimbotSmoothness, Precision=2, Rounding=2, Callback=function(v) Settings.aimbotSmoothness=v end})
aimSec:AddDropdown("aimPartDropdown", {Title="Aim Part", Values={"Head","Torso"}, Default=Settings.aimbotTargetPart=="Head" and 1 or 2, Callback=function(v) Settings.aimbotTargetPart=v end})
aimSec:AddToggle("wallCheckToggle", {Title="Wall Check", Default=Settings.aimbotIgnoreWalls, Callback=function(v) Settings.aimbotIgnoreWalls=v end})
aimSec:AddToggle("teamCheckToggle", {Title="Team Check", Default=Settings.teamCheck, Callback=function(v) Settings.teamCheck=v end})
aimSec:AddToggle("antiKatanaToggle", {Title="Anti-Katana", Default=Settings.antiKatana, Callback=function(v) Settings.antiKatana=v end})
aimSec:AddToggle("priorityEnableToggle", {Title="Enable Priority Mode", Default=Settings.aimbotPriorityEnabled, Callback=function(v) Settings.aimbotPriorityEnabled=v end})
aimSec:AddDropdown("priorityDropdown", {Title="Priority Type", Values={"Closest","LowHealth","HighHealth","Random"}, Default=1, Callback=function(v) Settings.aimbotPriority=v end})
aimSec:AddToggle("randomPartToggle", {Title="Random Hit Part", Default=Settings.aimbotRandomPart, Callback=function(v) Settings.aimbotRandomPart=v end})
aimSec:AddSlider("headChanceSlider", {Title="Head Chance (%)", Min=0, Max=100, Default=Settings.aimbotHeadChance, Rounding=0, Callback=function(v) Settings.aimbotHeadChance=v end})
aimSec:AddToggle("stayOnTargetToggle", {Title="Stay on target after kill", Default=Settings.aimbotStayOnTarget, Callback=function(v) Settings.aimbotStayOnTarget=v end})
aimSec:AddButton({Title="Add to Whitelist", Callback=function()
    local target = getTargetFromCam()
    if target then _G.FazetaWhitelist = _G.FazetaWhitelist or {}; _G.FazetaWhitelist[target.Name]=true; updateStatus("Whitelist + "..target.Name) else updateStatus("No target") end
end})

local trigSec = Tabs.Aimbot:AddSection("Triggerbot")
trigSec:AddToggle("triggerbotToggle", {Title="Triggerbot", Default=Settings.triggerbotEnabled, Callback=toggleTriggerbot})
trigSec:AddSlider("triggerDelaySlider", {Title="Delay (ms)", Min=50, Max=500, Default=Settings.currentTriggerDelay, Rounding=0, Callback=function(v) Settings.currentTriggerDelay=v end})

local rageSec = Tabs.Aimbot:AddSection("Rage Bot")
rageSec:AddToggle("rageBotToggle", {Title="Rage Bot (Master)", Default=Settings.rageBotEnabled, Callback=toggleRageBot})
rageSec:AddToggle("rageAimbotToggle", {Title="Aimbot (in Rage)", Default=Settings.rageAimbot, Callback=function(v) Settings.rageAimbot=v; if Settings.rageBotEnabled then applyRage() end end})
rageSec:AddToggle("rageTriggerbotToggle", {Title="Triggerbot (in Rage)", Default=Settings.rageTriggerbot, Callback=function(v) Settings.rageTriggerbot=v; if Settings.rageBotEnabled then applyRage() end end})
rageSec:AddToggle("rageWallPenToggle", {Title="Shoot through walls", Default=Settings.rageWallPen, Callback=function(v) Settings.rageWallPen=v; if Settings.rageBotEnabled then applyRage() end end})
rageSec:AddToggle("rageSwitchEmptyToggle", {Title="Switch to secondary on empty", Default=Settings.rageSwitchOnEmpty, Callback=function(v) Settings.rageSwitchOnEmpty=v end})
rageSec:AddSlider("rageShootDelaySlider", {Title="Shoot delay (ms)", Min=0, Max=1000, Default=Settings.rageShootDelay, Rounding=0, Callback=function(v) Settings.rageShootDelay=v end})
rageSec:AddDropdown("rageHitPartDropdown", {Title="Hit part", Values={"Head","Torso"}, Default=Settings.rageHitPart=="Head" and 1 or 2, Callback=function(v) Settings.rageHitPart=v end})

local specSec = Tabs.Aimbot:AddSection("Special Modes")
specSec:AddToggle("shotgunToggle", {Title="Shotgun Mode", Default=Settings.shotgunModeEnabled, Callback=function(v) Settings.shotgunModeEnabled=v end})
specSec:AddSlider("shotgunTPSlider", {Title="Shotgun TP Dist", Min=1, Max=10, Default=Settings.shotgunTPDistance, Rounding=1, Callback=function(v) Settings.shotgunTPDistance=v end})
specSec:AddToggle("daggerToggle", {Title="Dagger Mode", Default=Settings.daggerModeEnabled, Callback=function(v) Settings.daggerModeEnabled=v end})
specSec:AddSlider("daggerDistSlider", {Title="Parry Distance", Min=5, Max=30, Default=Settings.daggerParryDistance, Rounding=1, Callback=function(v) Settings.daggerParryDistance=v end})

-- Visuals Tab
local espSec = Tabs.Visuals:AddSection("ESP (Drawing)")
espSec:AddToggle("espToggle", {Title="Enable ESP", Default=Settings.espEnabled, Callback=toggleESP})
espSec:AddSlider("espDistSlider", {Title="Max Distance", Min=100, Max=5000, Default=Settings.espDistance, Rounding=0, Callback=function(v) Settings.espDistance=v end})
espSec:AddToggle("espBoxToggle", {Title="Show Box", Default=Settings.espBoxEnabled, Callback=function(v) Settings.espBoxEnabled=v end})
espSec:AddColorpicker("espBoxColor", {Title="Box Color", Default=Settings.espBoxColor, Callback=function(v) Settings.espBoxColor=v end})
espSec:AddSlider("espBoxThickness", {Title="Box Thickness", Min=1, Max=5, Default=Settings.espBoxThickness, Rounding=0, Callback=function(v) Settings.espBoxThickness=v end})
espSec:AddToggle("espNameToggle", {Title="Show Name", Default=Settings.espNameEnabled, Callback=function(v) Settings.espNameEnabled=v end})
espSec:AddColorpicker("espNameColor", {Title="Name Color", Default=Settings.espNameColor, Callback=function(v) Settings.espNameColor=v end})
espSec:AddToggle("espHealthToggle", {Title="Show Health", Default=Settings.espHealthEnabled, Callback=function(v) Settings.espHealthEnabled=v end})
espSec:AddToggle("espLevelToggle", {Title="Show Level", Default=Settings.espLevelEnabled, Callback=function(v) Settings.espLevelEnabled=v end})
espSec:AddToggle("espLevelColorByRank", {Title="Level Color by Rank", Default=Settings.espLevelColorByRank, Callback=function(v) Settings.espLevelColorByRank=v end})
espSec:AddColorpicker("espLevelColor", {Title="Level Color (static)", Default=Settings.espLevelColor, Callback=function(v) Settings.espLevelColor=v end})
espSec:AddToggle("espSkeletonToggle", {Title="Show Skeleton", Default=Settings.espSkeletonEnabled, Callback=function(v) Settings.espSkeletonEnabled=v end})
espSec:AddColorpicker("espSkeletonColor", {Title="Skeleton Color", Default=Settings.espSkeletonColor, Callback=function(v) Settings.espSkeletonColor=v end})

local hudSec = Tabs.Visuals:AddSection("HUD")
hudSec:AddToggle("hudToggle", {Title="Show HUD", Default=Settings.hudEnabled, Callback=function(v) Settings.hudEnabled=v end})

local effectsSec = Tabs.Visuals:AddSection("Effects")
effectsSec:AddToggle("noFlashToggle", {Title="No Flash", Default=Settings.noFlash, Callback=function(v) Settings.noFlash=v end})
effectsSec:AddToggle("noSmokeToggle", {Title="No Smoke", Default=Settings.noSmoke, Callback=function(v) Settings.noSmoke=v end})
effectsSec:AddToggle("noRecoilToggle", {Title="No Recoil", Default=Settings.noRecoil, Callback=function(v) Settings.noRecoil=v end})
effectsSec:AddToggle("noSpreadToggle", {Title="No Spread", Default=Settings.noSpread, Callback=function(v) Settings.noSpread=v end})

local fireSec = Tabs.Visuals:AddSection("Fire Control")
fireSec:AddButton({Title="Randomize Fire Colors", Callback=randomizeFireColors})

-- World Tab
local fogSec = Tabs.World:AddSection("Fog Control")
fogSec:AddToggle("fogToggle", {Title="Enable Fog", Default=Settings.fogEnabled, Callback=function(v) Settings.fogEnabled=v; applyFog() end})
fogSec:AddSlider("fogDensitySlider", {Title="Fog Density", Min=0, Max=1, Default=Settings.fogDensity, Rounding=2, Callback=function(v) Settings.fogDensity=v; applyFog() end})
fogSec:AddColorpicker("fogColorPicker", {Title="Fog Color", Default=Settings.fogColor, Callback=function(v) Settings.fogColor=v; applyFog() end})

local skySec = Tabs.World:AddSection("Sky (Custom)")
skySec:AddToggle("skyToggle", {Title="Custom Sky Color", Default=Settings.skyEnabled, Callback=function(v) Settings.skyEnabled=v; applySky() end})
skySec:AddColorpicker("skyColorPick", {Title="Sky Color", Default=Settings.skyColor, Callback=function(v) Settings.skyColor=v; if Settings.skyEnabled then applySky() end end})
skySec:AddButton({Title="Note: External images not supported", Callback=function() end})

local tracerSec = Tabs.World:AddSection("Tracers")
tracerSec:AddToggle("tracerToggle", {Title="Enable Tracers", Default=Settings.tracerEnabled, Callback=function(v) Settings.tracerEnabled=v end})
tracerSec:AddSlider("tracerLengthSlider", {Title="Length", Min=100, Max=1000, Default=Settings.tracerLength, Rounding=0, Callback=function(v) Settings.tracerLength=v end})
tracerSec:AddSlider("tracerDurationSlider", {Title="Duration (sec)", Min=0.1, Max=10, Default=Settings.tracerDuration, Precision=2, Rounding=2, Callback=function(v) Settings.tracerDuration=v end})
tracerSec:AddColorpicker("tracerColorPicker", {Title="Color", Default=Settings.tracerColor, Callback=function(v) Settings.tracerColor=v end})

-- Player Tab
local moveSec = Tabs.Player:AddSection("Movement")
moveSec:AddToggle("speedToggle", {Title="Speed", Default=Settings.speedEnabled, Callback=toggleSpeed})
moveSec:AddSlider("speedSlider", {Title="Walk Speed", Min=8, Max=120, Default=Settings.currentSpeed, Rounding=1, Callback=function(v) Settings.currentSpeed=v end})
moveSec:AddToggle("flyToggle", {Title="Fly", Default=Settings.isFlying, Callback=setFlightState})
moveSec:AddDropdown("flyModeDropdown", {Title="Fly Mode", Values={"V1","V2","V3"}, Default=Settings.flyMode=="V1" and 1 or Settings.flyMode=="V2" and 2 or 3, Callback=function(v) Settings.flyMode=v end})
moveSec:AddSlider("flySpeedSlider", {Title="Fly Speed V2/V3", Min=1, Max=1000, Default=Settings.flySpeedV2, Rounding=1, Callback=function(v) Settings.flySpeedV2=v end})
moveSec:AddToggle("noclipToggle", {Title="Noclip", Default=Settings.noclipEnabled, Callback=toggleNoclip})
moveSec:AddToggle("infJumpToggle", {Title="Infinite Jump", Default=Settings.infJumpEnabled, Callback=toggleInfJump})

local slideSec = Tabs.Player:AddSection("Slide Boost")
slideSec:AddToggle("slideToggle", {Title="Slide Boost", Default=Settings.slideBoostEnabled, Callback=function(v) Settings.slideBoostEnabled=v end})
slideSec:AddSlider("slidePower", {Title="Boost Power (1-10)", Min=1, Max=10, Default=Settings.slideBoostPower, Rounding=0, Callback=function(v) Settings.slideBoostPower=v end})

local jumpSec = Tabs.Player:AddSection("Jump Settings")
jumpSec:AddSlider("infJumpPowerSlider", {Title="Jump Power", Min=10, Max=200, Default=Settings.infJumpPower, Rounding=0, Callback=function(v) Settings.infJumpPower=v end})

local cameraSec = Tabs.Player:AddSection("Camera")
cameraSec:AddToggle("fovToggle", {Title="Custom FOV", Default=Settings.fovEnabled, Callback=function(v) Settings.fovEnabled=v; if not v and Camera then Camera.FieldOfView=70 end end})
cameraSec:AddSlider("fovSlider", {Title="FOV Value (max 120)", Min=30, Max=120, Default=Settings.customFOV, Rounding=0, Callback=function(v) Settings.customFOV=math.clamp(v,30,120); if Settings.fovEnabled and Camera then Camera.FieldOfView=Settings.customFOV end end})

-- Teleport Tab
local tpSec = Tabs.Teleport:AddSection("Auto Teleport")
tpSec:AddToggle("tpToggle", {Title="Auto TP", Default=Settings.tpEnabled, Callback=toggleTP})
tpSec:AddSlider("tpDistanceSlider", {Title="Distance", Min=1, Max=10, Default=Settings.tpDistance, Rounding=1, Callback=function(v) Settings.tpDistance=v end})
tpSec:AddDropdown("tpPositionDropdown", {Title="Position", Values={"Front","Back","Up","Down"}, Default=1, Callback=function(v) Settings.tpPosition=v end})

local upSec = Tabs.Teleport:AddSection("Vertical")
upSec:AddButton({Title="TP 1000 Up", Callback=teleportUp})
upSec:AddToggle("constantUpToggle", {Title="Constant TP Up", Default=Settings.constantTpUp, Callback=toggleConstantUp})

local randSec = Tabs.Teleport:AddSection("Random TP")
randSec:AddToggle("randomTPToggle", {Title="Random TP (around self)", Default=randomTPActive, Callback=toggleRandomTP})
randSec:AddSlider("randomRadius", {Title="Max Radius", Min=10, Max=200, Default=Settings.randomTpRadius, Rounding=0, Callback=function(v) Settings.randomTpRadius=v end})

-- Misc Tab
local autorunSec = Tabs.Misc:AddSection("AutoRun")
autorunSec:AddToggle("autoRunToggle", {Title="AutoRun", Description="Enable all main features", Default=Settings.autoRunEnabled, Callback=function(state)
    Settings.autoRunEnabled = state
    if state then
        if not Settings.aimbotEnabled then toggleAimbot(true) end
        if not Settings.triggerbotEnabled then toggleTriggerbot(true) end
        if not Settings.espEnabled then toggleESP(true) end
        if not Settings.speedEnabled then toggleSpeed(true) end
        if not Settings.isFlying then setFlightState(true) end
        if not Settings.noclipEnabled then toggleNoclip(true) end
        if not Settings.infJumpEnabled then toggleInfJump(true) end
        updateStatus("AutoRun ON")
    else
        if Settings.aimbotEnabled then toggleAimbot(false) end
        if Settings.triggerbotEnabled then toggleTriggerbot(false) end
        if Settings.espEnabled then toggleESP(false) end
        if Settings.speedEnabled then toggleSpeed(false) end
        if Settings.isFlying then setFlightState(false) end
        if Settings.noclipEnabled then toggleNoclip(false) end
        if Settings.infJumpEnabled then toggleInfJump(false) end
        updateStatus("AutoRun OFF")
    end
end})

local rpgSec = Tabs.Misc:AddSection("RPG Protection")
rpgSec:AddToggle("rpgBlockToggle", {Title="Block RPG Zone", Default=Settings.rpgBlockEnabled, Callback=function(v) Settings.rpgBlockEnabled=v; RPG_Block.Enabled=v end})
rpgSec:AddSlider("rpgZoneSizeSlider", {Title="Zone Size", Min=5, Max=25, Default=Settings.rpgBlockSize, Rounding=1, Callback=function(v) Settings.rpgBlockSize=v; RPG_Block.ZoneSize=v end})

-- Skin Changer
local skinSec = Tabs.Misc:AddSection("Skin Changer")
local weaponDropdown = skinSec:AddDropdown("weaponDropdown", {Title="Weapon", Values=weaponNames, Default=1})
local wrapDropdown = skinSec:AddDropdown("wrapDropdown", {Title="Wrap Texture", Values=filteredWraps, Default=#filteredWraps>0 and 1 or nil})
local materialDropdown = skinSec:AddDropdown("materialDropdown", {Title="Material", Values=materialList, Default=1})
local wrapMaterialDropdown = skinSec:AddDropdown("wrapMaterialDropdown", {Title="Wrap Material", Values=wrapVariantList, Default=#wrapVariantList>0 and 1 or nil})
local colorPicker = skinSec:AddColorpicker("skinColorPicker", {Title="Color", Transparency=0, Default=Color3.fromRGB(255,255,255)})
local reflectanceSlider = skinSec:AddSlider("reflectanceSlider", {Title="Reflectance", Min=0, Max=1, Default=0, Rounding=2})
local applyAllToggle = skinSec:AddToggle("applyAllToggle", {Title="Apply to all weapons", Default=false})
local useColorToggle = skinSec:AddToggle("useColorToggle", {Title="Apply Color", Default=false})
local useMaterialToggle = skinSec:AddToggle("useMaterialToggle", {Title="Apply Material", Default=false})
local useWrapTextureToggle = skinSec:AddToggle("useWrapTextureToggle", {Title="Apply Wrap", Default=false})
local useWrapMaterialToggle = skinSec:AddToggle("useWrapMaterialToggle", {Title="Use Wrap Material", Default=false})
local useTransparencyToggle = skinSec:AddToggle("useTransparencyToggle", {Title="Apply Transparency", Default=false})
local function applySkin()
    applyWeaponSkin(weaponDropdown.Value, colorPicker.Value, 1-colorPicker.Alpha, Enum.Material[materialDropdown.Value], wrapDropdown.Value, wrapMaterialNames[wrapMaterialDropdown.Value], reflectanceSlider.Value, useColorToggle.Value, useTransparencyToggle.Value, useMaterialToggle.Value, useWrapTextureToggle.Value, useWrapMaterialToggle.Value, applyAllToggle.Value)
end
skinSec:AddButton({Title="Apply Skin", Callback=applySkin})
skinSec:AddButton({Title="Randomize", Callback=function()
    colorPicker:SetValue(Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)))
    reflectanceSlider:SetValue(math.random())
    materialDropdown:SetValue(materialList[math.random(#materialList)])
    if #filteredWraps>0 then wrapDropdown:SetValue(filteredWraps[math.random(#filteredWraps)]) end
    if #wrapVariantList>0 then wrapMaterialDropdown:SetValue(wrapVariantList[math.random(#wrapVariantList)]) end
    applySkin()
end})
skinSec:AddButton({Title="Remove Effects", Callback=function()
    local sel = weaponDropdown.Value
    for _,model in ipairs(weaponModels) do
        if model.Name == sel then
            for _,part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Material = Enum.Material.SmoothPlastic
                    part.MaterialVariant = ""
                    part.Reflectance = 0
                    for _,child in ipairs(part:GetChildren()) do
                        if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then child:Destroy() end
                    end
                end
            end
        end
    end
end})

-- Settings Tab
local setSec = Tabs.Settings:AddSection("General")
setSec:AddButton({Title="Reset All Settings", Callback=function()
    for k,v in pairs(Settings) do
        if type(v) == "boolean" then Settings[k] = false
        elseif type(v) == "number" then Settings[k] = 0
        elseif type(v) == "string" then Settings[k] = ""
        end
    end
    updateStatus("Настройки сброшены")
end})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetFolder("FazZzetaRivals")
InterfaceManager:SetFolder("FazZzetaRivals")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

local windowVisible = true
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        windowVisible = not windowVisible
        Window:SetVisible(windowVisible)
    end
end)

-- ==================== ОБРАБОТЧИК РЕСПАВНА ====================
player.CharacterAdded:Connect(function(newChar)
    setFlightState(false)
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    removeSpeed()
    speedController = nil

    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    task.wait(0.5)

    if Settings.speedEnabled then applySpeedState() end
    if Settings.noclipEnabled then applyNoclip(true) end
    if Settings.isFlying then setFlightState(true) end
    if Settings.aimbotEnabled then startAimbot() end
    if Settings.triggerbotEnabled then startTriggerbot() end
    if Settings.tpEnabled then startTP() end
    if randomTPActive then toggleRandomTP(true) end
    if Settings.constantTpUp then toggleConstantUp(true) end
end)

UserInputService.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.P then
        if aimbotConnection then aimbotConnection:Disconnect() end
        if cameraConnection then cameraConnection:Disconnect() end
        if triggerbotConnection then triggerbotConnection:Disconnect() end
        if tpConnection then tpConnection:Disconnect() end
        if randomTPConnection then randomTPConnection:Disconnect() end
        if constantUpConnection then constantUpConnection:Disconnect() end
        removeSpeed()
        if bodyVelocity then bodyVelocity:Destroy() end
        updateStatus("Экстренное отключение")
        script:Destroy()
    end
end)

if Settings.autoRunEnabled then
    task.wait(2)
    if not Settings.aimbotEnabled then toggleAimbot(true) end
    if not Settings.triggerbotEnabled then toggleTriggerbot(true) end
    if not Settings.espEnabled then toggleESP(true) end
    if not Settings.speedEnabled then toggleSpeed(true) end
    if not Settings.isFlying then setFlightState(true) end
    if not Settings.noclipEnabled then toggleNoclip(true) end
    if not Settings.infJumpEnabled then toggleInfJump(true) end
    updateStatus("AutoRun activated")
end

updateStatus("FazZzeta Rivals v2.1 loaded. иди нахуй чмо и скажи спасибо что я не обленился")
