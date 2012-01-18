
-- Set up __index table for DirectedEdge metatable
local DirectedEdgeIndex = { isedge = true}

-- DirectedEdge metatable
local DEMT = {
	__index = DirectedEdgeIndex
}

-- OK, now I'm just showing off, so you can print a DirectedEdge
function DEMT:__tostring()
	return ("[edge '%s->%s']"):format(self.srcname, self.destname)
end

function DirectedEdgeIndex:createOSG()
	-- TODO use self.src and self.dest and set self.osg
	-- Might want to do the minimum necessary here and then just call self:updateOSG()
	-- to avoid duplication
	self.osg = Group{}
end
function DirectedEdgeIndex:updateOSG()
	-- TODO update if the xforms of the ends have changed
end

DirectedEdge = function(source, destination)
	-- setmetatable returns the table it is given after it modifies it by setting the metatable
	-- so this is a commonly-seen pattern
	local self = setmetatable({}, DEMT)

	-- Be able to take in either names or actual edges.
	-- A little bit more complex but makes the addRandomEdge and similar easier.
	if type(source) == "string" then
		self.srcname = source
	else
		self.src = source
		self.srcname = source.name
	end

	if type(destination) == "string" then
		self.destname = destination
	else
		self.dest = destination
		self.destname = destination.name
	end

	return self

	--[[ The older, simpler definition that required source and destination to be string names is:
	return setmetatable({srcname = source, destname = destination}, DEMT)
	]]

end
