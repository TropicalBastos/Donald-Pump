package.path = package.path .. ";../?.lua"

--necessary positioning helpers
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local bottomMarg = display.contentHeight - display.screenOriginY
local rightMarg = display.contentWidth - display.screenOriginX

local cloudGenerator = {}
local cloudGenerator_mt = {__index = cloudGenerator}

function cloudGenerator:touch(event)

  if gamePaused then
    return
  end

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

  if scoreMultiplier >= 50 then
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
    currentScore = currentScore+scoreMultiplier
    updatePlayScore()
    makeScoreFall(scoreMultiplier)
  else
    audio.play(popSound, {channel=1})
    local popSprite = display.newSprite(balloonSheet,balloonSequence)
    popSprite:addEventListener("sprite",popEvent)
    popSprite.x = event.target.x
    popSprite.y = event.target.y-50
    popSprite.width = event.target.width
    popSprite.height = event.target.height
    popSprite:scale(0.8,0.8)
    popSprite:play()
    event.target.alpha = 0
    event.target:removeEventListener("touch",self)
    currentScore = currentScore+1
    updatePlayScore()
    makeScoreFall(1)
  end
end

function cloudGenerator.new(number,view,speed)

  local cloudGroup = display.newGroup()
  local allClouds = {}

  for i = 0, number do
    local cloud = cloudGenerator:createCloud()
    table.insert(allClouds,cloud)
    cloudGroup:insert(cloud)
  end

  cGenerator = {
    allClouds = allClouds,
    speed = speed
  }

  return setmetatable(cGenerator,cloudGenerator_mt)
end

function cloudGenerator:createCloud()
  local width = rightMarg/6
  local randomX = math.random(rightMarg+width,rightMarg+500)
  local randomY = math.random(screenTop+width/2,centerY-20)
  local cloud = display.newImage("res/cloud.png",randomX,randomY)
  cloud.width = width
  cloud.height = cloud.width/2
  if whichScene == "play" then
    cloud:addEventListener("touch",self)
    end
  return cloud
end

function cloudGenerator:enterFrame()
  if gamePaused then
    return
  end
  self:move()
  self:outOfBounds()
end

function cloudGenerator:move()
  for i = 1, #self.allClouds do
    self.allClouds[i].x = self.allClouds[i].x - self.speed
  end
end

function cloudGenerator:outOfBounds()
  for i = 1, #self.allClouds do
    if self.allClouds[i].x < screenLeft - self.allClouds[i].width then
      self.allClouds[i]:removeSelf()
      self.allClouds[i] = nil
      local cloud = self:createCloud()
      self.allClouds[i] = cloud
    end
  end
end

function cloudGenerator:deleteAll()
  for i = 1, #self.allClouds do
    self.allClouds[i]:removeSelf()
    self.allClouds[i] = nil
  end
end

return cloudGenerator
