print("Client running")

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local REACH_ANIMATION_ID = "rbxassetid://136843786405051"

print("Client before events")
local explodeEvent = ReplicatedStorage:WaitForChild("ExplodeEvent")
local setBombEvent = ReplicatedStorage:WaitForChild("SetBombEvent")
print("Client events ready")

local function playReachAnimation()
	print("Play reach animation")
	local player = Players.LocalPlayer
	local character = player and player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = REACH_ANIMATION_ID

	local animator = humanoid:FindFirstChildOfClass("Animator")
	local track
	if animator then
		track = animator:LoadAnimation(animation)
	else
		track = humanoid:LoadAnimation(animation)
	end

	if track then
		track:Play()
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.E then
		explodeEvent:FireServer()
	elseif input.KeyCode == Enum.KeyCode.F then
		print("F pressed")
		playReachAnimation()
		print("Fire SetBombEvent")
		setBombEvent:FireServer()
	end
end)
