package.path = package.path .. ";../?lua"

local composer = require( "composer" )
local widget = require("widget")
local backButton = require("objects.backbutton")
local native = require("native")
local json = require( "json" )
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

-- -----------------------------------------------------------------------------------
-- Transaction listeners
-- -----------------------------------------------------------------------------------

local function loadProductsLocal(event)
    print(json.prettify(event))
end

local function transactionListener( event )
    
       -- Google IAP initialization event
       if ( event.name == "init" ) then
    
           if not ( event.transaction.isError ) then
               -- Perform steps to enable IAP, load products, etc.
               globalStore.loadProducts({PRODUCT_NO_ADS}, loadProductsLocal)
    
           else  -- Unsuccessful initialization; output error details
               print( event.transaction.errorType )
               print( event.transaction.errorString )
               native.showAlert("Error", "There has been an unknown error connecting to the Google Play Store", {"OK"})
           end
    
       -- Store transaction event
       elseif ( event.name == "storeTransaction" ) then
    
           if not ( event.transaction.state == "failed" ) then  -- Successful transaction
               print( json.prettify( event ) )
               print( "event.transaction: " .. json.prettify( event.transaction ) )

               if(event.transaction.productIdentifier == PRODUCT_NO_ADS) then
                    enableNoAds()
               end
    
           else  -- Unsuccessful transaction; output error details
               print( event.transaction.errorType )
               print( event.transaction.errorString )
               native.showAlert("Unsuccessful Purchase", "Unfortunately your payment has been rejected, you have not been charged.", {"OK"})
           end
       end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    composer.removeScene("scenes.menu")
    local bg = display.newImage("res/optionsmenu.png")
    bg.x = centerX
    bg.y = centerY
    bg.width = rightMarg + 100
    bg.height = bottomMarg + 100
    sceneGroup:insert(bg)

    local title = display.newText({
        text = "Store",
        fontSize = 40,
        font = secondaryFont,
        x = centerX,
        y = 30
    })

    local noAdsText = "No Ads! - $1.00"
    local noAdsObj = display.newText({
        text = noAdsText,
        font = secondaryFont,
        fontSize = 28,
        x = centerX,
        y = 100
    })
    
    local buyButton = display.newImage("res/buybutton.png")
    buyButton.width = 150
    buyButton.height = 60
    buyButton.y = noAdsObj.y + (buyButton.height)
    buyButton.x = centerX
    buyButton.product = "noads"
    buyButton.pressed = false
    buyButton:addEventListener("tap", confirmPurchase)

    local backBtn = backButton.new("scenes.menu")

    sceneGroup:insert(noAdsObj)
    sceneGroup:insert(buyButton)
    sceneGroup:insert(title)
    sceneGroup:insert(backBtn)
    globalStore.init(transactionListener)
end

function liftTouch(button)
    if(button.pressed) then
        button:scale(1.25, 1.25)
        button.pressed = false
    end
end


function confirmPurchase(event)

    audio.play(clickSound)

    if(not event.target.pressed) then
        event.target.pressed = true
        event.target:scale(0.8, 0.8)
    end

    local eventButton = event.target

    local function commenceTransaction(event, productId)
        liftTouch(eventButton)
        --if they click no
        if(event.index == 1) then
            return
        end
        -- Implement purchase with payment gateway
        globalStore.purchase(productId)
    end

    if(event.target.product == "noads") then
        native.showAlert("No Ads Module", "Would you like to purchase the No Ads Module for $1.00?", 
        {"No", "Yes"}, function(e) commenceTransaction(e, PRODUCT_NO_ADS) end )
    end

end


-- Should only call this function for testing
function disableNoAds()
    local storeBox = ggData:new("purchases")
    storeBox:set(PRODUCT_NO_ADS, false)
    storeBox:save()
    native.showAlert("Disabling", "Disabling the No Ads Module.", {"OK"})
end

function enableNoAds()
    local storeBox = ggData:new("purchases")
    storeBox:set(PRODUCT_NO_ADS, true)
    storeBox:save()
    native.showAlert("Purchase Successful", "Thank you for purchasing our No Ads Module.", {"OK"})
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
