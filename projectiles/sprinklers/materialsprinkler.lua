require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.material = config.getParameter("material") or "dirt"
  self.clusterThreshholdLower = config.getParameter("clusterThreshholdLower") or 0.1
  self.clusterThreshholdUpper = config.getParameter("clusterThreshholdUpper") or 0.3
end

function update(dt)
  
end

function uninit()
  --if world.placeMaterial(mcontroller.position()+{1,0}, "foreground", "deep_engiplatform") and world.placeMaterial(mcontroller.position()+{-1,0}, "foreground", "deep_engiplatform") then
  --  world.placeMaterial(mcontroller.position(), "foreground", "deep_engiplatform", nil, true)
  --end
  world.placeMaterial( { mcontroller.xPosition(),   mcontroller.yPosition()   }, "foreground", self.material)
  if ( math.random() > self.clusterThreshholdUpper ) then world.placeMaterial( { mcontroller.xPosition()+1, mcontroller.yPosition()   }, "foreground", self.material) end
  if ( math.random() > self.clusterThreshholdUpper ) then world.placeMaterial( { mcontroller.xPosition()-1, mcontroller.yPosition()   }, "foreground", self.material) end
  if ( math.random() > self.clusterThreshholdUpper ) then world.placeMaterial( { mcontroller.xPosition(),   mcontroller.yPosition()+1 }, "foreground", self.material) end
  if ( math.random() > self.clusterThreshholdUpper ) then world.placeMaterial( { mcontroller.xPosition(),   mcontroller.yPosition()-1 }, "foreground", self.material) end

  if ( math.random() > self.clusterThreshholdLower ) then world.placeMaterial( { mcontroller.xPosition()+1, mcontroller.yPosition()+1 }, "foreground", self.material) end
  if ( math.random() > self.clusterThreshholdLower ) then world.placeMaterial( { mcontroller.xPosition()-1, mcontroller.yPosition()+1 }, "foreground", self.material) end
  if ( math.random() > self.clusterThreshholdLower ) then world.placeMaterial( { mcontroller.xPosition()-1, mcontroller.yPosition()-1 }, "foreground", self.material) end
  if ( math.random() > self.clusterThreshholdLower ) then world.placeMaterial( { mcontroller.xPosition()+1, mcontroller.yPosition()-1 }, "foreground", self.material) end
  --world.placeMaterial(mcontroller.position(), "foreground", "deep_engiplatform", nil, true)
end
