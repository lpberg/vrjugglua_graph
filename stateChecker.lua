 local OSGBodies = {}
 local SimulationBodies = {}
 local BodyIDTable = {}
 
 --for all bodies in simulation
 --BodyIDTable[VPSBody] = VPSBody.id
 -- table.insert(SimulationBodies,VPSBody)
 
 
 function getTransformForCoordinateFrame(coordinateFrame, node)
	if node == nil then node = assert(knownInView(coordinateFrame)) end
	if node:isSameKindAs(osg.MatrixTransform()) then
		return node
	else
		return getTransformForCoordinateFrame(coordinateFrame, node.Children[1])
	end
end
 
 function getOSGBodyFromCoordinateFrame(body)
	if OSGBodies[body] ~= nil then
		 return OSGBodies[body]
	else
		OSGBodies[body] = getTransformForCoordinateFrame(body)
		return OSGBodies[body]
	end
end
 
 
 function PartInAssembley(body,assemblyCenter,threshold)
	local bodyPos = getOSGBodyFromCoordinateFrame(body):getPosition()
	local distance = (assemblyCenter - bodyPos):length()
	if distance < threshold then
		return true
	else
		return false
	end
end

function getCurrentState()
	local state = ""
	local bodies_in_state = {}
	for _,body in ipairs(SimulationBodies) do
		if(PartInAssembley(body,osg.Vec3(0,0,0),.5)) then
			table.insert(bodies_in_state,BodyIDTable[body])
		end
	end
	table.sort(bodies_in_state)
	for _,bodyid in ipairs(bodies_in_state) do
		state = state..bodyid
	end
	return state
end
		
			
			
			
		