local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")

local Player = Players.LocalPlayer
local ChatWhitelist = {}
local charAddedConnections = {}
local chatConnections = {}
local localTagChoice = nil

local CONFIG = {
    TAG_SIZE = UDim2.new(0, 0, 0, 32),
    TAG_OFFSET = Vector3.new(0, 2.0, 0),
    MAX_DISTANCE = 200000,
    DISTANCE_THRESHOLD = 50,
    HYSTERESIS = 5,
    CORNER_RADIUS = UDim.new(0, 10),
    PARTICLE_COUNT = 20,
    PARTICLE_SPEED = 2,
    TELEPORT_DISTANCE = 5,
    TELEPORT_HEIGHT = 0.5,
}

local RankData = {
    ["Kyri"] = {
        primary = Color3.fromRGB(0, 0, 0),
        accent = Color3.fromRGB(255, 105, 180),
        iconType = "Custom",
        customImageUrl =
        "https://raw.githubusercontent.com/Justanewplayer19/rizzyv2/refs/heads/main/15361-mocha-heart.png"
    },
    ["Alex"] = {
        primary = Color3.fromRGB(0, 0, 0),
        accent = Color3.fromRGB(52, 235, 235),
        iconType = "Custom",
        customImageUrl =
        "https://raw.githubusercontent.com/Justanewplayer19/rizzyv2/refs/heads/main/alexthingy-removebg-preview.png"
    },
    ["Server Booster"] = {
        primary = Color3.fromRGB(0, 0, 0),
        accent = Color3.fromRGB(255, 115, 250),
        emoji = "🚀",
        iconType = "Emoji"
    },
    ["Kyri's Wife"] = {
        primary = Color3.fromRGB(0, 0, 0),
        accent = Color3.fromRGB(255, 182, 193),
        emoji = "💗",
        iconType = "Emoji"
    },
    ["Alex's Wife"] = {
        primary = Color3.fromRGB(0, 0, 0),
        accent = Color3.fromRGB(173, 231, 255),
        emoji = "💙",
        iconType = "Emoji"
    },
    ["User"] = {
        primary = Color3.fromRGB(0, 0, 0),
        accent = Color3.fromRGB(138, 43, 226),
        iconType = "Custom",
        customImageUrl = "https://raw.githubusercontent.com/Justanewplayer19/rizzyv2/refs/heads/main/user.png"
    },
    ["AK User"] = {
        primary = Color3.fromRGB(0, 0, 0),
        accent = Color3.fromRGB(0, 149, 255),
        iconType = "Custom",
        customImageUrl = "https://raw.githubusercontent.com/Justanewplayer19/rizzyv2/refs/heads/main/akadmin.png"
    }
}

local Kyri = { "GoodHelper12345" }
local Alex = { "nither114" }
local ServerBoosters = { "" }
local KyrisWife = { "" }
local AlexsWife = { "" }

local vividHubMessage = "!"
local akAdminMessage = ""

local function downloadCustomImage(url, fileName)
    if not isfolder("VividHub") then
        makefolder("VividHub")
    end

    local imagePath = "VividHub/" .. fileName

    if not isfile(imagePath) then
        local success, imageData = pcall(function()
            return game:HttpGet(url)
        end)

        if success then
            local writeSuccess = pcall(function()
                writefile(imagePath, imageData)
            end)
            if writeSuccess then
                return true
            end
        end
        return false
    end
    return true
end

local function getCustomImageAsset(fileName)
    local imagePath = "VividHub/" .. fileName
    if isfile(imagePath) then
        local success, asset = pcall(function()
            return getcustomasset(imagePath)
        end)
        if success then
            return asset
        end
    end
    return nil
end

local function containsIgnoreCase(tbl, name)
    if not name or type(name) ~= "string" then return false end
    name = name:lower()
    for _, v in ipairs(tbl) do
        if type(v) == "string" and v:lower() == name then
            return true
        end
    end
    return false
end

