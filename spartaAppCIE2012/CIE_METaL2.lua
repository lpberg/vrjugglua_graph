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
	local green = {(154/255),(205/255),(50/255),1}
	local yellow = {1,(215/255),0,1}
	local red = {1,0,0,1}
	local teal = {0,(206/255),(209/255),1}
	local purple = {(138/255),(43/255),(210/255),1}
	local blue = {0,0,1,1}
	g = Graph(
	{
		--x = 0
		["012345"] = GraphNode{position = {0,0,0},radius = .03};
		["01234"] = GraphNode{position = {0,-1*fact,0},radius = .03,color = red}; 
		["0123"] = GraphNode{position = {0,-2*fact,0},radius = .03,color = teal};
		["12"] = GraphNode{position = {0,-4*fact,0},radius = .03,color = purple}; 
		["1"] = GraphNode{position = {0,-5*fact,0},radius = .03,color = green}; 
		["2"] = GraphNode{position = {.1,-6*fact,fact},radius = .03,color = blue}; 
		--x = 1
		["012"] = GraphNode{position = {1*fact,-3*fact,0},radius = .03,color = purple}; 
		["02"] = GraphNode{position = {1*fact,-4*fact,0},radius = .03,color = yellow}; 
		--x = 2
		["01"] = GraphNode{position = {2*fact,-4*fact,0},radius = .03,color = green}; 
		["0"] = GraphNode{position = {2*fact,-5*fact,0},radius = .03,color = yellow};
		--x = -1
		["123"] = GraphNode{position = {-1*fact,-3*fact,0},radius = .03,color = blue};
		["23"] = GraphNode{position = {-1*fact,-4*fact,0},radius = .03,color = yellow}; 
		--x = -2
		["13"] = GraphNode{position = {-2*fact,-4*fact,0},radius = .03,color = green};
		["3"] = GraphNode{position = {-2*fact,-5*fact,0},radius = .03,color = yellow};

	},
	{
		DirectedEdge("012345", "01234",{destColor=red, radius=.007});
		DirectedEdge("01234", "0123",{destColor=teal});
		DirectedEdge("0123", "123",{destColor=blue});
		DirectedEdge("0123", "012",{destColor=purple});
		DirectedEdge("123", "13",{destColor=green});
		DirectedEdge("123", "23",{destColor=yellow});
		DirectedEdge("123", "12",{destColor=purple});
		DirectedEdge("012", "12",{destColor=blue});
		DirectedEdge("012", "02",{destColor=yellow});
		DirectedEdge("012", "01",{destColor=green});
		DirectedEdge("13", "3",{destColor=yellow});
		DirectedEdge("13", "1",{destColor=purple});
		DirectedEdge("23", "3",{destColor=green});
		DirectedEdge("23", "2",{destColor=purple});
		DirectedEdge("12", "1",{destColor=green});
		DirectedEdge("12", "2",{destColor=yellow});
		DirectedEdge("02", "2",{destColor=blue});
		DirectedEdge("02", "0",{destColor=green});
		DirectedEdge("01", "1",{destColor=blue});
		DirectedEdge("01", "0",{destColor=yellow});
	}
	)
	g.actionArgs = {small_num = .55,damping = .80, c_mult = .02,desiredEdgeLength =.15, h_mult = 150}
	gxform = Transform{
		position = {2,1.75,0},
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

local function PartRemoved(body,threshold)
	local initPos = initPosById[body]
	local bodyPos = getOSGBodyFromCoordinateFrame(body):getMatrix():getTrans()
	local distance = (initPos - bodyPos):length()
	if distance < threshold then
		return false
	else
		return true
	end
end
function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
		  return true
		end
	end
	return false
end

local function WasInLastState(fullstring,element)
	local found_idx = string.find(fullstring,element)
	if found_idx ~= nil then
		return true
	else
		return false
	end
end


local old_state_table = {}
function getCurrentStateStatic()
	local state_string = ""
	local state_table = {}
	local bodies_removed = {}
	--find out which bodies are outside 'assembly area'
	for _,body in ipairs(SimulationBodies) do
		if(PartRemoved(body,.5)) then
			table.insert(bodies_removed,BodyIDTable[body])
		end
	end
	--if no bodies outside 'assembly area' state is null (= "")
	if #bodies_removed < 1 then
		state = ""
	end
	--if body was removed last check and still is removed - add it to state_string
	for _,bodyid in ipairs(old_state_table) do
		if table.contains(bodies_removed,bodyid) then
			table.insert(state_table,bodyid)
			state_string = state_string..bodyid
		end
	end
	--jconf s:/jconf30/METaL.tracked.stereo.reordered.withwand.jconf
	--for every element in bodies removed, if not in last state, add it to end
	for _,bodyid in ipairs(bodies_removed) do
		if not table.contains(old_state_table,bodyid) then
			table.insert(state_table,bodyid)
			state_string = state_string..bodyid
		end
	end
	old_state_table = state_table
	return state_string
end


function getCurrentStateDynamic()
	local state=""
	local bodies_in_state = {}
	for _,body in ipairs(SimulationBodies) do
		if(PartInAssembley(body,.5)) then
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
	g:updateCurrentState(getCurrentStateDynamic())
	local counter = 0
	local state = getCurrentStateDynamic()
	while true do
		if counter > 10 then
			local newState = getCurrentStateDynamic()
			if state ~= newState then
				state = newState
				print("Dyanmic State Change:"..state)
				print("Static State Change: "..getCurrentStateStatic())
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
			
		