function init()
    --object.setInteractive(true)
end

function onInteraction(args)
    return { "OpenTeleportDialog", {
        canBookmark = false,
        includePlayerBookmarks = false,
        destinations = {
            {
            name = "Useless Let-down",
            planetName = "Sandblasted Corridors",
            icon = "default",
            warpAction = "InstanceWorld:testmission1"
            },
            {
            name = "Awful Rock",
            planetName = "Salt Pits",
            icon = "default",
            warpAction = "InstanceWorld:testmission1"
            }
        }
    } }
end