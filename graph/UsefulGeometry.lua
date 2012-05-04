require("TransparentGroup")
require("Text")

TextLabel = function(here, there, val, size, zPlus, color)

	local midpoint = (here + there) * 0.5
	local mycolor
	if color ~= nil then
		mycolor = osg.Vec4(unpack(color))
	else
		mycolor = osg.Vec4(1.0, 1.0, 1.0, 1.0)
	end
	local vals = val -- fix for an issue with variables
	texts = TextGeode{
		tostring(vals),
		color = mycolor,
		lineHeight = size,
		position = {midpoint:x(), midpoint:y(), midpoint:z()+zPlus},
		font = Font("DroidSans")
	}
	return texts
end


local Cylinder = function (a)
	local pos = osg.Vec3(0.0, 0.0, 0.0) 
	local drbl = osg.ShapeDrawable(osg.Cylinder(pos, a.radius, a.height))
	local color = osg.Vec4(0,0,0,0)
	color:set(unpack(a.color))
	drbl:setColor(color)
	local geode = osg.Geode()
	geode:addDrawable(drbl)
	return geode
end

ColorSphere = function(a)
	local pos = osg.Vec3(0.0, 0.0, 0.0)
	local sphere = osg.Sphere(pos, a.radius)
	local drbl = osg.ShapeDrawable(sphere)
	local color = osg.Vec4()
	color:set(unpack(a.color))
	drbl:setColor(color)
	local geode = osg.Geode()
	geode:addDrawable(drbl)
	return geode
end

CylinderFromHereToThere = function(here, there, myradius,mycolor) 

	local midpoint = (here + there) * 0.5
	local myheight = (here-there):length()
	
	local xform = Transform{
		position = {midpoint:x(),midpoint:y(),midpoint:z()},
		Cylinder({height = myheight, color = mycolor, radius = myradius}),
	}
	local newVec = there - here
	local newQuat = osg.Quat()
	newQuat:makeRotate(osg.Vec3(0,0,1),osg.Vec3(newVec:x(),newVec:y(),newVec:z()))
	xform:setAttitude(newQuat)
	return xform
end

YellowCylinderFromHereToThere = function(here, there,radius) 
	
	local midpoint = (here + there) * 0.5
	local myheight = (here-there):length()
	local xform = Transform{
		position = {midpoint:x(),midpoint:y(),midpoint:z()},
		Cylinder{height = myheight, radius = radius*3, color = {1,1,0,0}}
	}
	local newVec = there - here
	local newQuat = osg.Quat() -- Isn't there a static method like osg.Quat.rotate()? TODO
	newQuat:makeRotate(osg.Vec3(0,0,1),osg.Vec3(newVec:x(),newVec:y(),newVec:z()))
	xform:setAttitude(newQuat)
	
	return xform
end

RedIndicatorSphere = function(myRadius) 
	local xform = Transform{
			position = {0,0,0},
			TransparentGroup{ColorSphere{radius = myRadius, color = {1,0,0,1}}},
		}
	return xform
end

