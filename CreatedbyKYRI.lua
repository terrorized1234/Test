local KyriLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Justanewplayer19/KyriLib/refs/heads/main/source.lua"))()

loadstring(game:HttpGet("https://raw.githubusercontent.com/loading123599/Phantom-Hub-V1.1/refs/heads/main/nametags.lua"))()

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local TeleportService = game:GetService('TeleportService')
local Player = Players.LocalPlayer
local camera = workspace.CurrentCamera
workspace.FallenPartsDestroyHeight = 0 / 0

local window = KyriLib.new("Phantom Hub", {
    GameName = "Mic Up"
})

local home = window:tab("Home", "house")
local player = window:tab("Player", "user")
local teleport = window:tab("Teleport", "map")
local utilities = window:tab("Utilities", "plus")
local spy = window:tab("Spy", "eye")
local trolling = window:tab("Trolling", "skull")

home:label("main features")

home:button("Load Nametags", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/loading123599/Phantom-Hub-V1.1/refs/heads/main/nametags.lua"))()
    window:notify("Success", "Nametags loaded", 2)
end)

home:button("Load Anti Void", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/terrorized1234/Test/refs/heads/main/antivoid.lua"))()
    window:notify("Success", "AntiVoid loaded", 2)
end)

local AntiBangEnabled = false
local IsVoiding = false

home:toggle("Anti-Bang / HeadSit", false, function(state)
    AntiBangEnabled = state
end, "antibang")

task.spawn(function()
    while true do
        if AntiBangEnabled then
            pcall(function()
                local char = Player.Character
                local hum = char and char:FindFirstChildWhichIsA('Humanoid')
                local root = char and char:FindFirstChild('HumanoidRootPart')
                local head = char and char:FindFirstChild('Head')

                local function IsPlayerSittingOnHead()
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= Player and p.Character then
                            local h = p.Character:FindFirstChildWhichIsA('Humanoid')
                            local r = p.Character:FindFirstChild('HumanoidRootPart')
                            if h and r and h:GetState() == Enum.HumanoidStateType.Seated and head and (r.Position - head.Position).Magnitude <= 3.5 then
                                return p
                            end
                        end
                    end
                    return nil
                end

                local function IsUsingBangAnimation()
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= Player and p.Character then
                            local h = p.Character:FindFirstChildWhichIsA('Humanoid')
                            local r = p.Character:FindFirstChild('HumanoidRootPart')
                            if h and r and root and (root.Position - r.Position).Magnitude <= 2 then
                                for _, track in ipairs(h:GetPlayingAnimationTracks()) do
                                    local id = track.Animation and track.Animation.AnimationId
                                    if id and (id:find('148840371') or id:find('5918726674')) then
                                        return p
                                    end
                                end
                            end
                        end
                    end
                    return nil
                end

                if hum and root and head and not IsVoiding then
                    local offender = IsPlayerSittingOnHead() or IsUsingBangAnimation()
                    if offender and offender.Character then
                        IsVoiding = true
                        local hum2 = offender.Character:FindFirstChildWhichIsA('Humanoid')
                        if hum2 then
                            hum2.Health = 0
                        end

                        pcall(function()
                            workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
                            root.CFrame = root.CFrame + Vector3.new(0, -1000, 0)
                            task.wait(0.1)
                            root.CFrame = root.CFrame + Vector3.new(0, 1000, 0)
                            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                        end)

                        IsVoiding = false
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

local isEnabled = false
local isHoldingZ = false
local thrustSpeed = 4

local function getNearestPlayer()
    local closest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild('HumanoidRootPart') then
            local char = Player.Character
            local root = char and char:FindFirstChild('HumanoidRootPart')
            if root then
                local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = p
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not isEnabled or not isHoldingZ then return end

    pcall(function()
        local char = Player.Character
        local humanoid = char and char:FindFirstChildWhichIsA('Humanoid')
        local root = char and char:FindFirstChild('HumanoidRootPart')

        if not (humanoid and root) then return end

        local target = getNearestPlayer()
        if not target or not target.Character then return end

        local targetHead = target.Character:FindFirstChild('Head')
        if not targetHead then return end

        humanoid.PlatformStand = true
        root.Velocity = Vector3.zero

        local oscillation = math.sin(tick() * thrustSpeed) * 0.4
        local offset = CFrame.new(0, 1.5, -0.8 + oscillation)
        local faceForward = CFrame.Angles(0, math.rad(180), 0)
        root.CFrame = targetHead.CFrame * offset * faceForward
    end)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Z and isEnabled then
        isHoldingZ = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Z then
        isHoldingZ = false
        local char = Player.Character
        local humanoid = char and char:FindFirstChildWhichIsA('Humanoid')
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end)

home:toggle("Enable FaceFuck (Hold Z)", false, function(state)
    isEnabled = state
    if not state then
        isHoldingZ = false
        local char = Player.Character
        local humanoid = char and char:FindFirstChildWhichIsA('Humanoid')
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end, "facefuck")

home:slider("Thrust Speed", 1, 10, 4, function(value)
    thrustSpeed = value
end, "thrustspeed")

home:label("anti-afk")

local AntiAFKEnabled = false
local AntiAFKConnection = nil
local LastMovement = tick()

home:toggle("Anti-AFK", false, function(state)
    AntiAFKEnabled = state

    if AntiAFKEnabled then
        AntiAFKConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                local char = Player.Character
                local humanoid = char and char:FindFirstChildWhichIsA('Humanoid')
                local root = char and char:FindFirstChild('HumanoidRootPart')

                if humanoid and root then
                    if tick() - LastMovement >= 30 then
                        local currentPos = root.CFrame
                        root.CFrame = currentPos * CFrame.new(0.1, 0, 0)
                        task.wait(0.1)
                        root.CFrame = currentPos

                        game:GetService('VirtualUser'):CaptureController()
                        game:GetService('VirtualUser'):ClickButton2(Vector2.new())

                        local cam = workspace.CurrentCamera
                        if cam then
                            local currentCFrame = cam.CFrame
                            cam.CFrame = currentCFrame * CFrame.Angles(0, math.rad(0.1), 0)
                            task.wait(0.1)
                            cam.CFrame = currentCFrame
                        end

                        LastMovement = tick()
                    end
                end
            end)
        end)
    else
        if AntiAFKConnection then
            AntiAFKConnection:Disconnect()
            AntiAFKConnection = nil
        end
    end
