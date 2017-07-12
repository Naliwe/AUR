--
-- Created by IntelliJ IDEA.
-- User: naliwe
-- Date: 7/11/17
-- Time: 9:35 PM
-- To change this template use File | Settings | File Templates.
--

local lfs = require "lfs"

Repo = {
    remoteDir = "",
    remote = "default",
    localPath = "default",
    tmpDir = "/tmp/kengine_helper",
    submodule = false,
    cached = true,
    cachedDir = tmpDir,
    branch = "master",
    postCreate = function()
        print('Initial setup finished.')
    end
}

function Repo:new(other)
    other = other or {}

    setmetatable(other, self)
    self.__index = self

    return other
end

local function _createTmpDir(repo)
    if (lfs.attributes(repo.tmpDir) == nil) then
        lfs.mkdir(repo.tmpDir)
    end
end

local function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

local matchers =
Set { ".git", ".gitignore", ".gitmodules", ".idea" }

local function _delGitFiles(path)
    for file in lfs.dir(path) do
        if (matchers[file]) then
            os.execute("rm -rf " .. path .. '/' .. file)
        else
            if file ~= "." and file ~= ".." then
                local f = path .. '/' .. file
                local attr = lfs.attributes(f)

                if attr.mode == "directory" then
                    _delGitFiles(f)
                end
            end
        end
    end
end

local function _populateRepo(repo)
    print(repo.localPath)

    _createTmpDir(repo)

    if (lfs.attributes(repo.cacheDir) ~= nil) then
        os.execute("cp -r " .. repo.cacheDir .. "/" .. repo.remoteDir .. " " .. repo.localPath)
        return
    end

    os.execute("git clone " .. repo.remote .. " " .. repo.tmpDir .. "/" .. repo.remoteDir .. " --recursive")

    local tmp = lfs.currentdir()
    lfs.chdir(repo.tmpDir .. "/" .. repo.remoteDir)

    os.execute("git checkout " .. repo.branch)

    if (not repo.submodule) then
        _delGitFiles(lfs.currentdir())
    end

    lfs.chdir(tmp)

    if (repo.cached and repo.cacheDir ~= repo.tmpDir) then
        if (lfs.attributes(repo.cacheDir) == nil) then
            lfs.mkdir(repo.cacheDir)
        end
        os.execute("cp -r " .. repo.tmpDir .. "/" .. repo.remoteDir .. " " .. repo.cacheDir)
    end

    os.execute("cp -r " .. repo.tmpDir .. "/" .. repo.remoteDir .. " " .. repo.localPath)
end

function Repo:create()
    if (lfs.attributes(self.localPath) == nil) then
        print('creating folder ' .. self.localPath)
        print('Confirm ? Y/n')
        local confirm = io.read("*line")

        if (confirm == "n") then
            return
        end

        lfs.mkdir(self.localPath)
    end

    _populateRepo(self)

    self.postCreate()
end