 local GraphPrototype = {}
local GMT = {__index = GraphPrototype}
math.randomseed(os.time())
math.random()

function GraphPrototype:addNodes(nodes)
	for nodename, node in pairs(nodes) do
		assert(self.nodes[nodename] == nil, "Node name already used!")
		self.nodes[nodename] = node
		table.insert(self.nodes, node)
		node.name = nodename
		self.osg.noderoot:addChild(node.osg)
		-- print("Graph: Added GraphNode:", node.name)
	end
end

function GraphPrototype:getNodesAndEdgesFromPath(args)
	local items = {}
	for _, n in ipairs(args) do
		table.insert(items, self.nodes[n])
	end
	for k, v in ipairs(args) do
		if args[k + 1] ~= nil then
			local e = self:getEdge(args[k], args[k + 1])
			table.insert(items, e)
		end
	end
	return items
end

function GraphPrototype:setTransparencyForPath(args)
	local nodes_and_edges = self:getNodesAndEdgesFromPath(args)
	for _, b in ipairs(nodes_and_edges) do
		b:setHighTransparency()
	end
end

function GraphPrototype:getPathAsEdgeTable(args)
	local edgeTable = {}
	for k, v in ipairs(args) do
		if args[k + 1] ~= nil then
			local e = self:getEdge(args[k], args[k + 1])
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
	for _, node in ipairs(self.currentPath) do
		print(node)
	end
end

-- function GraphPrototype:updateColorOfChildren(name)
	-- local node = self.nodes[name]
	-- for _, child in ipairs(node.children) do
		-- local edgeOfInterest = self:getEdge(name, child.name)
		-- if (edgeOfInterest.destColor ~= nil) then
			-- child:setColor(edgeOfInterest.destColor)
		-- end
	-- end
-- end

-- function GraphPrototype:DFSLowTransparencyGraph(state_name)
-- root = self.nodes[state_name]
-- root:setLowTransparency()
-- for _,child in ipairs(root.children) do
-- edge = self:getEdge(state_name,child.name)
-- edge:setLowTransparency()
-- self:DFSLowTransparencyGraph(child.name)
-- end
-- end
-- function GraphPrototype:DFSHighTransparencyGraph(state_name)
-- root = self.nodes[state_name]
-- root:setHighTransparency()
-- for _,child in ipairs(root.children) do
-- edge = self:getEdge(state_name,child.name)
-- edge:setHighTransparency()
-- self:DFSHighTransparencyGraph(child.name)
-- end
-- end
-- function GraphPrototype:DFSNoTransparencyGraph(state_name)
-- root = self.nodes[state_name]
-- root:setNoTransparency()
-- for _,child in ipairs(root.children) do
-- edge = self:getEdge(state_name,child.name)
-- edge:setNoTransparency()
-- self:DFSNoTransparencyGraph(child.name)
-- end
-- end	

-- function GraphPrototype:updateTransparencyEffects(state_name)
-- make all barely visible 
-- for _,node in ipairs(self.nodes) do
-- node:setHighTransparency()
-- end
-- for _,edge in ipairs(self.edges) do
-- edge:setHighTransparency()
-- end
-- update sibling transparency to low
-- for _,parent in ipairs(self.nodes[state_name].parents) do
-- self:DFSLowTransparencyGraph(parent.name)
-- end
-- no transparency on state
-- self:DFSNoTransparencyGraph(state_name)
-- end

