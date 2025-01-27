require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
  self.itemList = "itemScrollArea.itemList"

  world.setProperty("deep.mission", "")
  self.missionList = {}
  self.selectedItem = nil
  populateItemList()
end

function update(dt)
  populateItemList()
end

function populateItemList(forceRepop)
  local newSeed = math.floor(os.time() / 1800)
  if newSeed ~= self.seed then
    self.seed = newSeed
  else
    return
  end

  local config = root.assetJson("/interface/scripted/missionselect/namegen.config:names")
  
  local upgradeableWeaponItems = player.itemsWithTag("weapon")
  local missionList = {
    --{name="Useless Let-down", biome="Sandblasted Corridors", warp="InstanceWorld:testmission1"},
    --{name="Awful Rock", biome="Salt Pits", warp="InstanceWorld:testmission1"},
    --{name="Outpost", biome="Yes", warp="InstanceWorld:outpost"},
    --{name="The Ruin", biome="Gaming", warp="InstanceWorld:tentaclemission"}
  }
  for i=1,10 do
    local missionname = root.generateName("/interface/scripted/missionselect/namegen.config:names", self.seed + i * self.seed)
    table.insert(missionList, {name=missionname, biome="Salt Pits", warp="InstanceWorld:testmission1"})
  end

  if forceRepop or not compare(missionList, self.missionList) then
    self.missionList = missionList
    widget.clearListItems(self.itemList)
    widget.setButtonEnabled("btnConfirm", false)

    local showEmptyLabel = true

    for i, mission in pairs(self.missionList) do
      showEmptyLabel = false

      local listItem = string.format("%s.%s", self.itemList, widget.addListItem(self.itemList))

      widget.setText(string.format("%s.itemName", listItem), mission["name"])
      widget.setItemSlotItem(string.format("%s.itemIcon", listItem), upgradeableWeaponItems[i])

      widget.setData(listItem,
        {
          index = i,
          warp = mission["warp"]
        })

      widget.setVisible(string.format("%s.unavailableoverlay", listItem), false)
    end

    self.selectedItem = nil
    showWeapon(nil)

    widget.setVisible("emptyLabel", showEmptyLabel)
  end
end

function showWeapon(item, warp)
  local enableButton = false
  if item then
    widget.setText("essenceCost", string.format("%s", warp))
  end
  widget.setButtonEnabled("btnConfirm", true)
end

function itemSelected()
  local listItem = widget.getListSelected(self.itemList)
  self.selectedItem = listItem

  if listItem then
    local itemData = widget.getData(string.format("%s.%s", self.itemList, listItem))
    local weaponItem = self.missionList[itemData.index]
    showWeapon(weaponItem, itemData.warp)
  end
end

function confirm()
  if self.selectedItem then
    local selectedData = widget.getData(string.format("%s.%s", self.itemList, self.selectedItem))
    local mission = self.missionList[selectedData.index]

    if mission then
      world.setProperty("deep.mission", selectedData.warp)
      sb.logInfo(string.format("Selected %s", selectedData.warp))
    end
    --populateItemList(true)
  end
end
