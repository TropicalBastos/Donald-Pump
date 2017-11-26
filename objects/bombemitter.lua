package.path = package.path .. ";../?.lua"

vGroup = nil
local emitter = {}
local emitter_mt = {__index = emitter}
eventCopyBomb = nil

function emitter:collision(event)
  local collided = event.other
  eventCopyBomb = event
  if collided==toupe then
    timer.performWithDelay(10,self.pop)
  end
end

function emitter:pop(event)

  if event == nil then event = eventCopyBomb end

  local fallScore = nil

  --delete text from memory after it has exited screen
  local function deleteScoreText()
    fallScore:removeSelf()
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
  end

  if scoreMultiplier > 0 then
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
    makeScoreFall(scoreMultiplier*scoreTier)
  else
    local popSprite = display.newSprite(explosionSheet,explosionSeq)
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

function emitter:touch(event)
  if untappableObjectTapped then
    return
  end
  if gamePaused or gameOverOn then
    return
  end
  totalGameOver = true
  audio.play(explosionSound, {channel = 3})
  local popSprite = display.newSprite(explosionSheet,explosionSeq)
  popSprite:addEventListener("sprite",popEvent)
  popSprite.x = event.target.x
  popSprite.y = event.target.y-25
  popSprite.width = event.target.width
  popSprite.height = event.target.height
  popSprite:scale(2.5,2.5)
  popSprite:play()
  timer.performWithDelay(500, gameOverMenuListener)
  event.target.alpha = 0
  event.target:removeEventListener("touch",self)

  
  --display nuclear overlay
  displayNuclearOverlay()
end

function emitter.new(number,view)

  local bGroup = display.newGroup()
  local all = {}

  for i = 0, number do
    local b = emitter:createBalloon()
    bGroup:insert(b)
    table.insert(all,b)
  end

  vGroup = view
  vGroup:insert(bGroup)

  bEmitter = {
    all = all,
  }

  return setmetatable(bEmitter,emitter_mt)

end

function emitter:enterFrame()
  self:isOut()
end

function emitter:isOut()
  for i = 1, #self.all do
    if self.all[i].y < screenTop - self.all[i].height then
      self.all[i]:removeSelf()
      self.all[i] = nil
      self.all[i] = emitter:createBalloon()
      vGroup:insert(self.all[i])
      self.all[i]:toFront()
      playScore:toFront()
      if balloonSpeed < 6 then
        balloonSpeed = balloonSpeed + 0.004
      end
    end
  end
end

function emitter:createBalloon()
  local balloon
  local width = 50
  local height = 110
  local randomX = math.random(screenLeft+width/2,rightMarg-width/2)
  local randomY = math.random(bottomMarg+height,bottomMarg+800)
  balloon = display.newImage("res/bombballoon.png",randomX,randomY)
  balloon.width = width
  balloon.height = height
  balloon:addEventListener("touch",self)
  physics.addBody(balloon);
  balloon.gravityScale = balloonGravity
  balloon:addEventListener("collision",self)
  return balloon
end

return emitter
