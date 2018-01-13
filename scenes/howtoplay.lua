local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local bottomMarg = display.contentHeight - display.screenOriginY
local rightMarg = display.contentWidth - display.screenOriginX
local backBtn

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    composer.removeScene("scenes.menu")
    local bg = display.newImage("res/howtoplay.png")
    bg.width = rightMarg + 50
    bg.height = bottomMarg + 50
    bg.x = centerX
    bg.y = centerY

    backBtn = display.newSprite(backSheet, backSeq)
    backBtn:play()

    --back button dimensions
    backBtn:scale(0.6, 0.6)
    backBtn.y = bottomMarg - 35
    backBtn.x = 1000

    local backTr = {
        time = 1200,
        x = centerX + 15,
        transition = easing.inCubic
    }

    transition.to(backBtn, backTr)

    sceneGroup:insert(bg)
    sceneGroup:insert(backBtn)
end

--back event listener
function goBackToMain()
    audio.play(wooshSound, {channel=1})
    transition.to(backBtn, {
        x = -1000,
        time = 1000,
        transition = easing.outCubic,
        onComplete = function() composer.gotoScene("scenes.menu", {effect="crossFade", time=500}) end
    })
end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        backBtn:addEventListener("touch", goBackToMain)
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
