require "/scripts/vec2.lua"

function init()
  self.baseNumberPath = config.getParameter("numbersImage", "/interface/ammo/numbers_alt.png")
  self.counter = 0
end

function update(dt)
  localAnimator.clearDrawables()
  self.counter = self.counter + 0.1*dt
  local numberFrame = string.format("%s:%s", self.baseNumberPath, math.floor(self.counter))
  localAnimator.addDrawable({
    image = numberFrame,
    position = vec2.add(activeItemAnimation.ownerAimPosition(), {1,-1}),
    --rotation = angle,
    fullbright = true,
  }, "Monster+10")
end
