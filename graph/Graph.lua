local GraphPrototype = {}
local GMT = {__index = GraphPrototype}
math.randomseed(os.time())
math.random()

function GraphPrototype:addNodes(nodes)
	for nodename, node in pairs(nodes) do
		assert(self.nodes[nodename] == nil, "Node name already used!")
		-- Add to the graph's nodes table by name
		self.nodes[nodename] = node
		-- For fun, let's also keep them in an array-style, too,
		-- so #(graph.nodes) is useful and you can
		-- randomly pick a node by generating a number.
		table.insert(self.nodes, node)
		-- Tell each node its name, in case it's curious
		node.name = nodename
		-- Add the node to the scenegraph
		self.osg.noderoot:addChild(node.osg)
		print("Graph: Added GraphNode:", node.name)
	end
end

function GraphPrototype:getPathAsEdgeTable(args)
	local edgeTable= {}
	for k,v in ipairs(args) do
		if args[k+1] ~= nil then
			local e = self:getEdge(args[k],args[k+1])
			edgeTable[k] = e
		end
	end
	return edgeTable
end

function GraphPrototype:disablePathHighlighting()
	for _, edge in ipairs(self.edges) do
		edge:highlight(false)
	end
end

function GraphPrototype:disableNodeHighlighting()
	for _, node in ipairs(self.nodes) do
		node:highlight(false)
	end
end

function GraphPrototype:highlightPath(edgeTable)
	for _, edge in ipairs(edgeTable) do
		edge:highlight(true)
	end
end

function GraphPrototype:updateHighlightedPath()
	self:disablePathHighlighting()
	self:highlightPath(self:getPathAsEdgeTable(self.currentPath))
end

