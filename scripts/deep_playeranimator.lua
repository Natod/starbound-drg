require "/scripts/vec2.lua"
require "/scripts/deep_util.lua"

local deep_update = update or function() end
local deep_init = init or function() end

function init()
  deep_init()

  self.deep_numrender = {
    baseNumberPath = "/interface/ammo/numberssmall.png",
    charWidth = 0.75,
    alignment = {left = 0, center = 1, right = 2}
  }
  self.deep_barRender = {
    --[[
    test = {
      position = {0,0},
      width = 3,
      inset = 1,
      length = 3,
      bgColor = {20, 20, 30, 200},
      fgColor = {200, 200, 255, 200},
      progress = 0.5,
      empty = false
    }
    --]]
  }

  self.deep_itemStatus = {}

  message.setHandler("deep_changeItemField", function(messageName, isLocalEntity, newStatus)
    self.deep_itemStatus = newStatus
    --self.deep_itemStatus[key] = value
  end)
  message.setHandler("deep_playerAnimatorBarUpdate", function(messageName, isLocalEntity, key, barTable)
    --table.insert(self.deep_barRender, barTable)
    self.deep_barRender[key] = barTable
  end)

end

function update(dt)
  deep_update(dt)
  
  -- the sludge...
  localAnimator.clearDrawables()

  if self.deep_itemStatus.reserveAmmo 
  and self.deep_itemStatus.rAmmoDigits
  and self.deep_itemStatus.rAmmoPos
  and self.deep_itemStatus.rAmmoColor then
    deep_drawNum(
      self.deep_itemStatus.reserveAmmo, 
      self.deep_itemStatus.rAmmoDigits, 
      self.deep_itemStatus.rAmmoPos, 
      self.deep_itemStatus.rAmmoColor, 
      self.deep_numrender.alignment.right
    )
  end

  if self.deep_itemStatus.loadedAmmo 
  and self.deep_itemStatus.lAmmoDigits
  and self.deep_itemStatus.lAmmoPos
  and self.deep_itemStatus.lAmmoColor then
    deep_drawNum(
      self.deep_itemStatus.loadedAmmo, 
      self.deep_itemStatus.lAmmoDigits, 
      self.deep_itemStatus.lAmmoPos, 
      self.deep_itemStatus.lAmmoColor, 
      self.deep_numrender.alignment.right
    )
  end

  --render everything in the table and clear empty items
  for key,barTable in pairs(self.deep_barRender) do 
    if barTable.empty then
      deep_util.removeKey(self.deep_barRender, key)
    else
      deep_barRender(barTable)
    end
  end
end

--draw a number filling empty spaces up to "places" with 0
--eg. 6,3 >> 006,  9,1 >> 9,  349,4 >> 0349
--args: (value, int+, vec2F, color, alignment)
function deep_drawNum(num, places, offset, color, alignment)
  for i=1,places do
    deep_drawDigit(math.floor((num % 10^(i))/10^(i-1)), vec2.add(offset, {
      self.deep_numrender.charWidth/2 + 
      self.deep_numrender.charWidth*(places-i) - 
      (self.deep_numrender.charWidth*(places))/2*alignment, 
      0}), 
      color)
  end
end

--draw a single digit
--args: (single-digit integer, vec2F, color)
function deep_drawDigit(num, offset, color)
  local numberFrame = string.format("%s:%s", self.deep_numrender.baseNumberPath, num)
  localAnimator.addDrawable({
    image = numberFrame,
    position = offset,
    color = color,
    --rotation = angle,
    fullbright = true
  }, "Overlay")
end

function deep_barRender(barTable)
  --position, width, inset, length, bgColor, fgColor, progress, empty
  localAnimator.addDrawable({
    position = barTable.position,
    line = {
      {-barTable.length/2, 0},
      {barTable.length/2, 0}
    },
    width = barTable.width,
    color = barTable.bgColor
  }, "Overlay")
  localAnimator.addDrawable({
    position = barTable.position,
    line = {
      {-barTable.length/2 + (barTable.inset/10), 0},
      {
        -barTable.length/2 + (barTable.inset/10) + 
        (barTable.length/2 - (barTable.inset/10))*2*barTable.progress,
        0
      }
    },
    width = barTable.width - 2*barTable.inset,
    color = barTable.fgColor
  }, "Overlay")
end