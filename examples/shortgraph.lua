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
		["two"] = GraphNode{position = {-.1,.5,0},radius = .1};
		["three"] = GraphNode{position = {1,-1,1},radius = .1};
		["four"] = GraphNode{position = {1,2,0},radius = .1};
	},
	{
		DirectedEdge("one", "two",{labeltext="default1"});
		DirectedEdge("two", "three",{labeltext="default2"});
		DirectedEdge("three", "four",{labeltext="default3"});
		DirectedEdge("four", "one",{labeltext="default4"});
	}
)

RelativeTo.World:addChild(g.osg.root)
-- Some fun stuff follows here.
--g:getPathAsEdgeTable(arg)

g.actionArgs = {small_num = .55,damping = .80, c_mult = 2}


-- Add random node.
-- do
	-- putting this in a block so you can't get to randomNodeNum from outside
	-- essentially just creating a closure
	-- local randomNodeNum = 1

	-- addRandomNode is a global variable so it's accessible from outside this extra do-end block
	-- function addRandomNode(graph)
		-- local nodename = ("random_%d"):format(randomNodeNum)
		-- graph:addNodes{
			-- [nodename] = GraphNode{position = {math.random(-2,2), math.random(-2,2), math.random(-2,2)}}
		-- }
		-- randomNodeNum = randomNodeNum + 1
	-- end
-- end

-- function addRandomEdge(graph)
	-- local n = #(graph.nodes)
	-- local fromNum = math.random(1, n)
	-- local toNum = math.random(1, n)
	-- if fromNum ~= toNum then
		-- graph:addEdges{
			-- Our simple DirectedEdge constructor wants node names, so we'll get those names from the nodes
			-- DirectedEdge(graph.nodes[fromNum].name, graph.nodes[toNum].name)
			--[[
			if that's a bit much to follow, remember, that line is equivalent to:
			DirectedEdge(graph["nodes"][fromNum]["name"], graph["nodes"][toNum]["name"])
			]]
		-- }
	-- else
		-- print "Whoops, rolled the same number twice. Not actually adding an edge."
	-- end
-- end

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

-- Display the nodes kind of like how we did the edges - not complete, of course, but the idea is there.
for _, node in ipairs(g.nodes) do
	print(node) -- uses the __tostring metamethod
end

]]
