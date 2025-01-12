require("/quests/scripts/portraits.lua")
require("/quests/scripts/questutil.lua")

function init()
end

function questStart()
  player.giveEssentialItem("inspectiontool", "inspectionmode")

  for _, item in pairs(config.getParameter("skipIntroItems", {})) do
    player.giveItem(item)
  end
  player.giveEssentialItem("beamaxe","deep_pickaxe")
  player.giveEssentialItem("wiretool","deep_flaregun")
  player.giveEssentialItem("painttool","deep_platformgun")
  player.makeTechAvailable("deep_flare")
  player.enableTech("deep_flare")
  player.equipTech("deep_flare")
  setPortraits()

  if not player.introComplete() then
    player.warp("ownship")
  end
  --player.upgradeShip({shipLevel=1})
  player.upgradeShip(config.getParameter("shipUpgrade"))
  quest.complete()
  

  return

end

function questComplete()
  player.setIntroComplete(true)

  questutil.questCompleteActions()
end

function update(dt)
end

function uninit()
end