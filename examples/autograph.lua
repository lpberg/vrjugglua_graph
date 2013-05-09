require("Actions")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
function runfile(fn) dofile(vrjLua.findInModelSearchPath(fn)) end

runfile([[..\graph\loadGraphFiles.lua]])
runfile([[..\graph\simpleLightsGraph.lua]])
runfile([[..\extras\FDG_Layout.lua]])


-- A graph is G=(V, E)

local function randomGraph()
	local g = Graph({},{})

	local function randColor()
		local r = osgLua.GLfloat(math.random(-100,100)/100)
		local b = osgLua.GLfloat(math.random(-100,100)/100)
		local g = osgLua.GLfloat(math.random(-100,100)/100)
		local a = 1
		return {r,g,b,a}
	end

	local randomNodeNum = 1
	local function addRandomNode(graph)
		local nodename = ("random_%d"):format(randomNodeNum)
		graph:addNodes{
			[nodename] = GraphNode{position = {math.random(-2,2), math.random(-2,2), math.random(-2,2)},color=randColor()}
		}
		randomNodeNum = randomNodeNum + 1
	end

	function addRandomEdge(graph)
		local n = #(graph.nodes)
		local fromNum = math.random(1, n)
		local toNum = math.random(1, n)
		if fromNum ~= toNum then
			graph:addEdges{
				DirectedEdge(graph.nodes[fromNum].name, graph.nodes[toNum].name,{radius=.1/3})
			}
		else
			print "Whoops, rolled the same number twice. Not actually adding an edge."
		end
	end

	-- Add some random nodes
	for i=1,10 do
		addRandomNode(g)
	end

	-- Add some random edges
	for i=1,10 do
		addRandomEdge(g)
	end
	return g
end

graph = randomGraph()
RelativeTo.World:addChild(graph.osg.root)

local args = {}
-- args.c_mult = 19
-- args.coulomb = false
-- args.hooks = false
args.h_mult = 100
args.desiredEdgeLength = .05
-- args.small_num = .20
args.damping =  .25
function run()
	Actions.addFrameAction(function()
			ForceDirectedGraph(args,g.nodes)
	end)
end