local function createParticles(tag, parent, accentColor)
    for i = 1, CONFIG.PARTICLE_COUNT do
        local particle = Instance.new("Frame")
        particle.Name = "Particle_" .. i
        particle.Size = UDim2.new(0, math.random(1, 6), 0, math.random(1, 6))
        particle.Position = UDim2.new(math.random(), math.random(-10, 10), 1 + math.random() * 0.5, 0)
        particle.BackgroundColor3 = accentColor
        particle.BackgroundTransparency = math.random(0, 0.4)
        particle.BorderSizePixel = 0
        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(1, 0)
        pCorner.Parent = particle
        particle.Parent = parent

        spawn(function()
            while tag and tag.Parent do
                local startX = math.random()
                local startOffsetX = math.random(-10, 10)
                particle.Position = UDim2.new(startX, startOffsetX, 1 + math.random() * 0.5, 0)
                particle.Size = UDim2.new(0, math.random(1, 6), 0, math.random(1, 6))
                particle.BackgroundTransparency = math.random(0, 0.4)

                local duration = math.random(10, 40) / (CONFIG.PARTICLE_SPEED * 10)
                local endX = startX + (math.random() - 0.5) * 0.3
                local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)

                local tween = TweenService:Create(particle, tweenInfo, {
                    Position = UDim2.new(endX, startOffsetX, -0.5, math.random(-20, 20)),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 0)
                })
                tween:Play()
                task.wait(math.random(20, 40) / (CONFIG.PARTICLE_SPEED * 10))
            end
        end)
    end
end

