require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
  self.itemList = "itemScrollArea.itemList"
  --self.classes = config.getParameter("classes")
  
  self.classList = {}
  self.selectedItem = nil
  populateItemList()
end

function update(dt)
end

function populateItemList(forceRepop)
  
  local upgradeableWeaponItems = player.itemsWithTag("weapon")
  local classList = {
    {name="Driller", class="driller"},
    {name="Gunner", class="gunner"},
    {name="Engineer", class="engineer"},
    {name="Scout", class="scout"}
  }

  if forceRepop or not compare(classList, self.classList) then
    self.classList = classList
    widget.clearListItems(self.itemList)
    widget.setButtonEnabled("btnConfirm", false)

    local showEmptyLabel = true

    for i, class in pairs(self.classList) do
      showEmptyLabel = false

      local listItem = string.format("%s.%s", self.itemList, widget.addListItem(self.itemList))

      widget.setText(string.format("%s.itemName", listItem), class["name"])
      widget.setItemSlotItem(string.format("%s.itemIcon", listItem), upgradeableWeaponItems[i])

      widget.setData(listItem,
        {
          index = i,
          class = class["class"]
        })

      widget.setVisible(string.format("%s.unavailableoverlay", listItem), false)
    end

    self.selectedItem = nil
    showWeapon(nil)

    widget.setVisible("emptyLabel", showEmptyLabel)
  end
end

function showWeapon(item, class)
  local enableButton = false
  if item then
    widget.setText("essenceCost", string.format("%s", class))
  end
  widget.setButtonEnabled("btnConfirm", true)
end

function itemSelected()
  local listItem = widget.getListSelected(self.itemList)
  self.selectedItem = listItem

  if listItem then
    local itemData = widget.getData(string.format("%s.%s", self.itemList, listItem))
    local weaponItem = self.classList[itemData.index]
    showWeapon(weaponItem, itemData.class)
  end
end

function confirm()
  if self.selectedItem then
    local selectedData = widget.getData(string.format("%s.%s", self.itemList, self.selectedItem))
    --local class = self.classList[selectedData.index]

    --if class then
    world.sendEntityMessage(player.id(), "deep_setClass", selectedData.class)
    sb.logInfo(string.format("Selected %s", selectedData.class))
    --end
    --populateItemList(true)
  end
end
