--require "/scripts/util.lua"

function init()
    self.detectArea = config.getParameter("detectArea")
    self.detectArea[1] = object.toAbsolutePosition(self.detectArea[1])
    self.detectArea[2] = object.toAbsolutePosition(self.detectArea[2])
    self.warped = false
    self.warpTime = config.getParameter("warpTime")
    self.warpCounter = self.warpTime

    self.type = {drop = "drop", retrieval = "retrieval", arrival = "arrival"}
    self.drop = config.getParameter("dropType")
    if self.drop == self.type.drop then
        local music = config.getParameter("ambientMusic")
        local allPlayers = world.players()
        for i,playerId in ipairs(allPlayers) do
            world.sendEntityMessage(playerId, "playAltMusic", music)
        end
    end
end

function update(dt)
    if not self.warped then
        local allPlayers = world.players()
        local inPlayers = world.entityQuery(self.detectArea[1], self.detectArea[2], {
            includedTypes = {"player"},
            boundMode = "CollisionArea"
        })

        -- counter display
        object.say(string.format("%s %s out of %s : %s", self.drop, #inPlayers, #allPlayers, math.floor(self.warpCounter+0.9)))

        if self.drop == self.type.arrival then
            if #inPlayers == 0 then
                if self.warpCounter <= 0 then
                    object.smash(true)
                    self.warped = true
                else
                    self.warpCounter = self.warpCounter-(1*dt)
                end
            else
                self.warpCounter = self.warpTime
            end
        else
            if #inPlayers > 0 and #inPlayers >= #allPlayers then
                if self.warpCounter <= 0 then
                    -- warp players when counter is 0
                    for i,inPlayer in ipairs(inPlayers) do
                        if self.drop == self.type.drop then
                            world.sendEntityMessage(inPlayer, "warp", "InstanceWorld:testmission1")
                        else
                            world.sendEntityMessage(inPlayer, "warp", "Return")
                        end
                        self.warped = true
                    end
                else
                    self.warpCounter = self.warpCounter-(1*dt)
                end
            else
                self.warpCounter = self.warpTime
            end
        end
    end
end
