print("Client running")

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local explodeEvent = ReplicatedStorage:WaitForChild("ExplodeEvent")
local setBombEvent = ReplicatedStorage:WaitForChild("SetBombEvent")

local function playToolLikeAction()
	local player = Players.LocalPlayer
	local character = player and player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local motor = nil
	if humanoid.RigType == Enum.HumanoidRigType.R6 then
		local torso = character:FindFirstChild("Torso")
		if torso then
			motor = torso:FindFirstChild("Right Shoulder")
		end
	else
		local upperTorso = character:FindFirstChild("UpperTorso")
		if upperTorso then
			motor = upperTorso:FindFirstChild("RightShoulder")
		end
	end

	if not (motor and motor:IsA("Motor6D")) then
		return
	end

	local original = motor.Transform
	local up = CFrame.Angles(math.rad(-55), 0, 0) * CFrame.new(0, 0, -0.15)

	local tIn = TweenService:Create(motor, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transform = original * up })
	tIn:Play()

	task.delay(0.12, function()
		local tOut = TweenService:Create(motor, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transform = original })
		tOut:Play()
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.E then
		explodeEvent:FireServer()
	elseif input.KeyCode == Enum.KeyCode.F then
		print("F pressed")
		playToolLikeAction()
		print("Fire SetBombEvent")
		setBombEvent:FireServer()
	end
end)
