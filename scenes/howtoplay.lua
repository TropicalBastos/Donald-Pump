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
local propertyInfo = "Property Token: +1 property token, lose all tokens and its game over!"
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
local textForObjArray
local backBtn

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
    backBtn = display.newSprite(backSheet, backSeq)
    backBtn:play()

    pumpText = display.newText({text=pumpInfo, font=ruleFont, align="center", width=100, height=0})
    ultraText = display.newText({text=ultraInfo, font=ruleFont, align="center", width=100, height=0})
    toupeText = display.newText({text=toupeInfo, font=ruleFont, align="center", width=100, height=0})
    propertyText = display.newText({text=propertyInfo, font=ruleFont, align="center", width=100, height=0})
    nukeText = display.newText({text=bombInfo, font=ruleFont, align="center", width=100, height=0})

    textForObjArray = {pumpText, ultraText, toupeText, propertyText, nukeText}
    objArray = {pumpObj, ultraObj, toupeObj, propertyObj, nukeObj}
    for i=1, #objArray do
        objArray[i].width = 65
        objArray[i].height = 80
        --local xPos = (i * objArray[i].width) + 20
        local xPos
        if i == 1 then
            xPos = centerX - (objArray[i].width + 40)
        elseif i == 2 then
            xPos = centerX
        elseif i == 3 then
            xPos = centerX + (objArray[i].width + 40)
        elseif i == 4 then
            xPos = centerX - (objArray[i].width + 40)
        elseif i == 5 then
            xPos = centerX + (objArray[i].width + 40)
        end 
        objArray[i].x = xPos
        -- textForObjArray[i].width = 65
        -- textForObjArray[i].height = 40 
        textForObjArray[i].x = xPos
    end
    nukeObj.width = 35

    --back button dimensions
    backBtn:scale(0.6, 0.6)
    backBtn.y = bottomMarg - 35
    backBtn.x = 1000

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
        y = 15,
        transition = easing.outCubic
    }
    local tr2 = {
        time = 700,
        y = 60,
        transition = easing.outCubic
    }
    local tr3 = {
        time = 900,
        y = 110,
        transition = easing.outCubic
    }
    local balloonTr = {
        time = 1100,
        y = 170,
        transition = easing.outCubic
    }
    local descTr = {
        time = 1100,
        y = 240,
        transition = easing.outCubic
    }
    local backTr = {
        time = 1200,
        x = centerX + 15,
        transition = easing.inCubic
    }

    transition.to(titleObj, tr)
    transition.to(infoObj, tr2)
    transition.to(subInfoObj, tr3)
    transition.to(backBtn, backTr)
    for i=1, #objArray do
        balloonTr.time = balloonTr.time + 200
        if i >= 4 then
            transition.to(objArray[i], {
                time = 1100,
                y = 315,
                transition = easing.outCubic
            })
        else
            transition.to(objArray[i], balloonTr)
        end
    end
    for i=1, #textForObjArray do
        descTr.time = descTr.time + 200
        if i >= 4 then
            transition.to(textForObjArray[i], {
                time = 1100,
                y = 390,
                transition = easing.outCubic
            })
        else 
            transition.to(textForObjArray[i], descTr)
        end
    end

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
    for i=1, #objArray do 
        objArray[i]:removeSelf()
        textForObjArray[i]:removeSelf()
    end
    titleObj:removeSelf()
    infoObj:removeSelf()
    subInfoObj:removeSelf()
    bg:removeSelf()
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
