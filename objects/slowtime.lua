package.path = package.path .. ";../?lua"

local slowTimeSpeed = 0
local slowTimeWidth = 160
local slowTimeHeight = 90
local isPaused = false
local slowProbability = 800 --1 in 800 every frame
slowTimeNull = true
slowTimeNormal = nil
slowTimeTapped = nil
slowTime = nil

function newSlowTime(w,h,s)
  slowTimeWidth = w
  slowTimeHeight = h
  slowTimeSpeed = s
  createSlowTime()
end

function moveSlowTime()
  if slowTime ~= nil then
    slowTimeNormal.x = slowTimeNormal.x + slowTimeSpeed
    slowTimeTapped.x = slowTimeTapped.x + slowTimeSpeed
  end
end

function outSlowTime()
  if slowTimeNormal ~= nil then
    if slowTimeNormal.x > (rightMarg + slowTimeWidth) + 1000 then
      slowTime:removeSelf()
      slowTime = nil
      slowTimeNull = true
      createSlowTime()
    end
  end
end

function slowTimeFrame()
  if slowTime ~= nil then
    moveSlowTime()
    outSlowTime()
  else 
    createSlowTime()
  end
end

function slowTimeExplode()
  audio.play(x100Hit, {channel = 3})
  slowTimeNormal.alpha = 0
  slowTimeTapped.alpha = 0
  physics.pause()
  removeEventListeners()
  timer.performWithDelay(1000,  function() physics.start() addEventListeners() end)
  slowTimeNull = true
end

function createSlowTime()

  -- chance of slow time appearing
  local rN = math.random(1, slowProbability)
  if rN ~= slowProbability then
    return
  end

  local x = math.random(screenLeft - slowTimeWidth - 1000, screenLeft - slowTimeWidth)
  local y = math.random(screenTop + (slowTimeHeight/2), bottomMarg - (slowTimeHeight/2))
  slowTime = display.newGroup()
  slowTimeNormal = display.newImage("res/slowtime.png")
  slowTimeTapped = display.newImage("res/slowtimetapped.png")
  slowTimeTapped.x = x 
  slowTimeTapped.y = y
  slowTimeNormal.x = x
  slowTimeNormal.y = y
  slowTimeNormal.width = slowTimeWidth
  slowTimeNormal.height = slowTimeHeight
  slowTimeTapped.width = slowTimeWidth
  slowTimeTapped.height = slowTimeHeight
  slowTime:insert(slowTimeTapped)
  slowTime:insert(slowTimeNormal)
  slowTime:addEventListener("touch", tapSlowTime)
  slowTimeNull = false
end

function tapSlowTime()
  if gamePaused then return end
  local function tapOut()
    slowTimeNormal.isVisible = true
    untappableObjectTapped = false
  end
  audio.play(errorSound, {channel = 1})
  slowTimeNormal.isVisible = false
  untappableObjectTapped = true
  timer.performWithDelay(400, tapOut)
end

function deleteSlowTime()
  if slowTime ~= nil then
    slowTime:removeSelf()
    slowTime = nil
    slowTimeNull = true
  end
end
