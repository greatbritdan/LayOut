local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")

-----------------------------------------------------------------

local Group = Class("LayOut_Group")

function Group:initialize(instance)
    self.i = instance

    self.active = true
    self.children = {}
end

function Group:Update(dt)
    if not self.active then return end
    self:ForEachChildRev(function(v) v:Update(dt) end)
end

function Group:Draw(debug)
    if not self.active then return end
    self:ForEachChild(function(v) v:Draw() end)
    if debug then self:ForEachChild(function(v) v:DrawDebug() end) end
end

function Group:Mousepressed()
    if not self.active then return end
    self:ForEachChildRev(function(v) v:Mousepressed() end)
end
function Group:Mousereleased()
    if not self.active then return end
    self:ForEachChildRev(function(v) v:Mousereleased() end)
end
function Group:Wheelmoved(sx,sy)
    if not self.active then return end
    self:ForEachChildRev(function(v) v:Wheelmoved(sx,sy) end)
end

function Group:Keypressed(key)
    if not self.active then return end
    self:ForEachChildRev(function(v) v:Keypressed(key) end)
end
function Group:Textinput(text)
    if not self.active then return end
    self:ForEachChildRev(function(v) v:Textinput(text) end)
end

------------------------------------------------------------------

function Group:Add(child)
    table.insert(self.children,child); child.g = self
    return self
end
function Group:ForEachChild(func)
    if #self.children == 0 then return end
    for i = 1, #self.children do func(self.children[i]) end
end
function Group:ForEachChildRev(func)
    if #self.children == 0 then return end
    for i = #self.children, 1, -1 do func(self.children[i]) end
end

function Group:PopAndPush(element)
    local idx = Utils.TableContains(self.children,element)
    table.remove(self.children, idx)
    table.insert(self.children, element)
end

------------------------------------------------------------------

function Group:Enable() self.active = true; return self end
function Group:Disable() self.active = false; return self end

return Group