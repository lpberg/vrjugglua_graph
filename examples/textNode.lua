require("Text")

function createTextNode(arg)
	local function TextLabel(arg)
		arg.text = arg.text or "default"
		arg.textpadding = arg.textpadding or .90
		local lineHeight = arg.textpadding * arg.height
		local text = TextGeode{
			tostring(arg.text),
			color = osg.Vec4(unpack(arg.color)),
			lineHeight = lineHeight,
			position = {0, 0, .51 * arg.depth},
			font = Font("DroidSans")
		}
		local centerTextDist = text:computeBound():radius()
		local retForm = Transform{position = {-centerTextDist, (lineHeight / 2) + (arg.height-lineHeight), 0}, text}
		return retForm
	end
	local function Box(arg)
		local drbl = osg.ShapeDrawable(osg.Box(osg.Vec3(0.0, 0.0, 0.0), 1.0))
		local color = osg.Vec4(unpack(arg.color))
		drbl:setColor(color)
		local geode = osg.Geode()
		geode:addDrawable(drbl)
		local ret_xform = Transform{geode}
		ret_xform:setScale(Vec(arg.width, arg.height, arg.depth))
		return ret_xform
	end

	arg.boxcolor = arg.boxcolor or {0, .55, .29, 0}
	arg.textcolor = arg.textcolor or {0, 0, 0, 1}
	arg.width = arg.width or 1
	arg.height = arg.height or .5
	arg.depth = arg.depth or .05

	local my_text = TextLabel{text = arg.text, depth = arg.depth, height = arg.height, color = arg.textcolor}
	local text_radius = my_text:computeBound():radius()
	local my_box = Box{width = text_radius * 2.1, depth = arg.depth, height = arg.height, color = arg.boxcolor}

	local xform = Transform{
		my_box,
		my_text,
	}
	return xform
end


