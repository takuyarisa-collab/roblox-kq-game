-- Creates reusable stage module Models under Workspace.StageModules on server start.

local Workspace = game:GetService("Workspace")

local C = {
	BombTarget = Color3.fromRGB(255, 140, 0),
	Wall = Color3.fromRGB(55, 55, 55),
	Floor = Color3.fromRGB(190, 190, 190),
}

local function part(name, size, color, localCF)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Anchored = true
	p.CanCollide = true
	p.CFrame = localCF
	p.Parent = nil
	return p
end

local function buildModel(folder, modelName, pivotCF, specs)
	local m = Instance.new("Model")
	m.Name = modelName
	for _, s in ipairs(specs) do
		local p = part(s.name, s.size, s.color, pivotCF * s.localCF)
		p.Parent = m
	end
	m.Parent = folder
end

local old = Workspace:FindFirstChild("StageModules")
if old then
	old:Destroy()
end

local folder = Instance.new("Folder")
folder.Name = "StageModules"
folder.Parent = Workspace

local V3 = Vector3.new

-- 1
buildModel(folder, "Module_BreakWall_Short", CFrame.new(0, 4, 0), {
	{ name = "BombTarget", size = V3(10, 8, 2), color = C.BombTarget, localCF = CFrame.new() },
})

-- 2
buildModel(folder, "Module_BreakWall_Long", CFrame.new(30, 4, 0), {
	{ name = "BombTarget", size = V3(20, 8, 2), color = C.BombTarget, localCF = CFrame.new() },
})

-- 3
buildModel(folder, "Module_CoverWall", CFrame.new(70, 4, 0), {
	{ name = "Wall", size = V3(10, 8, 2), color = C.Wall, localCF = CFrame.new() },
})

-- 4: corridor — floor + left/right walls
buildModel(folder, "Module_CorridorBlock", CFrame.new(110, 1, 0), {
	{ name = "Floor", size = V3(20, 1, 8), color = C.Floor, localCF = CFrame.new(0, 0, 0) },
	{ name = "Wall", size = V3(2, 8, 8), color = C.Wall, localCF = CFrame.new(-11, 4, 0) },
	{ name = "Wall", size = V3(2, 8, 8), color = C.Wall, localCF = CFrame.new(11, 4, 0) },
})

-- 5: safe space — floor + side wall as cover
buildModel(folder, "Module_SafeSpace", CFrame.new(160, 1, 0), {
	{ name = "Floor", size = V3(16, 1, 16), color = C.Floor, localCF = CFrame.new(0, 0, 0) },
	{ name = "Wall", size = V3(16, 8, 2), color = C.Wall, localCF = CFrame.new(0, 4, 9) },
})

print("Stage modules generated")
