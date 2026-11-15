-- Run from anywhere: lua test/smoke/00_logging.lua
-- An invalid charging station is skipped with a Kora.logging.warn (event + context in fields), never print.
-- Named 00_ so it runs first under test/run.sh.
local scriptDir = debug.getinfo(1, 'S').source:match('@?(.*/)') or './'
local repoRoot = scriptDir .. '../../'
local calls = {}
_G.Kora = { logging = { warn = function(event, message, fields)
    calls[#calls + 1] = { level = 'warn', event = event, message = message, fields = fields }
    return true
end } }
_G.Fuel = nil
local realPrint = print
_G.print = function() error('stations.lua must log through Kora.logging, not print') end
dofile(repoRoot .. 'shared/stations.lua')
local out = Fuel.normalizeChargingStations({ { label = 'Broken station' } })
_G.print = realPrint
assert(#out == 0, 'the invalid station is skipped')
local call = assert(calls[1], 'a logger call was made')
assert(call.level == 'warn' and call.event == 'stations.charging_station_skipped', 'stable warn event name')
assert(call.fields.index == 1 and call.fields.field ~= nil and call.fields.reason ~= nil, 'skip context travels in fields')
print('kora_fuel: skipped charging station is logged through Kora.logging')
