require("Actions")
require("getScriptFilename")
require("TransparentGroup")
vrjLua.appendToModelSearchPath(getScriptFilename())
dofile(vrjLua.findInModelSearchPath([[..\graph\loadGraphFiles.lua]]))

g = Graph(
	{
		["one"] = GraphNode{position = {0,0,0},radius = .13};
		["two"] = GraphNode{position = {0,1,0},radius = .13};
		--["two"] = GraphNode{position = {0,1,0},radius = .03,color = red}; 
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
			for _,node in ipairs(g.nodes) do
				local distance = (osg.Vec3d(unpack(node.position))-device_pos):length()
				if math.abs(distance) < (node.radius*3) then
					node:highlight(true)
					hoveredNode = node
					Actions.waitForRedraw()
				else
					node:highlight(false)
					Actions.waitForRedraw()
				end
			end
		end
	end
)
Actions.addFrameAction(function()
	local drawBtn = gadget.DigitalInterface("VJButton2")
	while true do
		repeat
			Actions.waitForRedraw()
		until drawBtn.justPressed
		print(hoveredNode.name)
	end
end)	