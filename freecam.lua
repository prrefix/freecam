function freecam() -- stolen function because i can't be asked to make a freecam :)
    localPlayer = game.Players.LocalPlayer

    Camera = game.Workspace.CurrentCamera
    Mouse = localPlayer:GetMouse()
    
    UserInputService = game:GetService("UserInputService")
    
    movePosition = Vector2.new(0, 0)
    moveDirection = Vector3.new(0, 0, 0)
    
    targetMovePosition = movePosition
    
    Y_Sensitivity = 175
    X_Sensitivity = 175
    
    lastRightButtonDown = Vector2.new(0, 0)
    rightMouseButtonDown = false
    
    targetFOV = 70
    
    normalSpeed = 2.5 -- speed of fc
    sprintSpeed = 2
    
    sprinting = false
    sprintingSpeed = 3
    
    keysDown = {}
    
    moveKeys = {
        [Enum.KeyCode.D] = Vector3.new(1, 0, 0),
        [Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
        [Enum.KeyCode.S] = Vector3.new(0, 0, 1),
        [Enum.KeyCode.W] = Vector3.new(0, 0, -1),
        [Enum.KeyCode.E] = Vector3.new(0, 1, 0),
        [Enum.KeyCode.Q] = Vector3.new(0, -1, 0)
    }
    
    Tween = function(a, b, t)
        if t == 1 then
            return b
        else
            if tonumber(a) then
                return a * (1 - t) + (b * t)
            else
                return a:Lerp(b, t)
            end
        end
    end
    
    ClampVector3 = function(x, min, max)
        return Vector3.new(math.clamp(x.X, min.X, max.X), math.clamp(x.Y, min.Y, max.Y), math.clamp(x.Z, min.Z, max.Z))
    end
    
    UserInputService.InputChanged:connect(
        function(inputObject)
            if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
                movePosition = movePosition + Vector2.new(inputObject.Delta.x, inputObject.Delta.y)
            end
        end
    )
    
    CalculateMovement = function()
        local newMovement = Vector3.new(0, 0, 0)
        for i, v in pairs(keysDown) do
            newMovement = newMovement + (moveKeys[i] or Vector3.new(0, 0, 0))
        end
        local speedMultiplier = normalSpeed
        if keysDown[SprintKey] then
            speedMultiplier = sprintSpeed
        end
        return newMovement * speedMultiplier
    end
    
    Round = function(num, numDecimalPlaces)
        return math.floor((num / numDecimalPlaces) + .5) * numDecimalPlaces
    end
    
    Input = function(input, gameProcessed)
        if moveKeys[input.KeyCode] then
            if input.UserInputState == Enum.UserInputState.Begin then
                keysDown[input.KeyCode] = true
            elseif input.UserInputState == Enum.UserInputState.End then
                keysDown[input.KeyCode] = nil
            end
        else
            if input.UserInputState == Enum.UserInputState.Begin then
                print()
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    rightMouseButtonDown = true
                    lastRightButtonDown = Vector2.new(Mouse.X, Mouse.Y)
                    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                elseif input.KeyCode == Enum.KeyCode.Z then
                    targetFOV = 20
                elseif input.KeyCode == SprintKey then
                    sprinting = true
                end
            else
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    rightMouseButtonDown = false
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                elseif input.KeyCode == Enum.KeyCode.Z then
                    targetFOV = 70
                elseif input.KeyCode == SprintKey then
                    sprinting = false
                end
            end
        end
    end
    
    Mouse.WheelForward:connect(
        function()
            Camera.CoordinateFrame = Camera.CoordinateFrame * CFrame.new(0, 0, -5)
        end
    )
    
    Mouse.WheelBackward:connect(
        function()
            Camera.CoordinateFrame = Camera.CoordinateFrame * CFrame.new(-0, 0, 5)
        end
    )
    
    UserInputService.InputBegan:connect(Input)
    UserInputService.InputEnded:connect(Input)
    
    local Toggled = true
    if Toggled then
        Camera.CameraType = Enum.CameraType.Scriptable
        game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
        game.Players.LocalPlayer.Character.Humanoid.PlatformStand = true
    else
        game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
        game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
        game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
        game.Workspace.CurrentCamera.CameraType = "Custom"
    end
    
    game:GetService("RunService").RenderStepped:Connect(
        function()
            if Toggled then
                local mouseTarget = Mouse.Hit
    
                targetMovePosition = movePosition
                Camera.CoordinateFrame =
                    CFrame.new(Camera.CoordinateFrame.p) *
                    CFrame.fromEulerAnglesYXZ(
                        -targetMovePosition.Y / Y_Sensitivity,
                        -targetMovePosition.X / X_Sensitivity,
                        0
                    ) *
                    CFrame.new(CalculateMovement() * ((({[true] = sprintingSpeed})[sprinting]) or .5))
                Camera.FieldOfView = Tween(Camera.FieldOfView, targetFOV, .5)
                if rightMouseButtonDown then
                    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                    movePosition = movePosition - (lastRightButtonDown - Vector2.new(Mouse.X, Mouse.Y))
                    lastRightButtonDown = Vector2.new(Mouse.X, Mouse.Y)
                end
            end
        end
    )
end
freecam()