package.path = package.path .. ";../?.lua"

local propertyEmitter = {}
local propertyEmitter_mt = {__index = propertyEmitter}
local balloonProperty
local speed
local propBalloonTimer = nil

local function tapProperty()
    propertyLife:add()
    destroyPropBalloon()
end

local function createBalloon()
  if balloonProperty == nil then
    local width = 90
    local height = 110
    local randomX = math.random(screenLeft+width/2,rightMarg-width/2)
    local randomY = math.random(bottomMarg+height,bottomMarg+800)
    local chance = math.random()
    balloonProperty = display.newImage("res/propertyballoon.png",randomX,randomY)
    balloonProperty.width = width
    balloonProperty.height = height
    balloonProperty:addEventListener("touch",tapProperty)
    physics.addBody(balloonProperty);
    balloonProperty.gravityScale = balloonGravity
  end
end

local function chanceOfAppearance()
  local chance = 6
  local r = math.random(1,chance)
  if r==1 then
    createBalloon()
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