end, "antiafk")

task.spawn(function()
    while true do
        pcall(function()
            local char = Player.Character
            local humanoid = char and char:FindFirstChildWhichIsA('Humanoid')

            if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                LastMovement = tick()
            end
        end)
        task.wait(1)
    end
end)

player:label("character mods")

player:slider("WalkSpeed", 16, 200, 16, function(value)
    local char = Player.Character
    local humanoid = char and char:FindFirstChildWhichIsA('Humanoid')
    if humanoid then
        humanoid.WalkSpeed = value
    end
end, "walkspeed")

player:slider("JumpPower", 50, 300, 50, function(value)
    local char = Player.Character
    local humanoid = char and char:FindFirstChildWhichIsA('Humanoid')
    if humanoid then
        humanoid.JumpPower = value
    end
end, "jumppower")

player:button("Superman Fly", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Justanewplayer19/AngelHubScript/refs/heads/main/SupermanFly.lua'))()
    window:notify("Success", "Superman fly loaded", 2)
end)

player:button("Reset Speed/Jump", function()
    local char = Player.Character
    local humanoid = char and char:FindFirstChildWhichIsA('Humanoid')
    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
    window:notify("Reset", "Stats reset to default", 2)
end)

player:button("PermDeath", function()
    pcall(function()
        local char = Player.Character
        local humanoid = char and char:FindFirstChildWhichIsA('Humanoid')
        if humanoid then
            humanoid:ChangeState(15)
            window:notify("PermDeath", "Character permdeathed", 2)
        end
    end)
end)

teleport:label("quick teleports")

teleport:button("Teleport to Nearest", function()
    local nearest = getNearestPlayer()
    if nearest and nearest.Character and nearest.Character:FindFirstChild('HumanoidRootPart') then
        local char = Player.Character
        local root = char and char:FindFirstChild('HumanoidRootPart')
        if root then
            root.CFrame = nearest.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
            window:notify("Teleport", "Teleported to " .. nearest.Name, 2)
        end
    end
end)

teleport:button("Teleport Up (+50)", function()
    local char = Player.Character
    local root = char and char:FindFirstChild('HumanoidRootPart')
    if root then
        root.CFrame = root.CFrame + Vector3.new(0, 50, 0)
    end
end)

teleport:button("Teleport Down (-50)", function()
    local char = Player.Character
    local root = char and char:FindFirstChild('HumanoidRootPart')
    if root then
        root.CFrame = root.CFrame - Vector3.new(0, 50, 0)
    end
end)

teleport:button("Get Current Position", function()
    local char = Player.Character
    local root = char and char:FindFirstChild('HumanoidRootPart')
    if root then
        local pos = root.Position
        window:notify("Position", string.format("X=%.1f, Y=%.1f, Z=%.1f", pos.X, pos.Y, pos.Z), 5)
    end
end)

teleport:label("game locations")

