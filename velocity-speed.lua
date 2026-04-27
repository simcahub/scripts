--───── Config ─────--
local VelocitySpeed = {
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

--───── States ─────--
local CurrentRoll = 0
local CurrentPitch = 0

--───── Functions ─────--
function VelocitySpeed.StartSpeed()
    VelocitySpeed.Connection = RenderStepped:Connect(function()
        local LocalCharacter = LocalPlayer.Character
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

        CameraLookVector = Vector3.new(CameraLookVector.X, 0, CameraLookVector.Z)
        CameraRightVector = Vector3.new(CameraRightVector.X, 0, CameraRightVector.Z)

        if CameraLookVector.Magnitude > 0 then
            CameraLookVector = CameraLookVector.Unit
        end

        if CameraRightVector.Magnitude > 0 then
            CameraRightVector = CameraRightVector.Unit
        end

        if MoveDirection.Magnitude == 0 then
            VelocitySpeed.CurrentVelocity = VelocitySpeed.CurrentVelocity:Lerp(Vector3.zero, VelocitySpeed.Smoothness)

            CurrentRoll = CurrentRoll * (1 - VelocitySpeed.Smoothness)
            CurrentPitch = CurrentPitch * (1 - VelocitySpeed.Smoothness)

            LocalRootPart.AssemblyLinearVelocity = Vector3.new(
                VelocitySpeed.CurrentVelocity.X,
                LocalRootPart.AssemblyLinearVelocity.Y,
                VelocitySpeed.CurrentVelocity.Z
            )

            local BaseCFrame = CFrame.new(LocalRootPart.Position, LocalRootPart.Position + CameraLookVector)
            LocalRootPart.CFrame = BaseCFrame
            return
        end

        local InputX = MoveDirection:Dot(CameraRightVector)
        local InputZ = MoveDirection:Dot(CameraLookVector)

        local DesiredMove = (CameraRightVector * InputX + CameraLookVector * InputZ)

        if DesiredMove.Magnitude > 0 then
            DesiredMove = DesiredMove.Unit * VelocitySpeed.Speed
        end

        VelocitySpeed.CurrentVelocity = VelocitySpeed.CurrentVelocity:Lerp(DesiredMove, VelocitySpeed.Smoothness)

        LocalRootPart.AssemblyLinearVelocity = Vector3.new(
            VelocitySpeed.CurrentVelocity.X,
            LocalRootPart.AssemblyLinearVelocity.Y,
            VelocitySpeed.CurrentVelocity.Z
        )

        local TargetRoll = -InputX * VelocitySpeed.RollAmount
        local TargetPitch = -InputZ * VelocitySpeed.PitchAmount

        CurrentRoll = CurrentRoll + (TargetRoll - CurrentRoll) * VelocitySpeed.Smoothness
        CurrentPitch = CurrentPitch + (TargetPitch - CurrentPitch) * VelocitySpeed.Smoothness

        local BaseCFrame = CFrame.new(LocalRootPart.Position, LocalRootPart.Position + CameraLookVector)
        local TiltCFrame = CFrame.Angles(math.rad(CurrentPitch), 0, math.rad(CurrentRoll))

        LocalRootPart.CFrame = BaseCFrame * TiltCFrame
    end)
end

function VelocitySpeed.StopSpeed()
    if VelocitySpeed.Connection then
        VelocitySpeed.Connection:Disconnect()
        VelocitySpeed.Connection = nil
    end
end

return VelocitySpeed