--See http://www.lua.org/pil/16.html and http://www.lua.org/pil/16.1.html for more information
require("Actions")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
function runfile(fn) dofile(vrjLua.findInModelSearchPath(fn)) end
g = nil
runfile([[..\graph\loadGraphFiles.lua]])
runfile([[..\graph\simpleLightsGraph.lua]])
dofile(vrjLua.findInModelSearchPath([[textNode.lua]]))

local node1 = createTextNode{
	text = "Node1",
	height = .05,
}
local node2 = createTextNode{
	text = "Node2",
	height = .05,
}
local node3 = createTextNode{
	text = "Node3",
	height = .05,
}
local node4 = createTextNode{
	text = "Node4",
	height = .05,
}
local node5 = createTextNode{
	text = "Node5",
	height = .05,
}

-- RelativeTo.World:addChild(my_block1)

-- A graph is G=(V, E)
g = Graph(
	{
		["one"] = GraphNode{position = {1, 1, 0}, radius = .1};
		["two"] = GraphNode{position = {.75, .5, 0}, radius = .1};
		["three"] = GraphNode{position = {1.1, .5, 0}, radius = .1};
		["four"] = GraphNode{position = {.41, .1, 0}, radius = .05,custom_osg = node4};
		["five"] = GraphNode{position = {1.2, .1, 0}, radius = .05,custom_osg = node5};
	},
	{
		DirectedEdge("one", "two", {labeltext = "",color={1,1,0,1}});
		DirectedEdge("one", "three", {labeltext = "",color={1,1,0,1}});
		DirectedEdge("three", "four", {labeltext = "",color={1,1,0,1}});
		DirectedEdge("three", "five", {labeltext = "",color={1,1,0,1}});
		DirectedEdge("two", "four", {labeltext = "",color={1,1,0,1}});
	}
)

RelativeTo.World:addChild(g.osg.root)
-- g:updateCurrentState("one")

-- local filename = string.match(getScriptFilename(), "(.-)([^\\]-([^%.]+))$").."shortGraph"..".dot"
-- local img_filename = string.match(getScriptFilename(), "(.-)([^\\]-([^%.]+))$").."shortGraph"..".png"
-- g:writeOutDotFile(filename)
-- print(img_filename)
-- os.execute([["C:\Program Files (x86)\Graphviz2.30\bin\dot.exe"]]..[[ -Tpng ]]..filename..[[ -o ]]..img_filename)
-- print([["C:\Program Files (x86)\Graphviz2.30\bin\dot.exe" ]]..filename..[[ -o ]]..filename..[[im]])