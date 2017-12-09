package.path = package.path .. ";../?lua"

local rocketManSpeed = 0
local rocketManWidth = 160
local rocketManHeight = 90
rocketManNormal = nil
rocketManTapped = nil
rocketMan = nil

function newRocketMan(w,h,s)
  rocketManWidth = w
  rocketManHeight = h
  rocketManSpeed = s
  createRocketMan()
end

function moveRocketMan()
  rocketManNormal.x = rocketManNormal.x + rocketManSpeed
  --rocketManTapped.x = rocketManTapped.x - rocketManSpeed
end

function outRocketMan()
  if rocketManNormal ~= nil then
    if rocketManNormal.x > (rightMarg + rocketManWidth) + 1000 then
      rocketMan:removeSelf()
      createRocketMan()
    end
  end
end

function rocketManFrame()
  if gamePaused then
    return
  end
  if rocketMan ~= nil then
    moveRocketMan()
    outRocketMan()
  end
end

-- function planeExplode()
--   audio.play(explosionSound, {channel = 3})
--   local explodeSprite = display.newSprite(explosionSheet,explosionSeq)
--   explodeSprite:addEventListener("sprite",popEvent)
--   explodeSprite.x = planeNormal.x
--   explodeSprite.y = planeNormal.y
--   explodeSprite:scale(2.5, 2.5)
--   explodeSprite:play()
--   planeNormal.alpha = 0
--   planeTapped.alpha = 0
--   timer.performWithDelay(500, gameOverMenuListener)
-- end

function createRocketMan()
  local x = math.random(screenLeft - rocketManWidth - 1000, screenLeft - rocketManWidth)
  local y = math.random(screenTop + rocketManHeight, bottomMarg - rocketManHeight)
  rocketMan = display.newGroup()
  rocketManNormal = display.newSprite(rocketManSheet, rocketManSeq)
--   planeTapped = display.newImage("res/planetapped.png", x, y)
--   planeTapped.width = planeWidth
--   planeTapped.height = planeHeight
  --rocketMan:insert(planeTapped)
  rocketManNormal.x = x
  rocketManNormal.y = y
  rocketManNormal:scale(0.6, 0.6)
  rocketManNormal:play()
  rocketMan:insert(rocketManNormal)
  --rocketMan:addEventListener("touch", tapRocketMan)
end

-- function tapPlane()
--   if gamePaused then return end
--   local function tapOut()
--     planeNormal.isVisible = true
--     untappableObjectTapped = false
--   end
--   audio.play(errorSound, {channel = 1})
--   planeNormal.isVisible = false
--   untappableObjectTapped = true
--   timer.performWithDelay(400, tapOut)
-- end

function deleteRocketMan()
  if rocketMan ~= nil then
    rocketMan:removeSelf()
    rocketMan = nil
  end
end
