require("Actions")
require("getScriptFilename")
require("TransparentGroup")
vrjLua.appendToModelSearchPath(getScriptFilename())
dofile(vrjLua.findInModelSearchPath([[loadOmni.lua]]))
dofile(vrjLua.findInModelSearchPath([[loadBurrPuzzle.lua]]))
dofile(vrjLua.findInModelSearchPath([[..\graph\loadGraphFiles.lua]]))
switchToBasicFactory() 

local ar = .25
local assemblyPos = osg.Vec3d(-.2,.65,.1)
local OSGBodies = {}
local SimulationBodies = {}
local BodyIDTable = {}
 
 if not partDensity then
	partDensity = 2
end

RelativeTo.World:addChild(
	TransparentGroup{
		Sphere{radius=ar,position = {assemblyPos:x(),assemblyPos:y(),assemblyPos:z()}}
	}
)
 --for all bodies in simulation
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
		if(PartInAssembley(body,assemblyPos,1)) then
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
	local counter = 0
	local state = getCurrentState()
	while true do
		if counter > 100 then
			local newState = getCurrentState()
			if state ~= newState then
				state = newState
				print("State Change:"..state)
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
Actions.addFrameAction(fa)

			

simulation:startInSchedulerThread()
			
		