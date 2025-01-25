require "/scripts/vec2.lua"

function init()
  self.baseNumberPath = config.getParameter("numbersImage", "/interface/ammo/numbers_alt.png")
end

function update(dt)
  localAnimator.clearDrawables()

  local numberFrame = string.format("%s:%s", self.baseNumberPath, 0)
  localAnimator.addDrawable({
    image = numberFrame,
    position = vec2.add(activeItemAnimation.ownerAimPosition(), {1,-1}),
    --rotation = angle,
    fullbright = true,
  }, "Monster+10")
end
