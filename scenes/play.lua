package.path = package.path .. ";../?.lua"

local composer = require( "composer" )
local cloudGenerator = require("objects.cloudGenerator")
local bemitter = require("objects.bombemitter")
local pemitter = require("objects.pumpemitter")
local temitter = require("objects.toupeemitter")
local uemitter = require("objects.ultraemitter")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
--global
balloonSpeed = 1
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
whichScene = "play"
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

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
    bombEmitter = bemitter.new(50,sceneGroup)
    pumpEmitter = pemitter.new(5,sceneGroup)

    playScore = display.newText(globalTextOptions)
    playScore.text = "Score: " .. currentScore
    playScore.x = centerX
    playScore.y = bottomMarg - playScore.height/2
    sceneGroup:insert(playScore)
    playScore:toFront()

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
