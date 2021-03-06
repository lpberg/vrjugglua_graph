require("Actions")
require("getScriptFilename")
require("TransparentGroup")
vrjLua.appendToModelSearchPath(getScriptFilename())
dofile(vrjLua.findInModelSearchPath([[loadBurrPuzzle.lua]]))
dofile(vrjLua.findInModelSearchPath([[..\graph\loadGraphFiles.lua]]))
-- wand = Manipulators.Gadgeteer.Wand{position = "VJWand"}
-- addManipulator(wand)
switchToBasicFactory() 
puzzleX = 2.7525
puzzleY = 0
puzzleZ = 1.2
all = addBurrPuzzle(puzzleX,puzzleY,puzzleZ)
bounding = all:computeBound()
assemblyPos = bounding:center()
assemblyPos = osg.Vec3d(assemblyPos:x(),assemblyPos:y(),assemblyPos:z())
local OSGBodies = {}
local SimulationBodies = {}
local BodyIDTable = {}

helperSphere = Transform{ 
	TransparentGroup{
		Sphere{radius=bounding:radius(),position = {assemblyPos:x(),assemblyPos:y(),assemblyPos:z()}}
	}
}
RelativeTo.World:addChild(
	helperSphere
)

 do
	BodyIDTable[yellow] = yellow.id
	table.insert(SimulationBodies,yellow)
	BodyIDTable[green] = green.id
	table.insert(SimulationBodies,green)
	BodyIDTable[purple] = purple.id
	table.insert(SimulationBodies,purple)
	BodyIDTable[teal] = teal.id
	table.insert(SimulationBodies,teal)
	BodyIDTable[red] = red.id
	table.insert(SimulationBodies,red)
	BodyIDTable[blue] = blue.id
	table.insert(SimulationBodies,blue)
end

g = nil
local function createGraphVisualization()
	g = Graph(
	{
		["012345"] = GraphNode{position = {1,1.5,0},radius = .03};

	},
	{

	}
	)
	g.actionArgs = {small_num = .55,damping = .80, c_mult = .06,desiredEdgeLength =.15, h_mult = 50}
	RelativeTo.World:addChild(g.osg.root)
end
 
local function getTransformForCoordinateFrame(coordinateFrame, node)
	if node == nil then node = assert(knownInView(coordinateFrame)) end
	if node:isSameKindAs(osg.MatrixTransform()) then
		return node
	else
		return getTransformForCoordinateFrame(coordinateFrame, node.Child[1])
	end
end
 
local function getOSGBodyFromCoordinateFrame(body)
	if OSGBodies[body] ~= nil then
		 return OSGBodies[body]
	else
		OSGBodies[body] = getTransformForCoordinateFrame(body).Child[1]
		return OSGBodies[body]
	end
end
 
local function PartInAssembley(body,assemblyCenter,threshold)
	local bodyPos = getOSGBodyFromCoordinateFrame(body):getMatrix():getTrans()
	local distance = (assemblyCenter - bodyPos):length()
	print(distance)
	if distance < threshold then
		return true
	else
		return false
	end
end

function getCurrentState()
	local state=""
	local bodies_in_state = {}
	for _,body in ipairs(SimulationBodies) do
		if(PartInAssembley(body,assemblyPos,3)) then
			table.insert(bodies_in_state,BodyIDTable[body])
		end
	end
	table.sort(bodies_in_state)
	for _,bodyid in ipairs(bodies_in_state) do
		state = state..bodyid
	end
	return state
end

function KeepTrackofState()
	g:updateCurrentState(g.nodes[1].name)
	local counter = 0
	local state = getCurrentState()
	while true do
		if counter > 25 then
			local newState = getCurrentState()
			if state ~= newState then
				state = newState
				print("State Change:"..state)
				g:updateCurrentState(state)
			end
			counter = 0
		end
		counter = counter + 1
		Actions.waitForRedraw()
	end
end
function fa()
	KeepTrackofState()
end
createGraphVisualization()
--*Actions.addFrameAction(fa)

simulation:startInSchedulerThread()
			
		