
Grid = {	
	geode = osg.Geode(),
	show = function(size,color)
		local geode = Grid.geode
		if color == nil then
			print([[No color specfied setting color for grid to RED]])
			print([[Hint: to add color pass 'osg.Vec4(x,x,x,x)' as 2nd argument]])
			color = osg.Vec4(1, 0, 0, 1)
		end
		if size == nil then
			print([[No size specfied setting grid for grid to 50mx50m]])	
			print([[Hint: pass 'x' where x is your desired dimention (ie. Xm by Xm)]])
			size = 25
		end
		do
			geom = osg.Geometry()
			geode:addDrawable(geom)
			RelativeTo.World:addChild(geode)
			vertices = osg.Vec3Array()
			geom:setVertexArray(vertices)
			colors = osg.Vec4Array()
			geom:setColorArray(colors)
			geom:setColorBinding(osg.Geometry.AttributeBinding.BIND_PER_VERTEX)
			linestrip = osg.DrawArrays(osg.PrimitiveSet.Mode.LINES)
			geom:addPrimitiveSet(linestrip)
		end
		function addPoint(v)
			vertices.Item:insert(v)
			colors.Item:insert(color)
			linestrip:setCount(#(vertices.Item))
		end
		do
			local size = size/2.0
			local k = -size
			for i = 1,size*2+1,1 do
				addPoint(osg.Vec3(-size,0,k))
				addPoint(osg.Vec3(size,0,k))
				k = k +1
			end
			local k = -size
			for i = 1,size*2+1,1 do
				addPoint(osg.Vec3(k,0,-size))
				addPoint(osg.Vec3(k,0,size))
				k = k +1
			end
		end
	end,
	
	hide = function()
		RelativeTo.World:removeChild(Grid.geode)
	end
}
