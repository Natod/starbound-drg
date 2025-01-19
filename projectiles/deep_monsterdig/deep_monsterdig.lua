require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/deep_util.lua"

function init()
  self.monsterType = config.getParameter("monsterType", "iguarmor")
end

function update(dt)
end

function uninit()
  world.spawnMonster(self.monsterType, entity.position())
end
