package.path = package.path .. ";../?.lua"

local composer = require( "composer" )
local cloudGenerator = require("objects.cloudGenerator")
local bemitter = require("objects.bombemitter")
local pemitter = require("objects.pumpemitter")
local temitter = require("objects.toupeemitter")
local uemitter = require("objects.ultraemitter")
local propemitter = require("objects.propertyemitter")
local propertiesImport = require("objects.properties")
local americanNuke = require("objects.americabomb")
local rocketManObj = require("objects.rocketman")
local slowTimeObj = require("objects.slowtime")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
--global
--balloonGravity = -0.01
balloonGravity = 0
scoreMultiplier = 0
scoreTimer = nil
playScore = nil
currentScore = 0
prevScore = 0
yVelGlobal = 0

local bg
local current
local num
local bombEmitter = nil
local pumpEmitter = nil
local cloudEmitter = nil
local nuclearLoopSound = nil
local goingToMainMenu = false
local crosshair
nuclearOverlayOn = false
nuclearOverlay = nil
scoreTier = 1
backButton = nil
restartButton = nil
topBarHUD = nil
propertyLife = nil
speedTimer = nil
whichScene = "play"
gamePaused = true
darkenedScreen = nil
menuMenu = nil
retryMenu = nil
gameoverMenu = nil
gameOverOn = false
yesButton = nil
noButton = nil
fromMenuToPlay = true
gameOverScore = nil
totalGameOver = false
untappableObjectTapped = false
isOnMenu = false
playScene = nil
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    physics.pause()
    audio.stop({channel = 2})
    audio.play(playTheme, {channel = 2, loops = -1})
    playScene = self.view
    local sceneGroup = playScene
    -- Code here runs when the scene is first created but has not yet appeared on screen
    composer.removeScene("scenes.menu")
    composer.removeScene("scenes.transition")

    appodeal.hide( "banner" )

    --reset yvel of global objects
    yVelGlobal = -100

    --Background
    bg = display.newImage("res/bg.png",0,0)
    bg.width = rightMarg + 100
    bg.height = bottomMarg + 100
    bg.x = centerX
    bg.y = centerY
    sceneGroup:insert(bg)

    --initialize cloud emmiter
    cloudEmitter = cloudGenerator.new(5,sceneGroup,0.5)

    --zep object
    newZep(150,80,1.3)

    --plane object
    newPlane(300, 100, 2)

    --rocketMan object
    newRocketMan(200, 210, 3)

    --slow time object
    newSlowTime(220, 80, 3)

    --reset global
    balloonSpeed = 1

    --set up emitters
    bombEmitter = bemitter.new(25,sceneGroup)
    pumpEmitter = pemitter.new(8,sceneGroup)

    playScore = display.newText(globalTextOptions)
    playScore.text = "Score: " .. currentScore
    playScore.x = centerX
    playScore.y = bottomMarg - playScore.height/2
    sceneGroup:insert(playScore)
    playScore:toFront()

    local leftWall = display.newRect(0,0,50,10000)
    local rightWall = display.newRect (rightMarg, 0, 50, 10000)

    leftWall.alpha = 0
    rightWall.alpha = 0

    sceneGroup:insert(rightWall)
    sceneGroup:insert(leftWall)

    physics.addBody (leftWall, "static", { bounce = 0.1} )
    physics.addBody (rightWall, "static", { bounce = 0.1} )

    --set lives (properties) 3 lives to begin
    local propertyStart = 3
    if(tycoonConsumable) then
      propertyStart = 8
      disableTycoonConsumable()
    end
    propertyLife = propertiesImport.new(propertyStart)
    for i = 1, #propertyLife do
      local propY = propertyLife[i].y
      propertyLife[i].y = propertyLife[i].y - 100
      transition.to(propertyLife[i],{time=1000,transition=easing.inOutCubic,y=propY})
    end
    scoreTier = #propertyLife

    --add back button
    backButtonPosX = screenLeft+25
    backButtonPosY = bottomMarg-25
    backButton = display.newImage("res/back.png",-100,backButtonPosY)
    backButton.width = 50
    backButton.height = 50
    backButton:addEventListener("touch",backToMenuListener)
    transition.to(backButton,{time=1000,transition=easing.inOutCubic,x=backButtonPosX})

    --add restart button
    restartPosX = screenLeft + 25
    restartPosY = (screenTop + 25) + 3
    restartButton = display.newImage("res/restart.png",screenLeft - 100, restartPosY)
    restartButton.width = 50
    restartButton.height = 50
    restartButton:addEventListener("touch",retryMenuListener)
    transition.to(restartButton,{time=1000,transition=easing.inOutCubic,x=restartPosX, y=restartPosY})

    --add crosshair
    crosshair = display.newImage("res/target.png", rightMarg + 100, bottomMarg - 25)
    crosshair.width = 50
    crosshair.height = 50
    local crosshairX = rightMarg-25
    local crosshairY = bottomMarg - 25
    crosshair:addEventListener("touch", crosshairListener)
    transition.to(crosshair,{time=1000,transition=easing.inOutCubic, x=crosshairX, y=crosshairY})

    sceneGroup:insert(backButton)
    sceneGroup:insert(restartButton)
    sceneGroup:insert(crosshair)

    --check any scores passed in from previous round
    if event.params ~= nil then
      if event.params.score ~= nil then
        prevScore = event.params.score
      end
    end

    --animate startup
    startup()
