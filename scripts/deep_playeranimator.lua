require "/scripts/vec2.lua"

local deep_update = update or function() end
local deep_init = init or function() end

function init()
  deep_init()
  self.deep_numrender = {
    baseNumberPath = "/interface/ammo/numberssmall.png",
    charWidth = 0.75,
    alignment = {left = 0, center = 1, right = 2}
  }
  --self.baseNumberPath  --> self.deep_numrender.baseNumberPath
  --self.charWidth       --> self.deep_numrender.charWidth
  --self.alignment       --> self.deep_numrender.alignment
  self.deep_itemStatus = {}

  message.setHandler("deep_changeItemField", function(messageName, isLocalEntity, newStatus) --key, value
    self.deep_itemStatus = newStatus
    --self.deep_itemStatus[key] = value
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
    drawNum(
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
    drawNum(
      self.deep_itemStatus.loadedAmmo, 
      self.deep_itemStatus.lAmmoDigits, 
      self.deep_itemStatus.lAmmoPos, 
      self.deep_itemStatus.lAmmoColor, 
      self.deep_numrender.alignment.right
    )
  end


end

--draw a number filling empty spaces up to "places" with 0
--eg. 6,3 >> 006,  9,1 >> 9,  349,4 >> 0349
--args: (value, int+, vec2F, color, alignment)
function drawNum(num, places, offset, color, alignment)
  for i=1,places do
    drawDigit(math.floor((num % 10^(i))/10^(i-1)), vec2.add(offset, {
      self.deep_numrender.charWidth/2 + 
      self.deep_numrender.charWidth*(places-i) - 
      (self.deep_numrender.charWidth*(places))/2*alignment, 
      0}), 
      color)
  end
end

--draw a single digit
--args: (single-digit integer, vec2F, color)
function drawDigit(num, offset, color)
  local numberFrame = string.format("%s:%s", self.deep_numrender.baseNumberPath, num)
  localAnimator.addDrawable({
    image = numberFrame,
    position = offset,
    color = color,
    --rotation = angle,
    fullbright = true
  }, "Overlay")
end