local composer = require( "composer" )
package.path = package.path .. ";../?.lua"
local transitionBalloons = require("objects.transitionballoons")
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

--declare all objects for scene
--local sheetOptions
--local sheet_loading
--local loadingSequence
--local loading
local logo
local balloonGenerator
local loadingComplete = false
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local bottomMarg = display.contentHeight - display.screenOriginY
local rightMarg = display.contentWidth - display.screenOriginX
local bg

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    --set configurations for loading sprite sheet

    --consistent background for all scenes
    bg = display.newImage("res/loadingbg.png",0,0)
    bg.width = rightMarg + 100
    bg.height = bottomMarg + 100
    bg.x = centerX
    bg.y = centerY
    
    --sheetOptions = {
      --width = 500,
      --height = 500,
      --numFrames = 36
    --}
    --load sprite sheet with options
    --sheet_loading = graphics.newImageSheet("res/loadingmain.png",sheetOptions)

    -- set the sequence
    --loadingSequence = {
      --consecutive frames
      --{
        --name = "loading",
        --start = 1,
        --count = 36,
        --time = 2000,
        --loopCount = 0,
        --loopDirection = "forward"
      --}
    --}

    --loading = display.newSprite(sheet_loading,loadingSequence)
    --loading:scale(0.0,0.0)

    --positioning
    --loading.x = display.contentCenterX
    --loading.y = display.contentCenterY
    --loading:toBack()
    --loading:play()

    renderLogo()
    logo.y = centerY;
    logo:scale(0.0,0.0)

    sceneGroup:insert(logo)
    --sceneGroup:insert(loading)

    balloonGenerator = transitionBalloons.new(12,sceneGroup,10)

    local addBalloons = function()
      loadingComplete = true
    end

    --set loading timer to give enough time to show the splash screen
    timer.performWithDelay(5000,addBalloons,1)

    --wait a certain time then transition
    timer.performWithDelay(5500,slideUp,1)

    bg:toBack()
end


function renderLogo()
  logo = display.newImage("res/logo.png")
  logo.width = 350
  logo.height = 350
  logo.x = display.contentCenterX
end

function checkLoaded()
  if loadingComplete then
    Runtime:addEventListener("enterFrame",balloonGenerator)
    loadingComplete = false
  end
end

function slideUp()
  --slide display objects up as a trnsition before the next scene appears
  transition.to(logo,{y=-300,time=2000,transition=easing.inOutQuart,onComplete=goToMenu})
  --transition.to(loading,{y=-300,time=2000,transition=easing.inOutQuart,onComplete=goToMenu})
end

function goToMenu()
  local options = {
    effect = "fromBottom",
    time = 1000,
    params = {bg = bg}
  }
  composer.gotoScene("scenes.menu",options)
end

-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        --check every frame wether the loading has completed
          Runtime:addEventListener("enterFrame",checkLoaded)
          --cool transitions
          transition.to(loading,{time=1500,xScale=0.6,yScale=0.6,transition=easing.inBounce})
          transition.to(logo,{time=1500,xScale=0.6,yScale=0.6,transition=easing.inBounce})
    end
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
    Runtime:removeEventListener("enterFrame",checkLoaded)
    Runtime:removeEventListener("enterFrame",balloonGenerator)

    --remove and free memory from objects
    display.remove(logo)
    display.remove(loading)
    for i=0, #balloonGenerator.allBalloons do
      display.remove(balloonGenerator.allBalloons[i])
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
