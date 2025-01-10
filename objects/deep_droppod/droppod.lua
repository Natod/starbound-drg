--require "/scripts/util.lua"

function init()
    self.detectArea = config.getParameter("detectArea")
    self.detectArea[1] = object.toAbsolutePosition(self.detectArea[1])
    self.detectArea[2] = object.toAbsolutePosition(self.detectArea[2])
end

function update(dt)
    local allPlayers = world.entityQuery(object.position(), 100, {includedTypes = {"player"}})
    local inPlayers = world.entityQuery(self.detectArea[1], self.detectArea[2], {
        includedTypes = {"player"},
        boundMode = "CollisionArea"
    })

    object.say(string.format("%s out of %s", #inPlayers, #allPlayers))
    if #inPlayers >= #allPlayers then
        --for i,inPlayer in ipairs(inPlayers) do world.sendEntityMessage(Variant<EntityId, String> entityId, String messageType, [LuaValue args ...]) end
    end
end