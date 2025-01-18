require "/scripts/util.lua"
require "/scripts/rect.lua"

function init()

  self.players={}
  self.music = "/music/atlas.ogg"
  self.waveDelay = config.getParameter("waveDelay")

  self.waveCounter = self.waveDelay
  self.waveSizeMin = config.getParameter("waveSizeMin")
  self.waveSizeMax = config.getParameter("waveSizeMax")
  self.spawnRadiusOffset = config.getParameter("spawnRadiusOffset")

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

  for _,playerPos in pairs(playerPositions()) do
    -- queries in a radius around the player for stagehands of type monsterspawnpoint
    local stagehands = world.entityQuery(playerPos,250,
    {includedTypes={"stagehand"},boundMode="position",order="nearest",callScript="getStagehandType",callScriptResult="monsterspawnpoint"})
    Print(stagehands)

    local stagehandPos = {0,0}
    if #stagehands >2 then
      stagehandPos = world.entityPosition(stagehands[2])
    elseif #stagehands == 2 then 
      --sb.logInfo(sb.print(stagehands[1]))
      stagehandPos = world.entityPosition(stagehands[1])
    elseif #stagehands == 1 then
      --sb.logInfo(sb.print(stagehands[0]))
      stagehandPos = world.entityPosition(stagehands[0])
    else
      stagehandPos = playerPos
    end
    stagehandPos = vec2.add(stagehandPos, {(math.random()-0.5)*2*self.spawnRadiusOffset, (math.random()-0.5)*2*self.spawnRadiusOffset})
    
    for i=0,waveSize do --places enemies in a pi arc below
      local rayEnd = {math.cos(math.pi*i/waveSize)*150,-math.sin(math.pi*i/waveSize)*150}
      mSpawnPos = world.lineCollision(stagehandPos, vec2.add(stagehandPos,rayEnd),{"block"}) or rayEnd
      --world.spawnMonster("iguarmor", mSpawnPos)
      world.spawnProjectile("deep_flareblue",stagehandPos)  -- for position testing
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

function Print(data)
  sb.logInfo(sb.print(data))
end

function getStagehandType()
  return "missionmanager"
end