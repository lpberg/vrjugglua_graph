require("Actions")
require("getScriptFilename")
require("math")
vrjLua.appendToModelSearchPath(getScriptFilename())
function runfile(fn) dofile(vrjLua.findInModelSearchPath(fn)) end

runfile([[..\graph\loadGraphFiles.lua]])
runfile([[..\graph\simpleLightsGraph.lua]])

g = Graph({},{})

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

RelativeTo.World:addChild(g.osg.root)

function ForceDirectedGraph(args,nodes)

	local function Coulomb_repulsion(vec1,vec2,mult)
		mult = mult or 1
		local lenVec = vec2 - vec1
		local len = lenVec:length()
		local normVec = lenVec * (1/len)
		local magnitude = 1.0/math.pow(len,2)
		local retVec = normVec * magnitude
		return retVec*mult*-1
	end

	local function Hooks_attraction(vec1,vec2,d_desired,k)
		k = k or 1
		local d_desired = d_desired or 1
		local d = (vec2 - vec1):length()
		local d_diff = d - d_desired
		local x = math.abs
		local retVec
		if d_diff < 0 then
			retVec = (vec2 - vec1)
		else
			retVec = (vec1 - vec2)
		end
		return retVec*-k
	end
	--setting up local vars to be used later 
	args.c_mult = args.c_mult or 10
	args.desiredEdgeLength = args.desiredEdgeLength or .5
	args.h_mult = args.h_mult or 50
	if args.coulomb == nil then
		args.coulomb = true
	else
		args.hooks = false
	end
	if args.hooks == nil then
		args.hooks = true
	else
		args.hooks = false
	end
	
	args.small_num = args.small_num or .20
	print("samelll: "..args.small_num)
	args.damping = args.damping or .80
	
	local total_kinetic_energy = 0
	
	local timestep = Actions.waitForRedraw()

	print("Force Directed Graph Layout Algorithm: Started")
	repeat
		--reseting system total_kinetic_energy to zero
		total_kinetic_energy = 0 
		for _, node in ipairs(nodes) do
			--reset net force on current note (in order to recalculate total forces)
			local net_force_on_node = osg.Vec3(0,0,0) 
			--get current node's position
			local nodePos = osg.Vec3(unpack(node.position))
			--calculate Coulomb Forces on node (if set true in args)
			if(args.coulomb) then
				--iterate through every other node and sum forces
				for _, everyOtherNode in ipairs(nodes) do
					if(everyOtherNode.name ~= node.name) then
						local othernodePos = osg.Vec3(unpack(everyOtherNode.position))
						net_force_on_node = net_force_on_node + Coulomb_repulsion(nodePos,othernodePos,args.c_mult)
					end
				end
			end
			timestep = Actions.waitForRedraw()
			--calculate Hooks Forces on node
			if(args.hooks) then
				--iterate through every other node and sum forces
				for _, everyEdgeFromNode in ipairs(node.edges) do
					local othernodePos = osg.Vec3(unpack(everyEdgeFromNode.dest.position))
					net_force_on_node = net_force_on_node + Hooks_attraction(nodePos,othernodePos,args.desiredEdgeLength,args.h_mult)
				end
			end
			--update the node velocity from 
			node.velocity = (node.velocity + (net_force_on_node*timestep)) * args.damping
			 --calculate new position for node based on velocity and timestep
			local newNodePos = nodePos + (node.velocity*timestep)
			--setting new node position as lua table
			node:setPosition({newNodePos:x(),newNodePos:y(),newNodePos:z()})
			--updating total system kinetic engery
			total_kinetic_energy = total_kinetic_energy + (math.pow(node.velocity:length(),2))
			timestep = Actions.waitForRedraw()
		end
	print(total_kinetic_energy)
	until total_kinetic_energy < args.small_num
	print("Force Directed Graph Layout Algorithm: Complete")
	return true
end

local args = {}
-- args.c_mult = 19
-- args.coulomb = false
-- args.hooks = false
-- args.h_mult = 100
args.desiredEdgeLength = .25
args.small_num = 20
args.damping =  .80

function run()
	Actions.addFrameAction(function()
			ForceDirectedGraph(args,g.nodes)
	end)
end