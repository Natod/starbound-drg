require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/deep_util.lua"

function init(dt)
  
  self.detectRadius = config.getParameter("detectRadius")
  self.playerPosList = {}
  self.nearbyPlayers = {}
  
  self.movementSettings = config.getParameter("movementSettings")
  vehicle.setPersistent(true)
  vehicle.setDamageTeam({type = "ghostly"})
  vehicle.setInteractive(false)

  animator.setAnimationState("body", "idle")
  --vehicle.destroy()
  mcontroller.applyParameters(self.movementSettings)
end

function update(dt)
   
  local driver = vehicle.entityLoungingIn("seat")
  if driver then
    -- called when you first get in 
    if self.lastDriver == nil then
      --match the index of the driver's entityID to their position
      for i,p in pairs(self.nearbyPlayers) do
        if driver == p then
          --mcontroller.setPosition(vec2.add(self.playerPosList[p][2],{0,-2.65}))
          break
        end
      end
    end

    vehicle.setInteractive(false)
  else
    vehicle.setInteractive(false)
  end
  self.lastDriver = driver

  local spinny = false
  if driver == nil then
    self.nearbyPlayers = world.entityQuery(mcontroller.position(), self.detectRadius, {
      includedTypes = {"player"},
      boundMode = "CollisionArea",
      order = "nearest"
    })
    
    -- Update list of player positions over last 2 ticks
    if #self.nearbyPlayers >0 then
      for i,p in pairs(self.nearbyPlayers) do 
        self.playerPosList[p] = self.playerPosList[p] or {}
        self.playerPosList[p][2] = self.playerPosList[p][1] or {0,0}
        self.playerPosList[p][1] = world.entityPosition(p)
        --
        local playerX = world.entityPosition(p)[1] - 0
        local playerY = world.entityPosition(p)[2] - 2.5
        if  playerX > mcontroller.xPosition() - 1.7
        and playerX < mcontroller.xPosition() + 1.7
        and playerY > mcontroller.yPosition() + 2
        and playerY < mcontroller.yPosition() + 3.01 then
          --freak
          --sb.logInfo("freakin!!")
          local maxDisplacement = 1.25
          local poly = mcontroller.collisionPoly()
          --{{0,0},{0,1},{1,1},{1,0}}
          local resolvePos = world.resolvePolyCollision(poly, 
          vec2.add(mcontroller.position(),{
            (math.random()-0.5)*2 * maxDisplacement,
            (math.random()-0.5)*2 * maxDisplacement
          }), maxDisplacement)
          if resolvePos then
            mcontroller.setPosition(resolvePos)
            spinny = true
          end
        end
      end
    end
    if spinny then
      animator.rotateTransformationGroup("rotate", (math.random()-0.5)*2 * math.pi/4, {0,1.5})
    else
      animator.resetTransformationGroup("rotate")
    end
  end

  

end