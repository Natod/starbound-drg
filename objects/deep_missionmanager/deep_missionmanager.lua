require "/scripts/util.lua"

function init()
    world.loadUniqueEntity("missionmanager") -- loads missionmanager stagehand
    sb.logInfo("the dmissionman worked at least")
    object.smash(true)
end

function update(dt)
end
