require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/deep_util.lua"

function init()

  self.itemToPlace = config.getParameter("itemToPlace", "jeep")
  self.tileMod = config.getParameter("tileMod", "deep_aquarq")
  self.modRadius = config.getParameter("modRadius", 3)
  self.rayCastLength = config.getParameter("rayCastLength", 100)
  self.maxTries = config.getParameter("maxTries", 100)

-- raycast to a random angle and detect if it's a thick wall and if not try again at a shifted angle
  local rayAngle = math.random()*2*math.pi
  local thickEnough = false
  local spawnPos = {}
  for i=0,self.maxTries do 
    local rayOffsetUnitVec = {math.cos(rayAngle + i*2*math.pi/self.maxTries), math.sin(rayAngle + i*2*math.pi/self.maxTries)}
    local rayEndPoint = vec2.add(entity.position(), vec2.mul(rayOffsetUnitVec, self.rayCastLength ))
    local rayHitPoint = world.lineCollision(entity.position(),rayEndPoint,{"block"})
-- if the raycast hits anything it checks the next x tiles in
    thickEnough = false
    if rayHitPoint and self.modRadius >0 then
      thickEnough = true
      for j=1,self.modRadius do
        if thickEnough then
          thickEnough = thickEnough and world.pointTileCollision(vec2.add(rayHitPoint,vec2.mul(rayOffsetUnitVec,j)),{"block"})
        else
          break
        end
      end
      if thickEnough then
        spawnPos = vec2.add(rayHitPoint,vec2.mul(rayOffsetUnitVec,self.modRadius))
        world.spawnVehicle(self.itemToPlace, spawnPos)
        break
      end
    end
  end
-- place tilemods around the item
  if thickEnough then
    for i=0,self.modRadius do
      for j=0,(self.modRadius*self.modRadius) do
        local modAngle = j*2*math.pi/(self.modRadius*self.modRadius)
        local modPos = {math.cos(modAngle)*i, math.sin(modAngle)*i}
        world.placeMod(vec2.add(spawnPos,modPos), "foreground", self.tileMod, nil, true)
        Print("trying to place the mods")
      end
    end      
  end

  object.smash(true)

end

function update(dt)
end