end

function disableTycoonConsumable()
  local tycoon = ggData:new("consumables")
  tycoon:set(PRODUCT_TYCOON, false)
  tycoon:save()
  tycoonConsumable = false
end

-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

    end
end


function speedUp()
  if gamePaused then
    return
  end
  if yVelGlobal == -600 then
    return
  end
  -- if balloonGravity > -1.5 then
  --   balloonGravity = balloonGravity - 0.03
  -- end
  yVelGlobal = yVelGlobal - 10
  pumpEmitter:speedUp()
  bombEmitter:speedUp()
  toupeSpeedUp()
  propSpeedUp()
  ultraSpeedUp()
end

--global event for all pops
function popEvent(event)
  if event.phase == "ended" then
    event.target:removeSelf()
  end
end

function updatePlayScore()
  playScore.text = "Score: " .. currentScore
end

function bringHUDButtonsToFront()
  if crosshair == nil then
    return
  end
  crosshair:toFront()
  restartButton:toFront()
  backButton:toFront()
end

function removeEventListeners()
  Runtime:removeEventListener("enterFrame",bombEmitter)
  Runtime:removeEventListener("enterFrame",pumpEmitter)
  Runtime:removeEventListener("enterFrame",frameToupe)
  Runtime:removeEventListener("enterFrame",frameUltra)
  Runtime:removeEventListener("enterFrame",cloudEmitter)
  Runtime:removeEventListener("enterFrame",zepFrame)
  Runtime:removeEventListener("enterFrame",planeFrame)
  Runtime:removeEventListener("enterFrame",framePropBalloon)
  Runtime:removeEventListener("enterFrame", americaFrame)
  Runtime:removeEventListener("enterFrame", bringHUDButtonsToFront)
  Runtime:removeEventListener("enterFrame", rocketManFrame)
  Runtime:removeEventListener("enterFrame", slowTimeFrame)
end

function addEventListeners()
  Runtime:addEventListener("enterFrame",bombEmitter)
  Runtime:addEventListener("enterFrame",pumpEmitter)
  Runtime:addEventListener("enterFrame",frameToupe)
  Runtime:addEventListener("enterFrame",frameUltra)
  Runtime:addEventListener("enterFrame",cloudEmitter)
  Runtime:addEventListener("enterFrame",zepFrame)
  Runtime:addEventListener("enterFrame",planeFrame)
  Runtime:addEventListener("enterFrame",framePropBalloon)
  Runtime:addEventListener("enterFrame", americaFrame)
  Runtime:addEventListener("enterFrame", bringHUDButtonsToFront)
  Runtime:addEventListener("enterFrame", rocketManFrame)
  Runtime:addEventListener("enterFrame", slowTimeFrame)
