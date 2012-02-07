require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
local function loadfile(fn) dofile(vrjLua.findInModelSearchPath(fn)) end

loadfile("DirectedEdge.lua")
loadfile("GraphNode.lua")
loadfile("Graph.lua")
loadfile("UsefulGeometry.lua")
-- loadfile("simpleLightsGraph.lua")
loadfile("forceDirectGraph.lua")