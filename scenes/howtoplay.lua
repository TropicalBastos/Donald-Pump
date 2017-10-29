package.path = package.path .. ";../?.lua"

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


local bg
local title = "How to Play"
local info = "The Goal of the game is simple, hit as many balloons as possible avoiding the nukes and get an epic highscore!"
local subInfo = "The following balloon rules apply:"
local pumpInfo = "Normal Donald: 1 point for each property token"
local ultraInfo = "Donald Pump: x10 multiplier, score = property tokens x 10"
local toupeInfo = "The Toupe: cascade, get points for each balloon it hits"
local propertyInfo = "Property Token: +1 property token, lose all tokens and you its game over!"
local bombInfo = "DPRK Nuke: Touch it and its game over, so tap carefully"
local titleObj
local infoObj
local subInfoObj
local balloonContainer
local pumpObj
local ultraObj
local toupeObj
local propertyObj
local nukeObj
local objStartCol = 500
local objArray

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    composer.removeScene("scenes.menu")
    bg = display.newImage("res/howtoplay.png", centerX, centerY)
    bg.width = rightMarg + 100
    bg.height = bottomMarg + 100
    --balloonContainer = display.new

    pumpObj = display.newImage("res/pumpballoon.png")
    ultraObj = display.newImage("res/ultraballoon.png")
    toupeObj = display.newImage("res/toupeballoon.png")
    propertyObj = display.newImage("res/propertyballoon.png")
    nukeObj = display.newImage("res/bombballoon.png")

    pumpText = display.newText({text=pumpInfo, font=howFont})
    ultraText = display.newText({text=ultraInfo, font=howFont})
    toupeText = display.newText({text=toupeInfo, font=howFont})
    propertyText = display.newText({text=propertyInfo, font=howFont})
    nukeText = display.newText({text=bombInfo, font=howFont})

    textForObjArray = {pumpText, ultraText, toupeText, propertyText, nukeText}
    objArray = {pumpObj, ultraObj, toupeObj, propertyObj, nukeObj}
    for i=1, #objArray do
        objArray[i].width = 65
        objArray[i].height = 80
        --local xPos = (i * objArray[i].width) + 20
        local xPos
        if i == 1 then
            xPos = centerX - (objArray[i].width + 20)
        elseif i == 2 then
            xPos = centerX
        elseif i == 3 then
            xPos = centerX + (objArray[i].width + 20)
        elseif i == 4 then
            xPos = centerX - (objArray[i].width + 20)
        elseif i == 5 then
            xPos = centerX + (objArray[i].width + 20)
        end 
        objArray[i].x = xPos
        textForObjArray[i].width = 65
        textForObjArray[i].x = xPos 
    end
    nukeObj.width = 35

    local titleOptions = {
        text = title,
        font = titleFont,
        x = display.contentCenterX,
        y = 1000
    }
    local infoOptions = {
        text = info,
        font = howFont,
        x = display.contentCenterX,
        y = 1000,
        width = rightMarg/1.4
    }
    local subInfoOptions = {
        text = subInfo,
        font = howFont,
        x = display.contentCenterX,
        y = 1000,
        width = rightMarg/1.4
    }
    titleObj = display.newText(titleOptions)
    infoObj = display.newText(infoOptions)
    subInfoObj = display.newText(subInfoOptions)
    local tr = {
        time = 500,
        y = 30,
        transition = easing.outCubic
    }
    local tr2 = {
        time = 700,
        y = 100,
        transition = easing.outCubic
    }
    local tr3 = {
        time = 900,
        y = 150,
        transition = easing.outCubic
    }
    local balloonTr = {
        time = 1100,
        y = 220,
        transition = easing.outCubic
    }
    local descTr = {
        time = 1100,
        y = 280,
        transition = easing.outCubic
    }
    transition.to(titleObj, tr)
    transition.to(infoObj, tr2)
    transition.to(subInfoObj, tr3)
    for i=1, #objArray do
        balloonTr.time = balloonTr.time + 200
        transition.to(objArray[i], balloonTr)
        if i >= 4 then
            transition.to(objArray[i], {
                time = 1100,
                y = 320,
                transition = easing.outCubic
            })
        end
    end
    for i=1, #textForObjArray do
        descTr.time = descTr.time + 200
        transition.to(textForObjArray[i], descTr)
        if i >= 4 then
            transition.to(textForObjArray[i], {
                time = 1100,
                y = 370,
                transition = easing.outCubic
            })
        end
    end

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