end

function displayNuclearOverlay()
  if nuclearOverlayOn then
    return
  end
  nuclearOverlay = display.newImage("res/nuclearoverlay.png")
  nuclearOverlay.height = bottomMarg + 100
  nuclearOverlay.width = rightMarg + 100
  nuclearOverlay.x = centerX
  nuclearOverlay.y = centerY
  nuclearOverlay.alpha = 0
  transition.fadeIn(nuclearOverlay, {transition = easing.outCubic})
  nuclearOverlayOn = true
end

function incrementScoreTier()
  propertyLife:add()
  scoreTier = scoreTier + 1
end

function decrementScoreTier()
  if #propertyLife >= 1 then
    propertyLife:pop()
    scoreTier = scoreTier - 1
  end
  if #propertyLife == 0 then
    gameOverMenuListener()
  end
end

function startup()

  current = 3
  audio.play(clickSound, {channel = 4})
  local textOptions = {
      text = current,
      font = font321,
      x = centerX,
      y = centerY
  }

  num = display.newText(textOptions)

  num.alpha = 0
  transition.fadeIn(num,{onComplete = numOut})
end

--number transitions in and out
function numIn()
  if current == 0 then
    startGame()
    return
  end
  audio.play(clickSound, {channel = 4})
  num.text = current
  transition.fadeIn(num,{onComplete = numOut})
end

function numOut()
  current = current-1
  transition.fadeOut(num,{onComplete = numIn})
end

function startGame()
  --start showing balloons
  addEventListeners()
  beginToupeEmitter()
  beginUltraEmitter()
  beginPropBalloonEmitter()
  speedTimer = timer.performWithDelay(1000,speedUp,0)
  physics.start()
  gamePaused = false
  fromMenuToPlay = false
end

-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end

function crosshairListener()
  if gamePaused or totalGameOver or not finishedUltraAnimation or creatingNewNuke then
    return
  end
  
  audio.play(wooshSound, {channel = 1})
  local startNo = 3
  local crosshairTimer = nil

  local function bringBackCrosshair()
    transition.fadeIn(crosshair)
  end

  local function hide321()
    if gameOverOn then
      timer.cancel(crosshairTimer)
      crosshairTimer = nil
      return
    end
    if gamePaused or not finishedUltraAnimation then
      return
    end
    if startNo == 0 then
      timer.cancel(crosshairTimer)
      crosshairTimer = nil
      bringBackCrosshair()
      return
    end
    local currentNo = display.newText({
      text = tostring(startNo),
      font = secondaryFont,
      x = crosshair.x,
      y = crosshair.y,
      fontSize = 40
    })
    currentNo:setTextColor(255, 255, 0)
    transition.fadeIn(currentNo, {
      onComplete = function() 
        transition.fadeOut(currentNo, {onComplete = function() currentNo:removeSelf() end})
       end
    })
    startNo = startNo - 1
  end

  untappableObjectTapped = true
  timer.performWithDelay(400, function() untappableObjectTapped = false end)
  crosshairTimer = timer.performWithDelay(1000, hide321, 0)
  transition.fadeOut(crosshair)

  crosshairEffect()
  newAmerica(50, 110, 12)
  timer.performWithDelay(100, displayTargeter)
end

function displayTargeter()
  local targetRect = display.newRect(centerX, centerY, 50, bottomMarg + 100)
  local paint = { 1, 0, 0 }
  targetRect.alpha = 0
  targetRect.fill = paint
  transition.to(targetRect, {alpha = 0.2})
  timer.performWithDelay(500, 
  function() transition.fadeOut(targetRect, {onComplete = 
    function() targetRect:removeSelf() 
    end}) 
  end)
