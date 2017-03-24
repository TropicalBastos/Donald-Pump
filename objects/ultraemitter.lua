package.path = package.path .. ";../?.lua"

local emitter = {}
local emitter_mt = {__index = emitter}
local balloon
local speed

local function createBalloon()
  if balloon == nil then
    local width = 90
    local height = 110
    local randomX = math.random(screenLeft+width/2,rightMarg-width/2)
    local randomY = math.random(bottomMarg+height,bottomMarg+800)
    local chance = math.random()
    balloon = display.newImage("res/ultraballoon.png",randomX,randomY)
    balloon.width = width
    balloon.height = height
    balloon:addEventListener("tap",tapUltra)
    physics.addBody(balloon);
    balloon.gravityScale = balloonGravity
  end
end

local function chanceOfAppearance()
  local chance = 6
  local r = math.random(1,chance)
  if r==1 then
    createBalloon()
  end
end

function isOutUltra()
  if balloon ~= nil then
    if balloon.y < screenTop - balloon.height then
      balloon:removeSelf()
      balloon = nil
    end
  end
end

function tapUltra()
  local darkeffect = display.newRect(centerX,centerY,4000,4000)
  darkeffect:setFillColor(0,0,0)
  darkeffect.alpha = 0.2
  local popSprite = display.newSprite(ultraSheet,ultraSeq)
  popSprite:addEventListener("sprite",popEventUltra)
  popSprite.dark = darkeffect
  popSprite.x = balloon.x+50
  popSprite.y = balloon.y+25
  popSprite.width = balloon.width
  popSprite.height = balloon.height
  popSprite:play()
  balloon.alpha = 0
  balloon:removeEventListener("tap",tapUltra)
  removeEventListeners()

  --flex muscle animation
  local muscleSprite = display.newSprite(muscleSheet,muscleSeq)
  muscleSprite.x = centerX
  muscleSprite.y = centerY
  muscleSprite.alpha = 0.6
  muscleSprite:play()
  popSprite.muscle = muscleSprite

  --x3 score label
  local x3 = display.newText(globalTextOptions)
  x3.text = "x10 MULTIPLIER"
  x3:scale(0,0)
  popSprite.x3 = x3
  transition.to(x3,{xScale=1,yScale=1,transition=easing.outBounce,time=1000})

  --set true the score multiplier
  if scoreTimer ~= nil then
    timer.cancel(scoreTimer)
  end
  scoreMultiplier = true
  scoreTimer = timer.performWithDelay(10000,normalScoreMode)
  physics.pause()
end

function popEventUltra(event)
  -- fade out dark effect when animation finishes
  local dark = event.target.dark --get pointers to objects that need disposing
  local muscle = event.target.muscle
  local x3 = event.target.x3

  local function fadeOut2()
    muscle:removeSelf()
    x3:removeSelf()
  end

  local function fadeoutComplete()
    dark:removeSelf()
    transition.fadeOut(muscle,{onComplete=fadeOut2})
    transition.fadeOut(x3,{onComplete=fadeOut2})
    addEventListeners()
    physics.start()
  end

  if event.phase == "ended" then
    event.target:removeSelf()
    transition.fadeOut(dark,{onComplete = fadeoutComplete})
  end
end

function normalScoreMode()
  scoreMultiplier = false
  scoreTimer = nil
end

function frameUltra()
  isOutUltra()
end

function beginUltraEmitter()
  timer.performWithDelay(4000,chanceOfAppearance,0)
end
