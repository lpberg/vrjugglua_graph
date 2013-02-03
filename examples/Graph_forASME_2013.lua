--See http://www.lua.org/pil/16.html and http://www.lua.org/pil/16.1.html for more information
require("Actions")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
function runfile(fn) dofile(vrjLua.findInModelSearchPath(fn)) end

factory = Transform{
	position = {0,-1,10},
	orientation = AngleAxis(Degrees(-90), Axis{1.0, 0.0, 0.0}),
	scale = ScaleFrom.inches,
	Model("basicfactory.ive")
}
RelativeTo.World:addChild(factory)

runfile([[..\graph\loadGraphFiles.lua]])
runfile([[..\graph\simpleLightsGraph.lua]])
runfile([[simpleLights.lua]])

local fact = .15
local green = {(154/255),(205/255),(50/255),1}
local yellow = {1,(215/255),0,1}
local red = {1,0,0,1}
local teal = {0,(206/255),(209/255),1}
local purple = {(138/255),(43/255),(210/255),1}
local blue = {0,0,1,1}

g = Graph(
	{
		--x = 0
		["012345"] = GraphNode{position = {0,0,0},radius = .03};
		["01234"] = GraphNode{position = {0,-1*fact,0},radius = .03,color = red}; 
		["0123"] = GraphNode{position = {0,-2*fact,0},radius = .03,color = teal};
		["12"] = GraphNode{position = {0,-4*fact,0},radius = .03,color = purple}; 
		["1"] = GraphNode{position = {0,-5*fact,0},radius = .03,color = green}; 
		["2"] = GraphNode{position = {.1,-6*fact,fact},radius = .03,color = blue}; 
		--x = 1
		["012"] = GraphNode{position = {1*fact,-3*fact,0},radius = .03,color = purple}; 
		["02"] = GraphNode{position = {1*fact,-4*fact,0},radius = .03,color = yellow}; 
		--x = 2
		["01"] = GraphNode{position = {2*fact,-4*fact,0},radius = .03,color = green}; 
		["0"] = GraphNode{position = {2*fact,-5*fact,0},radius = .03,color = yellow};
		--x = -1
		["123"] = GraphNode{position = {-1*fact,-3*fact,0},radius = .03,color = blue};
		["23"] = GraphNode{position = {-1*fact,-4*fact,0},radius = .03,color = yellow}; 
		--x = -2
		["13"] = GraphNode{position = {-2*fact,-4*fact,0},radius = .03,color = green};
		["3"] = GraphNode{position = {-2*fact,-5*fact,0},radius = .03,color = yellow};

	},
	{
		DirectedEdge("012345", "01234",{destColor=red, radius=.007,labeltext="default1", labelSize=.04});
		DirectedEdge("01234", "0123",{destColor=teal,labeltext="default1", labelSize=.04});
		DirectedEdge("0123", "123",{destColor=blue,labeltext="default1", labelSize=.04});
		DirectedEdge("0123", "012",{destColor=purple,labeltext="default1", labelSize=.04});
		DirectedEdge("123", "13",{destColor=green,labeltext="default1", labelSize=.04});
		DirectedEdge("123", "23",{destColor=yellow,labeltext="default1", labelSize=.04});
		DirectedEdge("123", "12",{destColor=purple,labeltext="default1", labelSize=.04});
		DirectedEdge("012", "12",{destColor=blue,labeltext="default1", labelSize=.04});
		DirectedEdge("012", "02",{destColor=yellow,labeltext="default1", labelSize=.04});
		DirectedEdge("012", "01",{destColor=green,labeltext="default1", labelSize=.04});
		DirectedEdge("13", "3",{destColor=yellow,labeltext="default1", labelSize=.04});
		DirectedEdge("13", "1",{destColor=purple,labeltext="default1", labelSize=.04});
		DirectedEdge("23", "3",{destColor=green,labeltext="default1", labelSize=.04});
		DirectedEdge("23", "2",{destColor=purple,labeltext="default1", labelSize=.04});
		DirectedEdge("12", "1",{destColor=green,labeltext="default1", labelSize=.04});
		DirectedEdge("12", "2",{destColor=yellow,labeltext="default1", labelSize=.04});
		DirectedEdge("02", "2",{destColor=blue,labeltext="default1", labelSize=.04});
		DirectedEdge("02", "0",{destColor=green,labeltext="default1", labelSize=.04});
		DirectedEdge("01", "1",{destColor=blue,labeltext="default1", labelSize=.04});
		DirectedEdge("01", "0",{destColor=yellow,labeltext="default1", labelSize=.04});
	}
)

RelativeTo.World:addChild(Transform{position={2,1.5,0},g.osg.root})

-- g:updateCurrentState("012345")
-- g:updateCurrentState("01234")
-- g:updateCurrentState("0123")
-- g:updateCurrentState("012")



-- g.nodes["012345"]:highlight(true,1)
-- g.nodes["01234"]:highlight(true,1)
-- g.nodes["0123"]:highlight(true,1)
-- g.nodes["13"]:highlight(true,1)
-- g.nodes["3"]:highlight(true,1)

-- g.nodes["012345"]:setLowTransparency()
-- g.nodes["01234"]:setHighTransparency()
-- g.nodes["0123"]:setHighTransparency()
-- g.nodes["123"]:setHighTransparency()
-- g.nodes["13"]:setHighTransparency()
-- g.nodes["3"]:setHighTransparency()
args = {"0123","123","13","3"}
g:setTransparencyForPath(args)