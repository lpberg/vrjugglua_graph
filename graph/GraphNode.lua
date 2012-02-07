
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

function GNMT:__tostring()
	local data = {}
	for k, v in pairs(self) do
		if self.tostring_keys_to_skip[k] == nil then
			table.insert(data, table.concat{"[ [[", k, "]] ] = [[", tostring(v), "]]"})
		end
	end
	return table.concat{
		"[ [[",
		self.name,
		"]] ] = GraphNode{ ",
		table.concat(data, ", "),
		"}"
		}
end

function GraphNodeIndex:createOSG()
	self.osgsphere = Sphere{
		radius = self.radius,
		position = {0, 0, 0}
	}
	
	self.indicators = osg.Switch()
	self.indicators:addChild(RedIndicatorSphere())
	self.indicators:setValue(0,false)
	
	
	self.osg = Transform{
		position = self.position,
		self.osgsphere,
		self.indicators,
	}
end
function GraphNodeIndex:highlight(val,childNum)
	childNum = childNum or 0
	self.indicators:setValue(childNum,val)
end

function GraphNodeIndex:setPosition(pos)
	self.position = pos
	self:updateOSG()
end

function GraphNodeIndex:updateOSG()
	--update node pos
	self.osg:setPosition(osg.Vec3d(unpack(self.position)))
	-- TODO
	-- call update on all egdes
	for _,edge in ipairs(self.edges) do
		edge:updateOSG()
	end
end


GraphNode = function(node)
	-- default value
	node.radius = node.radius or 0.125
	setmetatable(node, GNMT)
	node:createOSG()
	node.parents = {}
	node.children = {}
	node.edges = {}
	node.velocity = osg.Vec3(0,0,0)
	return node
end