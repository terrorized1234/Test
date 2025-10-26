local platform = Instance.new("Part")
platform.Anchored = true
platform.Size = Vector3.new(5, 1, 5)
platform.Transparency = 1
platform.CanCollide = false
platform.Parent = workspace

local airWalkOn = false
local platformY = 0

game:GetService("RunService").RenderStepped:Connect(function()
  if airWalkOn then
    platform.Position = Vector3.new(
      humanoidRootPart.Position.X,
      platformY,
      humanoidRootPart.Position.Z
    )
    platform.CanCollide = true
  end
  heightLabel.Text = "Height: " .. string.format("%.3f", humanoidRootPart.Position.Y)
end)