end

function crosshairEffect()
      local emitter = prism.newEmitter({
      -- Particle building and emission options
      particles = {
        type = "image",
        image = "res/particle.png",
        width = 50,
        height = 50,
        color = {{1, 1, 0.1}, {1, 0, 0}},
        blendMode = "add",
        particlesPerEmission = 100,
        delayBetweenEmissions = 100,
        inTime = 100,
        lifeTime = 100,
        outTime = 1000,
        startProperties = {xScale = 1, yScale = 1},
        endProperties = {xScale = 0.3, yScale = 0.3}
      },
      -- Particle positioning options
      position = {
        type = "point"
      },
      -- Particle movement options
      movement = {
        type = "random",
        velocityRetain = .97,
        speed = 1,
        yGravity = -0.15
      }
    })
  
    emitter.emitX, emitter.emitY = crosshair.x, crosshair.y
    emitter:emit()
end

function backToMenuListener()
  if gamePaused or totalGameOver or not finishedUltraAnimation then
    return
  end

  untappableObjectTapped = true
  timer.performWithDelay(400, function() untappableObjectTapped = false end)

  physics.pause()
  gamePaused = true

  audio.play(clickSound, {channel = 1})

  --add menu container
  darkenedScreen = display.newRect(centerX,centerY,2000,2000)
  darkenedScreen:setFillColor(black)
  darkenedScreen.alpha = 0.3
  local menuMenuWidth = rightMarg - 25
  local menuMenuHeight = menuMenuWidth/1.5
  menuMenu = display.newImage("res/backtomenu.png",centerX,2000)
  menuMenu.width = menuMenuWidth
  menuMenu.height = menuMenuHeight
  transition.to(menuMenu,{y=centerY,time=200,
  onComplete=restartRuntimeTouch,transition=easing.inOutSine})

  --add buttons
  yesButton = display.newImage("res/yesbutton.png",
  centerX-(menuMenuWidth/4),2000)
  yesButton.width = menuMenuWidth/2.5
  yesButton.height = menuMenuHeight/3
  transition.to(yesButton,{y=centerY+(menuMenuHeight/4),time=200,
  onComplete=restartRuntimeTouch,transition=easing.inOutSine})

  noButton = display.newImage("res/nobutton.png",
  centerX+(menuMenuWidth/4),2000)
  noButton.width = menuMenuWidth/2.5
  noButton.height = menuMenuHeight/3
  transition.to(noButton,{y=centerY+(menuMenuHeight/4),time=200,
  onComplete=restartRuntimeTouch,transition=easing.inOutSine})

  yesButton:addEventListener("touch",menuButtonTouchListener)
  noButton:addEventListener("touch",menuButtonTouchListener)
end

function transitionTheMenu(item,callback)
  removeGameOverHighScore()
  transition.to(item,{time=500,y=-2000,onComplete=callback})
  transition.to(yesButton,{time=500,y=-2000})
  transition.to(noButton,{time=500,y=-2000})
  if darkenedScreen ~= nil then
    darkenedScreen:removeSelf()
  end
end

function goToMainMenu()
  if goingToMainMenu then
    return
  end
  local scoreToPass = currentScore
  if currentScore < prevScore then
    scoreToPass = prevScore
  end
  goingToMainMenu = true
  composer.gotoScene("scenes.transitionfromplay",{effect="crossFade",params={score=scoreToPass}})
end

function retry()
  local scoreToPass = currentScore
  if currentScore < prevScore then
    scoreToPass = prevScore
  end
  composer.gotoScene("scenes.transition",{effect="crossFade",params={score=scoreToPass}})
end

function resumeFromMenu()
  transitionTheMenu(menuMenu)
  physics.start()
  gamePaused = false
end

function resumeFromRetry()
  transitionTheMenu(retryMenu)
  physics.start()
  gamePaused = false
end

function menuButtonTouchListener(event)

local t = event.target
audio.play(clickSound, {channel = 1})
local pressed = false

