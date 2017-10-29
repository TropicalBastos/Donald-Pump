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
ruleFont = native.newFont("fonts/Jim.ttf", 10)

globalTextOptions = {
  text = "NULL",
  font = titleFont,
  x = display.contentCenterX,
  y = display.contentCenterY
}

--global screen position variables
centerX = display.contentCenterX
centerY = display.contentCenterY
screenTop = display.screenOriginY
screenLeft = display.screenOriginX
bottomMarg = display.contentHeight - display.screenOriginY
rightMarg = display.contentWidth - display.screenOriginX

--start the app on the loading scene
composer.gotoScene("scenes.loading")
