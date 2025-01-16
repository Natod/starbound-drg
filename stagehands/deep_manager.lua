require "/scripts/util.lua"
require "/scripts/rect.lua"

function init()
  sb.logInfo("WOW IT REALLY WORKS") --world.loadUniqueEntity
  for i=0, 50, 1 do  
    spawnWave({60*i,670})
  end
end


function update(dt)
  
end

function spawnWave(position)
  world.spawnMonster("iguarmor", position)
end
