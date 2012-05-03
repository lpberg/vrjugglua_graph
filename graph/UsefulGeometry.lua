CylinderFromHereToThere = function(here, there,rad,mycolor) 
	local Cylinder = function (a)
		local pos = osg.Vec3(0.0, 0.0, 0.0)
		if a.position then
			pos:set(unpack(a.position))
		end
		local drbl = osg.ShapeDrawable(osg.Cylinder(pos, rad or 0.025, a.height or 1.0))
		local color = osg.Vec4((105/255),(105/255),(105/255),0)
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
		Cylinder{height = (here-there):length(),color = mycolor},
	}
	local newVec = there - here
	local newQuat = osg.Quat() -- Isn't there a static method like osg.Quat.rotate()? TODO
	newQuat:makeRotate(osg.Vec3(0,0,1),osg.Vec3(newVec:x(),newVec:y(),newVec:z()))
	xform:setAttitude(newQuat)
	return xform
end
YellowCylinderFromHereToThere = function(here, there,rad) 
	local Cylinder = function (a)
		local pos = osg.Vec3(0.0, 0.0, 0.0)
		if a.position then
			pos:set(unpack(a.position))
		end
		local drbl = osg.ShapeDrawable(osg.Cylinder(pos, rad*3 or 0.025*3, a.height or 1.0))
		local color = osg.Vec4(1,1,0,0)
		if a.color then
			color:set(unpack(a.color))
		end
		drbl:setColor(color)
		local geode = osg.Geode()
		geode:addDrawable(drbl)
		
		local xform = Transform{
			geode,
		}
		return xform
	end
	
	local midpoint = (here + there) * 0.5
	local xform = Transform{
		position = {midpoint:x(),midpoint:y(),midpoint:z()},
		Cylinder{height = (here-there):length()},
	}
	local newVec = there - here
	local newQuat = osg.Quat() -- Isn't there a static method like osg.Quat.rotate()? TODO
	newQuat:makeRotate(osg.Vec3(0,0,1),osg.Vec3(newVec:x(),newVec:y(),newVec:z()))
	xform:setAttitude(newQuat)
	
	return xform
end

RedIndicatorSphere = function(myRadius) 
	local function TransparentObject(group)
		local state = group:getOrCreateStateSet()
		state:setRenderingHint(2) -- transparent bin

		local CONSTANT_ALPHA = 0x8003
		local ONE_MINUS_CONSTANT_ALPHA = 0x8004
		local bf = osg.BlendFunc()
		bf:setFunction(CONSTANT_ALPHA, ONE_MINUS_CONSTANT_ALPHA)
		state:setAttributeAndModes(bf)

		local bc = osg.BlendColor(osg.Vec4(1.0, 1.0, 1.0,  0.25))
		state:setAttributeAndModes(bc)
		group:setStateSet(state)
	end
	local ColorSphere = function(a)
		local pos = osg.Vec3(0.0, 0.0, 0.0)
		if a.position then
			pos:set(unpack(a.position))
		end
		local sphere = osg.Sphere(pos, a.radius or 1.0)
		local drbl = osg.ShapeDrawable(sphere)
		local color = osg.Vec4(0,0,0,1)
		if a.color then
			color:set(unpack(a.color))
		end
		drbl:setColor(color)
		local geode = osg.Geode()
		geode:addDrawable(drbl)
		return geode
	end

	local xform = Transform{
			position = {0,0,0},
			ColorSphere{radius = myRadius, color = {1,0,0,1}},
		}
	TransparentObject(xform)
	return xform
end
ColorSphere = function(a)
	local pos = osg.Vec3(0.0, 0.0, 0.0)
	if a.position then
		pos:set(unpack(a.position))
	end
	local sphere = osg.Sphere(pos, a.radius or 1.0)
	local drbl = osg.ShapeDrawable(sphere)
	local color = osg.Vec4(1,1,1,0)
	if a.color then
		color:set(unpack(a.color))
	end
	drbl:setColor(color)
	local geode = osg.Geode()
	geode:addDrawable(drbl)
	return geode
end