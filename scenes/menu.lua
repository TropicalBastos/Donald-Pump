package.path = package.path .. ";../?.lua"

local composer = require( "composer" )
local cloudGenerator = require("objects.cloudGenerator")
local menubuttons = require("objects.buttons")
local zepellin = require("objects.zep")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local whiteHouse
local title
local titleOffset
local bottomMarg = display.contentHeight - display.screenOriginY
local cloudEmitter
local flagSprite
local bg
local buttons
local highscore
local playScore
highscoreNumber = nil
whichScene = "menu"
ropeJoint = nil
box = nil

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    composer.removeScene("scenes.play")
    composer.removeScene("scenes.loading")

    --start physics that is used by some objects
    physics.start()
    physics.setGravity(0,25)

    --set the game to paused so it doesnt start up any game play objects
    gamePaused = false

    --Background
    bg = display.newImage("res/bg.png",0,0)
    bg.width = rightMarg + 100
    bg.height = bottomMarg + 100
    bg.x = centerX
    bg.y = centerY
    bg.alpha = 0
    sceneGroup:insert(bg)

    --white house graphic
    whiteHouse = display.newImage("res/whitehouse2.png",display.contentCenterX,100)
    whiteHouse.width = display.actualContentWidth
    whiteHouse.height = whiteHouse.width/3
    whiteHouse.y = bottomMarg - (whiteHouse.height/2)
    sceneGroup:insert(whiteHouse)

    --initialize cloud emmiter
    cloudEmitter = cloudGenerator.new(5,sceneGroup,0.5)

    title = createTitle()
    titleOffset = createTitle()

    --set text gradient
    local gradient = {
    type="gradient",
    color1={ 1, 0.3, 0.3 }, color2={ 1, 1, 1 }, direction="down"
    }
    title:setFillColor(gradient)
    title:scale(0,0)
    titleOffset:scale(0,0)
    title:setFillColor( 1, 1, 1 )
    --insert into view group
    sceneGroup:insert(title)

    flagSprite = createFlagSprite()
    flagSprite:scale(0.05,0.05)
    flagSprite.x = centerX + 19
    flagSprite.y = bottomMarg - (whiteHouse.height)+2
    flagSprite:play()
    sceneGroup:insert(flagSprite)

    --our zepellin object
    newZep(150,80,1.3)

    --insert buttons
    buttons = menubuttons.new(80,centerY+40,sceneGroup)
    buttons:setDimension(rightMarg/4)
    for i = 1, #buttons.allButtons do
      buttons.allButtons[i].y = buttons.allButtons[i].y+300
      buttons.allButtons[i]:addEventListener("touch",buttonTap)
      local r = math.random(3,6)/10
      physics.addBody(buttons.allButtons[i],{bounce=r,density=r})
      buttons.allButtons[i].gravityScale = -0.5
    end

    local leftWall = display.newRect(0,0,40,4000)
    local rightWall = display.newRect (rightMarg, 0, 40, 4000)
    local topWall = display.newRect (screenLeft, centerY-30, 4000, 10)
    topWall.alpha = 0
    leftWall.alpha = 0
    rightWall.alpha = 0

    sceneGroup:insert(topWall)
    sceneGroup:insert(rightWall)
    sceneGroup:insert(leftWall)

    physics.addBody (leftWall, "static", { bounce = 0.1} )
    physics.addBody (rightWall, "static", { bounce = 0.1} )
    physics.addBody (topWall, "static", { bounce = 0.1} )

    loadHighScore()

    --insert highscore
    if highscoreNumber == nil then
      highscoreNumber = 0
    end
    local textOptions = {
      text = "Highscore: ".. highscoreNumber,
      font = highscoreFont,
      x = display.contentCenterX,
      y = 18
    }
    highscore = display.newText(textOptions)
    highscore.alpha = 0

    --add listener for cloud emitter
    Runtime:addEventListener("enterFrame",cloudEmitter)
    Runtime:addEventListener("enterFrame",zepFrame)

    --check for new highscore
    if event.params ~= nil then
      if event.params.score ~= nil then
        local tempScore = event.params.score
        if tempScore > highscoreNumber then
          highscoreNumber = tempScore
          updateHighscore()
        end
      end
    end
end

--load the stored highscore into the scene
function loadHighScore()
  box = ggData:new("highscore")
  if box.highscore == nil then
    box:set("highscore",0)
    box:save()
  else
    highscoreNumber = box.highscore
  end
end

