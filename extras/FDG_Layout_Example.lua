require("Actions")
require("getScriptFilename")
require("math")
vrjLua.appendToModelSearchPath(getScriptFilename())
function runfile(fn) dofile(vrjLua.findInModelSearchPath(fn)) end

runfile([[..\graph\loadGraphFiles.lua]])
runfile([[..\graph\simpleLightsGraph.lua]])

g = Graph({}, {})

local myradius = .05

local randomNodeNum = 1
local function addRandomNode(graph)
	local nodename = ("random_%d"):format(randomNodeNum)
	graph:addNodes{
		[nodename] = GraphNode{position = {math.random(0, 2), math.random(0, 2), math.random(0, 1)},radius = myradius}
	}
	randomNodeNum = randomNodeNum + 1
end

function addRandomEdge(graph)
	local n = #(graph.nodes)
	local fromNum = math.random(1, n)
	local toNum = math.random(1, n)
	if fromNum ~= toNum then
		graph:addEdges{
			DirectedEdge(graph.nodes[fromNum].name, graph.nodes[toNum].name, {radius = myradius/ 3}),
			DirectedEdge(graph.nodes[toNum].name, graph.nodes[fromNum].name, {radius = myradius / 3})
		}
	else
		print "Whoops, rolled the same number twice. Not actually adding an edge."
	end
end

-- Add some random nodes
for i = 1, 10 do
	addRandomNode(g)
end

-- Add some random edges
for i = 1,20 do
	addRandomEdge(g)
end

RelativeTo.World:addChild(g.osg.root)

function ForceDirectedGraph(args, nodes)

	local function Coulomb_repulsion(vec1, vec2)
		args.c_mult = args.c_mult or 1
		local lenVec = vec2 - vec1
		local len = lenVec:length()
		local normVec = lenVec * (1 / len)
		local magnitude = 1.0 / math.pow(len, 2)
		local retVec = normVec * magnitude
		return retVec * args.c_mult * -1
	end

	local function Hooks_attraction(vec1, vec2)
		args.h_mult = args.h_mult or 1
		args.desiredEdgeLength = args.desiredEdgeLength or .5
		local d = (vec2 - vec1):length()
		local d_diff = d - args.desiredEdgeLength
		local x = math.abs
		local retVec
		if d_diff < 0 then
			retVec = (vec2 - vec1)
		else
			retVec = (vec1 - vec2)
		end
		return retVec * -args.h_mult
	end

	if args.coulomb == nil then
		args.coulomb = true
	else
		print("Coulomb Forces Disabled")
		args.coulomb = false
	end
	if args.hooks == nil then
		args.hooks = true
	else
		print("Hooks Forces Disabled")
		args.hooks = false
	end

	args.small_num = args.small_num or .20
	args.damping = args.damping or .80

	local total_kinetic_energy = 0
	local timestep = Actions.waitForRedraw()
	local previous = 0
	print("Force Directed Graph Layout Algorithm: Started")
	repeat
		total_kinetic_energy = 0
		for _, node in ipairs(nodes) do
			local net_force_on_node = osg.Vec3(0, 0, 0)
			local nodePos = osg.Vec3(unpack(node.position))
			if(args.coulomb) then
				for _, everyOtherNode in ipairs(nodes) do
					if(everyOtherNode.name ~= node.name) then
						local othernodePos = osg.Vec3(unpack(everyOtherNode.position))
						net_force_on_node = net_force_on_node + Coulomb_repulsion(nodePos, othernodePos)
					end
				end
			end
			timestep = Actions.waitForRedraw()
			if(args.hooks) then
				for _, everyEdgeFromNode in ipairs(node.edges) do
					local othernodePos = osg.Vec3(unpack(everyEdgeFromNode.dest.position))
					net_force_on_node = net_force_on_node + Hooks_attraction(nodePos, othernodePos)
				end
			end
			node.velocity = (node.velocity + (net_force_on_node * timestep)) * args.damping
			local newNodePos = nodePos + (node.velocity * timestep)
			node:setPosition({newNodePos:x(), newNodePos:y(), newNodePos:z()})
			total_kinetic_energy = total_kinetic_energy + (math.pow(node.velocity:length(), 2))
			timestep = Actions.waitForRedraw()
		end
		print("diff: "..math.abs(total_kinetic_energy - previous))
		previous = total_kinetic_energy
	until total_kinetic_energy < args.small_num
	print("Force Directed Graph Layout Algorithm: Complete")
	return true
end

local args = {}
-- args.c_mult = 190
-- args.coulomb = false?
args.hooks = false
args.h_mult = 100
args.desiredEdgeLength = .756
args.small_num = 20
args.damping = .80

function run()
	Actions.addFrameAction(function()
			ForceDirectedGraph(args, g.nodes)
		end)
end