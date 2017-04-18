package.path = package.path .. ";../?.lua"

local properties = {}
local properties_mt = {__index = properties}
local propWidth = 30
local propHeight = 40
local propY = (screenTop + propHeight/2) + 3

function properties.new(n)
  local props = {}
  for i = 1, n do
    local prop = display.newImage("res/prop.png")
    prop.width = propWidth
    prop.height = propHeight
    prop.y = propY
    if i == 1 then
      prop.x = (rightMarg - prop.width/2) - 10
    else
      prop.x = props[i-1].x - 40
    end
    props[i] = prop
  end
  return setmetatable(props,properties_mt)
end

function properties:add()
  local prop = display.newImage("res/prop.png")
  prop.width = propWidth
  prop.height = propHeight
  prop.x = self[#self].x - 30
  prop.y = propY
  self[#self+1] = prop
end

function properties:pop()
  if #self ~= 0 then
    self[#self]:removeSelf()
    self[#self] = ni
  end
end

return properties
