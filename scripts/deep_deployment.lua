require "/scripts/vec2.lua"

local deep_update = update or function() end
local deep_init = init or function() end

function init()
  deep_init()
  self.baseNumberPath = "/interface/ammo/numberssmall.png"
  self.ammoCount = 109
  self.charWidth = 0.75
end

function update(dt)
  deep_update(dt)
  

  -- the sludge...
  localAnimator.clearDrawables()
  drawNum(82, 3, {0,3}, {200, 200, 200, 200})
end

--draw a number filling empty spaces up to "places" with 0
--eg. 6,3 >> 006,  9,1 >> 9,  349,4 >> 0349
--args: (value, value, vec2F, color)
function drawNum(num, places, offset, color)
  for i=1,places do
    drawDigit(math.floor((num % 10^(i))/10^(i-1)), vec2.add(offset, {self.charWidth*(places-i)-(self.charWidth*(places-1))/2, 0}), color)
  end
end

--draw a single digit
--args: (single-digit integer, vec2F, color)
function drawDigit(num, offset, color)
  local numberFrame = string.format("%s:%s", self.baseNumberPath, num)
  localAnimator.addDrawable({
    image = numberFrame,
    position = offset,
    color = color,
    --rotation = angle,
    fullbright = true
  }, "Overlay")
end