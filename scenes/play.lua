package.path = package.path .. ";../?.lua"

local composer = require( "composer" )
local cloudGenerator = require("objects.cloudGenerator")
local bemitter = require("objects.bombemitter")
local pemitter = require("objects.pumpemitter")
local temitter = require("objects.toupeemitter")
local uemitter = require("objects.ultraemitter")
local propertiesImport = require("objects.properties")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
--global
balloonGravity = -0.01
scoreMultiplier = false
scoreTimer = nil
playScore = nil
currentScore = 0

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
gamePaused = false
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    physics.pause()

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    composer.removeScene("scenes.menu")

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

    local leftWall = display.newRect(0,0,0,10000)
    local rightWall = display.newRect (rightMarg, 0, 1, 10000)

    leftWall.alpha = 0
    rightWall.alpha = 0

    sceneGroup:insert(rightWall)
    sceneGroup:insert(leftWall)

    physics.addBody (leftWall, "static", { bounce = 0.1} )
    physics.addBody (rightWall, "static", { bounce = 0.1} )

    --set lives (properties) 3 lives to begin
    propertyLife = propertiesImport.new(3)
    scoreTier = #propertyLife

    --add back button
    backButton = display.newImage("res/back.png",screenLeft+25,bottomMarg-25)
    backButton.width = 50
    backButton.height = 50
    backButton:addEventListener("tap",backToMenuListener)

    --add restart button
    backButton = display.newImage("res/restart.png",rightMarg-25,bottomMarg-25)
    backButton.width = 50
    backButton.height = 50

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
end

function addEventListeners()
  Runtime:addEventListener("enterFrame",bombEmitter)
  Runtime:addEventListener("enterFrame",pumpEmitter)
  Runtime:addEventListener("enterFrame",frameToupe)
  Runtime:addEventListener("enterFrame",frameUltra)
  Runtime:addEventListener("enterFrame",cloudEmitter)
  Runtime:addEventListener("enterFrame",zepFrame)
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
  speedTimer = timer.performWithDelay(5000,speedUp,0)
  physics.start()
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
  if gamePaused then
    return
  end
  
  local darkenedScreen = display.newRect(centerX,centerY,2000,2000)
  darkenedScreen:setFillColor(black)
  darkenedScreen.alpha = 0.3
  local truckWidth = rightMarg - 25
  local truckHeight = truckWidth/1.5
  local truck = display.newImage("res/backtomenu.png",screenLeft-truckWidth-100,
                                  centerY-(truckHeight/2))
  truck.width = truckWidth
  truck.height = truckHeight
  physics.pause()
  gamePaused = true
  transition.to(truck,{x=centerX,time=800,onComplete=restartRuntimeTouch})
end

-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
    Runtime:removeEventListener("enterFrame",cloudEmitter)
    removeEventListeners()
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
