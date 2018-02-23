package.path = package.path .. ";../?.lua"

local emitter = {}
local emitter_mt = {__index = emitter}
local speed
local overlay
eventCopy = nil

function emitter:collision(event)
  local current = event.target
  local collided = event.other
  eventCopy = event
  if collided==toupe then
    timer.performWithDelay(50,self.pop)
  end
end

function showUltraOverlay()
  if overlay ~= nil then
    return
  end
  overlay = display.newImage("res/poweroverlay.png")
  overlay.x = centerX
  overlay.y = centerY
  overlay.width = rightMarg + 100
  overlay.height = bottomMarg + 100
  local function finish()
    transition.fadeOut(overlay, {
      time = 250,
      transition = easing.outCubic,
      onComplete = function() overlay:removeSelf() overlay = nil end
    })    
  end
  transition.fadeIn(overlay, {
    time = 250,
    transition = easing.inCubic,
    onComplete = finish
  })
end

function emitter:pop(event)

  if untappableObjectTapped then
    return
  end
  
  if event == nil then event = eventCopy end

  local fallScore = nil

  --delete text from memory after it has exited screen
  local function deleteScoreText()
    if fallScore ~= nil then
      display.remove(fallScore)
    end
  end

  local function makeScoreFall(n)
    --set falling text
    fallScore = display.newText(globalTextOptions)
    fallScore.x = event.target.x
    fallScore.y = event.target.y
    fallScore.text = n
    physics.addBody(fallScore)
    fallScore.isSensor = true
    timer.performWithDelay(5000,deleteScoreText)
    playScene:insert(fallScore)
  end

  if scoreMultiplier >= 5 then
    audio.play(x100Sound, {channel=1})
    event.target.alpha = 0
    event.target:removeEventListener("touch",self)
    currentScore = currentScore+(scoreTier*scoreMultiplier)
    updatePlayScore()
    makeScoreFall(scoreTier*scoreMultiplier)
    local emitter = prism.newEmitter({
      -- Particle building and emission options
      particles = {
        type = "image",
        image = "res/particle.png",
        width = 50,
        height = 50,
        color = {{1, 1, 0.1}, {1, 0, 0}},
        blendMode = "add",
        particlesPerEmission = 50,
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
  
    emitter.emitX, emitter.emitY = event.target.x, event.target.y
    emitter:emit()
  elseif scoreMultiplier > 0 then
    showUltraOverlay()
    audio.play(powerSound, {channel=1})
    local popSprite = display.newSprite(ultraSheet,ultraSeq)
    popSprite:addEventListener("sprite",popEvent)
    popSprite.x = event.target.x+50
    popSprite.y = event.target.y+25
    popSprite.width = event.target.width
    popSprite.height = event.target.height
    popSprite:play()
    event.target.alpha = 0
    event.target:removeEventListener("touch",self)
    currentScore = currentScore+(scoreTier*scoreMultiplier)
    updatePlayScore()
    makeScoreFall(scoreTier*scoreMultiplier)
  else
    audio.play(popSound, {channel=1})
    local popSprite = display.newSprite(balloonSheet,balloonSequence)
    popSprite:addEventListener("sprite",popEvent)
    popSprite.x = event.target.x
    popSprite.y = event.target.y-50
    popSprite.width = event.target.width
    popSprite.height = event.target.height
    popSprite:play()
    event.target.alpha = 0
    event.target:removeEventListener("touch",self)
    currentScore = currentScore+scoreTier
    updatePlayScore()
    makeScoreFall(scoreTier)
  end
end

function emitter:speedUp()
  for i = 1, #self.all do
    self.all[i]:setLinearVelocity(0, yVelGlobal)
  end
end

function emitter:touch(event)
  if gamePaused then
    return
  end
  self:pop(event)
end

function emitter.new(number,view)

  local bGroup = display.newGroup()
  local all = {}
  --local tapRect = {}

  for i = 0, number do
    local b = emitter:createBalloon()
    bGroup:insert(b)
    table.insert(all,b)
  end

  vGroup:insert(bGroup)

  bEmitter = {
    all = all
  }

  return setmetatable(bEmitter,emitter_mt)

end

function emitter:enterFrame()
  --move each invisible rect
  --for i = 1, #self.all do
    --self.all[i].tapRect.x = self.all[i].x
    --self.all[i].tapRect.y = self.all[i].y
  --end
  self:isOut()
end

function emitter:isOut()
  for i = 1, #self.all do
    if self.all[i].y < screenTop - self.all[i].height then
      if self.all[i].alpha ~= 0 then
        decrementScoreTier()
      end
      self.all[i]:removeSelf()
      self.all[i] = nil
      self.all[i] = self:createBalloon()
      vGroup:insert(self.all[i])
    end
  end
end

function emitter:createBalloon()
  local balloon
  local width = 130
  local height = 150
  local randomX = math.random(screenLeft+width/2,rightMarg-width/2)
  local randomY = math.random(bottomMarg+height,bottomMarg+1000)
  balloon = display.newImage("res/pumpballoon.png",randomX,randomY)
  balloon.width = width
  balloon.height = height
  balloon:addEventListener("collision",self)
  physics.addBody(balloon);
  balloon:addEventListener("touch",self)
  local g = balloonGravity
  if g < -0.15 then
    g = -0.15
  end
  balloon.gravityScale = g
  --bigger invisible rectangle for increased sensitivity on tap
  --local lRect = display.newRect(balloon.x,balloon.y,balloon.width*1.5,balloon.height*2)
  --lRect.alpha = 0
  --lRect:addEventListener("touch",self)
  --lRect.isHitTestable = true
  --balloon.tapRect = lRect
  --balloon.tapRect.p = balloon
  balloon:setLinearVelocity(0, yVelGlobal)
  playScene:insert(balloon)
  return balloon
end

return emitter
