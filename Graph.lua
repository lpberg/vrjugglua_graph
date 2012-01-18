
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
				edgeroot = Group{}
			}
		},
		GMT
	)
	self.osg.root = Group{self.osg.noderoot, self.osg.edgeroot}
	self:addNodes(V)
	self:addEdges(E)
	return self
end
