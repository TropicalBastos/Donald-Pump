package.path = package.path .. ";../?.lua"

local emitter = {}
local emitter_mt = {__index = emitter}
local speed

function emitter:tap(event)

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
    timer.performWithDelay(5000,deleteScoreText)
  end

  if scoreMultiplier then
    local popSprite = display.newSprite(ultraSheet,ultraSeq)
    popSprite:addEventListener("sprite",popEvent)
    popSprite.x = event.target.x+50
    popSprite.y = event.target.y+25
    popSprite.width = event.target.width
    popSprite.height = event.target.height
    popSprite:play()
    event.target.alpha = 0
    event.target:removeEventListener("tap",self)
    currentScore = currentScore+10
    updatePlayScore()
    makeScoreFall(10)
  else
    local popSprite = display.newSprite(balloonSheet,balloonSequence)
    popSprite:addEventListener("sprite",popEvent)
    popSprite.x = event.target.x
    popSprite.y = event.target.y-50
    popSprite.width = event.target.width
    popSprite.height = event.target.height
    popSprite:scale(0.8,0.8)
    popSprite:play()
    event.target.alpha = 0
    event.target:removeEventListener("tap",self)
    currentScore = currentScore+1
    updatePlayScore()
    makeScoreFall(1)
  end
  return true
end

function emitter.new(number,view)

  local bGroup = display.newGroup()
  local all = {}

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
  self:move()
  self:isOut()
end

function emitter:move()
  for i = 1, #self.all do
    if balloonSpeed < 3.5 then
    self.all[i].y = self.all[i].y - balloonSpeed
    else
      self.all[i].y = self.all[i].y - 3.5 --max speed
    end
  end
end

function emitter:isOut()
  for i = 1, #self.all do
    if self.all[i].y < screenTop - self.all[i].height then
      self.all[i]:removeSelf()
      self.all[i] = nil
      self.all[i] = self:createBalloon()
      vGroup:insert(self.all[i])
    end
  end
end

function emitter:createBalloon()
  local balloon
  local width = 50
  local height = 65
  local randomX = math.random(screenLeft+width/2,rightMarg-width/2)
  local randomY = math.random(bottomMarg+height,bottomMarg+800)
  balloon = display.newImage("res/pumpballoon.png",randomX,randomY)
  balloon.width = width
  balloon.height = height
  balloon:addEventListener("tap",self)
  return balloon
end

return emitter
