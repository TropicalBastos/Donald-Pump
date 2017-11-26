-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
spriteSheets = require("sheets.spritesheets")
physics = require("physics")
ggData = require("plugins.GGData")
prism = require("plugins.prism")

local composer = require("composer")

--setFonts
titleFont = native.newFont("fonts/Jim.ttf",28)
highscoreFont = native.newFont("fonts/Jim.ttf",20)
newHighscoreFont = native.newFont("fonts/Jim.ttf",30)
font321 = native.newFont("fonts/Jim.ttf",100)
howFont = native.newFont("fonts/Jim.ttf", 12)
ruleFont = native.newFont("fonts/Century.ttf", 13)

globalTextOptions = {
  text = "NULL",
  font = titleFont,
  x = display.contentCenterX,
  y = display.contentCenterY
}

--get any saved options
local vol = ggData:new("vol")
if vol.sound ~= nil then
  audio.setVolume(vol.sound, {channel=1})
  audio.setVolume(vol.sound, {channel=3})
  audio.setVolume(vol.sound, {channel=4})
end
if vol.music ~= nil then
  audio.setVolume(vol.music, {channel=2})
end

--global screen position variables
centerX = display.contentCenterX
centerY = display.contentCenterY
screenTop = display.screenOriginY
screenLeft = display.screenOriginX
bottomMarg = display.contentHeight - display.screenOriginY
rightMarg = display.contentWidth - display.screenOriginX

--global sounds
popSound = audio.loadSound("audio/pop.wav")
bounceSound = audio.loadSound("audio/bounce.wav")
windSound = audio.loadSound("audio/wind.mp3")
coinSound = audio.loadSound("audio/coin.wav")
explosionSound = audio.loadSound("audio/explosion.mp3")
gameOverSound = audio.loadSound("audio/gameover.mp3")
clickSound = audio.loadSound("audio/click.mp3")
powerSound = audio.loadSound("audio/powerup.wav")
whistleSound = audio.loadSound("audio/whistle.mp3")
wooshSound = audio.loadSound("audio/woosh.wav")
ultraSound = audio.loadSound("audio/ultra.wav")
errorSound = audio.loadSound("audio/error.wav")

--start the app on the loading scene
composer.gotoScene("scenes.loading")
