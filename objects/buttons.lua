package.path = package.path .. ";../?.lua"

local Buttons = {}
local Buttons_mt = {__index = Buttons}


Buttons.new = function(x,y,view)

  local xPos = x
  local yPos = y
  local ButtonGroup = display.newGroup()
  local allButtons = {}

  local play = display.newImage("res/play.png",xPos,yPos)
  local how = display.newImage("res/how.png",xPos,yPos)
  local options = display.newImage("res/options.png",xPos,yPos)

  table.insert(allButtons,play)
  table.insert(allButtons,how)
  table.insert(allButtons,options)

  ButtonGroup:insert(play)
  ButtonGroup:insert(how)
  ButtonGroup:insert(options)

  view:insert(ButtonGroup)

  local ButtonsTable = {
    allButtons = allButtons,
    ButtonGroup = ButtonGroup
  }

  return setmetatable(ButtonsTable,Buttons_mt)
end

function Buttons:setDimension(w)
  for i = 1, #self.allButtons do
    self.allButtons[i].width = w
    self.allButtons[i].height = w*1.5
    if(i>1) then
      self.allButtons[i].x = self.allButtons[i-1].x + self.allButtons[i].width/2+40
    end
  end
end

return Buttons
