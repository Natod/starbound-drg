require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/status.lua"

deep_util = {}

function deep_util.print(data)
  sb.logInfo(sb.print(data))
end

function deep_util.isInTable(query, table)
  for _,value in pairs(table) do
    if value == query then
      return true
    end
  end
  return false
end

function deep_util.removeKey(table, key)
  local val = table[key]
  table[key] = nil
  return val
end