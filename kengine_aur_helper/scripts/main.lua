--
-- Created by IntelliJ IDEA.
-- User: naliwe
-- Date: 7/11/17
-- Time: 9:23 PM
-- To change this template use File | Settings | File Templates.
--

local lfs = require "lfs"

local defaultPath = lfs.currentdir()
local index = string.find(arg[0], "/[^/]*$")

lfs.chdir(string.sub(arg[0], 0, index))

require "classes.repository"

local path = ""

if (arg[1] ~= nil) then
    if (string.find(arg[1], "/") == nil) then
        path = defaultPath .. "/" .. arg[1]
    else
        path = arg[1]
    end
else
    path = defaultPath;
end

r = Repo:new({ localPath = path })
r:create()
