require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  
end

function update(dt)
  
end

function uninit()
  --if world.placeMaterial(mcontroller.position()+{1,0}, "foreground", "deep_engiplatform") and world.placeMaterial(mcontroller.position()+{-1,0}, "foreground", "deep_engiplatform") then
  --  world.placeMaterial(mcontroller.position(), "foreground", "deep_engiplatform", nil, true)
  --end
  local centered = true

  if not world.placeMaterial( {mcontroller.xPosition() + 1, mcontroller.yPosition() }, "foreground", "deep_engiplatform") then
    world.placeMaterial( { mcontroller.xPosition()-2, mcontroller.yPosition() }, "foreground", "deep_engiplatform")
    world.placeMaterial( { mcontroller.xPosition()-3, mcontroller.yPosition() }, "foreground", "deep_engiplatform")
    world.placeMaterial( { mcontroller.xPosition()-4, mcontroller.yPosition() }, "foreground", "deep_engiplatform")
    centered = not centered
  end

  if not world.placeMaterial( {mcontroller.xPosition() - 1, mcontroller.yPosition() }, "foreground", "deep_engiplatform") then
    world.placeMaterial( { mcontroller.xPosition()+2, mcontroller.yPosition() }, "foreground", "deep_engiplatform")
    world.placeMaterial( { mcontroller.xPosition()+3, mcontroller.yPosition() }, "foreground", "deep_engiplatform")
    world.placeMaterial( { mcontroller.xPosition()+4, mcontroller.yPosition() }, "foreground", "deep_engiplatform")
    centered = not centered
  end
  
  world.placeMaterial( { mcontroller.xPosition(), mcontroller.yPosition() }, "foreground", "deep_engiplatform")

  if centered then
    world.placeMaterial( { mcontroller.xPosition()-2, mcontroller.yPosition() }, "foreground", "deep_engiplatform")
    world.placeMaterial( { mcontroller.xPosition()+2, mcontroller.yPosition() }, "foreground", "deep_engiplatform")
  end
  --world.placeMaterial(mcontroller.position(), "foreground", "deep_engiplatform", nil, true)
end
