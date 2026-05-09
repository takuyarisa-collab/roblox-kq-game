-- Generates a linear tutorial corridor under Workspace.TutorialStage on server start.

local Workspace = game:GetService("Workspace")

local C = {
	BombTarget = Color3.fromRGB(255, 140, 0),
	Wall = Color3.fromRGB(55, 55, 55),
	Floor = Color3.fromRGB(190, 190, 190),
	Goal = Color3.fromRGB(0, 200, 80),
}

local V3 = Vector3.new
local FLOOR_SIZE = V3(16, 1, 18)
local WALL_SIZE = V3(12, 8, 2)
local SHIELD_WALL_SIZE = V3(6, 8, 2)
local GOAL_SIZE = V3(10, 1, 10)
local SECTION_SPACING = 24
-- Start reference: floor top at y=3 (matches (0, 3, 0) play plane)
local FLOOR_CENTER_Y = 2.5
local WALL_CENTER_Y = FLOOR_CENTER_Y + 4

local function createPart(name, size, color, cf, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Anchored = true
	p.CanCollide = true
	p.CFrame = cf
	p.Parent = parent
	return p
end

local function addCorridorWalls(folder, sectionZ)
	local y = WALL_CENTER_Y
	local rot = CFrame.Angles(0, math.rad(90), 0)
	createPart("Wall", WALL_SIZE, C.Wall, CFrame.new(-7, y, sectionZ) * rot, folder)
	createPart("Wall", WALL_SIZE, C.Wall, CFrame.new(7, y, sectionZ) * rot, folder)
end

local function addFloor(folder, sectionZ)
	createPart("Floor", FLOOR_SIZE, C.Floor, CFrame.new(0, FLOOR_CENTER_Y, sectionZ), folder)
end

local old = Workspace:FindFirstChild("TutorialStage")
if old then
	old:Destroy()
end

local root = Instance.new("Folder")
root.Name = "TutorialStage"
root.Parent = Workspace

-- Z advances +forward; sections spaced by SECTION_SPACING.
local zStart = 0
local zBomb1 = SECTION_SPACING
local zBombShield = SECTION_SPACING * 2
local zDoubleBomb = SECTION_SPACING * 3
local zGoal = SECTION_SPACING * 4

-- 1. Start area
addFloor(root, zStart)
addCorridorWalls(root, zStart)

-- 2. Single BombTarget — touch → retreat → explode
addFloor(root, zBomb1)
addCorridorWalls(root, zBomb1)
createPart(
	"BombTarget",
	WALL_SIZE,
	C.BombTarget,
	CFrame.new(0, WALL_CENTER_Y, zBomb1 + 5),
	root
)

-- 3. BombTarget + side Wall cover (shield behind lateral Wall)
addFloor(root, zBombShield)
addCorridorWalls(root, zBombShield)
createPart(
	"BombTarget",
	WALL_SIZE,
	C.BombTarget,
	CFrame.new(0, WALL_CENTER_Y, zBombShield + 5),
	root
)
createPart(
	"Wall",
	SHIELD_WALL_SIZE,
	C.Wall,
	CFrame.new(-9, WALL_CENTER_Y, zBombShield) * CFrame.Angles(0, math.rad(90), 0),
	root
)

-- 4. Two BombTargets with a short gap — chain explosions
addFloor(root, zDoubleBomb)
addCorridorWalls(root, zDoubleBomb)
createPart(
	"BombTarget",
	WALL_SIZE,
	C.BombTarget,
	CFrame.new(0, WALL_CENTER_Y, zDoubleBomb - 3),
	root
)
createPart(
	"BombTarget",
	WALL_SIZE,
	C.BombTarget,
	CFrame.new(0, WALL_CENTER_Y, zDoubleBomb + 5),
	root
)

-- 5. Goal
addFloor(root, zGoal)
addCorridorWalls(root, zGoal)
createPart("Goal", GOAL_SIZE, C.Goal, CFrame.new(0, FLOOR_CENTER_Y, zGoal), root)

print("Tutorial stage generated")
