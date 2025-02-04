require "/scripts/vec2.lua"

local deep_update = update or function() end
local deep_init = init or function() end

function init()
  deep_init()
  self.baseNumberPath = "/interface/ammo/numberssmall.png"
  self.charWidth = 0.75
  self.alignment = {left = 0, center = 1, right = 2}
  self.itemStatus = {}

  message.setHandler("deep_changeItemField", function(messageName, isLocalEntity, newStatus) --key, value
    self.itemStatus = newStatus
    --self.itemStatus[key] = value
  end)

end

function update(dt)
  deep_update(dt)
  

  -- the sludge...
  localAnimator.clearDrawables()

  if self.itemStatus.reserveAmmo 
  and self.itemStatus.rAmmoDigits
  and self.itemStatus.rAmmoPos
  and self.itemStatus.rAmmoColor then
    drawNum(
      self.itemStatus.reserveAmmo, 
      self.itemStatus.rAmmoDigits, 
      self.itemStatus.rAmmoPos, 
      self.itemStatus.rAmmoColor, 
      self.alignment.right
    )
  end

  if self.itemStatus.loadedAmmo 
  and self.itemStatus.lAmmoDigits
  and self.itemStatus.lAmmoPos
  and self.itemStatus.lAmmoColor then
    drawNum(
      self.itemStatus.loadedAmmo, 
      self.itemStatus.lAmmoDigits, 
      self.itemStatus.lAmmoPos, 
      self.itemStatus.lAmmoColor, 
      self.alignment.right
    )
  end


end

--draw a number filling empty spaces up to "places" with 0
--eg. 6,3 >> 006,  9,1 >> 9,  349,4 >> 0349
--args: (value, int+, vec2F, color, alignment)
function drawNum(num, places, offset, color, alignment)
  for i=1,places do
    drawDigit(math.floor((num % 10^(i))/10^(i-1)), vec2.add(offset, {
      self.charWidth/2 + 
      self.charWidth*(places-i) - 
      (self.charWidth*(places))/2*alignment, 
      0}), 
      color)
  end
end

--draw a single digit
--args: (single-digit integer, vec2F, color)
function drawDigit(num, offset, color)
  local numberFrame = string.format("%s:%s", self.baseNumberPath, num)
  localAnimator.addDrawable({
    image = numberFrame,
    position = offset,
    color = color,
    --rotation = angle,
    fullbright = true
  }, "Overlay")
end