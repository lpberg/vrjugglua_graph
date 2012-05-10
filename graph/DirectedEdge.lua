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
	self.labelSwitch:setAllChildrenOff()
	--create "edge" osg objects inside a switch
	print("CreateOSG CAll - normal color: ",self.color)
	print("CreateOSG CAll - highlighted Color: ",self.highlightColor)
	self.indicators = osg.Switch()
	self.indicators:addChild(CylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius,self.color))
	self.indicators:addChild(CylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius*3,self.highlightColor))
	self.indicators:setSingleChildOn(0)
	--add both label and edge objects into main xform
	self.osg = Transform{
		self.indicators,
		self.labelSwitch,
	}
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
	self.labelSwitch.Child[1] = TextLabel(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.labeltext,self.labelSize,self.radius,self.labelColor)
	--update normal edge graphic
	self.indicators.Child[1] = CylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius,self.color)
	--update highlighted edge graphic
	-- print(self.highlightedColor)
	self.indicators.Child[2] = CylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius*3,self.highlightColor)
	-- self.indicators.Child[2] = HighlightCylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius,self.highlightColor)
end

function DirectedEdgeIndex:highlight(val)
	if val then
		--turn on yellow cylinder & everything else off
		self.indicators:setSingleChildOn(1)
	else
		--turn on normal cylinder & everything else off
		self.indicators:setSingleChildOn(0)
	end
end

function DirectedEdgeIndex:showLabel()
	self.labelSwitch:setAllChildrenOn()
end

function DirectedEdgeIndex:hideLabel()
	self.labelSwitch:setAllChildrenOff()
end

DirectedEdge = function(source, destination,args)
	-- setmetatable returns the table it is given after it modifies it by setting the metatable
	-- so this is a commonly-seen pattern
	local _radius = 0.007
	local _color = {(105/255),(105/255),(105/255),0} --gray color default
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
