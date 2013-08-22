--See http://www.lua.org/pil/16.html and http://www.lua.org/pil/16.1.html for more information
require("Actions")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
function runfile(fn) dofile(vrjLua.findInModelSearchPath(fn)) end

-- I split stuff up since it got hard to read once I commented it
runfile([[..\graph\loadGraphFiles.lua]])
runfile([[..\graph\simpleLightsGraph.lua]])




-- A graph is G=(V, E)
g = Graph(
	{
		["0"] = GraphNode{position = {2, 10, 0}};
		["1"] = GraphNode{position = {1.5, 9, 0}};
		["2"] = GraphNode{position = {2.5, 9, 0}};
		["3"] = GraphNode{position = {2.5, 8, 0}};
		["4"] = GraphNode{position = {1.5, 8, 0}};
		["5"] = GraphNode{position = {3, 7, 0}};
		["6"] = GraphNode{position = {0, 7, 0}};
		["7"] = GraphNode{position = {2, 7, 0}};
		["8"] = GraphNode{position = {1, 7, 0}};
		["9"] = GraphNode{position = {0, 5, 0}};
		["10"] = GraphNode{position = {4 / 3, 6, 0}};
		["11"] = GraphNode{position = {4, 7, 0}};
		["12"] = GraphNode{position = {2, 5, 0}};
		["13"] = GraphNode{position = {10 / 3, 6, 0}};
		["14"] = GraphNode{position = {2 / 3, 5, 0}};
		["15"] = GraphNode{position = {4, 6, 0}};
		["16"] = GraphNode{position = {4, 5, 0}};
		["17"] = GraphNode{position = {0, 6, 0}};
		["18"] = GraphNode{position = {2, 6, 0}};
		["19"] = GraphNode{position = {2 / 3, 6, 0}};
		["20"] = GraphNode{position = {8 / 3, 5, 0}};
		["21"] = GraphNode{position = {8 / 3, 6, 0}};
		["22"] = GraphNode{position = {4 / 3, 5, 0}};
		["23"] = GraphNode{position = {10 / 3, 5, 0}};
		["24"] = GraphNode{position = {.5, 4, 0}};
		["25"] = GraphNode{position = {3, 4, 0}};
		["26"] = GraphNode{position = {2, 4, 0}};
		["27"] = GraphNode{position = {0, 4, 0}};
		["28"] = GraphNode{position = {2.5, 4, 0}};
		["29"] = GraphNode{position = {1, 4, 0}};
		["30"] = GraphNode{position = {3.5, 4, 0}};
		["31"] = GraphNode{position = {4, 4, 0}};
		["32"] = GraphNode{position = {1.5, 4, 0}};
		["33"] = GraphNode{position = {2, 3, 0}};

	},
	{
		DirectedEdge("0", "1");
		DirectedEdge("0", "2");
		DirectedEdge("1", "4");
		DirectedEdge("2", "3");
		DirectedEdge("2", "1");
		DirectedEdge("3", "5");
		DirectedEdge("3", "6");
		DirectedEdge("4", "13");
		DirectedEdge("4", "14");
		DirectedEdge("4", "17");
		DirectedEdge("4", "7");
		DirectedEdge("5", "14");
		DirectedEdge("5", "18");
		DirectedEdge("5", "12");
		DirectedEdge("5", "19");
		DirectedEdge("5", "11");
		DirectedEdge("6", "13");
		DirectedEdge("6", "18");
		DirectedEdge("6", "10");
		DirectedEdge("6", "8");
		DirectedEdge("7", "22");
		DirectedEdge("7", "15");
		DirectedEdge("7", "14");
		DirectedEdge("7", "13");
		DirectedEdge("8", "10");
		DirectedEdge("8", "13");
		DirectedEdge("8", "9");
		DirectedEdge("8", "18");
		DirectedEdge("8", "21");
		DirectedEdge("9", "31");
		DirectedEdge("9", "28");
		DirectedEdge("9", "32");

		DirectedEdge("10", "29");
		DirectedEdge("10", "32");
		DirectedEdge("10", "27");
		DirectedEdge("11", "20");
		DirectedEdge("11", "16");
		DirectedEdge("11", "23");
		DirectedEdge("11", "14");
		DirectedEdge("11", "18");
		DirectedEdge("11", "12");
		DirectedEdge("12", "25");
		DirectedEdge("12", "29");
		DirectedEdge("12", "30");
		DirectedEdge("13", "26");
		DirectedEdge("13", "27");
		DirectedEdge("13", "28");
		DirectedEdge("14", "25");
		DirectedEdge("14", "24");
		DirectedEdge("14", "26");
		DirectedEdge("15", "24");
		DirectedEdge("15", "28");
		DirectedEdge("16", "31");
		--DirectedEdge("16", "31");
		DirectedEdge("16", "25");
		--DirectedEdge("16", "25");
		DirectedEdge("17", "27");
		--DirectedEdge("17", "27");
		DirectedEdge("17", "24");
		--DirectedEdge("17", "24");
		DirectedEdge("18", "26");
		DirectedEdge("18", "29");
		DirectedEdge("19", "24");
		--DirectedEdge("19", "24");
		DirectedEdge("19", "29");
		--DirectedEdge("19", "29");
		DirectedEdge("20", "30");
		--DirectedEdge("20", "30");
		DirectedEdge("20", "26");
		--DirectedEdge("20", "26");
		DirectedEdge("21", "26");
		--DirectedEdge("21", "26");
		DirectedEdge("21", "32");
		--DirectedEdge("21", "32");
		DirectedEdge("22", "28");
		--DirectedEdge("22", "28");
		DirectedEdge("22", "25");
		--DirectedEdge("22", "25");
		DirectedEdge("23", "30");
		DirectedEdge("23", "24");
		DirectedEdge("23", "31");
		DirectedEdge("24", "33");
		--DirectedEdge("24", "33");
		DirectedEdge("25", "33");
		--DirectedEdge("25", "33");
		DirectedEdge("26", "33");
		--DirectedEdge("26", "33");
		DirectedEdge("27", "33");
		--DirectedEdge("27", "33");
		DirectedEdge("28", "33");
		--DirectedEdge("28", "33");
		DirectedEdge("29", "33");
		--DirectedEdge("29", "33");
		DirectedEdge("30", "33");
		--DirectedEdge("30", "33");
		DirectedEdge("31", "33");
		--DirectedEdge("31", "33");
		DirectedEdge("32", "33");
		--DirectedEdge("32", "33");
	}
)
g.actionArgs = {small_num = .55, damping = .80, c_mult = 100, h_mult = 10, hooks = false}
RelativeTo.World:addChild(g.osg.root)
-- g:performAction()


local filename = string.match(getScriptFilename(), "(.-)([^\\]-([^%.]+))$") .. "adamGraph" .. ".dot"
local img_filename = string.match(getScriptFilename(), "(.-)([^\\]-([^%.]+))$") .. "adamGraph" .. ".png"
g:writeOutDotFile(filename)
-- print(img_filename)
os.execute([["C:\Program Files (x86)\Graphviz2.30\bin\dot.exe"]] .. [[ -Tpng ]] .. filename .. [[ -o ]] .. img_filename)
os.execute([["C:\Program Files (x86)\Graphviz2.30\bin\dot.exe" ]] .. filename .. [[ -o ]] .. filename .. [[im]])