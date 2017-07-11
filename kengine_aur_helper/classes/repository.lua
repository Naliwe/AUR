--
-- Created by IntelliJ IDEA.
-- User: naliwe
-- Date: 7/11/17
-- Time: 9:35 PM
-- To change this template use File | Settings | File Templates.
--

Repo = {
    remote = "default"
}

function Repo:new(other)
    other = other or {}
    setmetatable(other, self)
    self.__index = self
    return other
end

