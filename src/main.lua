package.cpath = package.cpath .. ";./luaclib/?.so"
package.path = package.path .. ";./src/?.lua"

local sparser = require "sproto2table"
require "functions"

local filename = "./input/both.sproto"
local outputfilename = "./output/both.lua"

local f = io.open(filename,"rb")
local buf = f:read("*a")
f:close()

local protoTab = sparser.parse(buf, filename)

f = io.open(outputfilename, "wb")
f:write(dumpTable(protoTab))
f:close()

return protoTab