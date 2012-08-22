require("Actions")
require("getScriptFilename")
require("TransparentGroup")
vrjLua.appendToModelSearchPath(getScriptFilename())
dofile(vrjLua.findInModelSearchPath([[..\graph\loadGraphFiles.lua]]))
dofile(vrjLua.findInModelSearchPath([[MySounds/PlaySound.lua]]))
dofile(vrjLua.findInModelSearchPath([[..\graph\simpleLightsGraph.lua]]))
local wavPath = vrjLua.findInModelSearchPath("tiny.wav")
local myWavSound = SoundWav(wavPath)
local wavPath2 = vrjLua.findInModelSearchPath("tiny1.wav")
local myWavSound2 = SoundWav(wavPath2)
local wavPath3 = vrjLua.findInModelSearchPath("new.wav")
local myWavSound3 = SoundWav(wavPath3)
g = Graph(
	{
		["one"] = GraphNode{position = {0,0,0},radius = .13};
		["two"] = GraphNode{position = {0,1,0},radius = .13};
		["three"] = GraphNode{position = {1,1,0},radius = .13};
		["four"] = GraphNode{position = {1,0,0},radius = .13};

	},
	{
		

	}
)
RelativeTo.World:addChild(g.osg.root)

local hoveredNode = nil
Actions.addFrameAction(
	function()
		local device = gadget.PositionInterface("VJWand")
		while true do
			local device_pos = device.position - osgnav.position
			local changed_this_time = false
			for _,node in ipairs(g.nodes) do
				local distance = (osg.Vec3d(unpack(node.position))-device_pos):length()
				if math.abs(distance) < (node.radius*2) then
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

Actions.addFrameAction(function()
	local drawBtn = gadget.DigitalInterface("WMButtonPlus")
	local device = gadget.PositionInterface("VJWand")
	while true do
		repeat
			Actions.waitForRedraw()
		until drawBtn.justPressed
		local newPos = device.position - osgnav.position
		local newName = tostring(newPos:x()+math.random(1,100))
		g:addNodes{
			[newName] = GraphNode{position = {newPos:x(),newPos:y(),newPos:z()+.1},radius = .13};
		}
		myWavSound3:trigger(1)
	end
end)	

Actions.addFrameAction(function()
	local tempXFORM = Transform{}
	local drawBtn = gadget.DigitalInterface("VJButton1")
	local device = gadget.PositionInterface("VJWand")
	while true do
		local pointOne = nil
		local pointTwo = nil
		repeat
			Actions.waitForRedraw()
		until drawBtn.justPressed
		pointOne = hoveredNode
		RelativeTo.World:addChild(tempXFORM)
		while drawBtn.pressed and pointOne ~= nil do 
			local device_pos = device.position - osgnav.position
			tempXFORM.Child[1] = CylinderFromHereToThere(osg.Vec3d(unpack(pointOne.position)), device_pos, pointOne.radius/3, {1,1,0,1}) 
			Actions.waitForRedraw()
		end
		RelativeTo.World:removeChild(tempXFORM)
		Actions.waitForRedraw()
		pointTwo = hoveredNode
		if pointTwo ~= nil and (pointOne.name ~= pointTwo.name) then
			print("adding edge")
			g:addEdges{
				DirectedEdge(pointOne.name, pointTwo.name,{color = {1,1,0,1},radius = pointOne.radius/3})
			}
			myWavSound:trigger(1)
		end
	end
end)	