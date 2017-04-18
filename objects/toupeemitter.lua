package.path = package.path .. ";../?.lua"


local emitter = {}
local emitter_mt = {__index = emitter}
local balloon
local speed
toupe = nil
toupeTimer = nil

local function createBalloon()
  if balloon == nil then
    local width = 90
    local height = 110
    local randomX = math.random(screenLeft+width/2,rightMarg-width/2)
    local randomY = math.random(bottomMarg+height,bottomMarg+800)
    balloon = display.newImage("res/toupeballoon.png",randomX,randomY)
    balloon.width = width
    balloon.height = height
    balloon:addEventListener("touch",tapToupe)
    physics.addBody(balloon);
    balloon.gravityScale = balloonGravity
  end
end

local function chanceOfAppearance()
  local chance = 5
  local r = math.random(1,chance)
  if r==1 then
    createBalloon()
  end
end

function isOutToupe()
  if balloon ~= nil then
    if balloon.y < screenTop - balloon.height then
      balloon:removeSelf()
      balloon = nil
    end
  end
end

function destroyToupe()
  toupe:removeSelf()
  toupeTimer = nil
end

function tapToupe()
  local popSprite = display.newSprite(balloonSheet,balloonSequence)
  popSprite:addEventListener("sprite",popEvent)
  popSprite.x = balloon.x
  popSprite.y = balloon.y-50
  popSprite.width = balloon.width
  popSprite.height = balloon.height
  popSprite:play()
  balloon.alpha = 0
  balloon:removeEventListener("touch",tapToupe)
  toupe = display.newImage("res/toupe.png",balloon.x,balloon.y)
  toupe:scale(0.6,0.6)
  physics.addBody(toupe)
  toupe.angularVelocity = 270
  toupe.isSensor = true
  if toupeTimer ~= nil then
    timer.cancel(toupeTimer)
  end
  toupeTimer = timer.performWithDelay(5000,destroyToupe)
end

function frameToupe()
  isOutToupe()
end

function beginToupeEmitter()
  timer.performWithDelay(4000,chanceOfAppearance,0)
end
