package.path = package.path .. ";../?lua"

local planeSpeed = 0
local planeWidth = 160
local planeHeight = 90
plane = nil

function newPlane(w,h,s)
  planeWidth = w
  planeHeight = h
  planeSpeed = s
  createPlane()
end

function movePlane()
  plane.x = plane.x - planeSpeed
end

function outPlane()
  if plane.x < (screenLeft-planeWidth)-1000 then
    plane:removeSelf()
    createPlane()
  end
end

function planeFrame()
  if gamePaused then
    return
  end
  if plane ~= nil then
    movePlane()
    outPlane()
  end
end

function createPlane()
  local x = math.random(rightMarg+planeWidth,rightMarg+planeWidth+1000)
  local y = math.random(screenTop+planeWidth/2,centerY)
  plane = display.newImage("res/plane.png",x,y)
  plane.width = planeWidth
  plane.height = planeHeight
end

function deletePlane()
  if plane ~= nil then
    plane:removeSelf()
    plane = nil
  end
end
