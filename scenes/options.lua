package.path = package.path .. ";../?.lua"

local composer = require( "composer" )
local widget = require( "widget" )
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

local bg
local title = "Options"
local volume = "Volume"
local volumeObj
local titleObj
local container
local soundSlider
local backBtn
local thumbsUp

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    composer.removeScene("scenes.menu")
    bg = display.newImage("res/optionsmenu.png")
    bg.width = rightMarg + 50
    bg.height = bottomMarg + 50
    bg.x = centerX
    bg.y = centerY

    local titleOptions = {
        text = title,
        font = titleFont,
        x = display.contentCenterX,
        y = 50
    }
    titleObj = display.newText(titleOptions)

    container = display.newImage("res/widgetcontainer.png")
    container.width = rightMarg/1.2
    container.height = 300
    container.x = centerX
    container.y = centerY
    container:scale(0, 1)

    local function sliderListener( event )
        local vol = event.value / 100
        audio.setVolume(vol)
    end

    soundSlider = widget.newSlider({
        x = display.contentCenterX,
        y = display.contentCenterY,
        orientation = "horizontal",
        width = container.width * 0.8,
        listener = sliderListener
    })
    soundSlider:scale(0, 1)

    local volumeOptions = {
        text = volume,
        font = titleFont,
        x = display.contentCenterX,
        y = 200
    }
    volumeObj = display.newText(volumeOptions)

    backBtn = display.newSprite(backSheet, backSeq)
    backBtn:scale(0.6, 0.6)
    backBtn.y = bottomMarg - 35
    backBtn.x = 1000
    backBtn:play()

    thumbsUp = display.newImage("res/thumbsup.png")
    thumbsUp.width = rightMarg * 0.65
    thumbsUp.height = thumbsUp.width * 0.8
    thumbsUp.x = rightMarg - (thumbsUp.width / 2)
    thumbsUp.y = 1500

    sceneGroup:insert(bg)
    sceneGroup:insert(titleObj)
    sceneGroup:insert(container)
    sceneGroup:insert(soundSlider)
    sceneGroup:insert(volumeObj)
    sceneGroup:insert(thumbsUp)
    sceneGroup:insert(backBtn)

    local containerTr = {
        xScale = 1,
        transition = easing.outCubic
    }

    local backTr = {
        time = 1200,
        x = centerX - 75,
        transition = easing.inCubic
    }

    local thumbsTr = {
        time = 1000,
        y = bottomMarg - (thumbsUp.height / 2),
        transition = easing.outCubic
    }

    transition.to(backBtn, backTr)
    transition.to(thumbsUp, thumbsTr)
    transition.to(container, containerTr)
    transition.to(soundSlider, containerTr)

end

--back event listener
function goBackToMain()
    transition.to(thumbsUp, {
        y = 1500,
        time = 800,
        transition = easing.inCubic
    })
    transition.to(backBtn, {
        x = -1000,
        time = 800,
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
