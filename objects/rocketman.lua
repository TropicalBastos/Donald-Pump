package.path = package.path .. ";../?lua"

local rocketManSpeed = 0
local rocketManWidth = 160
local rocketManHeight = 90
local isPaused = false
local rocketProbability = 5 --1 in 5
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
  rocketManTapped.x = rocketManTapped.x + rocketManSpeed
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
  if rocketMan ~= nil then
    if gamePaused then
      if not isPaused then
        rocketManNormal:pause()
        rocketManTapped:pause()
        isPaused = true
      end
      return
    end
  
    if isPaused then
      rocketManNormal:play()
      rocketManTapped:play()
      isPaused = false
    end
    
    moveRocketMan()
    outRocketMan()
  end
end

function rocketManExplode()
  audio.play(x100Sound, {channel = 3})

  local emitter = prism.newEmitter({
    -- Particle building and emission options
    particles = {
      type = "image",
      image = "res/particle.png",
      width = 50,
      height = 50,
      color = {{1, 1, 0.1}, {1, 0, 0}},
      blendMode = "add",
      particlesPerEmission = 100,
      delayBetweenEmissions = 100,
      inTime = 100,
      lifeTime = 100,
      outTime = 1000,
      startProperties = {xScale = 1, yScale = 1},
      endProperties = {xScale = 0.3, yScale = 0.3}
    },
    -- Particle positioning options
    position = {
      type = "point"
    },
    -- Particle movement options
    movement = {
      type = "random",
      velocityRetain = .97,
      speed = 1,
      yGravity = -0.15
    }
  })

  emitter.emitX, emitter.emitY = rocketManNormal.x, rocketManNormal.y
  emitter:emit()

  scoreMultiplier = 100

  if scoreTimer ~= nil then
    timer.cancel(scoreTimer)
    scoreMultiplier = scoreMultiplier + 100
  end

  scoreTimer = timer.performWithDelay(10000, normalScoreMode)

  --x scoremultiplier score label
  local x100 = display.newText(globalTextOptions)
  x100.text = "x" .. scoreMultiplier .. " MULTIPLIER"
  x100:scale(0,0)
  transition.to(x100,
  {
    xScale=1,
    yScale=1,
    transition=easing.outBounce,
    time=1000,
    onComplete = function() transition.fadeOut(x100, {onComplete = function() x100:removeSelf() end }) end
  })

  rocketManNormal.alpha = 0
  rocketManTapped.alpha = 0
  physics.pause()
  removeEventListeners()
  timer.performWithDelay(1000,  function() physics.start() addEventListeners() end)
end

function createRocketMan()

  -- chance of rocketman appearing
  local rN = math.random(1, rocketProbability)
  if rN ~= rocketProbability then
    return
  end

  local x = math.random(screenLeft - rocketManWidth - 1000, screenLeft - rocketManWidth)
  local y = math.random(screenTop + (rocketManHeight/2), bottomMarg - (rocketManHeight/2))
  rocketMan = display.newGroup()
  rocketManNormal = display.newSprite(rocketManSheet, rocketManSeq)
  rocketManTapped = display.newSprite(rocketManTappedSheet, rocketManSeq)
  rocketManTapped.x = x 
  rocketManTapped.y = y
  rocketManNormal.x = x
  rocketManNormal.y = y
  rocketManNormal:scale(0.6, 0.6)
  rocketManTapped:scale(0.6, 0.6)
  rocketManTapped:play()
  rocketManNormal:play()
  rocketMan:insert(rocketManTapped)
  rocketMan:insert(rocketManNormal)
  rocketMan:addEventListener("touch", tapRocketMan)
end

function tapRocketMan()
  if gamePaused then return end
  local function tapOut()
    rocketManNormal.isVisible = true
    untappableObjectTapped = false
  end
  audio.play(errorSound, {channel = 1})
  rocketManNormal.isVisible = false
  untappableObjectTapped = true
  timer.performWithDelay(400, tapOut)
end

function deleteRocketMan()
  if rocketMan ~= nil then
    rocketMan:removeSelf()
    rocketMan = nil
  end
end
