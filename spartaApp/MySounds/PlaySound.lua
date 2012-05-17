print("Loading PlaySound.lua. Wav files must be 16bit float.")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())

SoundWav = function(wavPath)
	snx.changeAPI("OpenAL")
	--create a sound info object 
	local soundInfo = snx.SoundInfo()
	-- set the filename attribute of the soundFile (path to your sound file)
	soundInfo.filename = wavPath
	--create a new sound handle and pass it the filename from the soundInfo object
	soundHandle = snx.SoundHandle(soundInfo.filename)
	--configure the soundHandle to use the soundInfo
	soundHandle:configure(soundInfo)
	--play or "trigger" the sound
	return soundHandle
end

SoundMp3 = function(mp3Path)
	snx.changeAPI("Audiere")
	--create a sound info object 
	soundInfo = snx.SoundInfo()
	-- set the filename attribute of the soundFile (path to your sound file)
	soundInfo.filename = mp3Path
	--create a new sound handle and pass it the filename from the soundInfo object
	soundHandle = snx.SoundHandle(soundInfo.filename)
	--configure the soundHandle to use the soundInfo
	soundHandle:configure(soundInfo)
	--play or "trigger" the sound
	return soundHandle
end

PlayStarTrekProgramCompleteMessage = function()
	my_sound = SoundWav(vrjLua.findInModelSearchPath("StarTrekSounds/Holodeck3ProgramComplete.wav"))
	my_sound:trigger(1)
end