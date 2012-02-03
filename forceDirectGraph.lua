

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
					net_force_on_node = net_force_on_node + Coulomb_repulsion(nodePos,othernodePos)
				end
			end
			--calculate Hooks Forces on node
			for _, everyEdgeFromNode in ipairs(node.edges) do
				local othernodePos = osg.Vec3(unpack(everyEdgeFromNode.dest.position))
				net_force_on_node = net_force_on_node + Hooks_attraction(nodePos,othernodePos)
			end
			--update the node velocity from 
			node.velocity = (node.velocity + (net_force_on_node*timestep)) * damping
			 --calculate new position for node based on velocity and timestep
			newNodePos = nodePos + (node.velocity*timestep)
			--setting new node position as lua table
			node.position = {newNodePos:x(),newNodePos:y(),newNodePos:z()}
			--update osgNode for visualiation
			--node:updateOSG()
			--updating total system kinetic engery
			total_kinetic_energy := total_kinetic_energy + (math.pow(node.velocity:length(),2))
			 
		end
	until total_kinetic_energy < some_really_small_number
	print("Force Directed Graph Layout Algorithm: Complete")
	return true
end


--Sudocode from: http://en.wikipedia.org/wiki/Force-based_algorithms_(graph_drawing)
 -- loop
     -- total_kinetic_energy := 0 // running sum of total kinetic energy over all particles
     -- for each node
         -- net-force := (0, 0) // running sum of total force on this particular node
         
         -- for each other node
             -- net-force := net-force + Coulomb_repulsion( this_node, other_node )
         -- next node
         
         -- for each spring connected to this node
             -- net-force := net-force + Hooke_attraction( this_node, spring )
         -- next spring
         
         -- // without damping, it moves forever
         -- this_node.velocity := (this_node.velocity + timestep * net-force) * damping
         -- this_node.position := this_node.position + timestep * this_node.velocity
         -- total_kinetic_energy := total_kinetic_energy + this_node.mass * (this_node.velocity)^2
     -- next node
 -- until total_kinetic_energy is less than some small number  // the simulation has stopped moving