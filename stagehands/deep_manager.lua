require "/scripts/util.lua"
require "/scripts/rect.lua"

function init()

  self.players={}
  self.music = "/music/atlas.ogg"
  self.waveDelay = config.getParameter("waveDelay")

  self.waveCounter = self.waveDelay
  self.waveSizeMin = config.getParameter("waveSizeMin")
  self.waveSizeMax = config.getParameter("waveSizeMax")

  playerScan()

  --sb.logInfo("WOW IT REALLY WORKS") 
  --world.loadUniqueEntity
  --[[
  for i=0, 50, 1 do  
    spawnWave({60*i,670})
  end
  
  sb.logInfo("playerID and positions:")
  sb.logInfo(sb.print(self.players))
  sb.logInfo(sb.print(playerPositions()))
  ]]
end


function update(dt)
  if self.waveCounter > 0 then
    self.waveCounter = self.waveCounter - (1*dt)
  end
  if self.waveCounter <= 0 then
    spawnWave({0,0})
  end

  playerScan()

end

function spawnWave(position)
  local waveSize = math.floor((math.random(self.waveSizeMin,self.waveSizeMax)/#self.players)+0.5)
  local mSpawnPos = {0,0}
  for _,pos in pairs(playerPositions()) do
    for i=0,waveSize do
      mSpawnPos = world.lineCollision(pos, vec2.add(pos,{math.cos(math.pi*i/waveSize),-math.sin(math.pi*i/waveSize)}),{"block"}) or {0,0}
    --sb.logInfo(sb.print(world.lineCollision(pos,vec2.add(pos,{0,-100}),{"block"})))
      world.spawnMonster("iguarmor", mSpawnPos)
    end
  end
  self.waveCounter = self.waveDelay
end

function playerScan()
  local players = world.players()
  local newPlayers = util.filter(players, function(entityId)
    return not contains(self.players, entityId)
  end)
  for _,playerId in pairs(newPlayers) do
    if self.music then
      world.sendEntityMessage(playerId, "playAltMusic", self.music) --, config.getParameter("musicFadeInTime"))
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
