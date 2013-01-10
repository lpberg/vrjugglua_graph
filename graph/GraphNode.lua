
local GraphNodeIndex = { isgraphnode = true}
local GNMT = { __index = GraphNodeIndex }

GraphNodeIndex.tostring_keys_to_skip = {
	["name"] = true, -- gets used elsewhere
	["edges"] = true,
	["parents"] = true,
	["children"] = true,
	["osg"] = true,
	["osgsphere"] = true,
	["tostring_keys_to_skip"] = true
}

-- function GNMT:__tostring()
	-- local data = {}
	-- for k, v in pairs(self) do
		-- if self.tostring_keys_to_skip[k] == nil then
			-- table.insert(data, table.concat{"[ [[", k, "]] ] = [[", tostring(v), "]]"})
		-- end
	-- end
	-- return table.concat{
		-- "[ [[",
		-- self.name,
		-- "]] ] = GraphNode{ ",
		-- table.concat(data, ", "),
		-- "}"
		-- }
-- end

function GraphNodeIndex:createOSG()
	self.osgsphere = ColorSphere{
		radius = self.radius,
		position = {0, 0, 0},
		color = self.color,
	}
	self.node_controll_switch = osg.Switch()
	self.transparent_low = TransparentGroup{alpha=.25}
	self.transparent_high = TransparentGroup{alpha=.75}
	self.transparent_custom = TransparentGroup{alpha=self.transparent_custom or .25}
	self.transparent_low:addChild(self.osgsphere)
	self.transparent_high:addChild(self.osgsphere)
	self.transparent_custom:addChild(self.osgsphere)
	
	
	self.node_controll_switch:addChild(self.osgsphere)
	self.node_controll_switch:addChild(self.transparent_low)
	self.node_controll_switch:addChild(self.transparent_high)
	self.node_controll_switch:addChild(self.transparent_custom)
	
	self.node_controll_switch:setSingleChildOn(0)
	
	
	self.indicators = osg.Switch()
	self.indicators:addChild(RedIndicatorSphere(self.radius*1.5))
	self.indicators:addChild(GreenIndicatorSphere(self.radius*2))
	self.indicators:setValue(0,false)
	self.indicators:setValue(1,false)
	
	self.osg = Transform{
		position = self.position,
		self.node_controll_switch,
		self.indicators,
	}
end

function GraphNodeIndex:setLowTransparency()
	self.node_controll_switch:setSingleChildOn(2)
end
function GraphNodeIndex:setHighTransparency()
	self.node_controll_switch:setSingleChildOn(1)
end
function GraphNodeIndex:setNoTransparency()
	self.node_controll_switch:setSingleChildOn(0)
end

function GraphNodeIndex:setColor(color)
	self.color = color
	self.osgsphere:getDrawable(0):setColor(osg.Vec4(unpack(color)))
end

function GraphNodeIndex:highlight(val,childNum)
	childNum = childNum or 0
	self.indicators:setValue(childNum,val)
	if val then
		self.isHighlighted = true
	else
		self. isHighlighted = false
	end
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
	-- default value
	
	node.radius = node.radius or 0.125
	node.color = node.color or {1,1,1,1}
	setmetatable(node, GNMT)
	node:createOSG()
	node.parents = {}
	node.children = {}
	node.edges = {}
	node.velocity = osg.Vec3(0,0,0)
	node.isHighlighted = false
	return node
end