local function mainMenuGo()
  if t.gameover == nil then
    transitionTheMenu(menuMenu,goToMainMenu)
  else
    transitionTheMenu(gameoverMenu,goToMainMenu)
  end
end

  if event.phase == "began" then
    pressed = true
    event.target:scale(0.6,0.6)
    --if it was called by the gameover menu
     if t.gameover ~= nil then
     --cancel increase of game speed
      timer.cancel(speedTimer)
      timer.performWithDelay(100,mainMenuGo)
     end
    if event.target == yesButton then
      --cancel increase of game speed
      timer.cancel(speedTimer)
      timer.performWithDelay(100,mainMenuGo)
    else
      if t.gameover ~= nil then
        timer.cancel(speedTimer)
        timer.performWithDelay(100,mainMenuGo)
      else
        timer.performWithDelay(100,resumeFromMenu)
      end
    end

  elseif event.phase == "ended" or event.phase == "cancelled" then
    if pressed then
      event.target:scale(1.67,1.67)
      pressed = false
    end
  end

end

function retryButtonTouchListener(event)

local t = event.target
audio.play(clickSound, {channel = 1})
local pressed = false

local function retryMenuGo()
  if t.gameover == nil then
    transitionTheMenu(retryMenu,retry)
  else
    transitionTheMenu(gameoverMenu,retry)
  end
end

  if event.phase == "began" then
    pressed = true
    event.target:scale(0.6,0.6)
    if event.target == yesButton then
      --cancel increase of game speed
      timer.cancel(speedTimer)
      timer.performWithDelay(100,retryMenuGo)
    else
      timer.performWithDelay(100,resumeFromRetry)
    end

  elseif event.phase == "ended" or event.phase == "cancelled" then
    if pressed then
      event.target:scale(1.67,1.67)
      pressed = false
    end
  end

end

function retryMenuListener()
  if gamePaused or totalGameOver or not finishedUltraAnimation then
    return
  end

  untappableObjectTapped = true
  timer.performWithDelay(400, function() untappableObjectTapped = false end)

  physics.pause()
  gamePaused = true
  audio.play(clickSound, {channel = 1})

  --add menu container
  darkenedScreen = display.newRect(centerX,centerY,2000,2000)
  darkenedScreen:setFillColor(black)
  darkenedScreen.alpha = 0.3
  local retryMenuWidth = rightMarg - 25
  local retryMenuHeight = retryMenuWidth/1.5
  retryMenu = display.newImage("res/retrymenu.png",centerX,2000)
  retryMenu.width = retryMenuWidth
  retryMenu.height = retryMenuHeight
  transition.to(retryMenu,{y=centerY,time=200,
  onComplete=restartRuntimeTouch,transition=easing.inOutSine})

  --add buttons
  yesButton = display.newImage("res/yesbutton.png",
  centerX-(retryMenuWidth/4),2000)
  yesButton.width = retryMenuWidth/2.5
  yesButton.height = retryMenuHeight/3
  transition.to(yesButton,{y=centerY+(retryMenuHeight/4),time=200,
  onComplete=restartRuntimeTouch,transition=easing.inOutSine})

  noButton = display.newImage("res/nobutton.png",
  centerX+(retryMenuWidth/4),2000)
  noButton.width = retryMenuWidth/2.5
  noButton.height = retryMenuHeight/3
  transition.to(noButton,{y=centerY+(retryMenuHeight/4),time=200,
  onComplete=restartRuntimeTouch,transition=easing.inOutSine})

  yesButton:addEventListener("touch",retryButtonTouchListener)
  noButton:addEventListener("touch",retryButtonTouchListener)
end

function gameOverMenuListener()

