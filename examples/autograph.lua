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

	},
	{

	}
)



g.actionArgs = {small_num = .55,damping = .80, c_mult = 2}
-- local function randColor()
	-- local r = math.random(0,1)
	-- local b = math.random(0,1)
	-- local g = math.random(0,1)
	-- local vec4 = osg.Vec4(r,b,g,1)
	-- print(vec4)
	-- return {vec4:x(),vec4:y(),vec4:z()}
-- end

-- Add random node.
local randomNodeNum = 1
local function addRandomNode(graph)
	local nodename = ("random_%d"):format(randomNodeNum)
	graph:addNodes{
		[nodename] = GraphNode{position = {math.random(-2,2), math.random(-2,2), math.random(-2,2)}}
	}
	randomNodeNum = randomNodeNum + 1
end

function addRandomEdge(graph)
	local n = #(graph.nodes)
	local fromNum = math.random(1, n)
	local toNum = math.random(1, n)
	if fromNum ~= toNum then
		graph:addEdges{
			-- Our simple DirectedEdge constructor wants node names, so we'll get those names from the nodes
			DirectedEdge(graph.nodes[fromNum].name, graph.nodes[toNum].name,{color = randColor()})
		}
	else
		print "Whoops, rolled the same number twice. Not actually adding an edge."
	end
end

-- Some fun things you can try

-- Add some random nodes
for i=1,10 do
	addRandomNode(g)
end

-- Add some random edges
for i=1,10 do
	addRandomEdge(g)
end

RelativeTo.World:addChild(g.osg.root)

--[[Display the edges (in a particular way - notice how this could be useful?)
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

]]--
