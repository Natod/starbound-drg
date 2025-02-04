require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/status.lua"
require "/scripts/deep_util.lua"

local deep_update = update or function() end
local deep_init = init or function() end
local deep_uninit = uninit or function() end

function init()
  deep_init()
  --[[
  local blockTable =
  {
    [4803] = "wet",
  }
  --]] 


  --The pizza...
  --
  if not storage.ammoTable or not (storage.ammoTable.reserve and storage.ammoTable.loaded and storage.ammoTable.maxR) then
    storage.ammoTable = {
      reserve = {},
      loaded = {},
      maxR = {}
    }
    --sb.logInfo("it was detected................................")
  else
    --sb.logError("it was NOT detected!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1")
    --deep_util.print(storage.ammoTable)
  end

  --]]
  --storage.ammoTable = {}

  self.deep_tags = {
    deepmod = "deep_deep",
    weapon = "weapon",
    ammo = "deep_ammo",
    reloadable = "deep_reloadable"
  }
  --sludge...
  message.setHandler("deep_updateAmmoTable", function(messageName, isLocalEntity, LR, key, value) --itemID, ammo count
    storage.ammoTable[LR][key] = value
  end)
  message.setHandler("deep_getAmmoTable", function(messageName, isLocalEntity, LR, key) --loaded/reserve, itemID
    if storage.ammoTable[LR][key] then
      return storage.ammoTable[LR][key]
    else
      sb.logError(string.format("Message %s failed to retrieve value %s for item %s", messageName, LR, key))
      return nil
    end
  end)
  message.setHandler("deep_setClass", function(messageName, isLocalEntity, class)
    if class == "driller" then
      player.giveEssentialItem("beamaxe","flamethrower")
      player.giveEssentialItem("wiretool","raygun")
      player.giveEssentialItem("painttool","deep_drills")
      player.giveEssentialItem("inspectiontool", "deep_satchel")
    elseif class == "gunner" then
      player.giveEssentialItem("beamaxe","neotommygun")
      player.giveEssentialItem("wiretool","neopistol")
      player.giveEssentialItem("painttool", "deep_ziplinegun")
      player.giveEssentialItem("inspectiontool", "frostshield")
    elseif class == "engineer" then
      player.giveEssentialItem("beamaxe","doomcannon")
      player.giveEssentialItem("wiretool","neolaserlauncher")
      player.giveEssentialItem("painttool","deep_platformgun")
      player.giveEssentialItem("inspectiontool", "standingturret")
    elseif class == "scout" then
      player.giveEssentialItem("beamaxe","electricrailgun")
      player.giveEssentialItem("wiretool","adaptablecrossbow")
      player.giveEssentialItem("painttool","deep_grapple")
      player.giveEssentialItem("inspectiontool", "deep_flaregun")
    else
      sb.logError(string.format("Attempted to set class to nonexistent class %s", class))
    end
  end)
  --resupply
  message.setHandler("deep_resupplyFactor", function(messageName, isLocalEntity, factor) -- float 0-1
    for ID,val in pairs(storage.ammoTable.reserve) do 
      if storage.ammoTable.reserve[ID] and storage.ammoTable.maxR[ID] then
        storage.ammoTable.reserve[ID] = math.min(storage.ammoTable.reserve[ID] + math.ceil(factor * storage.ammoTable.maxR[ID]), storage.ammoTable.maxR[ID])
      else
        sb.logError(string.format("Unable to get table info for item %s. messageName:%s", ID, messageName))
      end
    end
  end)
end

function update(dt)
  deep_update()

  --[[
  if contains(player.primaryHandItemTags(), self.deep_tags.ammo) then
    deep_util.print(player.primaryHandItem().name)
  end
  --]]
  --world.sendEntityMessage(player.primaryHandItem(), )
  --deep_util.print(storage.ammoTable.reserve)

  --player.lounge(8)
end

function uninit()
  deep_uninit()
end

function checkBlocks()
  local matID = world.material(vec2.add({mcontroller.xPosition(), mcontroller.yPosition()}, {0,-2}), "foreground")
  return matID
end



