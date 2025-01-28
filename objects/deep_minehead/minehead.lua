require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/deep_util.lua"

function init(dt)
  object.setInteractive(true)
  self.detectArea = config.getParameter("detectArea")
  --self.detectArea[1] = vec2.add(entity.position(),self.detectArea[1])
  --self.detectArea[2] = vec2.add(entity.position(),self.detectArea[2])
  self.detectArea[1] = object.toAbsolutePosition(self.detectArea[1])
  self.detectArea[2] = object.toAbsolutePosition(self.detectArea[2])
  self.promises = {}
  self.resources = {}
end

function update(dt)
  for i,promise in pairs(self.promises) do
    if promise:finished() then
      if promise:succeeded() then
        local result = promise:result()
        object.say(string.format("Recieved : %s", result))
        self.resources[result] = (self.resources[result] or 0) + 1
        deep_util.print(self.resources)
      else
        local err = promise:error()
        sb.logInfo("Minehead didn't receive a response. Error: %s", err)
      end
      self.promises[i] = nil
    end
  end
  --check if they have the mineheadDeposit tag
  local depositables = world.entityQuery(self.detectArea[1], self.detectArea[2], {
    includedTypes = {"projectile", "vehicle"},
    boundMode = "CollisionArea",
    callScript = "identifyType",
    callScriptArgs = {"mineheadDeposit"},
    callScriptResult = true
  })
  for i,id in pairs(depositables) do
    local pos = world.entityPosition(id)
    if (self.detectArea[1][1] <= pos[1]) and (pos[1] <= self.detectArea[2][1])
    and (self.detectArea[1][2] <= pos[2]) and (pos[2] <= self.detectArea[2][2]) then
      table.insert(self.promises, world.sendEntityMessage(id, "depositableType"))
      object.say(string.format("Sent message to entity : %s", id))
    end
  end
end