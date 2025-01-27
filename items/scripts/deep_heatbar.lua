require "/scripts/vec2.lua"

function init()
  self.barParams = config.getParameter("heatBar")
  self.maxHeat = config.getParameter("maxHeat", 20)
  self.heat = 0
  self.overheated = false
end

function update(dt)
  localAnimator.clearDrawables()

  self.heat = animationConfig.animationParameter("heat")
  if self.heat <= 0 then
    return
  end
  self.overheated = animationConfig.animationParameter("overheated")
  local position = activeItemAnimation.ownerPosition()
  local heatRatio = self.heat/self.maxHeat

  if not self.overheated then
    self.barParams.color = {
      200 + 55*(heatRatio)^2, 
      200 - 100*(heatRatio)^2, 
      200 - 100*(heatRatio)^2, 
      200
    }
  else
    self.barParams.color = {
      255, 
      100,
      100, 
      200
    }
  end
  
  localAnimator.addDrawable({
      position = vec2.add(position,self.barParams.offset),
      line = {
        {-self.barParams.length/2, 0}, 
        {self.barParams.length/2, 0}
      },
      width = self.barParams.width,
      color = self.barParams.bgColor
    }, "Overlay")

  localAnimator.addDrawable({
      position = vec2.add(position, self.barParams.offset),
      line = {
        {-self.barParams.length/2 + (self.barParams.inset/10), 0}, 
        {
          -self.barParams.length/2 + (self.barParams.inset/10) + 
          (self.barParams.length/2 - (self.barParams.inset/10))*2*heatRatio ,
          0
        }
      },
      width = self.barParams.width - 2*self.barParams.inset,
      color = self.barParams.color
    }, "Overlay")
end