function GraphPrototype:updateCurrentState(state_name)
	self:hideAllEdgeLabels()
	--Does the node / state exist in the graph yet
	assert(self:getNode(state_name) ~= nil)

	--Is this the first state in the graph?
	if(#self.currentPath == 0) then
		--add to current path table
		table.insert(self.currentPath, state_name)
		--highlight the new "current node"
		self:getNode(state_name):highlight(true)
		--enable: show labels on child edges
		--self:showLabelsOnChildrenEdges(state_name)

	--Else, if current path is not empty 
	else
		--disable all node highlighting
		self:disableNodeHighlighting()
		--iterate through current path table to see if we went backwards 'up' the graph to a previous state
		local currentStateFound = false
		for idx, stateName in ipairs(self.currentPath) do
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
			table.insert(self.currentPath, state_name)
		end
		--turn on highlighting for current node
		self:getNode(state_name):highlight(true)
		--update the visualization for the highlighted path
		self:updateHighlightedPath()
		--updated the color of the children nodes according to 'dest'
		-- self:updateColorOfChildren(state_name)
		--show the labels for the current nodes children only
		--self:showLabelsOnChildrenEdges(state_name)
		--update transparency - not in use right now
		-- self:updateTransparencyEffects(state_name)
	end
end

function GraphPrototype:getEdge(srcname, destname)
	for _, edge in ipairs(self.edges) do
		if edge.srcname == srcname and edge.destname == destname then
			return edge
		end
	end
	print("Graph:getEdge - Edge Not Found")
	return nil
	-- if (self.nodes[srcname] ~= nil and self.nodes[destname] ~= nil) then
		-- print("edge not found in graph...creating one..")
		-- local myNodeRadius = self.nodes[1].radius or .01
		-- self:addEdges({DirectedEdge(srcname, destname, {radius = (myNodeRadius / (8))})})
		-- return self:getEdge(srcname, desname)
	-- else
		-- print("could not create edge as one or both of node names are not currently nodes")
	-- end
end

function GraphPrototype:getNode(nodename)
	for _, node in ipairs(self.nodes) do
		if node.name == nodename then
			return node
		end
	end
	print("Graph:getNode - Node Not Found")
	return nil
end

function GraphPrototype:getNodeWithChildren(nodename)
	local nodes = {}
	local parent = self:getNode(nodename)
	table.insert(nodes, parent)
	for _, child in ipairs(parent.children) do
		table.insert(nodes, child)
	end
	return nodes
end

function GraphPrototype:edgeExists(newedge)
	for _, edge in ipairs(self.edges) do
		if edge.srcname == newedge.srcname and edge.destname == newedge.destname then
			return true
		end
	end
	return false
end

function GraphPrototype:showLabelsOnChildrenEdges(state_name)
	for _, child in ipairs(self.nodes[state_name].children) do
		local edge = self:getEdge(state_name, child.name)
		edge:showLabel()
	end
end

function GraphPrototype:hideLabelsOnChildrenEdges(state_name)
	for _, child in ipairs(self.nodes[state_name].children) do
		local edge = self:getEdge(state_name, child.name)
		edge:hideLabel()
	end
end

function GraphPrototype:hideAllEdgeLabels()
	for _, edge in ipairs(self.edges) do
		edge:hideLabel()
	end
end

function GraphPrototype:writeOutDotFile(filename)
	local outfile = io.open(filename, "w")
	local outstr = "digraph G {\n"
	--write out nodes
	for _, node in ipairs(self.nodes) do
		--adding node name lable
		outstr = outstr .. '\t' .. node.name .. " [" .. 'label="' .. node.name .. '",'
		--TODO: not sure how to conver color systems...?
		-- outstr = outstr..'fillcolor="'..node.label..'",'
		outstr = outstr .. 'width="' .. (node.radius * 2) .. '",'
		outstr = outstr .. 'height="' .. (node.radius * 2) .. '",'
		--adding final newline
		outstr = outstr .. "];\n"
	end
	--write out connections
	for _, edge in ipairs(self.edges) do
		outstr = outstr .. '\t' .. edge.src.name .. " -> " .. edge.dest.name .. ";\n"
	end
	outstr = outstr .. "}"
	outfile:write(outstr)
	outfile:close()
	print(filename .. " created")
end

function GraphPrototype:addEdges(edges)
	for _, edge in ipairs(edges) do
		if not self:edgeExists(edge) then
			-- Look up the source and destination graphnode by name.
			assert(self.nodes[edge.srcname], "Graph:addEdges - Source name of edge unknown!")
			edge.src = self.nodes[edge.srcname]

			assert(self.nodes[edge.destname], "Graph:addEdges - Destination name of edge unknown!")
			edge.dest = self.nodes[edge.destname]

			-- The source node is told about this edge and its child
			table.insert(edge.src.edges, edge)
			table.insert(edge.src.children, edge.dest)

			-- The destination node is told about this edge and its parent
			table.insert(edge.dest.edges, edge)
			table.insert(edge.dest.parents, edge.src)

			-- We add this edge to our list of edges.
			table.insert(self.edges, edge)

			--TODO: Hack - need to tell edge object radius of src geometry for arrows
			-- edge.src_radius = edge.src_radius or self.nodes[1].radius
			edge.src_radius = edge.src_radius or edge.dest.radius

			-- Visualization
			edge:createOSG()
			self.osg.edgeroot:addChild(edge.osg)
			print("Graph:addEdges -  Added DirectedEdge from", edge.srcname, "to", edge.destname)
		else
			print("Graph:addEdges - Edge ", edge.srcname, " to ", edge.destname, " Already Exists")
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
