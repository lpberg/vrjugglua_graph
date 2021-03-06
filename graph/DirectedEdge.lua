-- Set up __index table for DirectedEdge metatable
local DirectedEdgeIndex = { isedge = true }

-- DirectedEdge metatable
local DEMT = {__index = DirectedEdgeIndex}

function DirectedEdgeIndex:createOSG()

	assert(self.osg == nil, "DirectedEdge:createOSG - createOSG called twice!?")
	--set up directedEdge variables
	self.srcpos = self.src.position
	self.destpos = self.dest.position

	--create "label" object (off by default)
	self.labelSwitch = osg.Switch()
	local edge_label = TextLabel(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)), self.label, self.fontsize, self.radius, self.fontcolor)
	self.labelSwitch:addChild(edge_label)
	self.labelSwitch:setAllChildrenOff()
	
	--create edge geometry
	self.osgcylinder = CylinderFromHereToThereWithArrows{here = Vec(unpack(self.srcpos)), there = Vec(unpack(self.destpos)), radius = self.radius, color = self.color, node_radius = self.src_radius}

	self.osg_elements = Transform{
		self.osgcylinder,
		self.labelSwitch
	}

	--create a edge controller switch
	self.edge_control_switch = osg.Switch()
	-- --add children to edge control switch
	self.edge_control_switch:addChild(self.osg_elements)

	--create switch for indicator
	self.indicators = osg.Switch()
	local highlighted_cylinder = CylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)), self.radius * 1.1, self.highlightColor)
	self.indicators:addChild(highlighted_cylinder)
	--highlight off by default
	self.indicators:setAllChildrenOff()
	--add both label and edge objects into main xform
	self.osg = Transform{
		self.indicators,
		self.edge_control_switch,
	}
end

function DirectedEdgeIndex:updateOSG()
	--only update if src or dest positions have changed
	if self.srcpos == self.src.position and self.destpos == self.dest.position then
		return
	end
	--update the internal position variables
	self.srcpos = self.src.position
	self.destpos = self.dest.position
	-- update label graphic
	local edge_label = TextLabel(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)), self.label, self.fontsize, self.radius, self.fontcolor)
	self.osg_elements.Child[2].Child[1] = edge_label
	--update normal edge graphic
	local new_edge = CylinderFromHereToThereWithArrows{here = Vec(unpack(self.srcpos)), there = Vec(unpack(self.destpos)), radius = self.radius, color = self.color, node_radius = self.src_radius}
	self.osg_elements.Child[1] = new_edge
	--update highlighted edge graphic
	self.indicators.Child[1] = CylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)), self.radius * 1.1, self.highlightColor)
end

function DirectedEdgeIndex:highlight(val)
	--TODO: this turns all highlighting on - problem?
	if val then
		self.indicators:setAllChildrenOn()
	else
		self.indicators:setAllChildrenOff()
	end
end

function DirectedEdgeIndex:showLabel()
	self.labelSwitch:setAllChildrenOn()
end

function DirectedEdgeIndex:hideLabel()
	self.labelSwitch:setAllChildrenOff()
end

DirectedEdge = function(source, destination, args)
	-- _src_radius = args.src_radius or 0.007
	args = args or {}
	_radius = args.radius or 0.007
	_color = args.color or {(105 / 255), (105 / 255), (105 / 255), 1}
	_fontcolor = args.fontcolor or {1, 1, 1, 1}
	_fontsize = args.fontsize or .25
	_label = args.label or ""
	_destColor = args.destColor or nil
	_highlightColor = args.highlightColor or {1, 1, 0, 1}

	return setmetatable({srcname = source,
			destname = destination,
			src_radius = _src_radius,
			radius = _radius,
			color = _color,
			destColor = _destColor,
			fontcolor = _fontcolor,
			fontsize = _fontsize,
			label = _label,
			highlightColor = _highlightColor
		}, DEMT)
end
