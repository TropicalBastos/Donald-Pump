-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
spriteSheets = require("spritesheets")
physics = require("physics")

local composer = require("composer")

--setFonts
titleFont = native.newFont("Jim.ttf",28)
highscoreFont = native.newFont("Jim.ttf",20)
font321 = native.newFont("Jim.ttf",100)

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
