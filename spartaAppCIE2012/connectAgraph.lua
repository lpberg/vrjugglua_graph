require("AddAppDirectory")
require("TransparentGroup")
AddAppDirectory()

runfile[[..\graph\loadGraphFiles.lua]]
runfile[[MySounds/PlaySound.lua]]
runfile[[..\graph\simpleLightsGraph.lua]]

local device = gadget.PositionInterface("VJWand")
local addNodeBtn = gadget.DigitalInterface("WMButtonPlus")
local addEdgeBtn = gadget.DigitalInterface("VJButton1")

local wavPath = vrjLua.findInModelSearchPath("tiny.wav")
local myWavSound = SoundWav(wavPath)
local wavPath2 = vrjLua.findInModelSearchPath("tiny1.wav")
local myWavSound2 = SoundWav(wavPath2)
local wavPath3 = vrjLua.findInModelSearchPath("new.wav")
local myWavSound3 = SoundWav(wavPath3)

local function randomColor()
	local r = math.random(0,255)/255
	local b = math.random(0,255)/255
	local g = math.random(0,255)/255
	return {r,g,b,1}
end

local function getWandPositionInWorld()
	return RelativeTo.World:getInverseMatrix():preMult(device.position)
end

local my_radius = .13/2

local g = Graph(
	{
		["one"] = GraphNode{position = {0,0,0},radius = my_radius,color = randomColor()};
		["two"] = GraphNode{position = {0,1,0},radius = my_radius,color = randomColor()};
		["three"] = GraphNode{position = {1,1,0},radius = my_radius,color = randomColor()};
		["four"] = GraphNode{position = {1,0,0},radius = my_radius,color = randomColor()};

	},
	{
		

	}
)
RelativeTo.World:addChild(g.osg.root)

--LITTLE SPHERE TO FOLLOW WAND
Actions.addFrameAction(
	function()
		wandSphere = osg.MatrixTransform()
		wandSphere:addChild(Sphere{radius = .05})
		RelativeTo.World:addChild(wandSphere)
		while true do
			mat = wandSphere:getMatrix()
			mat:setTrans(getWandPositionInWorld())
			wandSphere:setMatrix(mat)
			Actions.waitForRedraw()
		end
	end
)

--HOVER ACTION HIGHLIGHT
local hoveredNode = nil
Actions.addFrameAction(
	function()
		while true do
			local device_pos = getWandPositionInWorld()
			local changed_this_time = false
			for _,node in ipairs(g.nodes) do
				local distance = (osg.Vec3d(unpack(node.position))-device_pos):length()
				if math.abs(distance) < (my_radius*3) then
					if not node.isHighlighted then
						node:highlight(true)
						myWavSound2:trigger(1)
					end
					changed_this_time = true
					hoveredNode = node
					Actions.waitForRedraw()
				else
					if node.isHighlighted then
						node:highlight(false)
					end
					Actions.waitForRedraw()
				end
			end
			if changed_this_time == false then
				hoveredNode = nil
			end
		end
	end
)

--ADD NODE TO SCENE
Actions.addFrameAction(function()
	while true do
		repeat
			Actions.waitForRedraw()
		until addNodeBtn.justPressed
		local newPos = getWandPositionInWorld()
		local newName = tostring(newPos:x()+math.random(1,100))
		g:addNodes{
			[newName] = GraphNode{
							position = {newPos:x(),newPos:y(),newPos:z()+.1},
							radius = my_radius,
							color = randomColor()
						};
		}
		myWavSound3:trigger(1)
	end
end)	

--ADD EDGE TO SCENE
Actions.addFrameAction(function()
	local tempXFORM = Transform{}
	while true do
		local pointOne = nil
		local pointTwo = nil
		repeat
			Actions.waitForRedraw()
		until addEdgeBtn.justPressed
		pointOne = hoveredNode
		RelativeTo.World:addChild(tempXFORM)
		while addEdgeBtn.pressed and pointOne ~= nil do 
			local device_pos = getWandPositionInWorld()
			tempXFORM.Child[1] = CylinderFromHereToThere(osg.Vec3d(unpack(pointOne.position)), device_pos, pointOne.radius/3, {1,1,0,1}) 
			Actions.waitForRedraw()
		end
		RelativeTo.World:removeChild(tempXFORM)
		Actions.waitForRedraw()
		pointTwo = hoveredNode
		if pointTwo ~= nil and (pointOne.name ~= pointTwo.name) then
			print("adding edge")
			g:addEdges{
				DirectedEdge(pointOne.name, pointTwo.name,{color = randomColor(),radius = pointOne.radius/3})
			}
			myWavSound:trigger(1)
		end
	end
end)	