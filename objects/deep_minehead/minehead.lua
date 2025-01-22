require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/deep_util.lua"

function init(dt)
  object.setInteractive(true)
  self.detectArea = config.getParameter("detectArea")
  self.detectArea[1] = object.toAbsolutePosition(self.detectArea[1])
  self.detectArea[2] = object.toAbsolutePosition(self.detectArea[2])
  self.aquarqCount = 0
end

function update(dt)
  --check if they have the mineheadDeposit tag
  local depositables = world.entityQuery(self.detectArea[1], self.detectArea[2], {
    includedTypes = {"projectile", "vehicle"},
    boundMode = "CollisionArea",
    callScript = "identifyType",
    callScriptArgs = {"mineheadDeposit"},
    callScriptResult = true
  })
  --[[
  for i,item in pairs(depositables) do 

  end
  ]]
end


