package.path = package.path .. ";../?.lua"


local emitter = {}
local emitter_mt = {__index = emitter}
local balloon
local speed

local function createBalloon()
  if balloon == nil then
    local width = 50
    local height = 65
    local randomX = math.random(screenLeft+width/2,rightMarg-width/2)
    local randomY = math.random(bottomMarg+height,bottomMarg+800)
    local chance = math.random()
    if chance < 0.04 and chance > 0.01 then
      balloon = display.newImage("res/toupeballoon.png",randomX,randomY)
      balloon.width = width
      balloon.height = height
      balloon:addEventListener("tap",tapToupe)
    end
  end
end

function moveToupe()
  if balloon ~= nil then
    balloon.y = balloon.y - balloonSpeed
  end
end

function isOutToupe()
  if balloon ~= nil then
    if balloon.y < screenTop - balloon.height then
      balloon:removeSelf()
      balloon = nil
      createBalloon()
    end
  end
end

function tapToupe()
  local popSprite = display.newSprite(toupeSheet,toupeSeq)
  popSprite:addEventListener("sprite",popEvent)
  popSprite.x = balloon.x
  popSprite.y = balloon.y-25
  popSprite.width = balloon.width
  popSprite.height = balloon.height
  popSprite:play()
  balloon.alpha = 0
  balloon:removeEventListener("tap",tapToupe)
  return true
end

function frameToupe()
  moveToupe()
  isOutToupe()
end

function beginToupeEmitter()
  timer.performWithDelay(1000,createBalloon,0)
end