local locations = {
    ["School Lockers"] = Vector3.new(411.2, 37.9, 62.9),
    ["Classroom"] = Vector3.new(415.0, 37.7, 63.7),
    ["Stage"] = Vector3.new(433.2, 43.2, -5.6),
    ["Campfire"] = Vector3.new(378.5, 40.2, -190.8),
    ["Playground"] = Vector3.new(653.2, 38.5, 103.3),
    ["Soccer Arena"] = Vector3.new(570.5, 37.4, 146.8),
    ["Skybase Top"] = Vector3.new(724.8, 933.8, -183.3),
    ["Donut Shop"] = Vector3.new(759.2, 30.3, 86.9),
    ["Bathrooms"] = Vector3.new(728.0, 29.2, 114.4),
    ["Booth 1"] = Vector3.new(521.2, 21.0, -163.4),
    ["Booth 2"] = Vector3.new(552.0, 21.0, -164.7),
    ["Booth 3"] = Vector3.new(583.4, 21.0, -164.7),
    ["Rating Place"] = Vector3.new(401.9, 40.7, 119.1),
    ["Swings"] = Vector3.new(654.9, 21.2, 129.6),
    ["Merry-Go-Round"] = Vector3.new(650.2, 21.2, 98.8),
}

local locationOptions = {}
for name, _ in pairs(locations) do
    table.insert(locationOptions, name)
end

teleport:dropdown("Select Location", locationOptions, "School Lockers", function(selected)
    if locations[selected] then
        local char = Player.Character
        local root = char and char:FindFirstChild('HumanoidRootPart')
        if root then
            root.CFrame = CFrame.new(locations[selected])
            window:notify("Teleport", "Teleported to " .. selected, 2)
        end
    end
end)

utilities:label("external scripts")

utilities:button("Infinite Yield", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    window:notify("Success", "Infinite Yield loaded", 2)
end)

utilities:button("System Broken", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/script'))()
    window:notify("Success", "System Broken loaded", 2)
end)

utilities:button("Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, Player)
end)

utilities:toggle("Infinite Zoom Out", false, function(state)
    if state then
        Player.CameraMaxZoomDistance = 100000
        Player.CameraMinZoomDistance = 0.1
    else
        Player.CameraMaxZoomDistance = 128
        Player.CameraMinZoomDistance = 0.1
    end
end, "infinitezoom")

spy:label("spectate mode")

local isSpyMode = false
local currentTargetIndex = 1
local spectateTargets = {}
local originalCameraSubject = nil
local originalCameraType = nil

local function updateSpectateTargets()
    spectateTargets = {}
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") then
            table.insert(spectateTargets, otherPlayer)
        end
    end
end

local function startSpyMode()
    updateSpectateTargets()

    if #spectateTargets == 0 then
        window:notify("Spy Mode", "No players to spectate", 2)
        return false
    end

    isSpyMode = true
    originalCameraSubject = camera.CameraSubject
    originalCameraType = camera.CameraType

    local currentTarget = spectateTargets[currentTargetIndex]
    if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = currentTarget.Character.Humanoid
        camera.CameraType = Enum.CameraType.Custom
        window:notify("Spy Mode", "Spectating " .. currentTarget.Name, 2)
    end

    return true
end

local function stopSpyMode()
    isSpyMode = false
    camera.CameraSubject = originalCameraSubject
    camera.CameraType = originalCameraType
    window:notify("Spy Mode", "Stopped spectating", 2)
end

local function switchTarget(direction)
    if not isSpyMode or #spectateTargets == 0 then return end

    currentTargetIndex = currentTargetIndex + direction

    if currentTargetIndex > #spectateTargets then
        currentTargetIndex = 1
    elseif currentTargetIndex < 1 then
        currentTargetIndex = #spectateTargets
    end

    local currentTarget = spectateTargets[currentTargetIndex]
    if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = currentTarget.Character.Humanoid
        window:notify("Spy Mode", "Now spectating " .. currentTarget.Name, 1)
    end
end

spy:toggle("Activate Spy Mode", false, function(state)
    if state then
        startSpyMode()
    else
        stopSpyMode()
    end
end, "spymode")

spy:button("Previous Player (Q)", function()
    switchTarget(-1)
end)

spy:button("Next Player (E)", function()
    switchTarget(1)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Q then
        switchTarget(-1)
    elseif input.KeyCode == Enum.KeyCode.E then
        switchTarget(1)
    end
end)

spy:label("security cameras")

local isCameraMode = false
local originalCameraMode = nil
local currentCameraPosition = nil
local cameraRotationX = 0
local cameraRotationY = 0

