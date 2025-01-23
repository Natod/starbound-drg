require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  projectile.processAction(projectile.getParameter("initAction"))
end


function update(dt)
  
end

function uninit()
  --local newproj = world.spawnProjectile( "deep_gunflare2", mcontroller.position(), activeItem.ownerEntityId(), nil, nil, nil) 
  --world.sendEntityMessage(newproj, "projVelocity", mcontroller.xVelocity(),mcontroller.yVelocity())
end
