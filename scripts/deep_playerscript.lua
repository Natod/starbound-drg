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
  if not storage.ammoTable or not (storage.ammoTable.reserve and storage.ammoTable.loaded) then
    storage.ammoTable = {
      reserve = {},
      loaded = {}
    }
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
  message.setHandler("deep_getAmmoTable", function(messageName, isLocalEntity, LR, key) --loaded/reserve, itemIDd
    if storage.ammoTable[LR][key] then
      return storage.ammoTable[LR][key]
    else
      sb.logError(string.format("Message %s failed to retrieve ammo for item %s", messageName, key))
      return nil
    end
  end)
  --player.interact("SitDown", 8, player.id())
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



