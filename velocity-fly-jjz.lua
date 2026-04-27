--───── Config ─────--
local VelocityFly = {
    Speed = 70,
    Smoothness = 0.15,
    RollAmount = 25,
    PitchAmount = 20,
    CurrentVelocity = Vector3.zero,
    Connection = nil
}

--───── Services ─────--
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))

--───── Variables ─────--
local RenderStepped = RunService.RenderStepped
local LocalPlayer = Players.LocalPlayer

local CharacterController = require(LocalPlayer.PlayerScripts.Client.Controllers.CharacterController)

--───── States ─────--
local CurrentRoll = 0
local CurrentPitch = 0

--───── Functions ─────--
function VelocityFly.StartFly()
    VelocityFly.Connection = RenderStepped:Connect(function()
        local LocalCharacter = CharacterController.LocalCharacter.ServerModel
        if not LocalCharacter then return end

        local LocalRootPart = LocalCharacter:FindFirstChild("HumanoidRootPart") or LocalCharacter.PrimaryPart
        if not LocalRootPart then return end

        local LocalHumanoid = LocalCharacter:FindFirstChild("Humanoid")
        if not LocalHumanoid then return end

        local MoveDirection = LocalHumanoid.MoveDirection
        local Camera = workspace.CurrentCamera

        local CameraCFrame = Camera.CFrame
        local CameraLookVector = CameraCFrame.LookVector
        local CameraRightVector = CameraCFrame.RightVector

        if MoveDirection.Magnitude == 0 then
            VelocityFly.CurrentVelocity = VelocityFly.CurrentVelocity:Lerp(Vector3.zero, VelocityFly.Smoothness)

            CurrentRoll = CurrentRoll * (1 - VelocityFly.Smoothness)
            CurrentPitch = CurrentPitch * (1 - VelocityFly.Smoothness)

            LocalRootPart.AssemblyLinearVelocity = VelocityFly.CurrentVelocity

            local BaseCFrame = CFrame.new(LocalRootPart.Position, LocalRootPart.Position + CameraLookVector)
            LocalRootPart.CFrame = BaseCFrame
            return
        end

        local InputX = MoveDirection:Dot(CameraRightVector)
        local InputZ = MoveDirection:Dot(CameraLookVector)

        local DesiredMove = (CameraRightVector * InputX + CameraLookVector * InputZ)

        if DesiredMove.Magnitude > 0 then
            DesiredMove = DesiredMove.Unit * VelocityFly.Speed
        end

        VelocityFly.CurrentVelocity = VelocityFly.CurrentVelocity:Lerp(DesiredMove, VelocityFly.Smoothness)
        LocalRootPart.AssemblyLinearVelocity = VelocityFly.CurrentVelocity

        local TargetRoll = -InputX * VelocityFly.RollAmount
        local TargetPitch = -InputZ * VelocityFly.PitchAmount

        CurrentRoll = CurrentRoll + (TargetRoll - CurrentRoll) * VelocityFly.Smoothness
        CurrentPitch = CurrentPitch + (TargetPitch - CurrentPitch) * VelocityFly.Smoothness

        local BaseCFrame = CFrame.new(LocalRootPart.Position, LocalRootPart.Position + CameraLookVector)
        local TiltCFrame = CFrame.Angles(math.rad(CurrentPitch), 0, math.rad(CurrentRoll))

        LocalRootPart.CFrame = BaseCFrame * TiltCFrame
    end)
end

function VelocityFly.StopFly()
    if VelocityFly.Connection then
        VelocityFly.Connection:Disconnect()
        VelocityFly.Connection = nil
    end
end

return VelocityFly