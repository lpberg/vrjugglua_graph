CylinderFromHereToThere = function(here, there) 
	local Cylinder = function (a)
		local pos = osg.Vec3(0.0, 0.0, 0.0)
		if a.position then
			pos:set(unpack(a.position))
		end
		local drbl = osg.ShapeDrawable(osg.Cylinder(pos, a.radius or 0.025, a.height or 1.0))
		local color = osg.Vec4(0,0,1,0)
		if a.color then
			color:set(unpack(a.color))
		end
		drbl:setColor(color)
		local geode = osg.Geode()
		geode:addDrawable(drbl)
		return geode
	end
	

	local midpoint = (here + there) * 0.5
	local xform = Transform{
		position = {midpoint:x(),midpoint:y(),midpoint:z()},
		Cylinder{height = (here-there):length()},
	}
	local newVec = there - here
	local newQuat = osg.Quat() -- Isn't there a static method like osg.Quat.rotate()? TODO
	newQuat:makeRotate(osg.Vec3(0,0,1),newVec)
	xform:setAttitude(newQuat)
	return xform
end