local function teleportToPlayer(targetPlayer)
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character
    local targetCharacter = targetPlayer.Character
    if not (character and targetCharacter) then return end

    local humanoid = character:FindFirstChild("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not (humanoid and hrp and targetHRP) then return end

    local targetCFrame = targetHRP.CFrame
    local teleportPosition = targetCFrame.Position - (targetCFrame.LookVector * CONFIG.TELEPORT_DISTANCE)
    teleportPosition = teleportPosition + Vector3.new(0, CONFIG.TELEPORT_HEIGHT, 0)

    local particlepart = Instance.new("Part", workspace)
    particlepart.Transparency = 1
    particlepart.Anchored = true
    particlepart.CanCollide = false
    particlepart.Position = hrp.Position

    local transmitter1 = Instance.new("ParticleEmitter")
    transmitter1.Texture = "http://www.roblox.com/asset/?id=241922778"
    transmitter1.Size = NumberSequence.new(4)
    transmitter1.Lifetime = NumberRange.new(0.15, 0.15)
    transmitter1.Rate = 100
    transmitter1.TimeScale = 0.25
    transmitter1.VelocityInheritance = 1
    transmitter1.Drag = 5
    transmitter1.Parent = particlepart

    local fadeTime = 0.1
    local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local meshParts = {}

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("MeshPart") then
            table.insert(meshParts, part)
        end
    end

    for _, part in ipairs(meshParts) do
        local tween = TweenService:Create(part, tweenInfo, { Transparency = 1 })
        tween:Play()
    end

    task.wait(fadeTime)
    hrp.CFrame = CFrame.new(teleportPosition, targetHRP.Position)

    local teleportSound = Instance.new("Sound")
    teleportSound.SoundId = "rbxassetid://5066021887"
    local head = character:FindFirstChild("Head")
    if head then
        teleportSound.Parent = head
    else
        teleportSound.Parent = hrp
    end
    teleportSound.Volume = 0.5
    teleportSound:Play()

    for _, part in ipairs(meshParts) do
        local tween = TweenService:Create(part, tweenInfo, { Transparency = 0 })
        tween:Play()
    end

    task.wait(1)
    particlepart:Destroy()
end

local function attachTagToHead(character, player, rankText)
    local head = character:FindFirstChild("Head")
    if not head then
        head = character:WaitForChild("Head", 1)
        if not head then return end
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end

    if Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui") then
        for _, child in ipairs(Players.LocalPlayer.PlayerGui:GetChildren()) do
            if child:IsA("BillboardGui") and child.Name == "RankTag" and child.Adornee == head then
                child:Destroy()
            end
        end
    end

    local rankData = RankData[rankText] or
        { primary = Color3.fromRGB(0, 0, 0), accent = Color3.fromRGB(138, 43, 226), emoji = "🌐", iconType = "Emoji" }
    local tag = Instance.new("BillboardGui")
    tag.Name = "RankTag"
    tag.Adornee = head
    tag.Size = CONFIG.TAG_SIZE
    tag.StudsOffset = CONFIG.TAG_OFFSET
    tag.AlwaysOnTop = true
    tag.MaxDistance = CONFIG.MAX_DISTANCE
    tag.LightInfluence = 0
    tag.ResetOnSpawn = false
    tag.Active = true

    local container = Instance.new("Frame")
    container.Name = "TagContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundColor3 = rankData.primary
    container.BackgroundTransparency = 0.15
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Parent = tag

    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = CONFIG.CORNER_RADIUS
    containerCorner.Parent = container

    local border = Instance.new("UIStroke")
    border.Color = rankData.accent
    border.Thickness = 2
    border.Transparency = 0.2
    border.Parent = container

    local clickButton = Instance.new("TextButton")
    clickButton.Name = "ClickButton"
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.ZIndex = 10
    clickButton.AutoButtonColor = false
    clickButton.Active = true
    clickButton.Parent = container

    if player ~= Players.LocalPlayer then
        clickButton.MouseButton1Click:Connect(function()
            teleportToPlayer(player)
        end)
        clickButton.MouseEnter:Connect(function()
            TweenService:Create(container, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
        end)
        clickButton.MouseLeave:Connect(function()
            TweenService:Create(container, TweenInfo.new(0.3), { BackgroundTransparency = 0.15 }):Play()
        end)
    end

    local particlesContainer = Instance.new("Frame")
    particlesContainer.Name = "ParticlesContainer"
    particlesContainer.Size = UDim2.new(1, 0, 1, 0)
    particlesContainer.BackgroundTransparency = 1
    particlesContainer.ZIndex = 2
    particlesContainer.ClipsDescendants = true
    particlesContainer.Parent = container
    local pContainerCorner = Instance.new("UICorner")
    pContainerCorner.CornerRadius = UDim.new(1, 0)
    pContainerCorner.Parent = particlesContainer
    createParticles(tag, particlesContainer, rankData.accent)

    local iconContainer
    if rankData.iconType == "Custom" and rankData.customImageUrl then
        local fileName = rankText:gsub("%s+", "_") .. ".png"
        downloadCustomImage(rankData.customImageUrl, fileName)

        iconContainer = Instance.new("ImageLabel")
        iconContainer.Name = "IconImage"
        iconContainer.Size = UDim2.new(0, 30, 0, 30)
        iconContainer.Position = UDim2.new(0, 8, 0.5, -15)
        iconContainer.BackgroundTransparency = 1
        iconContainer.ZIndex = 5
        iconContainer.ScaleType = Enum.ScaleType.Fit

        local customAsset = getCustomImageAsset(fileName)
        if customAsset then
            iconContainer.Image = customAsset
        else
            iconContainer.Image = ""
        end

        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0.2, 0)
        iconCorner.Parent = iconContainer

        iconContainer.Parent = container
    else
        iconContainer = Instance.new("TextLabel")
        iconContainer.Name = "EmojiLabel"
        iconContainer.Size = UDim2.new(0, 30, 0, 30)
        iconContainer.Position = UDim2.new(0, 8, 0.5, -15)
        iconContainer.BackgroundTransparency = 1
        iconContainer.Text = rankData.emoji
        iconContainer.TextSize = 22
        iconContainer.Font = Enum.Font.GothamBold
        iconContainer.TextColor3 = Color3.new(1, 1, 1)
        iconContainer.ZIndex = 5
        iconContainer.Parent = container
    end

    local displayNameLabel = Instance.new("TextLabel")
    displayNameLabel.Name = "DisplayNameLabel"
    displayNameLabel.BackgroundTransparency = 1
    local shortDisplayName = player.DisplayName or player.Name
    if #shortDisplayName > 14 then
        shortDisplayName = string.sub(shortDisplayName, 1, 14) .. "…"
    end
    displayNameLabel.Text = "@" .. shortDisplayName
    displayNameLabel.TextSize = 10
    displayNameLabel.Font = Enum.Font.GothamBold
    displayNameLabel.TextColor3 = rankData.accent
    displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    displayNameLabel.ZIndex = 5
    displayNameLabel.TextScaled = false

    local rankLabel = Instance.new("TextLabel")
    rankLabel.Name = "RankLabel"
    rankLabel.BackgroundTransparency = 1
    local shortRankText = rankText
    if #shortRankText > 16 then
        shortRankText = string.sub(shortRankText, 1, 16) .. "…"
    end
    rankLabel.Text = shortRankText
    rankLabel.TextSize = 14
    rankLabel.Font = Enum.Font.GothamBold
    rankLabel.TextColor3 = rankData.accent
    rankLabel.TextXAlignment = Enum.TextXAlignment.Left
    rankLabel.ZIndex = 5
    rankLabel.TextScaled = false

    local function getTextWidth(text, font, textSize)
        local textService = game:GetService("TextService")
        local result = textService:GetTextSize(text, textSize, font, Vector2.new(1000, 16))
        return result.X
    end

    local sidePadding = 16
    local iconWidth = 36
    local rankWidth = getTextWidth(rankLabel.Text, Enum.Font.GothamBold, 14)
    local displayWidth = getTextWidth(displayNameLabel.Text, Enum.Font.GothamBold, 10)
    local maxTextWidth = math.max(rankWidth, displayWidth)
    local totalWidth = iconWidth + maxTextWidth + (sidePadding * 2)

    tag.Size = UDim2.new(0, totalWidth, 0, CONFIG.TAG_SIZE.Y.Offset)
    container.Size = UDim2.new(1, 0, 1, 0)

    iconContainer.Position = UDim2.new(0, sidePadding, 0.5, -15)
    iconContainer.Size = UDim2.new(0, 30, 0, 30)

    if rankWidth > displayWidth then
        rankLabel.TextXAlignment = Enum.TextXAlignment.Left
        displayNameLabel.TextXAlignment = Enum.TextXAlignment.Center
    elseif displayWidth > rankWidth then
        rankLabel.TextXAlignment = Enum.TextXAlignment.Center
        displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    else
        rankLabel.TextXAlignment = Enum.TextXAlignment.Left
        displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    end

    rankLabel.Size = UDim2.new(1, -(iconWidth + sidePadding * 2), 0, 16)
    rankLabel.Position = UDim2.new(0, iconWidth + sidePadding, 0, 3)
    rankLabel.Parent = container

    displayNameLabel.Size = UDim2.new(1, -(iconWidth + sidePadding * 2), 0, 16)
    displayNameLabel.Position = UDim2.new(0, iconWidth + sidePadding, 0, 17)
    displayNameLabel.Parent = container

    local isMinimized = false
    local FULL_SIZE = UDim2.new(0, totalWidth, 0, CONFIG.TAG_SIZE.Y.Offset)
    local MINI_SIZE = UDim2.new(0, 40, 0, 40)
    local MINI_OFFSET = Vector3.new(0, 1.0, 0)
    local activeTween = true

    spawn(function()
        while activeTween do
            if character and head and head.Parent and Players.LocalPlayer and Players.LocalPlayer.Character then
                local localHead = Players.LocalPlayer.Character:FindFirstChild("Head")
                if localHead then
                    local distance = (head.Position - localHead.Position).Magnitude
                    if distance > (CONFIG.DISTANCE_THRESHOLD + CONFIG.HYSTERESIS) and not isMinimized then
                        isMinimized = true
                        TweenService:Create(tag, TweenInfo.new(0.5), { Size = MINI_SIZE, StudsOffset = MINI_OFFSET })
                            :Play()
                        TweenService:Create(rankLabel, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
                        TweenService:Create(displayNameLabel, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
                        if rankData.iconType == "Custom" then
                            TweenService:Create(iconContainer, TweenInfo.new(0.5),
                                { Position = UDim2.new(0.5, -15, 0.5, -15), Size = UDim2.new(0, 30, 0, 30), ImageTransparency = 0 })
                                :Play()
                        else
                            TweenService:Create(iconContainer, TweenInfo.new(0.5),
                                { Position = UDim2.new(0.5, -15, 0.5, -15), Size = UDim2.new(0, 30, 0, 30), TextSize = 26 })
                                :Play()
                        end
                        TweenService:Create(containerCorner, TweenInfo.new(0.5), { CornerRadius = UDim.new(1, 0) }):Play()
                    elseif distance < (CONFIG.DISTANCE_THRESHOLD - CONFIG.HYSTERESIS) and isMinimized then
                        isMinimized = false
                        TweenService:Create(tag, TweenInfo.new(0.5),
                            { Size = FULL_SIZE, StudsOffset = CONFIG.TAG_OFFSET }):Play()
                        TweenService:Create(rankLabel, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()
                        TweenService:Create(displayNameLabel, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()
                        if rankData.iconType == "Custom" then
                            TweenService:Create(iconContainer, TweenInfo.new(0.5),
                                { Position = UDim2.new(0, 8, 0.5, -15), Size = UDim2.new(0, 30, 0, 30), ImageTransparency = 0 })
                                :Play()
                        else
                            TweenService:Create(iconContainer, TweenInfo.new(0.5),
                                { Position = UDim2.new(0, 8, 0.5, -15), Size = UDim2.new(0, 30, 0, 30), TextSize = 22 })
                                :Play()
                        end
                        TweenService:Create(containerCorner, TweenInfo.new(0.5), { CornerRadius = CONFIG.CORNER_RADIUS })
                            :Play()
                    end
                end
            end
            task.wait(0.2)
        end
    end)

    tag.AncestryChanged:Connect(function(_, parent)
        if not parent then
            activeTween = false
        end
    end)

    tag.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    return tag
end

local function createNotificationUI()
    if game:GetService("CoreGui"):FindFirstChild("TagNotification") or localTagChoice ~= nil then
        return nil, nil, nil, nil
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "TagNotification"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Size = UDim2.new(0, 280, 0, 140)
    frame.Position = UDim2.new(0.5, -140, 0.5, -70)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = frame

    local blur = Instance.new("BlurEffect")
    blur.Size = 10
    blur.Parent = game:GetService("Lighting")

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 16
    title.Text = "Click yes for Tag"
    title.Parent = frame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(0.9, 0, 0, 40)
    messageLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    messageLabel.TextSize = 14
    messageLabel.TextWrapped = true
    messageLabel.Text = "Would you like to display tag"
    messageLabel.Parent = frame

    local function createButton(text, position, color)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.35, 0, 0, 30)
        button.Position = position
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Font = Enum.Font.GothamBold
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 14
        button.Text = text
        button.AutoButtonColor = false
        button.BackgroundTransparency = 0
        button.Parent = frame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), { BackgroundTransparency = 0.2 }):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
        end)
        return button
    end

    local yesButton = createButton("Yes", UDim2.new(0.1, 0, 0.7, 0), Color3.fromRGB(46, 204, 113))
    local noButton = createButton("No", UDim2.new(0.55, 0, 0.7, 0), Color3.fromRGB(231, 76, 60))
    return gui, yesButton, noButton, blur
end

local function createTag(player, rankText, showPrompt)
    if showPrompt and player == Players.LocalPlayer then
        if localTagChoice ~= nil then
            if localTagChoice then
                if player.Character then
                    attachTagToHead(player.Character, player, rankText)
                end
                if charAddedConnections[player] then charAddedConnections[player]:Disconnect() end
                charAddedConnections[player] = player.CharacterAdded:Connect(function(character)
                    task.wait()
                    attachTagToHead(character, player, rankText)
                end)
            end
            return
        end
        local gui, yesButton, noButton, blur = createNotificationUI()
        if not gui then return end
        local playerGui = player:WaitForChild("PlayerGui", 5)
        if not playerGui then
            if blur then blur:Destroy() end
            if gui then gui:Destroy() end
            return
        end
        gui.Parent = playerGui

        local clicked = false
        local function cleanup(choiceMade)
            if clicked then return end
            clicked = true
            localTagChoice = choiceMade
            gui:Destroy()
            if blur then
                blur:Destroy()
            end
        end

        yesButton.MouseButton1Click:Connect(function()
            cleanup(true)
            if player.Character then
                attachTagToHead(player.Character, player, rankText)
            end
            if charAddedConnections[player] then charAddedConnections[player]:Disconnect() end
            charAddedConnections[player] = player.CharacterAdded:Connect(function(character)
                task.wait()
                attachTagToHead(character, player, rankText)
            end)

            task.spawn(function()
                task.wait(0.5)
                local generalChannel = TextChatService:FindFirstChild("TextChannels")
                if generalChannel then
                    generalChannel = generalChannel:FindFirstChild("RBXGeneral")
                end

                if generalChannel and generalChannel:IsA("TextChannel") then
                    local success1, err1 = pcall(function()
                        generalChannel:SendAsync(vividHubMessage)
                    end)
                    if not success1 then
                        warn("failed to send vivid message")
                    end

                    task.wait(0.3)

                    local success2, err2 = pcall(function()
                        generalChannel:SendAsync(akAdminMessage)
                    end)
                    if not success2 then
                        warn("failed to send ak message")
                    end
                end
            end)
        end)

        noButton.MouseButton1Click:Connect(function()
            cleanup(false)
        end)
    else
        if player.Character then
            attachTagToHead(player.Character, player, rankText)
        end
        if charAddedConnections[player] then charAddedConnections[player]:Disconnect() end
        charAddedConnections[player] = player.CharacterAdded:Connect(function(character)
            task.wait()
            attachTagToHead(character, player, rankText)
        end)
    end
end

local function applyPlayerTag(player)
    if not player or not player:IsDescendantOf(Players) then
        return
    end
    local showPrompt = (player == Players.LocalPlayer)
    local assignedTag = nil

    if containsIgnoreCase(Kyri, player.Name) then
        assignedTag = "Kyri"
    elseif containsIgnoreCase(Alex, player.Name) then
        assignedTag = "Alex"
    elseif containsIgnoreCase(KyrisWife, player.Name) then
        assignedTag = "Kyri's Wife"
    elseif containsIgnoreCase(AlexsWife, player.Name) then
        assignedTag = "Alex's Wife"
    elseif containsIgnoreCase(ServerBoosters, player.Name) then
        assignedTag = "Server Booster"
    elseif ChatWhitelist[player.Name:lower()] then
        assignedTag = "User"
    elseif ChatWhitelist["ak_" .. player.Name:lower()] then
        assignedTag = "AK User"
    end

    local localPlayerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
    if localPlayerGui and player.Character and player.Character:FindFirstChild("Head") then
        local head = player.Character.Head
        for _, gui in ipairs(localPlayerGui:GetChildren()) do
            if gui:IsA("BillboardGui") and gui.Name == "RankTag" and gui.Adornee == head then
                gui:Destroy()
            end
        end
    end

    if assignedTag then
        createTag(player, assignedTag, showPrompt)
    end
end

local function setupChatListener(player)
    if chatConnections[player] then
        return
    end
    local conn = player.Chatted:Connect(function(msg)
        if not player or not player:IsDescendantOf(Players) then
            if chatConnections[player] then
                chatConnections[player]:Disconnect()
                chatConnections[player] = nil
            end
            return
        end

        local cleanMsg = msg:gsub("%s+", "")

        if cleanMsg == akAdminMessage:gsub("%s+", "") then
            if containsIgnoreCase(Kyri, player.Name)
                or containsIgnoreCase(Alex, player.Name)
                or containsIgnoreCase(KyrisWife, player.Name)
                or containsIgnoreCase(AlexsWife, player.Name)
                or containsIgnoreCase(ServerBoosters, player.Name) then
                return
            end
            if ChatWhitelist["ak_" .. player.Name:lower()] then
                return
            end
            ChatWhitelist["ak_" .. player.Name:lower()] = true
            applyPlayerTag(player)
        elseif cleanMsg == vividHubMessage:gsub("%s+", "") then
            if containsIgnoreCase(Kyri, player.Name)
                or containsIgnoreCase(Alex, player.Name)
                or containsIgnoreCase(KyrisWife, player.Name)
                or containsIgnoreCase(AlexsWife, player.Name)
                or containsIgnoreCase(ServerBoosters, player.Name) then
                return
            end
            if ChatWhitelist[player.Name:lower()] then
                return
            end
            ChatWhitelist[player.Name:lower()] = true
            applyPlayerTag(player)
        end
    end)
    chatConnections[player] = conn
end

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(applyPlayerTag, player)
    task.spawn(setupChatListener, player)
end

Players.PlayerAdded:Connect(function(player)
    task.wait(0.5)
    task.spawn(setupChatListener, player)
    task.spawn(applyPlayerTag, player)
end)

Players.PlayerRemoving:Connect(function(player)
    if chatConnections[player] then
        chatConnections[player]:Disconnect()
        chatConnections[player] = nil
    end
    if charAddedConnections[player] then
        charAddedConnections[player]:Disconnect()
        charAddedConnections[player] = nil
    end
end)

local localPlayerGui = Players.LocalPlayer and Players.LocalPlayer:WaitForChild("PlayerGui")
if localPlayerGui then
    spawn(function()
        while task.wait(2) do
            local validAdornees = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Head") then
                    table.insert(validAdornees, player.Character.Head)
                    local hasTag = false
                    for _, gui in ipairs(localPlayerGui:GetChildren()) do
                        if gui:IsA("BillboardGui") and gui.Name == "RankTag" and gui.Adornee == player.Character.Head then
                            hasTag = true
                            break
                        end
                    end
                    if not hasTag then
                        local shouldHaveTag = false
                        if containsIgnoreCase(Kyri, player.Name)
                            or containsIgnoreCase(Alex, player.Name)
                            or containsIgnoreCase(KyrisWife, player.Name)
                            or containsIgnoreCase(AlexsWife, player.Name)
                            or containsIgnoreCase(ServerBoosters, player.Name)
                            or ChatWhitelist[player.Name:lower()]
                            or ChatWhitelist["ak_" .. player.Name:lower()] then
                            shouldHaveTag = true
                        end
                        if shouldHaveTag then
                            applyPlayerTag(player)
                        end
                    end
                end
            end
            for i = #localPlayerGui:GetChildren(), 1, -1 do
                local gui = localPlayerGui:GetChildren()[i]
                if gui:IsA("BillboardGui") and gui.Name == "RankTag" then
                    local adornee = gui.Adornee
                    if not adornee or not adornee:IsDescendantOf(workspace) or not table.find(validAdornees, adornee) then
                        gui:Destroy()
                    end
                end
            end
        end
    end)
end

print("vivid tags loaded")

--[[
HOW TO ADD NEW TAGS:

1. add a new rank in RankData with this format:
   ["Rank Name"] = {
       primary = Color3.fromRGB(0, 0, 0),
       accent = Color3.fromRGB(255, 255, 255),
       emoji = "🔥",
       iconType = "Emoji"
   }

   for custom images instead:
   ["Rank Name"] = {
       primary = Color3.fromRGB(0, 0, 0),
       accent = Color3.fromRGB(255, 255, 255),
       iconType = "Custom",
       customImageUrl = "your_image_url_here.png"
   }

2. create a player list variable:
   local YourRankName = {"username1", "username2"}

3. add to applyPlayerTag function:
   elseif containsIgnoreCase(YourRankName, player.Name) then
       assignedTag = "Rank Name"

4. add to setupChatListener function:
   or containsIgnoreCase(YourRankName, player.Name)

5. add to tag monitoring loop:
   or containsIgnoreCase(YourRankName, player.Name)
--]]
