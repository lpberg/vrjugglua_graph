--See http://www.lua.org/pil/16.html and http://www.lua.org/pil/16.1.html for more information
require("Actions")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
function runfile(fn) dofile(vrjLua.findInModelSearchPath(fn)) end

local lines = {}

local function file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then io.close(f) return true else return false end
end

local function organizeData()
	local newlines = {}
	local current_str = ""
	for v,line in ipairs(lines) do
		line = string.gsub(line, "\n", "")
		line = string.gsub(line, "\t", "")
		if string.find(line,";") ~= nil and current_str == "" then
			table.insert(newlines,line)
		else
			if string.find(line,";") then
				current_str = current_str..line
				table.insert(newlines,current_str)
				current_str = ""
			else
				current_str = current_str..line
			end		
		end
	end
	return newlines
end

local function readInFile(filename)
	if file_exists(filename) then
		local file = assert(io.open(filename, "r"))
		for line in file:lines() do
			table.insert(lines, line)
		end
		lines = organizeData(lines)
		file:close()
	end
end

local function createNode(line,g)
	node_name = string.gsub(string.sub(line,1,string.find(line," ")), " ", "")
	start_Idx_of_pos = string.find(line,[[pos="]])
	tempstr = string.sub(line,start_Idx_of_pos+5,string.find(line,[[;]]))
	tempstr = string.sub(tempstr,1,string.find(line,[["]]))
	tempstr = string.sub(tempstr,1,string.find(tempstr,[["]])-1)
	comma = string.find(tempstr,[[,]])
	pos_x = string.sub(tempstr,1,comma-1)
	pos_y = string.sub(tempstr,comma+1,#tempstr)
	print("NODE: "..node_name.." at ("..pos_x..","..pos_y..")")
	--INSERT CODE FOR CREATING NODE IN GRAPH
	g:addNodes({[node_name] = GraphNode{position = {pos_x,pos_y,0},radius = .1};})
end

local function createEdge(line,g)
	end_Idx_of_Src = string.find(line,"-")-1
	start_Idx_of_Dest = string.find(line,">")+1
	end_Idx_of_Dest = string.find(line,"pos")-2
	node1 = string.sub(line,1,end_Idx_of_Src)
	node2 = string.sub(line,start_Idx_of_Dest,end_Idx_of_Dest)
	node1 = string.gsub(node1, " ", "")
	node2 = string.gsub(node2, " ", "")
	print("EDGE from "..node1.." to "..node2)
	--INSERT CODE FOR CREATING EDGE IN GRAPH
	g:addEdges{DirectedEdge(node1, node2);}
	
end

local function createGraph(graph)
	for v,line in ipairs(lines) do
		if string.find(line,"digraph ") == nil and string.find(line,"node ") == nil then
			if string.find(line,"->") then
				--EDGE STUFF HERE
				createEdge(line,graph)
			else
				--EDGE STUFF HERE
				createNode(line,graph)
			end
		end
	end
end

--create new graph regardless of post intention (update/start fresh)
function readInDotFile(filename)
	graph = Graph({},{})
	readInFile(filename)
	createGraph(graph)
	return graph
end

