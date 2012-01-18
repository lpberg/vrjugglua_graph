
local GraphNodeIndex = { isgraphnode = true}

function GraphNodeIndex:createOSG()
	self.osgsphere = Sphere{
		radius = self.radius,
		position = {0, 0, 0}
	}
	self.osg = Transform{
		position = self.position,
		self.osgsphere
	}
end

function GraphNodeIndex:updateOSG()
	-- TODO
	-- if self.position is different than self.xform:getPosition, update
	-- and call update on all edges.
end

local GNMT = { __index = GraphNodeIndex }
GraphNode = function(node)
	-- default value
	node.radius = node.radius or 0.125
	setmetatable(node, GNMT)
	node:createOSG()
	node.parents = {}
	node.children = {}
	node.edges = {}
	return node
end
