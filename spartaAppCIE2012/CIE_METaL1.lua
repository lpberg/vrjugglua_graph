require("Actions")
require("getScriptFilename")
require("TransparentGroup")
vrjLua.appendToModelSearchPath(getScriptFilename())
dofile(vrjLua.findInModelSearchPath([[loadBurrPuzzle.lua]]))
dofile(vrjLua.findInModelSearchPath([[..\graph\loadGraphFiles.lua]]))
wand = Manipulators.Gadgeteer.Wand{position = "VJWand"}
addManipulator(wand)
switchToBasicFactory() 
puzzleX = 2.7525
puzzleY = -.125
puzzleZ = 1.2
all = addBurrPuzzle(puzzleX,puzzleY,puzzleZ)
Actions.addFrameAction(setBackParts)
simulation:startInSchedulerThread()
			
		