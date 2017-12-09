package.path = package.path .. ";../?lua"

local americaSpeed = 0
local americaWidth = 100
local americaHeight = 60
local collisionHappening = false
creatingNewNuke = false
america = nil

function newAmerica(w,h,s)
  if creatingNewNuke then
    return
  end
  if america ~= nil then
    america:removeSelf()
    america = nil
  end
  americaWidth = w
  americaHeight = h
  americaSpeed = s
  creatingNewNuke = true
  timer.performWithDelay(3000, function() creatingNewNuke = false end)
  collisionHappening = false
  createAmerica()
end

function outAmericanNuke()
  if america ~= nil then
    if america.y < (screenTop - america.width) - 100 then
      deleteAmericanNuke()
    end
  end
end

function checkObjectCollision(displayObj)
  if displayObj ~= nil then
        --distances
        local yDist
        local xDist
    
        --calculate distance
        if america.y >= displayObj.y then
          yDist = america.y - displayObj.y
        else
          yDist = displayObj.y - america.y
        end
    
        if america.x >= displayObj.x then
          xDist = america.x - displayObj.x
        else 
          xDist = displayObj.x - america.x 
        end
    
        if xDist <= (displayObj.width/2)
        and yDist <= (displayObj.height/2) then
          return true
        end
      end

      return false
end

function checkCollisions()
  if collisionHappening then
    return
  end
  if checkObjectCollision(planeNormal) then
    planeExplode()
    america.alpha = 0
    collisionHappening = true
  end
end

function americaFrame()
  if gamePaused then
    return
  end
  if america ~= nil then
    checkCollisions()
    outAmericanNuke()
  end
end

function createAmerica()
  local x = centerX
  local y = bottomMarg + americaHeight + 100
  america = display.newSprite(americaSheet, americaSeq)
  america:scale(0.5, 0.5)
  america.x = x
  america.y = y
  physics.addBody(america, "kinematic")
  america.gravityScale = balloonGravity
  america:setLinearVelocity(0, americaSpeed)
  america:play()
end

function deleteAmericanNuke()
  if america ~= nil then
    america:removeSelf()
    america = nil
  end
end
