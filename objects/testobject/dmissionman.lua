require "/scripts/util.lua"

function init()
    world.loadUniqueEntity("missionmanager")
    world.spawnItem("testobject", object.position())
    sb.logInfo("the dmissionman worked at least")
end

function update(dt)
end
