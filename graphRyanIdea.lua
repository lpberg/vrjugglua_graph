--See http://www.lua.org/pil/16.html and http://www.lua.org/pil/16.1.html for more information
require("Actions")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
--dofile(vrjLua.findInModelSearchPath([[simpleLightsGraph.lua]]))
function runfile(fn) dofile(vrjLua.findInModelSearchPath(fn)) end

-- I split stuff up since it got hard to read once I commented it
runfile("DirectedEdge.lua")
runfile("GraphNode.lua")
runfile("Graph.lua")

-- A graph is G=(V, E)
g = Graph(
	{
		["one"] = GraphNode{position = {-1,-1,0}};
		["two"] = GraphNode{position = {-1,1,0}};
		["three"] = GraphNode{position = {1,-1,0}};
		["four"] = GraphNode{position = {1,1,0}};
	},
	{
		DirectedEdge("one", "two");
		DirectedEdge("two", "three");
		DirectedEdge("three", "four");
		DirectedEdge("four", "one");
	}
)

RelativeTo.World:addChild(g.osg.root)


-- Some fun stuff follows here.

-- Add random node.
do
	-- putting this in a block so you can't get to randomNodeNum from outside
	-- essentially just creating a closure
	local randomNodeNum = 1

	-- addRandomNode is a global variable so it's accessible from outside this extra do-end block
	function addRandomNode(graph)
		local nodename = ("random_%d"):format(randomNodeNum)
		graph:addNodes{
			[nodename] = GraphNode{position = {math.random(-2,2), math.random(-2,2), math.random(-2,2)}}
		}
		randomNodeNum = randomNodeNum + 1
	end
end

function addRandomEdge(graph)
	local n = #(graph.nodes)
	local fromNum = math.random(1, n)
	local toNum = math.random(1, n)
	if fromNum ~= toNum then
		graph:addEdges{
			-- Our simple DirectedEdge constructor wants node names, so we'll get those names from the nodes
			DirectedEdge(graph.nodes[fromNum].name, graph.nodes[toNum].name)
			--[[
			if that's a bit much to follow, remember, that line is equivalent to:
			DirectedEdge(graph["nodes"][fromNum]["name"], graph["nodes"][toNum]["name"])
			]]
		}
	else
		print "Whoops, rolled the same number twice. Not actually adding an edge."
	end
end

--[[ Some fun things you can try

-- Add some random nodes
for i=1,5 do
	addRandomNode(g)
end

-- Add some random edges
for i=1,5 do
	addRandomEdge(g)
end

-- Display the edges (in a particular way - notice how this could be useful?)
for _, e in ipairs(g.edges) do
	print(e) -- uses the __tostring metamethod
end

-- Display some info about the nodes.
for i, node in ipairs(g.nodes) do
	print( ("Node named '%s' (internal ID %d), has %d parents and %d children"):format(node.name, i, #(node.parents), #(node.children)) )
end

]]
