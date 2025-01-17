require "/scripts/util.lua"
require "/scripts/rect.lua"

function init()

  self.players={}

  playerScan()

  sb.logInfo("WOW IT REALLY WORKS") --world.loadUniqueEntity
  --[[
  for i=0, 50, 1 do  
    spawnWave({60*i,670})
  end
  ]]
  sb.logInfo(sb.print(playerPositions()))
end


function update(dt)
  
end

function spawnWave(position)
  world.spawnMonster("iguarmor", position)
end

function playerScan()
  local players = world.players()
  local newPlayers = util.filter(players, function(entityId)
    return contains(self.players, entityId)
  end)
  for _,playerId in pairs(newPlayers) do
    if self.music then
      world.sendEntityMessage(playerId, "playAltMusic", self.music, config.getParameter("musicFadeInTime"))
    end
  end
  self.players = players
end

function playerPositions()
  local positions = {}
  for _,player in pairs(self.players) do
    table.insert(positions, world.entityPosition(player))
  end
  return positions
end
