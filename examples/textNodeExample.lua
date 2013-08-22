--See http://www.lua.org/pil/16.html and http://www.lua.org/pil/16.1.html for more information
require("Actions")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
dofile(vrjLua.findInModelSearchPath([[..\graph\loadGraphFiles.lua]]))

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

g = Graph(
	{
		["one"] = GraphNode{position = {1, 1, 0}, radius = .1, custom_osg = node1};
		["two"] = GraphNode{position = {.75, .5, 0}, radius = .1, custom_osg = node2};
		["three"] = GraphNode{position = {1.1, .5, 0}, radius = .1, custom_osg = node3};
		["four"] = GraphNode{position = {.41, .1, 0}, radius = .05, custom_osg = node4};
		["five"] = GraphNode{position = {1.2, .1, 0}, radius = .05, custom_osg = node5};
	},
	{
		DirectedEdge("one", "two", {labeltext = "", color = {1, 1, 0, 1}});
		DirectedEdge("one", "three", {labeltext = "", color = {1, 1, 0, 1}});
		DirectedEdge("three", "four", {labeltext = "", color = {1, 1, 0, 1}});
		DirectedEdge("three", "five", {labeltext = "", color = {1, 1, 0, 1}});
		DirectedEdge("two", "four", {labeltext = "", color = {1, 1, 0, 1}});
	}
)

RelativeTo.World:addChild(g.osg.root)