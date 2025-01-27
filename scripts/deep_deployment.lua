require "/scripts/vec2.lua"

local deep_update = update or function() end
local deep_init = init or function() end

function init()
  deep_init()
  self.baseNumberPath = "/interface/ammo/numberssmall.png"
end

function update(dt)
  deep_update(dt)
  
  local ammoCount = 109

  -- the sludge...
  localAnimator.clearDrawables()
  drawNum(math.floor(ammoCount/100), {-0.75, 0}, {200, 200, 200, 200})
  drawNum(math.floor((ammoCount % 100)/10), {0, 0}, {200, 200, 200, 200})
  drawNum(math.floor(ammoCount%10), {0.75, 0}, {200, 200, 200, 200})
  
  
end

function drawNum(num, offset, color)
  local numberFrame = string.format("%s:%s", self.baseNumberPath, num)
  localAnimator.addDrawable({
    image = numberFrame,
    position = vec2.add({0,3}, offset),
    color = color,
    --rotation = angle,
    fullbright = true
  }, "Monster+10")
end