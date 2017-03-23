package.path = package.path .. ";../?lua"

local zepSpeed = 0
local zepWidth = 100
local zepHeight = 60
zep = nil

function newZep(w,h,s)
  zepWidth = w
  zepHeight = h
  zepSpeed = s
  createZep()
end

function moveZep()
  zep.x = zep.x - zepSpeed
end

function outZep()
  if zep.x < (screenLeft-zepWidth)-1000 then
    zep:removeSelf()
    createZep()
  end
end

function zepFrame()
  moveZep()
  outZep()
end

function createZep()
  local x = math.random(rightMarg+zepWidth,rightMarg+zepWidth+1000)
  local y = math.random(screenTop+zepWidth/2,centerY)
  zep = display.newImage("res/zep.png",x,y)
  zep.width = zepWidth
  zep.height = zepHeight
end
