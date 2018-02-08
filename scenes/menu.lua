package.path = package.path .. ";../?.lua"

local composer = require( "composer" )
local cloudGenerator = require("objects.cloudGenerator")
local menubuttons = require("objects.buttons")
local zepellin = require("objects.zep")
local donaldPlane = require("objects.plane")
local flyAwayText = require("plugins.FlyAwayText")
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
local flyText
local menuButtonTapped = false
isOnMenu = true
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
    --resetHighscore()
    composer.removeScene("scenes.play")
    composer.removeScene("scenes.loading")
    composer.removeScene("scenes.howtoplay")
    composer.removeScene("scenes.options")
    composer.removeScene("scenes.transitionfromplay")
    composer.removeScene("scenes.store")

    --start physics that is used by some objects
    physics.start()
    physics.setGravity(0,25)

    --set the game to paused so it doesnt start up any game play objects
    gamePaused = false

    --get and show any alerts from previous scenes
    if event.params ~= nil then
      if(event.params.alert ~= nil) then
          local alert = display.newText({
            text = event.params.alert,
            font = titleFont,
            fontSize = 18,
            x = centerX,
            y = centerY - 100,
            width = rightMarg / 1.5
          })
          alert.alpha = 0
          sceneGroup:insert(alert)
          transition.fadeIn(alert, {time = 1000})

          local function fadeOutAlert()
              transition.fadeOut(alert)
          end

          timer.performWithDelay(5000, fadeOutAlert)
      end
    end

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
    whiteHouse.width = (display.actualContentWidth) / 1.3
    whiteHouse.height = whiteHouse.width/2.25
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
    flagSprite:scale(0.5, 0.5)
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
      buttons.allButtons[i]:addEventListener("collision", bounceCollision)
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

    --check for new highscore OLD
    -- if event.params ~= nil then
    --   if event.params.score ~= nil then
    --     local tempScore = event.params.score
    --     if tempScore > highscoreNumber then
    --       highscoreNumber = tempScore
    --       updateHighscore()
    --     end
    --   end
    -- end

    --check for new highscore NEW
    local changeScore = ggData:new("updateHighscore")
    if changeScore ~= nil then
      if changeScore:get("updateHighscore") ~= nil then
        highscoreNumber = changeScore:get("updateHighscore")
        updateHighscore()
        changeScore:set("updateHighscore", nil)
        changeScore:save()
      end
    end

    local storeGraphic = display.newImage("res/store.png")
    storeGraphic.width = 180
    storeGraphic.height = 70
    storeGraphic.x = -400
    storeGraphic.y = bottomMarg - (storeGraphic.height + 50)
    storeGraphic:rotate(90)
    storeGraphic:addEventListener("tap", storeClickListener)
    storeGraphic.button = "store"
    sceneGroup:insert(storeGraphic)
    transition.to(storeGraphic, {x = screenLeft + storeGraphic.height/2, time = 1500, transition = easing.outCubic})

    --display ad randomly
    --displayAd(3, "interstitial")
    displayAd(2, "banner")

end

function storeClickListener(event)
  if menuButtonTapped then
    return
  end
  menuButtonTapped = true
  audio.play(clickSound, {channel = 3})
  local storeGraphic = event.target
  transition.to(storeGraphic, {xScale = 4, yScale = 4, alpha = 0.5, x = centerX, rotation = 0, time = 500,
    onComplete = function() popEventMenu(event) end})
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

--update the highscore with animation
function updateHighscore()

  highscoreParticles()

  local textOptions = {
    text = "New Highscore!",
    font = newHighscoreFont,
    x = display.contentCenterX,
    y = centerY
  }

  local scoreOptions = {
    text = "" .. highscoreNumber,
    font = newHighscoreFont,
    x = display.contentCenterX,
    y = centerY+50
  }

  local updateScoreText = display.newText(textOptions)
  local updateScoreNumber = display.newText(scoreOptions)
  updateScoreText:scale(0,0)
  updateScoreNumber:scale(0,0)
  transition.to(updateScoreText,{time=2000,xScale=1,yScale=1,
  transition=easing.inOutElastic,onComplete=updateScoreComplete})
  transition.to(updateScoreNumber,{time=2000,xScale=1,yScale=1,
  transition=easing.inOutElastic,onComplete=updateScoreComplete})
end

--callback function after new highscore has been displayed on screen
function updateScoreComplete(event)
  local ust = event
  local t = event.text
  local y
  event:removeSelf()

  if t == "New Highscore!" then
    y = centerY
  else
    y = centerY + 50
  end

  local textOptions = {
    text = t,
    font = newHighscoreFont,
    x = display.contentCenterX,
    y = y
  }

  flyText = flyAwayText.new(textOptions)
  flyText:fly(100,{time=200,delay=0,y=-100,transition=easing.outSine})
  highscore.text = "Highscore: " .. highscoreNumber
end

function resetHighscore()
  box = ggData:new("highscore")
  box:set("highscore",0)
  box:save()
end

function highscoreParticles()

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

  emitter.emitX, emitter.emitY = centerX, bottomMarg
  emitter:emit()

end

function bounceCollision()
    audio.play(bounceSound, {channel=3})
end

--balloon button tap animation and functions
function buttonTap(event)
  if menuButtonTapped then
    return
  end
  menuButtonTapped = true
  audio.play(popSound, {channel=1})
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
    popSprite.button = "options"
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
    elseif event.target.button == "how" then
      composer.gotoScene("scenes.howtoplay", {effect="crossFade", time=1000})
    elseif event.target.button == "options" then
      composer.gotoScene("scenes.options", {effect="crossFade", time=1000})
    elseif event.target.button == "store" then
      composer.gotoScene("scenes.store", {effect="crossFade", time=1000})
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
        audio.stop({channel = 2})
        audio.play(menuTheme, {channel = 2, loops = -1})

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
    width = 80,
    height = 60,
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
    if flyText ~= nil then
      flyText:removeSelf()
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
