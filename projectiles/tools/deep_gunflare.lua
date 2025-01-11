require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  
end


function update(dt)
  
end

function uninit()
  local newproj = world.spawnProjectile( "deep_gunflare2", mcontroller.position(), nil, nil, nil, nil) 
  --world.sendEntityMessage(newproj, "projVelocity", mcontroller.xVelocity(),mcontroller.yVelocity())
end
