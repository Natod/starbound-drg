require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/messageutil.lua"

function init()
  --mcontroller.setVelocity({0,100})
  message.setHandler("projVelocity", setProjVelocity(0,100))
end

function setProjVelocity(x,y)
  mcontroller.setVelocity({x,y})
end


function update(dt)
  
end

function uninit()
  
end

