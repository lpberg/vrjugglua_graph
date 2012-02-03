require("Actions")
function Coulomb_repulsion(vec1,vec2,mult)
	mult = mult or 1
	local lenVec = vec2 - vec1
	local len = lenVec:length()
	local normVec = lenVec * (1/len)
	local magnitude = 1.0/math.pow(len,2)
	local retVec = normVec * magnitude
	return retVec*mult*-1
end

function Hooks_attraction(vec1,vec2,d_desired,k)
	k = k or 1
	local d = (vec2 - vec1):length()
	local d_diff = d - d_desired
	local x = math.abs
	local retVec
	if d_diff < 0 then
		retVec = (vec2 - vec1)
	else
		retVec = (vec1 - vec2)
	end
	return retVec*-k
end
	
function ForceDirectedGraph(g,small_Num,timestep,damping)
	--setting up local vars to be used later 
	local total_kinetic_energy = 0
	local some_really_small_number = small_Num or 1
	local damping = damping or .80
	local timestep = timestep or .05
	print("Force Directed Graph Layout Algorithm: Started")
	 repeat
		--reseting system total_kinetic_energy to zero
		 total_kinetic_energy = 0 
		 for _, node in ipairs(g.nodes) do
			 --reset net force on current note (to recalculate)
			 local net_force_on_node = osg.Vec3(0,0,0) 
			 --get this nodes position
			 local nodePos = osg.Vec3(unpack(node.position))
			 --calculate Coulomb Forces on node
			 for _, everyOtherNode in ipairs(g.nodes) do
				if(everyOtherNode.name ~= node.name) then
					local othernodePos = osg.Vec3(unpack(everyOtherNode.position))
					net_force_on_node = net_force_on_node + Coulomb_repulsion(nodePos,othernodePos,10)
				end
			end
			--calculate Hooks Forces on node
			for _, everyEdgeFromNode in ipairs(node.edges) do
				local othernodePos = osg.Vec3(unpack(everyEdgeFromNode.dest.position))
				net_force_on_node = net_force_on_node + Hooks_attraction(nodePos,othernodePos,1,20)
			end
			--update the node velocity from 
			node.velocity = (node.velocity + (net_force_on_node*timestep)) * damping
			 --calculate new position for node based on velocity and timestep
			local newNodePos = nodePos + (node.velocity*timestep)
			--setting new node position as lua table
			node:setPosition({newNodePos:x(),newNodePos:y(),newNodePos:z()})
			--updating total system kinetic engery
			total_kinetic_energy = total_kinetic_energy + (math.pow(node.velocity:length(),2))
			Actions.waitForRedraw()
			print(total_kinetic_energy)
		end
	until total_kinetic_energy < some_really_small_number
	print("Force Directed Graph Layout Algorithm: Complete")
	return true
end

