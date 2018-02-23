

local flyAwayText = {}
local flyAway_mt = {__index = flyAwayText}


function flyAwayText.new(options)
  if options.text == nil then
    print("Error: Failed to initialise string, no text passed into flyAway.new!")
    return
  end

  if options.font == nil then
    print("Error: Failed to initialise string, no font passed into flyAway.new!")
    return
  end

  if options.x == nil then
    options.x = display.contentCenterX
  end

  if options.y == nil then
    options.y = display.contentCenterY
  end

  local charArray = {}
  for i = 1, #options.text do
    local string = options.text
    charArray[i] = display.newText({text=string:sub(i,i),font=options.font,x=options.x,y=options.y,fontSize=options.fontSize})
  end

  local TextObject = {
    textArray = charArray
  }

  local meta = setmetatable(TextObject, flyAway_mt)
  meta:centerTextArray()
  return meta
end

--Function that centers the entire text array as if it were a textobject--
function flyAwayText:centerTextArray()
  local len = #self.textArray
  --if length is odd then center the middle character and center all other chars
  --from the left and right of the middle character
  if (len % 2) ~= 0 then

    local middle = math.floor((len/2) + 1)
    local charRef = self.textArray[middle]
    charRef.x = display.contentCenterX

    for i = middle+1, #self.textArray do
      self.textArray[i].x = self.textArray[i-1].x + self.textArray[i-1].width
    end

    for i = middle-1, 1, -1 do
      self.textArray[i].x = self.textArray[i+1].x - self.textArray[i+1].width
    end

  else

    local middle = len/2
    local charRef = self.textArray[middle]
    charRef.x = display.contentCenterX - (charRef.width/2)

    for i = middle+1, #self.textArray do
      self.textArray[i].x = self.textArray[i-1].x + self.textArray[i-1].width
    end

    for i = middle-1, 1, -1 do
      self.textArray[i].x = self.textArray[i+1].x - self.textArray[i+1].width
    end

  end

end

--Fly function: makes each character of a text move depending on
--the options table passed in
function flyAwayText:fly(delta,options)

  local index = 1
  local current
  local ti
  local callback


  --if a callback was passed into options table then store it
  if options.onComplete ~= nil then
    callback = options.onComplete
  end

  --closure that deals with the transition controls of text animation
  local function fly()
    if index > #self.textArray then
      if callback ~= nil then
        callback()
      end
      return
    end
    transition.to(self.textArray[index],options)
    index = index + 1
  end

  --start animation
  ti = timer.performWithDelay(delta,fly,#self.textArray)

end

function flyAwayText:removeSelf()
  for i = 1, #self.textArray do
    self.textArray[i]:removeSelf()
  end
end

return flyAwayText
