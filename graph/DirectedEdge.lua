local DEDebug = function(...)
	print("DirectedEdge:", ...)
end

-- Set up __index table for DirectedEdge metatable
local DirectedEdgeIndex = { isedge = true }

-- DirectedEdge metatable
local DEMT = {
	__index = DirectedEdgeIndex
}

-- OK, now I'm just showing off, so you can print a DirectedEdge, but
-- notice how I'm converting to string here...
function DEMT:__tostring()
	return ("DirectedEdge([[%s]], [[%s]])"):format(self.srcname, self.destname)
end

function DirectedEdgeIndex:createOSG()

	assert(self.osg == nil, "Only call this createOSG once!")
	--set up directedEdge variables
	self.srcpos = self.src.position
	self.destpos = self.dest.position
	
	--create "label" object
	self.labelSwitch = osg.Switch()
	self.labelSwitch:addChild(TextLabel(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)), self.labeltext, self.labelSize, self.radius, self.labelColor))
	--hiding label by default
	self.labelSwitch:setAllChildrenOff()
	--normal edge osg
	self.osgcylinder = CylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius,self.color)
	--create a edge controller switch
	self.edge_control_switch = osg.Switch()
	self.osg_elements = Transform{
							self.osgcylinder,
							self.labelSwitch
						}
	--create transparent groups
	self.transparent_low = TransparentGroup{alpha=.25}
	self.transparent_high = TransparentGroup{alpha=.75}
	self.transparent_custom = TransparentGroup{alpha=self.transparent_custom or .25}
	--add osg_elements to tranparent groups
	self.transparent_low:addChild(self.osg_elements)
	self.transparent_high:addChild(self.osg_elements)
	self.transparent_custom:addChild(self.osg_elements)
	--add children to edge control switch
	self.edge_control_switch:addChild(self.osg_elements)
	self.edge_control_switch:addChild(self.transparent_low)
	self.edge_control_switch:addChild(self.transparent_high)
	self.edge_control_switch:addChild(self.transparent_custom)
	
	--create switch for indicator
	self.indicators = osg.Switch()
	local highlighted_cylinder = CylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius*1.1,self.highlightColor)
	self.indicators:addChild(highlighted_cylinder)
	--highlight off by default
	self.indicators:setAllChildrenOff()
	--add both label and edge objects into main xform
	self.osg = Transform{
		self.indicators,
		self.edge_control_switch,
	}
end


function DirectedEdgeIndex:setLowTransparency()
	self.edge_control_switch:setSingleChildOn(2)
end
function DirectedEdgeIndex:setHighTransparency()
	self.edge_control_switch:setSingleChildOn(1)
end
function DirectedEdgeIndex:setNoTransparency()
	self.edge_control_switch:setSingleChildOn(0)
end
function DirectedEdgeIndex:updateOSG()
	if self.srcpos == self.src.position and self.destpos == self.dest.position then
		--No need to update
		return
	end
	--update the internal position variables
	self.srcpos = self.src.position
	self.destpos = self.dest.position
	-- update label graphic
	self.osg_elements.Child[2].Child[1] = TextLabel(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.labeltext,self.labelSize,self.radius,self.labelColor)
	--update normal edge graphic
	self.osg_elements.Child[1] = CylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius,self.color)
	--update highlighted edge graphic
	self.indicators.Child[1] = CylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius*1.1,self.highlightColor)
	-- self.indicators.Child[2] = HighlightCylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius,self.highlightColor)
end

function DirectedEdgeIndex:shrinkEdge()
	self.radius = self.radius/2
	self:updateOSG()
end
function DirectedEdgeIndex:expandEdge()
	self.radius = self.radius*2
	self:updateOSG()
end

function DirectedEdgeIndex:highlight(val)
	if val then
		--turn on yellow cylinder & everything else off
		self.indicators:setAllChildrenOn()
	else
		--turn on normal cylinder & everything else off
		self.indicators:setAllChildrenOff()
	end
end

function DirectedEdgeIndex:showLabel()
	print("here i am")
	self.labelSwitch:setAllChildrenOn()
end

function DirectedEdgeIndex:hideLabel()
	self.labelSwitch:setAllChildrenOff()
end

DirectedEdge = function(source, destination,args)
	-- setmetatable returns the table it is given after it modifies it by setting the metatable
	-- so this is a commonly-seen pattern
	local _radius = 0.007
	local _color = {(105/255),(105/255),(105/255),1} --gray color default
	local _labelColor = {1,1,1,1}
	local _highlightColor = {1,1,0,1}
	local _label = ""
	local _labelSize = .25
	local _destColor = nil

	if args ~= nil then
		_radius = args.radius or _radius
		_color = args.color or _color
		_labelColor = args.labelColor or _labelColor
		_labelSize = args.labelSize or _labelSize
		_label = args.labeltext or _label
		_destColor = args.destColor or _destColor
		_highlightColor = args.highlightColor or _highlightColor
	end
	return setmetatable({srcname = source, 
						 destname = destination, 
						 radius = _radius, 
						 color = _color, 
						 destColor = _destColor, 
						 labelColor = _labelColor, 
						 labelSize = _labelSize, 
						 labeltext = _label, 
						 highlightColor = _highlightColor
						 }, DEMT)
end
