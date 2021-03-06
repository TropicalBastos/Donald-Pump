package.path = package.path .. ";../?.lua"

local properties = {}
local properties_mt = {__index = properties}
local propWidth = 30
local propHeight = 30
local propY = (screenTop + propHeight/2) + 10

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
      prop.x = props[i-1].x - 30
    end
    props[i] = prop
  end
  return setmetatable(props,properties_mt)
end

function properties:add()
  if #self < 8 then
    local prop = display.newImage("res/prop.png")
    prop.width = propWidth
    prop.height = propHeight
    prop.x = self[#self].x - 40
    prop.y = propY
    self[#self+1] = prop
    scoreTier = #self
  end
end

function properties:deleteAll()
  for i = 1, #self do
    self[i]:removeSelf()
  end
end

function properties:pop()
  if #self ~= 0 then
    self[#self]:removeSelf()
    self[#self] = nil
  end
end

return properties
