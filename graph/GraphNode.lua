
local GraphNodeIndex = { isgraphnode = true}
local GNMT = { __index = GraphNodeIndex }

function GraphNodeIndex:createOSG()
	self.osgsphere = ColorSphere{
		radius = self.radius,
		position = {0, 0, 0},
		color = self.color,
	}
	
	--overwrite osgsphere if custom node was passed
	self.osgsphere = self.custom_osg or self.osgsphere
	
	self.node_control_switch = osg.Switch()
		
	self.node_control_switch:addChild(self.osgsphere)
	
	self.node_control_switch:setSingleChildOn(0)
	
	--indicator switch used for highlighting nodes
	self.indicators = osg.Switch()
	self.indicators:addChild(RedIndicatorSphere(self.radius*1.5))
	self.indicators:setValue(0,false)
	-- self.indicators:setValue(1,false)
	
	self.osg = Transform{
		position = self.position,
		self.node_control_switch,
		self.indicators,
	}
end

function GraphNodeIndex:setColor(color)
	if self.custom_osg == nil then
		self.color = color
		self.osgsphere:getDrawable(0):setColor(osg.Vec4(unpack(color)))
	end
end

function GraphNodeIndex:highlight(val,indicatorNum)
	indicatorNum = indicatorNum or 0
	self.indicators:setValue(indicatorNum,val)
	self.isHighlighted = val
end

function GraphNodeIndex:setPosition(pos)
	self.position = pos
	self:updateOSG()
end

function GraphNodeIndex:updateOSG()
	self.osg:setPosition(osg.Vec3d(unpack(self.position)))
	for _,edge in ipairs(self.edges) do
		edge:updateOSG()
	end
end

GraphNode = function(node)
	node.isHighlighted = false
	node.position = node.position or {0,0,0}
	node.label = node.label or node.labeltext or "default_label" --not implemented
	node.fontcolor = node.fontcolor or {1,1,1,1} --not implemented
	node.radius = node.radius or 0.125
	node.color = node.color or {1,1,1,1}
	node.fillcolor = node.color 
	setmetatable(node, GNMT)
	node:createOSG()
	node.parents = {}
	node.children = {}
	node.edges = {}
	-- node.velocity = osg.Vec3(0,0,0)
	return node
end