local cameraPositions = {
    ["School Lockers"] = Vector3.new(411.2, 37.9, 62.9),
    ["Classroom"] = Vector3.new(415.0, 37.7, 63.7),
    ["Stage"] = Vector3.new(433.2, 43.2, -5.6),
    ["Campfire"] = Vector3.new(378.5, 40.2, -190.8),
    ["Playground"] = Vector3.new(653.2, 38.5, 103.3),
    ["Skybase Top"] = Vector3.new(724.8, 933.8, -183.3),
}

local function activateCamera(position, name)
    if isSpyMode then
        stopSpyMode()
    end

    isCameraMode = true
    currentCameraPosition = position
    originalCameraMode = camera.CameraType
    originalCameraSubject = camera.CameraSubject

    cameraRotationX = 0
    cameraRotationY = 0

    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.new(position)

    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    window:notify("Camera", name .. " camera activated. Press X to exit", 3)
end

local function exitCamera()
    isCameraMode = false
    currentCameraPosition = nil
    cameraRotationX = 0
    cameraRotationY = 0

    camera.CameraType = originalCameraMode or Enum.CameraType.Custom
    camera.CameraSubject = originalCameraSubject or (Player.Character and Player.Character:FindFirstChild("Humanoid"))

    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    window:notify("Camera", "Camera exited", 2)
end

UserInputService.InputChanged:Connect(function(input)
    if not isCameraMode or not currentCameraPosition then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Delta
        local sensitivity = 0.3

        cameraRotationY = cameraRotationY - math.rad(delta.X * sensitivity)
        cameraRotationX = cameraRotationX - math.rad(delta.Y * sensitivity)

        cameraRotationX = math.clamp(cameraRotationX, -math.rad(89), math.rad(89))

        local newCFrame = CFrame.new(currentCameraPosition) * 
                         CFrame.Angles(0, cameraRotationY, 0) * 
                         CFrame.Angles(cameraRotationX, 0, 0)

        camera.CFrame = newCFrame
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.X and isCameraMode then
        exitCamera()
    end
end)

spy:button("Exit Camera (X)", function()
    if isCameraMode then
        exitCamera()
    end
end)

local cameraOptions = {}
for name, _ in pairs(cameraPositions) do
    table.insert(cameraOptions, name)
end

spy:dropdown("Select Camera", cameraOptions, "School Lockers", function(selected)
    if cameraPositions[selected] then
        activateCamera(cameraPositions[selected], selected)
    end
end)

trolling:label("trolling features")

local function createPlatform()
    local platform = Instance.new("Part")
    platform.Name = "infbaseplate"
    platform.Anchored = true
    platform.Size = Vector3.new(9000, 5, 9000)
    platform.Position = Vector3.new(400, 10, 5)
    platform.Transparency = 0.5
    platform.BrickColor = BrickColor.new("Really black")
    platform.Material = Enum.Material.SmoothPlastic
    platform.Parent = workspace
end

createPlatform()

local followConnection = nil
local targetToFollow = nil

local function followPlayer(target)
    if followConnection then
        followConnection:Disconnect()
    end

    followConnection = RunService.RenderStepped:Connect(function()
        pcall(function()
            local char = Player.Character
            local targetChar = target.Character
            if not char or not targetChar then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")

            if hrp and humanoid and targetHRP then
                humanoid.Sit = false
                humanoid:ChangeState(11)
                hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
            end
        end)
    end)

    window:notify("Follow", "Following " .. target.Name, 2)
end

local function stopFollowing()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end

    local char = Player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end

    window:notify("Follow", "Stopped following", 2)
end

trolling:button("Follow Nearest Player", function()
    local nearest = getNearestPlayer()
    if nearest then
        targetToFollow = nearest
        followPlayer(nearest)
    end
end)

trolling:button("Stop Following", function()
    stopFollowing()
end)

trolling:label("follow specific player")

local playerOptions = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= Player then
        table.insert(playerOptions, p.Name)
    end
end

if #playerOptions > 0 then
    trolling:dropdown("Select Player", playerOptions, playerOptions[1], function(selected)
        local target = Players:FindFirstChild(selected)
        if target then
            followPlayer(target)
        end
    end)
end

Players.PlayerAdded:Connect(function()
    if isSpyMode then
        updateSpectateTargets()
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if isSpyMode then
        updateSpectateTargets()

        if #spectateTargets == 0 then
            stopSpyMode()
        elseif currentTargetIndex > #spectateTargets then
            currentTargetIndex = 1
            local currentTarget = spectateTargets[currentTargetIndex]
            if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = currentTarget.Character.Humanoid
            end
        end
    end
end)

Player.CharacterAdded:Connect(function()
    if isSpyMode then
        wait(1)
        stopSpyMode()
    end
    if isCameraMode then
        wait(1)
        exitCamera()
    end
end)

window:notify("Phantom Hub", "Script loaded successfully", 3)
