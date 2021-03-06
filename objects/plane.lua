package.path = package.path .. ";../?lua"

local planeSpeed = 0
local planeWidth = 160
local planeHeight = 90
planeNormal = nil
planeTapped = nil
plane = nil

function newPlane(w,h,s)
  planeWidth = w
  planeHeight = h
  planeSpeed = s
  createPlane()
end

function movePlane()
  planeNormal.x = planeNormal.x - planeSpeed
  planeTapped.x = planeTapped.x - planeSpeed
end

function outPlane()
  if planeNormal ~= nil then
    if planeNormal.x < (screenLeft-planeWidth)-1000 then
      plane:removeSelf()
      createPlane()
    end
  end
end

function planeFrame()
  if gamePaused then
    return
  end
  if plane ~= nil then
    movePlane()
    outPlane()
  end
end

function planeExplode()
  audio.play(explosionSound, {channel = 3})
  local explodeSprite = display.newSprite(explosionSheet,explosionSeq)
  explodeSprite:addEventListener("sprite",popEvent)
  explodeSprite.x = planeNormal.x
  explodeSprite.y = planeNormal.y
  explodeSprite:scale(6, 6)
  explodeSprite:play()
  planeNormal.alpha = 0
  planeTapped.alpha = 0
  timer.performWithDelay(500, gameOverMenuListener)
end

function createPlane()
  local x = math.random(rightMarg+planeWidth,rightMarg+planeWidth+1000)
  local y = math.random(screenTop+planeWidth/2,centerY)
  plane = display.newGroup()
  planeNormal = display.newImage("res/plane.png",x,y)
  planeNormal.width = planeWidth
  planeNormal.height = planeHeight
  planeTapped = display.newImage("res/planetapped.png", x, y)
  planeTapped.width = planeWidth
  planeTapped.height = planeHeight
  plane:insert(planeTapped)
  plane:insert(planeNormal)
  plane:addEventListener("touch", tapPlane)
end

function tapPlane()
  if gamePaused then return end
  local function tapOut()
    planeNormal.isVisible = true
    untappableObjectTapped = false
  end
  audio.play(errorSound, {channel = 1})
  planeNormal.isVisible = false
  untappableObjectTapped = true
  timer.performWithDelay(400, tapOut)
end

function deletePlane()
  if plane ~= nil then
    plane:removeSelf()
    plane = nil
  end
end
