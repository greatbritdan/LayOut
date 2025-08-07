local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")

-----------------------------------------------------------------

local Base = Class("LayOut_Base")

function Base:initialize(instance,transform,args)
    args = args or {}
    self.args = args
    if not self.type then self.type = LAYOUT_TYPES.BASE end
    if args.tag then self.tag = args.tag end
    self.i = instance -- instance
    self.t = Utils.Transform(transform) -- transform

    if LAYOUT_SETTINGS.randomstyle then
        self.i:RandomStyle()
    end
    self.s = instance.style -- style

    self.visible = true
    self.active = true
    self.children = {}
    self.siblings = {}

    self.tooltip, self.tooltipmode = nil, "hover"
end
function Base:InitializeElement(disable)
    if (not disable) or (not disable.style) then
        self.ax = self.newax or self.s:GetStyleData(self,"alignx",nil,LAYOUT_ALIGNHOR.MIDDLE)
        self.ay = self.neway or self.s:GetStyleData(self,"aligny",nil,LAYOUT_ALIGNHOR.MIDDLE)
        self.mx = self.new or self.args.mx or self.s:GetStyleData(self,"marginx","margin",0)
        self.my = self.new or self.args.my or self.s:GetStyleData(self,"marginy","margin",0)
        self.sx = self.new or self.args.sx or self.s:GetStyleData(self,"spacingx","spacing",0)
        self.sy = self.new or self.args.sy or self.s:GetStyleData(self,"spacingy","spacing",0)
    end
    if self.BaseInitializeElement and ((not disable) or (not disable.base)) then
        self:BaseInitializeElement()
    end
    if (not disable) or (not disable.children) then
        self:ForEachSiblingRev(function(v) v:InitializeElement() end)
        self:ForEachChildRev(function(v) v:InitializeElement() end)
    end
end
function Base:Modified()
    self:ForEachSiblingRev(function(v) v:Modified() end)
    self:ForEachChildRev(function(v) v.t.x, v.t.y, v.t.w, v.t.h = self.t.x, self.t.y, self.t.w, self.t.h; v:Modified() end)
    self:InitializeElement()
end

function Base:Update(dt,hoverparent)
    if not self:IsActive() then return end
    self:ForEachSiblingRev(function(v) v:Update(dt) end)
    local mx,my = Utils.GetMouse(self)
    self.hovering = false
    if (not Utils.IsCosmetic(self)) and ((not self.parent) or (self.parent and hoverparent)) then
        if (not self.i.hover) and self:PointInsideInteraction(mx,my) then
            self.i:SetHover(self)
        end
        self.hovering = self.i.hover == self and self:PointInsideBase(mx,my)
    end
    self:BaseUpdate(dt)
    self:ForEachChildRev(function(v) v:Update(dt,self:PointInsideBase(mx,my)) end)
    if (not self.i.hover) and self:PointInsideBase(mx,my) then
        self.i.hover = {}
    end
end
function Base:BaseUpdate(dt)
end

function Base:Draw()
    if not self:IsVisible() then return end
    self:BaseDraw()
    self:ForEachSibling(function(v) v:Draw() end)
    self:ForEachChild(function(v) v:Draw() end)
end
function Base:BaseDraw()
end
function Base:DrawDebug()
    if not self:IsVisible() then return end
    love.graphics.setColor(1,0,0,0.5)
    love.graphics.rectangle("line", self.t.x, self.t.y, self.t.w, self.t.h)
    love.graphics.setColor(0,1,0,0.5)
    local x,y,w,h = self:GetContentBounds()
    if x then love.graphics.rectangle("line", x, y, w, h) end
    self:ForEachSibling(function(v) v:DrawDebug() end)
    self:ForEachChild(function(v) v:DrawDebug() end)
    if self._isFocused then
        love.graphics.setColor(1,0.5,0,0.5)
        love.graphics.rectangle("fill", self.t.x, self.t.y, self.t.w, self.t.h)
    end
end

function Base:Mousepressed()
    if not self:IsActive() then return end
    self:ForEachSiblingRev(function(v) v:Mousepressed() end)
    if self.hovering then
        self.pressing = true
        if (not Utils.IsCosmetic(self)) and (not self.i.focus) then self.i:SetFocus(self) end
        if self.Click then self:Click() end
    end
    self:ForEachChildRev(function(v) v:Mousepressed() end)
