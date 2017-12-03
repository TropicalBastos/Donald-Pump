package.path = package.path .. ";../?.lua"

local emitter = {}
local emitter_mt = {__index = emitter}
local balloonUltra
local speed
local ultraTimer = nil
finishedUltraAnimation = true

local function createBalloon()
  if balloonUltra == nil then
    local width = 110
    local height = 90
    local randomX = math.random(screenLeft+width/2,rightMarg-width/2)
    local randomY = math.random(bottomMarg+height,bottomMarg+800)
    local chance = math.random()
    balloonUltra = display.newImage("res/ultraballoon.png",randomX,randomY)
    balloonUltra.width = width
    balloonUltra.height = height
    balloonUltra:addEventListener("touch",tapUltra)
    physics.addBody(balloonUltra);
    balloonUltra.gravityScale = balloonGravity
    balloonUltra:setLinearVelocity(0, yVelGlobal)
  end
end

local function chanceOfAppearance()
  local chance = 6
  local r = math.random(1,chance)
  if r==1 then
    createBalloon()
  end
end

function ultraSpeedUp()
  if balloonUltra ~= nil then
    balloonUltra:setLinearVelocity(0, yVelGlobal)
  end
end

function destroyUltra()
  display.remove(balloonUltra)
  if balloonUltra ~= nil then
    balloonUltra = nil
  end
end

function isOutUltra()
  if balloonUltra ~= nil then
    if balloonUltra.y < screenTop - balloonUltra.height then
      balloonUltra:removeSelf()
      balloonUltra = nil
    end
  end
end

function tapUltra()
  if untappableObjectTapped then
    return
  end
  if gamePaused then
    return
  end

  audio.play(ultraSound, {channel = 4})
  finishedUltraAnimation = false
  local darkeffect = display.newRect(centerX,centerY,4000,4000)
  darkeffect:setFillColor(0,0,0)
  darkeffect.alpha = 0.2
  local popSprite = display.newSprite(ultraSheet,ultraSeq)
  popSprite:addEventListener("sprite",popEventUltra)
  popSprite.dark = darkeffect
  popSprite.x = balloonUltra.x+50
  popSprite.y = balloonUltra.y+25
  popSprite.width = balloonUltra.width
  popSprite.height = balloonUltra.height
  popSprite:play()
  balloonUltra.alpha = 0
  balloonUltra:removeEventListener("touch",tapUltra)
  removeEventListeners()

  --flex muscle animation
  local muscleSprite = display.newSprite(muscleSheet,muscleSeq)
  muscleSprite.x = centerX
  muscleSprite.y = centerY
  muscleSprite.alpha = 0.7
  muscleSprite:play()
  popSprite.muscle = muscleSprite

  scoreMultiplier = 10

  --set true the score multiplier
  if scoreTimer ~= nil then
    timer.cancel(scoreTimer)
    scoreMultiplier = scoreMultiplier + 10
  end

  --x scoremultiplier score label
  local x3 = display.newText(globalTextOptions)
  x3.text = "x" .. scoreMultiplier .. " MULTIPLIER"
  x3:scale(0,0)
  popSprite.x3 = x3
  transition.to(x3,{xScale=1,yScale=1,transition=easing.outBounce,time=1000})

  scoreTimer = timer.performWithDelay(10000,normalScoreMode)
  physics.pause()
end

function popEventUltra(event)
  -- fade out dark effect when animation finishes
  local dark = event.target.dark --get pointers to objects that need disposing
  local muscle = event.target.muscle
  local x3 = event.target.x3

  local function fadeOut2()
    --muscle:removeSelf()
    --x3:removeSelf()
  end

  local function fadeoutComplete()
    dark:removeSelf()
    transition.fadeOut(muscle,{onComplete=fadeOut2})
    transition.fadeOut(x3,{onComplete=fadeOut2})
    if not gameOverOn then
      addEventListeners()
      physics.start()
    end
    finishedUltraAnimation = true
  end

  if event.phase == "ended" then
    event.target:removeSelf()
    transition.fadeOut(dark,{onComplete = fadeoutComplete})
  end
end

function normalScoreMode()
  scoreMultiplier = 0;
  scoreTimer = nil
end

function frameUltra()
  if gamePaused then
    return
  end
  isOutUltra()
end

function cancelUltraEmitter()
  timer.cancel(ultraTimer)
end

function beginUltraEmitter()
  ultraTimer = timer.performWithDelay(4000,chanceOfAppearance,0)
end
