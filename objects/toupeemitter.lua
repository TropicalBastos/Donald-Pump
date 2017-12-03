package.path = package.path .. ";../?.lua"


local emitter = {}
local emitter_mt = {__index = emitter}
local balloonToupe
local speed
local toupe_Timer
toupe = nil
toupeTimer = nil

local function createBalloon()
  if balloonToupe == nil then
    local width = 90
    local height = 110
    local randomX = math.random(screenLeft+width/2,rightMarg-width/2)
    local randomY = math.random(bottomMarg+height,bottomMarg+800)
    balloonToupe = display.newImage("res/toupeballoon.png",randomX,randomY)
    balloonToupe.width = width
    balloonToupe.height = height
    balloonToupe:addEventListener("touch",tapToupe)
    physics.addBody(balloonToupe);
    balloonToupe.gravityScale = balloonGravity
    balloonToupe:setLinearVelocity(0, yVelGlobal)
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
  if balloonToupe ~= nil then
    if balloonToupe.y < screenTop - balloonToupe.height then
      balloonToupe:removeSelf()
      balloonToupe = nil
    end
  end
end

function destroyToupe()
  display.remove(balloonToupe)
  display.remove(toupe)
  if balloonToupe ~= nil then
    balloonToupe = nil
  end
end

function toupeSpeedUp()
  if balloonToupe ~= nil then
    balloonToupe:setLinearVelocity(0, yVelGlobal)
  end
end

function tapToupe()
  if untappableObjectTapped then
    return
  end
  if gamePaused then
    return
  end
  audio.play(whistleSound, {channel = 3})
  local popSprite = display.newSprite(balloonSheet,balloonSequence)
  popSprite:addEventListener("sprite",popEvent)
  popSprite.x = balloonToupe.x
  popSprite.y = balloonToupe.y-50
  popSprite.width = balloonToupe.width
  popSprite.height = balloonToupe.height
  popSprite:play()
  balloonToupe.alpha = 0
  balloonToupe:removeEventListener("touch",tapToupe)
  toupe = display.newImage("res/toupe.png",balloonToupe.x,balloonToupe.y)
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
  if gamePaused then
    return
  end
  isOutToupe()
end

function cancelToupeEmitter()
  timer.cancel(toupe_Timer)
end

function beginToupeEmitter()
  toupe_Timer = timer.performWithDelay(4000,chanceOfAppearance,0)
end
