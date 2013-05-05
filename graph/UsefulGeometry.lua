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
	local centerTextDist = texts:computeBound():radius()
	return Transform{position = {-centerTextDist,0,0}, texts}
end


local Cylinder = function (a)
	local pos = osg.Vec3(0.0, 0.0, 0.0) 
	local drbl = osg.ShapeDrawable(osg.Cylinder(pos, a.radius, a.height))
	local color = osg.Vec4(unpack(a.color))
	drbl:setColor(color)
	local geode = osg.Geode()
	geode:addDrawable(drbl)
	return geode
end

ColorSphere = function(a)
	local pos = osg.Vec3(0.0, 0.0, 0.0)
	local sphere = osg.Sphere(pos, a.radius)
	local drbl = osg.ShapeDrawable(sphere)
	local color = osg.Vec4(unpack(a.color))
	drbl:setColor(color)
	local geode = osg.Geode()
	geode:addDrawable(drbl)
	return geode
end

CylinderFromHereToThere = function(here, there, myradius, mycolor) 
	local midpoint = (here + there) * 0.5
	local myheight = (here-there):length()
	local xform = Transform{
		position = {midpoint:x(),midpoint:y(),midpoint:z()},
		Cylinder{height = myheight, color = mycolor, radius = myradius},
	}
	local newVec = there - here
	local newQuat = osg.Quat()
	newQuat:makeRotate(osg.Vec3(0,0,1),osg.Vec3(newVec:x(),newVec:y(),newVec:z()))
	xform:setAttitude(newQuat)
	return xform
end

Cone = function(a)
	local pos = osg.Vec3(0.0, 0.0, 0.0)
	if a.position then
		pos:set(unpack(a.position))
	end
	local drbl = osg.ShapeDrawable(osg.Cone(pos, a.radius or 1.0,a.height or 1.0))
	local color = osg.Vec4(0,0,0,0)
	if a.color then
		color:set(unpack(a.color))
	end
	drbl:setColor(color)
	local geode = osg.Geode()
	geode:addDrawable(drbl)
	return geode
end

CylinderFromHereToThereWithArrows = function(a) 
	local midpoint = (a.here + a.there) * 0.5
	local total_dist = (a.here-a.there):length()
	if a.cone_color == nil then
		a.cone_color = a.color
	end
	if a.cone_radius == nil then
		a.cone_radius = a.radius*1.5
	end
	if a.cone_height == nil then
		a.cone_height = total_dist*(1/15)
	end
	
	local cylinder_lenth = total_dist - a.node_radius - a.cone_height 
	local cone_z = (cylinder_lenth-(total_dist/2.0))+(a.cone_height/4)
	local col_z = -((total_dist-cylinder_lenth)/2.0)
	
	local cone = Transform{
		Cone{position = {0,0,cone_z},color=a.cone_color, radius = a.cone_radius, height=a.cone_height},
	}
	local col = Transform{
		position = {0,0,col_z},
		Cylinder{height = cylinder_lenth, color = a.color, radius = a.radius},
	}
	local xform = Transform{
		position = {midpoint:x(),midpoint:y(),midpoint:z()},
		col,
		cone,
	}
	local newVec = a.there - a.here
	local newQuat = osg.Quat()
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

GreenIndicatorSphere = function(myRadius) 
	local xform = Transform{
			position = {0,0,0},
			TransparentGroup{ColorSphere{radius = myRadius, color = {0,1,0,1}},alpha=.15},
		}
	return xform
end