function GraphPrototype:createChildFromCurrentState(name)
	print("Creating new node")
	local childPos
	if(#self.currentPath == 0) then
		childPos = {0,0,0}
	else
		childPos = self:getNode(self.currentPath[#self.currentPath]).position
	end
	local myNodeRadius = self.nodes[1].radius or .01
	if (#self:getNode(self.currentPath[#self.currentPath]).children > 0) then
		local lastChild = #self:getNode(self.currentPath[#self.currentPath]).children
		childPos = self:getNode(self.currentPath[#self.currentPath]).children[lastChild].position
		self:addNodes({[name] = GraphNode{position = {childPos[1]+.125,childPos[2],childPos[3]},radius = myNodeRadius}})
	else
		local rand = math.random(1,50)
		rand = rand/1000
		print(rand)
		self:addNodes({[name] = GraphNode{position = {childPos[1]+rand,childPos[2]-self.actionArgs.desiredEdgeLength,childPos[3]},radius = myNodeRadius}})
	end
	self:addEdges({DirectedEdge(self.currentPath[#self.currentPath], name,{radius = (myNodeRadius/(4*2))})})
end

function GraphPrototype:printCurrentPath()
	for _,v in ipairs(self.currentPath) do
		print(v)
	end
end

function GraphPrototype:updateColorOfChildren(name)
	local node = self.nodes[name]
	for _,child in ipairs(node.children) do
		local edgeOfInterest = self:getEdge(name,child.name) 
		if (edgeOfInterest.destColor ~= nil) then
			child:setColor(edgeOfInterest.destColor)
		end
	end
end

function GraphPrototype:updateCurrentState(state_name)
	local childCreatedThisExecution = false
	--Does the node / state exist in the graph yet?, if not then create one
	if (self:getNode(state_name) == nil) then
		self:createChildFromCurrentState(state_name)
		childCreatedThisExecution = true
	end
	--Is this the first state in the graph?, then add it and highlight node
	if(#self.currentPath == 0) then
		table.insert(self.currentPath,state_name)
		self:getNode(state_name):highlight(true)
		self:printCurrentPath()
	--if its not the first, find newest path, and update graphics
	else
		self:disableNodeHighlighting()
		local currentStateFound = false
		for idx,stateName in ipairs(self.currentPath) do
			if(currentStateFound == false) then
				if(stateName == state_name) then
					currentStateFound = true
				end
			else
				self.currentPath[idx] = nil
			end
		end
		--wasn't in the path, add it
		if(currentStateFound == false) then
			table.insert(self.currentPath,state_name)
		end
		self:getNode(state_name):highlight(true)
		self:updateHighlightedPath()
		-- if new child created and a parent exists call FDG on its parent
		if (#self.currentPath > 1 and childCreatedThisExecution) then
			-- local nodesOfInterest = self:getNodeWithChildren(self.currentPath[#self.currentPath - 1
			local parent = self:getNode(self.currentPath[#self.currentPath - 1])
			
			--self.actionArgs.coulomb = false
			self:performAction({parent})
			--self.actionArgs.coulomb = true
			self:performAction(parent.children)
		end
		self:updateHighlightedPath()
		self:updateColorOfChildren(state_name)
	end
end

function GraphPrototype:getEdge(srcname,destname)
	for _, edge in ipairs(self.edges) do
		if edge.srcname == srcname and edge.destname == destname then
			return edge
		end
	end
	
	if (self.nodes[srcname] ~= nil and self.nodes[destname] ~= nil) then
		print("edge not found in graph...creating one..")
		local myNodeRadius = self.nodes[1].radius or .01
		self:addEdges({DirectedEdge(srcname, destname,{radius = (myNodeRadius/(8))})})
		return self:getEdge(srcname,desname) 
	else
		print("could not create edge as one or both of node names are not currently nodes...:(")
	end
	
end

function GraphPrototype:getNode(nodename)
	local retNode = nil
	for _, node in ipairs(self.nodes) do
		if node.name == nodename then
			retNode = node
		end
	end
	return retNode
end

function GraphPrototype:getNodeWithChildren(nodename)
	local nodes = {}
	local parent = self:getNode(nodename)
	table.insert(nodes,parent)
	for _,child in ipairs(parent.children) do
		table.insert(nodes,child)
	end
	return nodes
end

function GraphPrototype:performAction(nodes)
	local function addFrameActionNow()
		self:ForceDirectedGraph(self.actionArgs,nodes)
	end
	Actions.addFrameAction(addFrameActionNow)
end


function GraphPrototype:addEdges(edges)
	for _, edge in ipairs(edges) do
		-- Look up the source and destination graphnode by name.
		assert(self.nodes[edge.srcname], "Source name of edge unknown!")
		edge.src = self.nodes[edge.srcname]

		assert(self.nodes[edge.destname], "Destination name of edge unknown!")
		edge.dest = self.nodes[edge.destname]

		-- The source node is told about this edge and its child
		table.insert(edge.src.edges, edge)
		table.insert(edge.src.children, edge.dest)

		-- The destination node is told about this edge and its parent
		table.insert(edge.dest.edges, edge)
		table.insert(edge.dest.parents, edge.src)

		-- We add this edge to our list of edges.
		table.insert(self.edges, edge)

		-- Visualization
		edge:createOSG()
		self.osg.edgeroot:addChild(edge.osg)

		print("Graph: Added DirectedEdge from", edge.srcname, "to", edge.destname)
	end
end

function GraphPrototype:ForceDirectedGraph(args,nodes)
	local nodes = nodes or self.nodes
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
	args.desiredEdgeLength = args.desiredEdgeLength or 1
	args.h_mult = args.h_mult or 50
	args.coulomb = args.coulomb or true
	args.hooks = args.hooks or true
	args.small_num = args.small_num or .20
	args.damping = args.damping or .80
	
	local total_kinetic_energy = 0
	local timestep = Actions.waitForRedraw()

	print("Force Directed Graph Layout Algorithm: Started")
	 repeat
		--reseting system total_kinetic_energy to zero
		 total_kinetic_energy = 0 
		 for _, node in ipairs(nodes) do
			 --reset net force on current note (to recalculate)
			 local net_force_on_node = osg.Vec3(0,0,0) 
			 --get this nodes position
			 local nodePos = osg.Vec3(unpack(node.position))
			 --calculate Coulomb Forces on node
			if(args.coulomb) then
				 for _, everyOtherNode in ipairs(nodes) do
					if(everyOtherNode.name ~= node.name) then
						local othernodePos = osg.Vec3(unpack(everyOtherNode.position))
						net_force_on_node = net_force_on_node + Coulomb_repulsion(nodePos,othernodePos,args.c_mult)
					end
				end
			end
			--calculate Hooks Forces on node
			if(args.hooks) then
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
	until total_kinetic_energy < args.small_num
	print("Force Directed Graph Layout Algorithm: Complete")
	return true
end



 Graph = function(V, E)
	local self = setmetatable(
		{
			nodes = {},
			edges = {},
			currentPath = {},
			osg = {
				noderoot = Group{},
				edgeroot = Group{},
			}
		},
		GMT
	)
	self.osg.root = Group{self.osg.noderoot, self.osg.edgeroot}
	self:addNodes(V)
	self:addEdges(E)
	return self
end
