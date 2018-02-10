package.path = package.path .. ";../?lua"
local composer = require("composer")

local backButton = {}
local backButton_mt = {__index = backButton}

--takes scene string to which it goes back to
function backButton.new(scene)

    local function goToScene(e)
        audio.play(wooshSound, {channel=1})
        transition.to(e.target, {
            x = -1000,
            time = 1000,
            transition = easing.outCubic,
            onComplete = function() composer.gotoScene(scene, {effect="crossFade", time=500}) end
        })
    end

    local backBtn = display.newSprite(backSheet, backSeq)
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

    backBtn:addEventListener("touch", goToScene)
    transition.to(backBtn, backTr)
    return backBtn

end

return backButton