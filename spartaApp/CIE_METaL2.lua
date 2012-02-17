require("Actions")
require("getScriptFilename")
require("TransparentGroup")
vrjLua.appendToModelSearchPath(getScriptFilename())
dofile(vrjLua.findInModelSearchPath([[loadBurrPuzzle.lua]]))
dofile(vrjLua.findInModelSearchPath([[..\graph\loadGraphFiles.lua]]))
wand = Manipulators.Gadgeteer.Wand{position = "VJWand"}
addManipulator(wand)
switchToBasicFactory() 
puzzleX = 2.7525
puzzleY = -.125
puzzleZ = 1.2
all = addBurrPuzzle(puzzleX,puzzleY,puzzleZ)
bounding = all:computeBound()
assemblyPos = bounding:center()
assemblyPos = osg.Vec3d(assemblyPos:x(),assemblyPos:y(),assemblyPos:z())
local OSGBodies = {}
local SimulationBodies = {}
local BodyIDTable = {}
initPosById = {}

-- helperSphere = Transform{ 
	-- TransparentGroup{
		-- Sphere{radius=bounding:radius(),position = {assemblyPos:x(),assemblyPos:y(),assemblyPos:z()}}
	-- }
-- }
-- RelativeTo.World:addChild(
	-- helperSphere
-- )

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
function setupInitPositions()
	initPosById[yellow] = getOSGBodyFromCoordinateFrame(yellow):getMatrix():getTrans()
	initPosById[green] = getOSGBodyFromCoordinateFrame(green):getMatrix():getTrans()
	initPosById[purple] = getOSGBodyFromCoordinateFrame(purple):getMatrix():getTrans()
	initPosById[teal] = getOSGBodyFromCoordinateFrame(teal):getMatrix():getTrans()
	initPosById[red] = getOSGBodyFromCoordinateFrame(red):getMatrix():getTrans()
	initPosById[blue] = getOSGBodyFromCoordinateFrame(blue):getMatrix():getTrans()
end



g = nil

local function createGraphVisualization()
	local fact = .15
	g = Graph(
	{
		--x = 0
		["012345"] = GraphNode{position = {0,0,0},radius = .03};
		["01234"] = GraphNode{position = {0,-1*fact,0},radius = .03};
		["0123"] = GraphNode{position = {0,-2*fact,0},radius = .03};
		["12"] = GraphNode{position = {0,-4*fact,0},radius = .03};
		["1"] = GraphNode{position = {0,-5*fact,0},radius = .03};
		["2"] = GraphNode{position = {0,-6*fact,fact},radius = .03};
		--x = 1
		["012"] = GraphNode{position = {1*fact,-3*fact,0},radius = .03};
		["02"] = GraphNode{position = {1*fact,-4*fact,0},radius = .03};
		--x = 2
		["01"] = GraphNode{position = {2*fact,-4*fact,0},radius = .03};
		["0"] = GraphNode{position = {2*fact,-5*fact,0},radius = .03};
		--x = -1
		["123"] = GraphNode{position = {-1*fact,-3*fact,0},radius = .03};
		["23"] = GraphNode{position = {-1*fact,-4*fact,0},radius = .03};
		--x = -2
		["13"] = GraphNode{position = {-2*fact,-4*fact,0},radius = .03};
		["3"] = GraphNode{position = {-2*fact,-5*fact,0},radius = .03};

	},
	{
		DirectedEdge("012345", "01234");
		DirectedEdge("01234", "0123");
		DirectedEdge("0123", "123");
		DirectedEdge("0123", "012");
		DirectedEdge("123", "13");
		DirectedEdge("123", "23");
		DirectedEdge("123", "12");
		DirectedEdge("012", "12");
		DirectedEdge("012", "02");
		DirectedEdge("012", "01");
		DirectedEdge("13", "3");
		DirectedEdge("13", "1");
		DirectedEdge("23", "3");
		DirectedEdge("23", "2");
		DirectedEdge("12", "1");
		DirectedEdge("12", "2");
		DirectedEdge("02", "2");
		DirectedEdge("02", "0");
		DirectedEdge("01", "1");
		DirectedEdge("01", "0");
	}
	)
	g.actionArgs = {small_num = .55,damping = .80, c_mult = .02,desiredEdgeLength =.15, h_mult = 150}
	gxform = Transform{
		position = {1,1.75,0},
		g.osg.root,
	}	
	RelativeTo.World:addChild(gxform)
end
 

local function PartInAssembley(body,threshold)
	local initPos = initPosById[body]
	local bodyPos = getOSGBodyFromCoordinateFrame(body):getMatrix():getTrans()
	local distance = (initPos - bodyPos):length()
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
		if(PartInAssembley(body,2)) then
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
	setupInitPositions()
	-- g:updateCurrentState(g.nodes[1].name)
	g:updateCurrentState(getCurrentState())
	local counter = 0
	local state = getCurrentState()
	while true do
		if counter > 10 then
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
Actions.addFrameAction(fa)
Actions.addFrameAction(setBackParts)
simulation:startInSchedulerThread()
			
		