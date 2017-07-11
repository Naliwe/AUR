--
-- Created by IntelliJ IDEA.
-- User: naliwe
-- Date: 7/11/17
-- Time: 9:35 PM
-- To change this template use File | Settings | File Templates.
--

local lfs = require "lfs"

Repo = {
    name = "default",
    remote = "default",
    localPath = "default"
}

function Repo:new(other)
    other = other or {}

    setmetatable(other, self)
    self.__index = self

    return other
end

local function _populateRepo(repo)
    print(repo.localPath)
end

function Repo:create()
    if (lfs.attributes(self.localPath) == nil) then
        print('creating folder '..self.localPath)
        print('Confirm ? Y/n')
        local confirm = io.read("*line")

        if (confirm == "n") then
            return
        end

        lfs.mkdir(self.localPath)
    end
end