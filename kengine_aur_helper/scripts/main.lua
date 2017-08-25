#!    /usr/bin/env lua

--
-- Created by IntelliJ IDEA.
-- User: naliwe
-- Date: 7/11/17
-- Time: 9:23 PM
-- To change this template use File | Settings | File Templates.
--
--

local lfs = require "lfs"
local argparse = require "argparse"
local parser = argparse()
local savePath = lfs.currentdir()

parser:argument("localPath", "The location you want the repo to be created at"):default(savePath)
parser:argument("remoteDir", "The engine folder name"):default "engine"

parser:option "--tmp":default "/tmp/kengine_helper"
parser:option "-n --name":default "example"
parser:flag("-s --submodule"):description "Should I install the engine as a git submodule ?":default(false)

parser:mutex(parser:option("-c --cache", "Where you want me to cache deps"):default(os.getenv("HOME") .. "/.config/kengine_helper"),
    parser:flag("--no-cache", "Do not cache deps"):default(false))

local args = parser:parse()
local attr = lfs.symlinkattributes(arg[0])
local linkTarget = lfs.symlinkattributes(arg[0], "target")
local index = 0

if (attr ~= nil) then
    if (attr.mode == "link") then
        index = string.find(attr.target, "/[^/]*$")
        lfs.chdir(string.sub(attr.target, 0, index))
    else
        index = string.find(arg[0], "/[^/]*$")
        lfs.chdir(string.sub(arg[0], 0, index))
    end
end


require "classes.repository"

local path = ""

if (args.localPath ~= nil) then
    if (string.find(args.localPath, "/") == nil) then
        path = savePath .. "/" .. args.localPath
    else
        path = args.localPath
    end
end

r = Repo:new({
    remote = "git@github.com:Phiste/kengine.git",
    remoteDir = args.remoteDir,
    localPath = path,
    tmpDir = args.tmp,
    cached = not args.nocache,
    cacheDir = args.cache,
    submodule = args.submodule,
    branch = "kengine_aur",
    postCreate = function()
        os.execute("cp -r " .. r.localPath .. '/' .. r.remoteDir .. "/aur_utils/* " .. r.localPath)
        local pos = 0
        local cmakelistsPath = r.localPath .. '/' .. "CMakeLists.txt"
        local cmakeLines = "set(project_name " .. args.name .. ")\nset(engine_dir " .. r.remoteDir .. ")"

        for line in io.lines(cmakelistsPath) do
            pos = pos + string.len(line)
            if (line == "# helper_placeholder") then
                break
            end
        end

        local handle = io.open(cmakelistsPath)
        handle:seek("set", pos)
        handle:write(cmakeLines)
        io.close(handle)
    end
})
r:create()
