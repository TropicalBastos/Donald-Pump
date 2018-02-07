package.path = package.path .. ";../?lua"

local zepSpeed = 0
local zepWidth = 100
local zepHeight = 60
zepNormal = nil
zepTapped = nil
zep = nil

function newZep(w,h,s)
  zepWidth = w
  zepHeight = h
  zepSpeed = s
  createZep()
end

function moveZep()
  zepNormal.x = zepNormal.x - zepSpeed
  zepTapped.x = zepTapped.x - zepSpeed
end

function outZep()
  if zepNormal ~= nil then
    if zepNormal.x < (screenLeft-zepWidth)-1000 then
      zep:removeSelf()
      createZep()
    end
  end
end

function zepFrame()
  if gamePaused then
    return
  end
  if zep ~= nil then
    moveZep()
    outZep()
  end
end

function zepExplode()
  audio.play(explosionSound, {channel = 3})
  local explodeSprite = display.newSprite(explosionSheet,explosionSeq)
  explodeSprite:addEventListener("sprite",popEvent)
  explodeSprite.x = zepNormal.x
  explodeSprite.y = zepNormal.y
  explodeSprite:scale(6, 6)
  explodeSprite:play()
  zepNormal.alpha = 0
  zepTapped.alpha = 0
  timer.performWithDelay(500, gameOverMenuListener)
end

function createZep()
  local x = math.random(rightMarg+zepWidth,rightMarg+zepWidth+1000)
  local y = math.random(screenTop+zepWidth/2,centerY)
  zep = display.newGroup()
  zepNormal = display.newImage("res/zep.png",x,y)
  zepNormal.width = zepWidth
  zepNormal.height = zepHeight
  zepTapped = display.newImage("res/zeptapped.png",x,y)
  zepTapped.width = zepWidth
  zepTapped.height = zepHeight
  zep:insert(zepTapped)
  zep:insert(zepNormal)
  zep:addEventListener("touch", tapZep)
end

function tapZep()
  if gamePaused or isOnMenu then return end
  local function tapOut()
    zepNormal.isVisible = true
    untappableObjectTapped = false
  end
  audio.play(errorSound, {channel = 1})
  zepNormal.isVisible = false
  untappableObjectTapped = true
  timer.performWithDelay(400, tapOut)
end

function deleteZep()
  if zep ~= nil then
    zep:removeSelf()
    zep = nil
  end
end
