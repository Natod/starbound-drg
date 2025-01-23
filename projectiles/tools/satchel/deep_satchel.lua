require "/scripts/deep_util.lua"
function init()
  self.armed = false
  self.counter = 0
  self.velThreshhold = config.getParameter("velocityThreshhold", 0.5)
end

function update(dt)
  --deep_util.print(mcontroller.velocity())
  if self.counter >= 0.8 then
    if mcontroller.xVelocity() < self.velThreshhold
    and mcontroller.xVelocity() > -self.velThreshhold
    and mcontroller.yVelocity() < self.velThreshhold
    and mcontroller.yVelocity() > -self.velThreshhold then
      self.armed = true
    end
  else
    self.counter = self.counter + 1*dt
  end
end

function trigger()
  if self.armed then
    projectile.die()
  end
end