end
function Base:Mousereleased()
    if not self:IsActive() then return end
    self:ForEachSiblingRev(function(v) v:Mousereleased() end)
    if self.hovering and self.pressing then
        if self.Release then self:Release() end
    end
    self.pressing = false
    self:ForEachChildRev(function(v) v:Mousereleased() end)
end
function Base:Wheelmoved(sx,sy)
    if not self:IsActive() then return end
    local mx,my = Utils.GetMouse(self)
    if (self.type == LAYOUT_TYPES.PANEL and self:PointInsideBase(mx,my)) or self.hovering then
        if self.Scroll then self:Scroll(sx,sy) end
    end
    self:ForEachChildRev(function(v) v:Wheelmoved(sx,sy) end)
end

function Base:Keypressed(key)
    if not self:IsActive() then return end
    if self._isFocused then
        if self.Input then self:Input(key) end
    end
    self:ForEachChildRev(function(v) v:Keypressed(key) end)
end
function Base:Textinput(text)
    if not self:IsActive() then return end
    if self._isFocused then
        if self.InputText then self:InputText(text) end
    end
    self:ForEachChildRev(function(v) v:Textinput(text) end)
end

------------------------------------------------------------------

function Base:GetHost()
    if self.parent then return self.parent:GetHost() end
    return self
end

function Base:Add(child)
    table.insert(self.children,child); child.parent = self
    if self.g then child.g = self.g end
    self:Modified()
    return self
end
function Base:ForEachChild(func)
    if #self.children == 0 then return end
    for i = 1, #self.children do func(self.children[i]) end
end
function Base:ForEachChildRev(func)
    if #self.children == 0 then return end
    for i = #self.children, 1, -1 do func(self.children[i]) end
end
function Base:ForEachSibling(func)
    if #self.siblings == 0 then return end
    for i = 1, #self.siblings do func(self.siblings[i]) end
end
function Base:ForEachSiblingRev(func)
    if #self.siblings == 0 then return end
    for i = #self.siblings, 1, -1 do func(self.siblings[i]) end
end

function Base:PointInsideBase(x,y)
    return self:PointInsideInteraction(x,y)
end
function Base:PointInsideInteraction(x,y)
    return (x > 0 and y > 0 and x < self.t.w and y < self.t.h)
end

function Base:GetContentBounds() return false end
function Base:GetValue() return nil end

-----------------------------------------------------------------

function Base:Left() self.newax = LAYOUT_ALIGNHOR.LEFT; self.ax = self.newax; return self end
function Base:Middle() self.newax = LAYOUT_ALIGNHOR.MIDDLE; self.ax = self.newax; return self end
function Base:Right() self.newax = LAYOUT_ALIGNHOR.RIGHT; self.ax = self.newax; return self end

function Base:Top() self.neway = LAYOUT_ALIGNVER.TOP; self.ay = self.neway; return self end
function Base:Center() self.neway = LAYOUT_ALIGNVER.CENTER; self.ay = self.neway; return self end
function Base:Bottom() self.neway = LAYOUT_ALIGNVER.BOTTOM; self.ay = self.neway; return self end

function Base:SetCallback(callback) self.callback = callback; return self end
function Base:SetTooltip(tooltip) self.tooltip = tooltip; return self end
function Base:SetTooltipMode(mode) self.tooltipmode = mode; return self end -- hover, focus

function Base:Show() self.visible = true; return self end
function Base:Hide() self.visible = false; return self end
function Base:IsVisible(forchild)
    if self.parent then return self.parent:IsVisible(true) end
    if forchild and self.childvisible ~= nil then return self.childvisible end
    return self.visible
end

function Base:Enable() self.active = true; return self end
function Base:Disable() self.active = false; return self end
function Base:IsActive(forchild)
    if self.parent then return self.parent:IsActive(true) end
    if forchild and self.childactive ~= nil then return self.childactive end
    return self.active
end

function Base:Link(tag) self.linked = tag; return self end
function Base:GetLinked()
    if not self.linked then return nil end
    local elements = self.i:Find(self.linked)
    if elements and #elements > 0 then return elements[1] end
    return nil
end

return Base