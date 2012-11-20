--See http://www.lua.org/pil/16.html and http://www.lua.org/pil/16.1.html for more information
require("Actions")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
function runfile(fn) dofile(vrjLua.findInModelSearchPath(fn)) end

runfile([[..\graph\loadGraphFiles.lua]])
runfile([[..\graph\simpleLightsGraph.lua]])
runfile([[..\extras\FDG_Layout.lua]])


-- A graph is G=(V, E)
g = Graph(
	{

	},
	{

	}
)

local function randColor()
	local r = osgLua.GLfloat(math.random(-100,100)/100)
	local b = osgLua.GLfloat(math.random(-100,100)/100)
	local g = osgLua.GLfloat(math.random(-100,100)/100)
	local a = osgLua.GLfloat(math.random(-100,100)/100)
	return {r,g,b,a}
end

-- Add random node.
local randomNodeNum = 1
local function addRandomNode(graph)
	local nodename = ("random_%d"):format(randomNodeNum)
	graph:addNodes{
		[nodename] = GraphNode{position = {math.random(-2,2), math.random(-2,2), math.random(-2,2)},color = randColor()}
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
			DirectedEdge(graph.nodes[fromNum].name, graph.nodes[toNum].name,{color = randColor(), labeltext = "label" ,labelSize=.15, highlightColor=randColor()})
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
for i=1,25 do
	addRandomEdge(g)
end

RelativeTo.World:addChild(g.osg.root)

args={}
args.c_mult = 100
args.h_mult = 100
args.desiredEdgeLength = 2
args.small_num = .20
args.damping =  .05

Actions.addFrameAction(function()
		ForceDirectedGraph({},g.nodes)
end)

