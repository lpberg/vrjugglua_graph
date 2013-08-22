

-- g:updateCurrentState("one")

-- local filename = string.match(getScriptFilename(), "(.-)([^\\]-([^%.]+))$").."shortGraph"..".dot"
-- local img_filename = string.match(getScriptFilename(), "(.-)([^\\]-([^%.]+))$").."shortGraph"..".png"
-- g:writeOutDotFile(filename)
-- print(img_filename)
-- os.execute([["C:\Program Files (x86)\Graphviz2.30\bin\dot.exe"]]..[[ -Tpng ]]..filename..[[ -o ]]..img_filename)
-- print([["C:\Program Files (x86)\Graphviz2.30\bin\dot.exe" ]]..filename..[[ -o ]]..filename..[[im]])
--See http://www.lua.org/pil/16.html and http://www.lua.org/pil/16.1.html for more information
require("Actions")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
function runfile(fn) dofile(vrjLua.findInModelSearchPath(fn)) end
runfile([[..\..\graph\loadGraphFiles.lua]])
runfile([[..\..\graph\simpleLightsGraph.lua]])
runfile([[readInDOT.lua]])

local function randomGraph()
	local g = Graph({},{})
	local function randColor()
		local r = osgLua.GLfloat(math.random(0,100)/100)
		local b = osgLua.GLfloat(math.random(0,100)/100)
		local g = osgLua.GLfloat(math.random(0,100)/100)
		local a = 1
		return {r,g,b,a}
	end
	local randomNodeNum = 1
	local function addRandomNode(graph)
		local nodename = ("random%d"):format(randomNodeNum)
		graph:addNodes{
			[nodename] = GraphNode{color=randColor(),radius=.05}
		}
		randomNodeNum = randomNodeNum + 1
	end
	function addRandomEdge(graph)
		local n = #(graph.nodes)
		local fromNum = math.random(1, n)
		local toNum = math.random(1, n)
		if fromNum ~= toNum then
			graph:addEdges{
				DirectedEdge(graph.nodes[fromNum].name, graph.nodes[toNum].name,{radius=.01})
			}
		else
			print "Whoops, rolled the same number twice. Not actually adding an edge."
		end
	end
	for i=1,10 do
		addRandomNode(g)
	end
	for i=1,10 do
		addRandomEdge(g)
	end
	return g
end

g = randomGraph()

RelativeTo.World:addChild(g.osg.root)

local function applyGraphVizLayoutAlgorithm(g,posScale)
	local function getFilenameInThisDirectory(name_of_file)
		local file =  string.match(getScriptFilename(), "(.-)([^\\]-([^%.]+))$")..name_of_file
		return file
	end

	local function runGraphVizDot(infile,outfile)
		local command = [["C:\Program Files (x86)\Graphviz2.30\bin\dot.exe" ]]..infile..[[ -o ]]..outfile
		local exit_status = os.execute(command)
		if exit_status ~= 0 then
			print("Graphviz Failed - Exit Code: "..exit_status)
		end
	end

	local function getImageFromDOT(infile,outfile)
		os.execute([["C:\Program Files (x86)\Graphviz2.30\bin\dot.exe" -Tpng ]]..infile..[[ -o ]]..outfile)
	end
	
	local filename = getFilenameInThisDirectory("temp.dot")
	local outfilename = filename..[[OUT]]
	g:writeOutDotFile(filename)
	runGraphVizDot(filename,outfilename)
	-- getImageFromDOT(outfilename,outfilename..".png")
	local g2 = readInDotFile(outfilename)
	for _,node in ipairs(g2.nodes) do
		g.nodes[node.name]:setPosition({node.position[1]/posScale,node.position[2]/posScale,0/posScale})
	end
	os.remove(filename)
	os.remove(outfilename)
end

applyGraphVizLayoutAlgorithm(g,500)


