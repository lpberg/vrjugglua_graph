
-- It may help to think of the __index table as the prototype object
local GraphPrototype = {}
local GMT = {__index = GraphPrototype}

-- I factored this out into a method because you'll probably want to do this at some point
-- after initial construction, and this prevents code duplication.
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
		
		print("Graph: Added GraphNode", node.name)
	end
end

function GraphPrototype:getPathAsEdgeTable(args)
	local edgeTable= {}
	for k,v in ipairs(args) do
		if args[k+1] ~= nil then
			e = self:getEdge(args[k],args[k+1])
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
function GraphPrototype:createChildFromCurrentState(name)
	-- if this is first node , set pos default to 000 - bad idea
	local childPos
	if(#self.currentPath == 0) then
		childPos = {0,0,0}
	else
		childPos = self:getNode(self.currentPath[#self.currentPath]).position
	end
	self:addNodes({[name] = GraphNode{position = {childPos[1],childPos[2]-.5,childPos[3]}}})
	self:addEdges({DirectedEdge(self.currentPath[#self.currentPath], name)})
	--self:updateCurrentState(name)
end
function GraphPrototype:getEdge(srcname,destname)
	for _, edge in ipairs(self.edges) do
		if edge.srcname == srcname and edge.destname == destname then
			return edge
		end
	end
	error("Edge not found in graph", 2)
end

		-- g:getPathAsEdgeTable({"one","two","three"})
function GraphPrototype:getNode(nodename)
	for _, node in ipairs(self.nodes) do
		if node.name == nodename then
			return node
		end
	end
	error("Node:"..nodename.." not found in graph", 2)
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

 Graph = function(V, E)
	local self = setmetatable(
		{
			nodes = {},
			edges = {},
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
