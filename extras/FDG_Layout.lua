function ForceDirectedGraph(args,nodes)
	-- local nodes = nodes or self.nodes
	local function Coulomb_repulsion(vec1,vec2,mult)
		mult = mult or 1
		local lenVec = vec2 - vec1
		local len = lenVec:length()
		local normVec = lenVec * (1/len)
		local magnitude = 1.0/math.pow(len,2)
		local retVec = normVec * magnitude
		return retVec*mult*-1
	end

	local function Hooks_attraction(vec1,vec2,d_desired,k)
		k = k or 1
		local d_desired = d_desired or 1
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
	--setting up local vars to be used later 
	args.c_mult = args.c_mult or 10
	args.desiredEdgeLength = args.desiredEdgeLength or 1
	args.h_mult = args.h_mult or 50
	args.coulomb = args.coulomb or true
	args.hooks = args.hooks or true
	args.small_num = args.small_num or .20
	args.damping = args.damping or .80
	
	local total_kinetic_energy = 0
	local timestep = Actions.waitForRedraw()

	print("Force Directed Graph Layout Algorithm: Started")
	 repeat
		--reseting system total_kinetic_energy to zero
		 total_kinetic_energy = 0 
		 for _, node in ipairs(nodes) do
			 --reset net force on current note (to recalculate)
			 local net_force_on_node = osg.Vec3(0,0,0) 
			 --get current node's position
			 local nodePos = osg.Vec3(unpack(node.position))
			 --calculate Coulomb Forces on node (if set true in args)
			if(args.coulomb) then
				--iterate through every other node and sum forces
				 for _, everyOtherNode in ipairs(nodes) do
					if(everyOtherNode.name ~= node.name) then
						local othernodePos = osg.Vec3(unpack(everyOtherNode.position))
						net_force_on_node = net_force_on_node + Coulomb_repulsion(nodePos,othernodePos,args.c_mult)
					end
				end
			end
			--calculate Hooks Forces on node
			if(args.hooks) then
				--iterate through every other node and sum forces
				for _, everyEdgeFromNode in ipairs(node.edges) do
					local othernodePos = osg.Vec3(unpack(everyEdgeFromNode.dest.position))
					net_force_on_node = net_force_on_node + Hooks_attraction(nodePos,othernodePos,args.desiredEdgeLength,args.h_mult)
				end
			end
			--update the node velocity from 
			node.velocity = (node.velocity + (net_force_on_node*timestep)) * args.damping
			 --calculate new position for node based on velocity and timestep
			local newNodePos = nodePos + (node.velocity*timestep)
			--setting new node position as lua table
			node:setPosition({newNodePos:x(),newNodePos:y(),newNodePos:z()})
			--updating total system kinetic engery
			total_kinetic_energy = total_kinetic_energy + (math.pow(node.velocity:length(),2))
			timestep = Actions.waitForRedraw()
		end
	until total_kinetic_energy < args.small_num
	print("Force Directed Graph Layout Algorithm: Complete")
	return true
end