function updateHighscore()
  local textOptions = {
    text = "New Highscore! " .. highscoreNumber,
    font = newHighscoreFont,
    x = display.contentCenterX,
    y = centerY
  }
  local updateScoreText = display.newText(textOptions)
  updateScoreText:scale(0,0)
  transition.to(updateScoreText,{time=2000,delay=1000,xScale=1,yScale=1,
  transition=easing.inOutElastic,onComplete=updateScoreComplete})
  box:set("highscore",highscoreNumber)
  box:save()
end

function updateScoreComplete(event)
  local ust = event
  transition.to(ust,{time=500,delay=1000,y=0,xScale=0,yScale=0,
  onComplete=function(event) event:removeSelf() end})
  highscore.text = "Highscore: " .. highscoreNumber
end

--balloon button tap animation and functions
function buttonTap(event)
  if event.target == buttons.allButtons[1] then
    local popSprite = display.newSprite(balloonSheet,balloonSequence)
    popSprite.button = "play"
    popSprite:addEventListener("sprite",popEventMenu)
    popSprite.x = buttons.allButtons[1].x
    popSprite.y = buttons.allButtons[1].y-50
    popSprite.width = buttons.allButtons[1].width
    popSprite.height = buttons.allButtons[1].height
    popSprite:scale(0.8,0.8)
    buttons.allButtons[1]:removeSelf()
    popSprite:play()
  elseif event.target == buttons.allButtons[2] then
    local popSprite = display.newSprite(balloonSheet,balloonSequence)
    popSprite.button = "how"
    popSprite:addEventListener("sprite",popEventMenu)
    popSprite.x = buttons.allButtons[2].x
    popSprite.y = buttons.allButtons[2].y-50
    popSprite.width = buttons.allButtons[2].width
    popSprite.height = buttons.allButtons[2].height
    popSprite:scale(0.8,0.8)
    buttons.allButtons[2]:removeSelf()
    popSprite:play()
  elseif event.target == buttons.allButtons[3] then
    local popSprite = display.newSprite(balloonSheet,balloonSequence)
    popSprite.button = "rank"
    popSprite:addEventListener("sprite",popEventMenu)
    popSprite.x = buttons.allButtons[3].x
    popSprite.y = buttons.allButtons[3].y-50
    popSprite.width = buttons.allButtons[3].width
    popSprite.height = buttons.allButtons[3].height
    popSprite:scale(0.8,0.8)
    buttons.allButtons[3]:removeSelf()
    popSprite:play()
  end
end

--remove sprite from memory after it has popped
function popEventMenu(event)
  if event.phase == "ended" then
    event.target:removeSelf()
  end

  local function changeScene()
    if event.target.button == "play" then
      composer.gotoScene("scenes.play")
    end
  end

  transition.to(whiteHouse,{time=500,x=-800})
  transition.to(flagSprite,{time=500,x=-800})
  transition.to(title,{time=500,y=-500})
  transition.to(titleOffset,{time=500,y=-500, onComplete=changeScene})
  transition.fadeOut(highscore)
  for i = 1, #buttons.allButtons do
    transition.fadeOut(buttons.allButtons[i])
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

        animateTitle()

        local transitionOptions = {
          time = 1000,
          onComplete = function()
            if event.params ~= nil then
              if event.params.bg ~= nil then
                event.params.bg:removeSelf()
              end
            end
          end --remove previous bg
        }
        transition.fadeIn(bg,transitionOptions)
        transition.fadeIn(highscore)

    end
end

function createTitle()
  --title
  local textOptions = {
    text = "Donald pump",
    font = titleFont,
    x = display.contentCenterX,
    y = 50
  }
  return display.newText(textOptions)
end

function animateTitle()
  local options = {
    time = 500,
    xScale = 1.3,
    yScale = 1.3,
    transition = easing.inExpo
  }
  transition.to(title,options)
  local options2 = {
    time = 500,
    xScale = 1.35,
    yScale = 1.35,
    transition = easing.inExpo
  }
  transition.to(titleOffset,options2)
end


--create our animated flag
function createFlagSprite()
  local options = {
    width = 800,
    height = 600,
    numFrames = 9
  }

  local sprite = graphics.newImageSheet("res/wavingflagsheet.png",options)

  local seq = {
    name = "loading",
    start = 1,
    count = 9,
    time = 1000,
    loopCount = 0,
    loopDirection = "forward"
  }

  return display.newSprite(sprite,seq)
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
    Runtime:removeEventListener("enterFrame",zepFrame)
    zep:removeSelf()
    cloudEmitter:deleteAll()
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
