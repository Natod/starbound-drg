require "/scripts/vec2.lua"

local deep_update = update or function() end
local deep_init = init or function() end
local deep_uninit = uninit or function() end

function init()
  deep_init()


end

function update()
  deep_update()


end

function uninit()
  deep_uninit()

  
end