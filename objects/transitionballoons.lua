package.path = package.path .. ";../?.lua"

--bottom margin - for balloon positioning off screen
local bottomMarg = display.contentHeight - display.screenOriginY

-- other positioning helpers
local screenLeft = display.screenOriginX
local rightMarg = display.contentWidth - display.screenOriginX

local transitionBalloons = {}
--set metatable that points to trabsitionBalloons object
local transitionBalloons_mt = {__index = transitionBalloons}

--transitionbaloons.new = function()
function transitionBalloons.new (numberOfBalloons,view,speed)
  local balloonGroup = display.newGroup() --group of balloons for the display
  local allBalloons = {} --table that holds balloons

  for i=0, numberOfBalloons do
    local balloon = transitionBalloons:createBalloon()
    balloonGroup:insert(balloon) --insert into display group
    table.insert(allBalloons,balloon) --insert into table of objects references
  end

  view:insert(balloonGroup)

  local newBalloonGenerator = {
    allBalloons = allBalloons,
    speed = speed
  }

  --returns the balloongenerator object that inherits transitionBalloons_mt so its functions
  return setmetatable(newBalloonGenerator,transitionBalloons_mt)

end

function transitionBalloons:enterFrame()
  self:move()
  --self:check()
end

function transitionBalloons:createBalloon()
  local width = 50
  local height = 65

  --half width to constrain center x of balloon within screen
  local hWidth = width/2

  local image = display.newImage("res/balloon.png",math.random(screenLeft+hWidth,rightMarg-hWidth),
  math.random(bottomMarg+100,bottomMarg+800))
  image.width = width
  image.height = height

  return image
end

function transitionBalloons:move()
  for i=1, #self.allBalloons do
    self.allBalloons[i].y = self.allBalloons[i].y - self.speed
  end
end

function transitionBalloons:check()
  for i=1, #self.allBalloons do
    if self.allBalloons[i].y <= 0 then
      self.allBalloons[i]:removeSelf()
      self.allBalloons[i] = nil
      self.allBalloons[i] = transitionBalloons:createBalloon()
    end
  end
end

--return the module
return transitionBalloons
