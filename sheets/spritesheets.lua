--The following is a storage of sprite sheets
--universal balloon pop animation
local balloonPopSheetOptions = {
  width = 386,
  height = 328,
  numFrames = 39
}

balloonSequence = {
    name = "popsequence",
    frames = {
      39,38,37,36,35,34,33,32,31,30,
      29,28,27,26,25,24,23,22,21,20,
      19,18,17,16,15,14,13,12,11,10,
      9,8,7,6,5,4,3,2,1
    },
    time = 500,
    loopCount = 1,
    loopDirection = "forward"
}

balloonSheet = graphics.newImageSheet("res/popeffect.png",balloonPopSheetOptions)

--explosion effect

local explosionOptions = {
  width = 100,
  height = 60,
  numFrames = 25
}

explosionSeq = {
  name= "explosionseq",
  start = 1,
  count = 25,
  time = 800,
  loopCount = 1,
  loopDirection = "forward"
}

explosionSheet = graphics.newImageSheet("res/nuked.png",explosionOptions)

--collect toupe effect
local toupeSheetOptions = {
  width = 192,
  height = 192,
  numFrames = 35
}

toupeSeq = {
  name= "toupeseq",
  start = 1,
  count = 35,
  time = 500,
  loopCount = 1,
  loopDirection = "forward"
}

toupeSheet = graphics.newImageSheet("res/toupesheet.png",toupeSheetOptions)

--ultra pump effect
local ultraOptions = {
  width = 612,
  height = 344,
  numFrames = 30
}

ultraSeq = {
  name= "ultraseq",
  start = 1,
  count = 30,
  time = 500,
  loopCount = 1,
  loopDirection = "forward"
}

ultraSheet = graphics.newImageSheet("res/ultrasheet.png",ultraOptions)

--epic muscle flex animation
local muscleOptions = {
  width = 328,
  height = 335,
  numFrames = 7
}

muscleSeq = {
  name= "muscleseq",
  start = 1,
  count = 7,
  time = 250,
  loopCount = 1,
  loopDirection = "bounce"
}

muscleSheet = graphics.newImageSheet("res/donaldpumpsheet.png",muscleOptions)
