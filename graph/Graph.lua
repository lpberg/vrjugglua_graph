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

function GraphPrototype:DFSLowTransparencyGraph(state_name)
	root = self.nodes[state_name]
	root:setLowTransparency()
	for _,child in ipairs(root.children) do
		edge = self:getEdge(state_name,child.name)
		edge:setLowTransparency()
		self:DFSLowTransparencyGraph(child.name)
	end
end
function GraphPrototype:DFSHighTransparencyGraph(state_name)
	root = self.nodes[state_name]
	root:setHighTransparency()
	for _,child in ipairs(root.children) do
		edge = self:getEdge(state_name,child.name)
		edge:setHighTransparency()
		self:DFSHighTransparencyGraph(child.name)
	end
end
function GraphPrototype:DFSNoTransparencyGraph(state_name)
	root = self.nodes[state_name]
	root:setNoTransparency()
	for _,child in ipairs(root.children) do
		edge = self:getEdge(state_name,child.name)
		edge:setNoTransparency()
		self:DFSNoTransparencyGraph(child.name)
	end
end	

function GraphPrototype:updateTransparencyEffects(state_name)
	-- make all barely visible 
	for _,node in ipairs(self.nodes) do
			node:setHighTransparency()
	end
	for _,edge in ipairs(self.edges) do
			edge:setHighTransparency()
	end
	-- update sibling transparency to low
	for _,parent in ipairs(self.nodes[state_name].parents) do
		self:DFSLowTransparencyGraph(parent.name)
	end
	-- no transparency on state
	self:DFSNoTransparencyGraph(state_name)
end

function GraphPrototype:updateCurrentState(state_name)
	self:hideAllEdgeLabels()
	--Does the node / state exist in the graph yet
	assert(self:getNode(state_name) ~= nil) 

	--Is this the first state in the graph?
	if(#self.currentPath == 0) then
		--add to current path table
		table.insert(self.currentPath,state_name)
		--highlight the new "current node"
		self:getNode(state_name):highlight(true)
		--enable: show labels on child edges
		--self:showLabelsOnChildrenEdges(state_name)

	--Else, if current path has stuff in it 
	else
		--disable all node highlighting
		self:disableNodeHighlighting()
		
		--iterate through current path table to see if we went backwards 'up' the graph to a previous state
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
		--if newstate wasn't in the path, add it to the end
		if(currentStateFound == false) then
			table.insert(self.currentPath,state_name)
		end
		--turn on highlighting for current node
		self:getNode(state_name):highlight(true)
		--update the visualization for the highlighted path
		self:updateHighlightedPath()
		--updated the color of the children nodes according to 'dest'
		self:updateColorOfChildren(state_name)
		--show the labels for the current nodes children only
		--self:showLabelsOnChildrenEdges(state_name)
		--update transparency - not in use right now
		-- self:updateTransparencyEffects(state_name)
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
		print("could not create edge as one or both of node names are not currently nodes")
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

function GraphPrototype:edgeExists(newedge)
	local found = false
	for _, edge in ipairs(self.edges) do 
		if edge.srcname == newedge.srcname and edge.destname == newedge.destname then
			found = true
		end
	end
	return found
end
function GraphPrototype:showLabelsOnChildrenEdges(state_name)
	for _,child in ipairs(self.nodes[state_name].children) do
		local edge = self:getEdge(state_name,child.name)
		edge:showLabel()
	end
end
function GraphPrototype:hideLabelsOnChildrenEdges(state_name)
	for _,child in ipairs(self.nodes[state_name].children) do
		local edge = self:getEdge(state_name,child.name)
		edge:hideLabel()
	end
end
function GraphPrototype:hideAllEdgeLabels()
	for _,edge in ipairs(self.edges) do
		edge:hideLabel()
	end
end

function GraphPrototype:addEdges(edges)
	for _, edge in ipairs(edges) do
		if not self:edgeExists(edge) then
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
		else
			print("Edge ",edge.srcname," to ",edge.destname," Already Exists")
		end
	end
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
