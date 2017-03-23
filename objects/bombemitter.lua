package.path = package.path .. ";../?.lua"

vGroup = nil
local emitter = {}
local emitter_mt = {__index = emitter}

function emitter:tap(event)
  local popSprite = display.newSprite(explosionSheet,explosionSeq)
  popSprite:addEventListener("sprite",popEvent)
  popSprite.x = event.target.x
  popSprite.y = event.target.y-25
  popSprite.width = event.target.width
  popSprite.height = event.target.height
  popSprite:scale(2.5,2.5)
  popSprite:play()
  event.target.alpha = 0
  event.target:removeEventListener("tap",self)
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
  local width = 90
  local height = 110
  local randomX = math.random(screenLeft+width/2,rightMarg-width/2)
  local randomY = math.random(bottomMarg+height,bottomMarg+800)
  balloon = display.newImage("res/bombballoon.png",randomX,randomY)
  balloon.width = width
  balloon.height = height
  balloon:addEventListener("tap",self)
  physics.addBody(balloon);
  balloon.gravityScale = balloonGravity
  return balloon
end

return emitter