--if gameover menu is already on screen then exit the function, no need to propagate
  if gameOverOn or gamePaused then
    return
  end

  gameOverOn = true
  physics.pause()
  gamePaused = true

  nuclearLoopSound = audio.play(gameOverSound, {channel = 4, loops = -1})

  --add menu container
  darkenedScreen = display.newRect(centerX,centerY,2000,2000)
  darkenedScreen:setFillColor(black)
  darkenedScreen.alpha = 0
  transition.to(darkenedScreen,{alpha=0.9, time=1000})
  local gameoverMenuWidth = rightMarg - 25
  local gameoverMenuHeight = gameoverMenuWidth/1.5
  gameoverMenu = display.newImage("res/gameover.png",centerX,centerY)
  gameoverMenu.width = 0
  gameoverMenu.height = 0
  transition.to(gameoverMenu,{y=centerY,time=200,width=gameoverMenuWidth,height=gameoverMenuHeight,
  onComplete=restartRuntimeTouch,transition=easing.inOutBounce})

  --add highscore, if there is one
  compareHighScore()

  --add buttons
  yesButton = display.newImage("res/yesbutton.png",
  centerX-(gameoverMenuWidth/4),2000)
  yesButton.gameover = true
  local yesButtonWidth = gameoverMenuWidth/2.5
  local yesButtonHeight = gameoverMenuHeight/3
  yesButton.width = 0
  yesButton.height = 0
  transition.to(yesButton,{y=centerY+(gameoverMenuHeight/4),time=200,width = yesButtonWidth, height = yesButtonHeight,
  onComplete=restartRuntimeTouch,transition=easing.inOutBounce})

  noButton = display.newImage("res/nobutton.png",
  centerX+(gameoverMenuWidth/4),2000)
  noButton.gameover = true
  local noButtonWidth = gameoverMenuWidth/2.5
  local noButtonHeight = gameoverMenuHeight/3
  noButton.width = 0
  noButton.height = 0
  transition.to(noButton,{y=centerY+(gameoverMenuHeight/4),time=200,width = noButtonWidth, height = noButtonHeight,
  onComplete=restartRuntimeTouch,transition=easing.inOutBounce})

  yesButton:addEventListener("touch",retryButtonTouchListener)
  noButton:addEventListener("touch",menuButtonTouchListener)
end

function compareHighScore()
  local box = ggData:new('highscore')
  -- if currentScore < prevScore then
  --   return
  -- end

  local textOptions = {
    text = "Your score: ".. currentScore,
    font = secondaryFont,
    fontSize = 24,
    x = display.contentCenterX,
    y = 18
  }

  if currentScore > box.highscore then
    textOptions.text = "New Highscore! ".. currentScore
    updateHighscoreDB(currentScore)

    --for rende4ring on the menu scene
    local changeScore = ggData:new("updateHighscore")
    changeScore:set("updateHighscore", currentScore)
    changeScore:save()
  end

  gameOverScore = display.newText(textOptions)
  gameOverScore.alpha = 0
  transition.to(gameOverScore, {alpha = 1, time = 1000})
end

function removeGameOverHighScore()
  if gameOverScore ~= nil then
    gameOverScore:removeSelf()
    gameOverScore = nil
  end
end

function updateHighscoreDB(n)
  local box = ggData:new("highscore")
  box:set("highscore", n)
  box:save()
end

function deleteAllNonSceneObjects()
  cloudEmitter:deleteAll()
  propertyLife:deleteAll()
  destroyToupe()
  destroyUltra()
  destroyPropBalloon()
  deleteZep()
  deletePlane()
  deleteAmericanNuke()
  deleteRocketMan()
  deleteSlowTime()
  if darkenedScreen ~= nil then
    darkenedScreen = nil
  end
  if(nuclearOverlay ~= nil) then
      nuclearOverlay:removeSelf()
      nuclearOverlay = nil
  end
end

-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
    removeEventListeners()
    deleteAllNonSceneObjects()
    cancelUltraEmitter()
    cancelToupeEmitter()
    cancelPropBalloonEmitter()
    if nuclearLoopSound ~= nil then
        audio.stop(nuclearLoopSound)
    end
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
