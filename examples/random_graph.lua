require("Actions")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
function runfile(fn) dofile(vrjLua.findInModelSearchPath(fn)) end
g = nil
runfile([[..\graph\loadGraphFiles.lua]])
runfile([[..\graph\simpleLightsGraph.lua]])
runfile([[..\extras\FDG_Layout.lua]])


local function randomGraph()
	local g = Graph({},{})

	local function randColor()
		local r = osgLua.GLfloat(math.random(25,100)/100)
		local b = osgLua.GLfloat(math.random(25,100)/100)
		local g = osgLua.GLfloat(math.random(25,100)/100)
		local a = 1
		return {r,g,b,a}
	end

	local randomNodeNum = 1
	local function addRandomNode(graph)
		local nodename = ("random_%d"):format(randomNodeNum)
		graph:addNodes{
			[nodename] = GraphNode{position = {math.random(-1,1), math.random(-1,1), math.random(-1,1)},color=randColor()}
		}
		randomNodeNum = randomNodeNum + 1
	end

	function addRandomEdge(graph)
		local n = #(graph.nodes)
		local fromNum = math.random(1, n)
		local toNum = math.random(1, n)
		if fromNum ~= toNum then
			graph:addEdges{
				DirectedEdge(graph.nodes[fromNum].name, graph.nodes[toNum].name,{radius=.1/3, color={1,1,0,1}})
			}
		else
			print "Whoops, rolled the same number twice. Not actually adding an edge."
		end
	end

	-- Add some random nodes
	for i=1,5 do
		addRandomNode(g)
	end

	-- Add some random edges
	for i=1,5 do
		addRandomEdge(g)
	end
	return g
end

graph = randomGraph()

RelativeTo.World:addChild(graph.osg.root)



