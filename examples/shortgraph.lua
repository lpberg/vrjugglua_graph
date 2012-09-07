--See http://www.lua.org/pil/16.html and http://www.lua.org/pil/16.1.html for more information
require("Actions")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
function runfile(fn) dofile(vrjLua.findInModelSearchPath(fn)) end

runfile([[..\graph\loadGraphFiles.lua]])
runfile([[..\graph\simpleLightsGraph.lua]])


-- A graph is G=(V, E)
g = Graph(
	{
		["one"] = GraphNode{position = {1,1,0},radius = .1};
		["two"] = GraphNode{position = {.75,.5,0},radius = .1};
		["three"] = GraphNode{position = {1.1,.5,0},radius = .1};
		["four"] = GraphNode{position = {.41,.1,0},radius = .1};
		["five"] = GraphNode{position = {1.2,.1,0},radius = .1};
	},
	{
		DirectedEdge("one", "two",{labeltext=""});
		DirectedEdge("one", "three",{labeltext=""});
		-- DirectedEdge("three", "four",{labeltext=""});
		DirectedEdge("three", "five",{labeltext=""});
		DirectedEdge("two", "four",{labeltext=""});
	}
)

RelativeTo.World:addChild(g.osg.root)
g:updateCurrentState("one")
