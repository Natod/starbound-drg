--require "/scripts/util.lua"

function init()
    self.detectArea = config.getParameter("detectArea")
    self.detectArea[1] = object.toAbsolutePosition(self.detectArea[1])
    self.detectArea[2] = object.toAbsolutePosition(self.detectArea[2])
    self.warped = false
end

function update(dt)
    if not self.warped then
        local allPlayers = world.entityQuery(object.position(), 100, {includedTypes = {"player"}})
        local inPlayers = world.entityQuery(self.detectArea[1], self.detectArea[2], {
            includedTypes = {"player"},
            boundMode = "CollisionArea"
        })

        object.say(string.format("%s out of %s", #inPlayers, #allPlayers))
        if #inPlayers > 0 and #inPlayers >= #allPlayers then
            for i,inPlayer in ipairs(inPlayers) do world.sendEntityMessage(inPlayer, "warp", "InstanceWorld:testmission1") end
            self.warped = true
        end
    end
end