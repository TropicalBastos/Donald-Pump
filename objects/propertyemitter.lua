package.path = package.path .. ";../?.lua"

local propertyEmitter = {}
local propertyEmitter_mt = {__index = propertyEmitter}
local balloonProperty
local speed
local propBalloonTimer = nil

local function tapProperty(event)
    if untappableObjectTapped or gamePaused then
      return
    end
    propertyLife:add()
    destroyPropBalloon()
    local popSprite = display.newSprite(balloonSheet,balloonSequence)
    popSprite:addEventListener("sprite",popEvent)
    popSprite.x = event.target.x
    popSprite.y = event.target.y-50
    popSprite.width = event.target.width
    popSprite.height = event.target.height
    popSprite:play()
    event.target.alpha = 0
    event.target:removeEventListener("touch",tapProperty)

    audio.play(coinSound, {channel=3})

    --display coin
    local coin = display.newImage('res/propcoin.png')
    coin.x = event.target.x
    coin.y = event.target.y
    coin.width = 60
    coin.height = 60
    transition.to(coin, {
      time = 1000,
      x = rightMarg,
      y = screenTop,
      transition = easing.inQuad,
      onComplete = function() coin:removeSelf() end
    })
end

local function createBalloon()
  if balloonProperty == nil then
    local width = 90
    local height = 110
    local randomX = math.random(screenLeft+width/2,rightMarg-width/2)
    local randomY = math.random(bottomMarg+height,bottomMarg+800)
    --local chance = math.random()
    balloonProperty = display.newImage("res/propertyballoon.png",randomX,randomY)
    balloonProperty.width = width
    balloonProperty.height = height
    balloonProperty:addEventListener("touch",tapProperty)
    physics.addBody(balloonProperty);
    balloonProperty.gravityScale = balloonGravity
    balloonProperty:setLinearVelocity(0, yVelGlobal)
  end
end

local function chanceOfAppearance()
  local chance = 6
  local r = math.random(1,chance)
  if r==1 then
    createBalloon()
  end
end

function propSpeedUp()
  if balloonProperty ~= nil then
    balloonProperty:setLinearVelocity(0, yVelGlobal)
  end
end

function destroyPropBalloon()
  display.remove(balloonProperty)
  if balloonProperty ~= nil then
    balloonProperty = nil
  end
end

function isOutPropBalloon()
  if balloonProperty ~= nil then
    if balloonProperty.y < screenTop - balloonProperty.height then
      balloonProperty:removeSelf()
      balloonProperty = nil
    end
  end
end

function framePropBalloon()
  if gamePaused then
    return
  end
  isOutPropBalloon()
end

function cancelPropBalloonEmitter()
  timer.cancel(propBalloonTimer)
end

function beginPropBalloonEmitter()
  propBalloonTimer = timer.performWithDelay(4000,chanceOfAppearance,0)
end