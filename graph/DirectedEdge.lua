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
	self.srcpos = self.src.position
	self.destpos = self.dest.position
	
	self.labelSwitch = osg.Switch()

	self.labelSwitch:addChild(TextLabel(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)), self.labeltext, self.labelSize, self.radius, self.labelColor))
	-- self.label:setAllChildOff()
	self.indicators = osg.Switch()
	self.indicators:addChild(CylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius,self.color))
	self.indicators:addChild(YellowCylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius))
	self.indicators:setSingleChildOn(0)
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
	--update the internal pos variables
	self.srcpos = self.src.position
	self.destpos = self.dest.position
	-- update label graph
	self.labelSwitch.Child[1] = TextLabel(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.labeltext,self.labelSize,self.radius,self.labelColor)
	--update normal edge graphic
	self.indicators.Child[1] = CylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius,self.color)
	--update highlighted edge graphic
	self.indicators.Child[2] = YellowCylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)),self.radius)
	--DEDebug "updateOSG is done!"
end

function DirectedEdgeIndex:highlight(val)
	if val then
		self.indicators:setSingleChildOn(1)
	else
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
	local _radius = 0.025
	local _color = {(105/255),(105/255),(105/255),0} --gray color default
	local _labelColor = {1,1,1,1}
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
	end
	return setmetatable({srcname = source, destname = destination, radius = _radius, color = _color, destColor = _destColor, labelColor = _labelColor, labelSize = _labelSize, labeltext = _label}, DEMT)
end
