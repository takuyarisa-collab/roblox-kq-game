print("Bomb server script loaded")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local explodeEvent = ReplicatedStorage:WaitForChild("ExplodeEvent")
local setBombEvent = ReplicatedStorage:WaitForChild("SetBombEvent")

local currentBomb = nil
local explosionRadius = 10
local bombSetDistance = 8

local function isShieldingPart(inst: Instance?): boolean
	return inst ~= nil and inst:IsA("BasePart") and (inst.Name == "Wall" or inst.Name == "BombTarget")
end

local function isExplosionShielded(pos: Vector3, character: Model): boolean
	local root = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")

	-- 判定対象が揃っていない場合はセーフ扱いにしない
	if not (root and root:IsA("BasePart") and head and head:IsA("BasePart")) then
		return false
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { character }
	params.IgnoreWater = true

	local function blockedTo(targetPart: BasePart): boolean
		local dir = targetPart.Position - pos
		local result = workspace:Raycast(pos, dir, params)
		return result ~= nil and isShieldingPart(result.Instance)
	end

	-- 2点のうち1点でも遮蔽なしなら被弾、2点とも遮蔽ならセーフ
	return blockedTo(root) and blockedTo(head)
end

local function makeBomb(part)
	if currentBomb and currentBomb ~= part then
		currentBomb.Color = Color3.fromRGB(163, 162, 165)
	end

	currentBomb = part
	part.Color = Color3.fromRGB(255, 0, 0)
	print("Bomb set:", part:GetFullName())
end

local function setup()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "BombTarget" then
			print("Found BombTarget:", obj:GetFullName())
		end
	end
end

setup()
workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") and obj.Name == "BombTarget" then
		print("New BombTarget:", obj:GetFullName())
	end
end)

setBombEvent.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not (root and root:IsA("BasePart")) then
		return
	end

	local nearest = nil
	local nearestDist = math.huge
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "BombTarget" then
			local d = (obj.Position - root.Position).Magnitude
			if d < nearestDist then
				nearest = obj
				nearestDist = d
			end
		end
	end

	if nearest and nearestDist <= bombSetDistance then
		makeBomb(nearest)
	end
end)

explodeEvent.OnServerEvent:Connect(function(player)
	if not currentBomb then
		print("No bomb")
		return
	end

	local pos = currentBomb.Position
	print("BOOM")

	local explosion = Instance.new("Explosion")
	explosion.Position = pos
	explosion.BlastRadius = explosionRadius
	explosion.BlastPressure = 0
	explosion.DestroyJointRadiusPercent = 0
	explosion.Parent = workspace

	-- 爆弾化した対象を破壊
	currentBomb:Destroy()
	currentBomb = nil

	-- 自爆判定
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = character:FindFirstChild("HumanoidRootPart")

		if humanoid and root then
			local distance = (root.Position - pos).Magnitude
			if distance <= explosionRadius then
				if isExplosionShielded(pos, character) then
					print("Shielded from explosion")
				else
					humanoid.Health = 0
					print("Self exploded")
				end
			end
		end
	end
end)