require "/scripts/vec2.lua"

function init()

  --self.fireTime = config.getParameter("fireTime", 1)
  --self.fireTimeVariance = config.getParameter("fireTimeVariance", 0)
  self.projectileCount = math.floor(math.random(config.getParameter("projectileCountMin"), config.getParameter("projectileCountMax"))+0.5)
  self.spread = config.getParameter("spread")
  self.projectile = config.getParameter("projectile")
  self.projectileConfig = config.getParameter("projectileConfig", {})
  self.projectilePosition = config.getParameter("projectilePosition", {0, 0})
  self.projectileDirection = config.getParameter("projectileDirection", {1, 0})
  self.inaccuracy = config.getParameter("inaccuracy", 0)

  self.projectilePosition = object.toAbsolutePosition(self.projectilePosition)


  local projectileDirection = vec2.rotate(self.projectileDirection, 4*math.random()-2 )

  for i=1, self.projectileCount do
    projectileDirection = vec2.rotate(projectileDirection, self.spread + sb.nrand(-self.inaccuracy,self.inaccuracy))
    world.spawnProjectile(self.projectile, self.projectilePosition, entity.id(), projectileDirection, false, self.projectileConfig)
  end
  object.smash(true)

end

function update(dt)
end
