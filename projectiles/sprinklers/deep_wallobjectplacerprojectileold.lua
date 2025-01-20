require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.tileMod = config.getParameter("tileMod", "deep_aquarq")
  self.modRadius = config.getParameter("modRadius", 3)
end

function update(dt)
  
end

function uninit()
  local modCenter = vec2.add(
    mcontroller.position(),
    {
      math.cos(mcontroller.rotation())*self.modRadius,
      math.sin(mcontroller.rotation())*self.modRadius
    }
  )
  -- if the mod cannot be placed on the expected center point, move forward and try again
  if not world.placeMod(modCenter, "foreground", self.tileMod, nil, true) then
    world.spawnProjectile(
      "deep_wallobjectplacerprojectile", 
      modCenter, 
      nil, 
      {math.cos(mcontroller.rotation()), math.sin(mcontroller.rotation())}, -- unit vector
      nil, 
      {
        speed = projectile.getParameter("speed")
        tileMod = self.tileMod
        modRadius = self.modRadius
      }
    )
  end

end
