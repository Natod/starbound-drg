--require "/scripts/util.lua"

function init()
    self.detectArea = config.getParameter("detectArea")
    self.detectArea[1] = object.toAbsolutePosition(self.detectArea[1])
    self.detectArea[2] = object.toAbsolutePosition(self.detectArea[2])
    self.warped = false
    self.warpTime = config.getParameter("warpTime")
    self.warpCounter = self.warpTime
end

function update(dt)
    if not self.warped then
        local allPlayers = world.entityQuery(object.position(), 100, {includedTypes = {"player"}})
        local inPlayers = world.entityQuery(self.detectArea[1], self.detectArea[2], {
            includedTypes = {"player"},
            boundMode = "CollisionArea"
        })

        -- counter display
        object.say(string.format("%s out of %s : %s", #inPlayers, #allPlayers, math.floor(self.warpCounter+0.9)))
        if #inPlayers > 0 and #inPlayers >= #allPlayers then
            if self.warpCounter <= 0 then
                -- warp players when counter is 0
                for i,inPlayer in ipairs(inPlayers) do
                    world.sendEntityMessage(inPlayer, "warp", "InstanceWorld:testmission1")
                end
                self.warped = true
            else
                self.warpCounter = self.warpCounter-(1*dt)
            end
        else
            self.warpCounter = self.warpTime
        end
    end
end
