--See http://www.lua.org/pil/16.html and http://www.lua.org/pil/16.1.html for more information
require("Actions")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())

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
	_,_,node_name = string.find(line,"([%w]*)%s*%[",1)
	node_name = string.gsub(node_name," ","")
	node_name = string.gsub(node_name,"\t","")
	_,_,pos_x,pos_y,pos_z = string.find(line,[[pos=%"(%d*),(%d*),?(%d*)%"]])
	if pos_z == "" then pos_z = 0 end
	print("NODE: "..node_name.." at ("..pos_x..","..pos_y..","..pos_z..")")
	--create graph node
	g:addNodes({[node_name] = GraphNode{position = {pos_x,pos_y,pos_y},radius = .01};})
end

local function createEdge(line,g)
	_,_,node1,node2 = string.find(line,"(%w*)%s*->%s*(%w*)%s*%[")
	print("EDGE from "..node1.." to "..node2)
	--INSERT CODE FOR CREATING EDGE IN GRAPH
	g:addEdges{DirectedEdge(node1, node2,{});}
	
end

local function createGraph(graph)
	for v,line in ipairs(lines) do
		if string.find(line,"digraph ") == nil and string.find(line,"node ") == nil then
			if string.find(line,"->") then
				createEdge(line,graph)
			else
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

