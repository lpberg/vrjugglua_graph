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
	-- TODO use self.src and self.dest and set self.osg
	-- Might want to do the minimum necessary here and then just call self:updateOSG()
	-- to avoid duplication
	assert(self.osg == nil, "Only call this createOSG once!")
	self.osg = Group{}
	self:updateOSG()
end
function DirectedEdgeIndex:updateOSG()
	-- TODO update if the xforms of the ends have changed
	if self.srcpos == self.src.position and self.destpos == self.dest.position then
		-- nothing to do here!
		DEDebug "updateOSG had nothing to do"
		return
	end
	self.srcpos = self.src.position
	self.destpos = self.dest.position
	self.osg.Child[1] = CylinderFromHereToThere(Vec(unpack(self.srcpos)), Vec(unpack(self.destpos)))
	DEDebug "updateOSG is done!"
end

DirectedEdge = function(source, destination)
	-- setmetatable returns the table it is given after it modifies it by setting the metatable
	-- so this is a commonly-seen pattern
	return setmetatable({srcname = source, destname = destination}, DEMT)
end
