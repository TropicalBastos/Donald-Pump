package.path = package.path .. ";../?lua"
local composer = require("composer")


--takes scene string to which it goes back to
function backButton.new(scene)

    local function goToScene()
        audio.play(wooshSound, {channel=1})
        transition.to(backBtn, {
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

    transition.to(backBtn, backTr)
    return backBtn

end