package.path = package.path .. ";../?.lua"

local composer = require( "composer" )
local cloudGenerator = require("objects.cloudGenerator")
local bemitter = require("objects.bombemitter")
local pemitter = require("objects.pumpemitter")
local temitter = require("objects.toupeemitter")
local uemitter = require("objects.ultraemitter")
local propemitter = require("objects.propertyemitter")
local propertiesImport = require("objects.properties")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
--global
balloonGravity = -0.01
scoreMultiplier = 0
scoreTimer = nil
playScore = nil
currentScore = 0
prevScore = 0

local bg
local current
local num
local bombEmitter = nil
local pumpEmitter = nil
local cloudEmitter = nil
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
gameOverHighscore = nil
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    physics.pause()

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    composer.removeScene("scenes.menu")
    composer.removeScene("scenes.transition")

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
    propertyLife = propertiesImport.new(3)
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
    backButton:addEventListener("tap",backToMenuListener)
    transition.to(backButton,{time=1000,transition=easing.inOutCubic,x=backButtonPosX})

    --add restart button
    restartPosX = rightMarg-25
    restartPosY = bottomMarg-25
    restartButton = display.newImage("res/restart.png",rightMarg+100,bottomMarg-25)
    restartButton.width = 50
    restartButton.height = 50
    restartButton:addEventListener("tap",retryMenuListener)
    transition.to(restartButton,{time=1000,transition=easing.inOutCubic,x=restartPosX})

    sceneGroup:insert(backButton)
    sceneGroup:insert(restartButton)

    --check any scores passed in from previous round
    if event.params ~= nil then
      if event.params.score ~= nil then
        prevScore = event.params.score
      end
    end

    --animate startup
    startup()
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
  if balloonGravity > -0.23 then
    balloonGravity = balloonGravity - 0.01
  end
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

function removeEventListeners()
  Runtime:removeEventListener("enterFrame",bombEmitter)
  Runtime:removeEventListener("enterFrame",pumpEmitter)
  Runtime:removeEventListener("enterFrame",frameToupe)
  Runtime:removeEventListener("enterFrame",frameUltra)
  Runtime:removeEventListener("enterFrame",cloudEmitter)
  Runtime:removeEventListener("enterFrame",zepFrame)
  Runtime:removeEventListener("enterFrame",framePropBalloon)
end

function addEventListeners()
  Runtime:addEventListener("enterFrame",bombEmitter)
  Runtime:addEventListener("enterFrame",pumpEmitter)
  Runtime:addEventListener("enterFrame",frameToupe)
  Runtime:addEventListener("enterFrame",frameUltra)
  Runtime:addEventListener("enterFrame",cloudEmitter)
  Runtime:addEventListener("enterFrame",zepFrame)
  Runtime:addEventListener("enterFrame",framePropBalloon)
end

function incrementScoreTier()
  propertyLife:add()
  scoreTier = scoreTier + 1
end

function decrementScoreTier()
  if #propertyLife == 0 then
    gameOverMenuListener()
    return
  elseif #propertyLife >= 1 then
    propertyLife:pop()
    scoreTier = scoreTier - 1
  end
end

function startup()

  current = 3

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
  speedTimer = timer.performWithDelay(5000,speedUp,0)
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

function backToMenuListener()
  if gamePaused or not finishedUltraAnimation then
    return
  end

  physics.pause()
  gamePaused = true

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
  darkenedScreen:removeSelf()
end

function goToMainMenu()
  local scoreToPass = currentScore
  if currentScore < prevScore then
    scoreToPass = prevScore
  end
  composer.gotoScene("scenes.menu",{effect="crossFade",params={score=scoreToPass}})
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

local function mainMenuGo()
  if t.gameover == nil then
    transitionTheMenu(menuMenu,goToMainMenu)
  else
    transitionTheMenu(gameoverMenu,goToMainMenu)
  end
end

  if event.phase == "began" then
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
      timer.performWithDelay(100,resumeFromMenu)
    end

  elseif event.phase == "ended" or event.phase == "cancelled" then
    event.target:scale(1.67,1.67)
  end

end

function retryButtonTouchListener(event)

local t = event.target

local function retryMenuGo()
  if t.gameover == nil then
    transitionTheMenu(retryMenu,retry)
  else
    transitionTheMenu(gameoverMenu,retry)
  end
end

  if event.phase == "began" then
    event.target:scale(0.6,0.6)
    if event.target == yesButton then
      --cancel increase of game speed
      timer.cancel(speedTimer)
      timer.performWithDelay(100,retryMenuGo)
    else
      timer.performWithDelay(100,resumeFromRetry)
    end

  elseif event.phase == "ended" or event.phase == "cancelled" then
    event.target:scale(1.67,1.67)
  end

end

function retryMenuListener()
  if gamePaused or not finishedUltraAnimation then
    return
  end

  physics.pause()
  gamePaused = true

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
  if gameOverOn then
    return
  end

  gameOverOn = true
  physics.pause()
  gamePaused = true

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
  if currentScore > box.highscore then
    local textOptions = {
      text = "New Highscore! ".. currentScore,
      font = highscoreFont,
      x = display.contentCenterX,
      y = 18
    }
    gameOverHighscore = display.newText(textOptions)
    gameOverHighscore.alpha = 0
    transition.to(gameOverHighscore, {alpha = 1, time = 1000})
  end
end

function removeGameOverHighScore()
  if gameOverHighscore ~= nil then
    gameOverHighscore:removeSelf()
    gameOverHighscore = nil
  end
end

function deleteAllNonSceneObjects()
  cloudEmitter:deleteAll()
  propertyLife:deleteAll()
  destroyToupe()
  destroyUltra()
  destroyPropBalloon()
  deleteZep()
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
