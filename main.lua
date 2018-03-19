-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
spriteSheets = require("sheets.spritesheets")
physics = require("physics")
ggData = require("plugins.GGData")
prism = require("plugins.prism")
appodeal = require( "plugin.appodeal" )
globalStore = require("store")

local composer = require("composer")

--setFonts
titleFont = native.newFont("fonts/Jim.ttf",28)
highscoreFont = native.newFont("fonts/Jim.ttf",20)
font321 = native.newFont("fonts/Jim.ttf",100)
howFont = native.newFont("fonts/Jim.ttf", 12)
secondaryFont = native.newFont("fonts/exte.ttf", 18)
lastResortFont = native.newFont("fonts/Century.ttf", 24)

-- Store constants
PRODUCT_NO_ADS = "com.globalgust.donaldpump.no_ads"
PRODUCT_TYCOON = "com.globalgust.donaldpump.tycoon"

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
popSound = audio.loadSound("audio/pop.mp3")
bounceSound = audio.loadSound("audio/bounce.mp3")
windSound = audio.loadSound("audio/wind.mp3")
coinSound = audio.loadSound("audio/coin.mp3")
explosionSound = audio.loadSound("audio/explosion.mp3")
gameOverSound = audio.loadSound("audio/gameover.mp3")
clickSound = audio.loadSound("audio/click.mp3")
powerSound = audio.loadSound("audio/powerup.mp3")
whistleSound = audio.loadSound("audio/whistle.mp3")
wooshSound = audio.loadSound("audio/woosh.mp3")
ultraSound = audio.loadSound("audio/ultra.mp3")
errorSound = audio.loadSound("audio/error.mp3")
introSound = audio.loadSound("audio/intro.mp3")
menuTheme = audio.loadSound("audio/menutheme.mp3")
playTheme = audio.loadSound("audio/playtheme.mp3")
x100Sound = audio.loadSound("audio/x100.mp3")
x100Hit = audio.loadSound("audio/x100first.mp3")
slowTimeAudio = audio.loadSound("audio/slowtime.mp3")

--ads
platform = system.getInfo("platform")

local adModule = ggData:new("purchases")
local noAdsModule = false
if adModule:get(PRODUCT_NO_ADS) ~= nil then
  if(adModule:get(PRODUCT_NO_ADS)) then
    noAdsModule = true
  end
end

print("No ads module: " .. tostring(noAdsModule))

if platform == "android" or platform == "ios" then
  APP_KEY = "389488ad64e1ea1d16b092b6664cafc6da1a918eeb0dc771"

  function adListener( event )
      if ( event.phase == "init" ) then  -- Successful initialization
          print( event.isError )
      end
  end

  appodeal.init( adListener, { appKey=APP_KEY } )
end

function setNoAdsModule(bool)
  noAdsModule = bool
end

function displayAd(chance, type)
  if noAdsModule then
    return
  end
    if platform == "android" or platform == "ios" then
      local randomAdNumer = math.random(chance)
      if randomAdNumer == chance then
        appodeal.show( type )
      end
    end
end

--Consumables
tycoonConsumable = false
local tycoon = ggData:new("consumables")
if tycoon:get(PRODUCT_TYCOON) ~= nil then
  tycoonConsumable = tycoon:get(PRODUCT_TYCOON)
end

--start the app on the loading scene
composer.gotoScene("scenes.loading")
