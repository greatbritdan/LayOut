local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")
local Base = require(LAYOUT_REQUIREPATH..".Elements.Base")
local Layout = require(LAYOUT_REQUIREPATH..".Elements.Layout")
local Label = require(LAYOUT_REQUIREPATH..".Elements.Label")

-----------------------------------------------------------------

local Panel = Class("LayOut_Panel",Layout)

function Panel:initialize(instance,transform,args,parent)
    args = args or {}
    self.type = LAYOUT_TYPES.PANEL
    Base.initialize(self,instance,transform,args,parent)

    self.layoutat = {anchor="tl",direction="h"}
    self.layout = {}

    self.initstage = "start"; self:InitializeElement({children=true})

    self.moveable = true
    if args.moveable == false then self.moveable = false end
    self.collapsable = args.collapsable or false
    self.scrollable = args.scrollable or false

    self.titlebarsize = args.titlebarheight or (self.my*2)+self.font:getHeight()
    self.title = args[1] or args.title or "no title"
    if self.collapsable then
        self.siblings[1] = self.i:Button({self.t.x+self.t.w-self.titlebarsize, self.t.y, self.titlebarsize, self.titlebarsize},{mx=0,my=0}):SetCallback(function(button)
            button._panelparent:Collapse()
        end):Add(self.i:Label(nil,{"-",mx=0,my=0}):Middle():Center())
        self.siblings[1]._panelparent = self
    end
    self:UpdateTitlebar()

    self.dragging = false
    self.collapsed = false

    self.scrolly, self.scrollh = 0, args.scrollheight or self.t.h*2
    self.scrollymax = self.scrollh-self.t.h
    self.scrollbarwidth = args.scrollbarwidth or (self.titlebarsize/2)
    self.scrollbarheight = (self.t.h-self.titlebarsize)*(self.t.h/self.scrollh)
    self.scrollbargap = (self.t.h-self.titlebarsize) - self.scrollbarheight
    self.scrollopacity = 0
    self.scrollspeed = args.scrollspeed or 10
    self.scrollwheninside = true

    self.layoutboundsoffset = {x=0, y=self.titlebarsize, w=0, h=(self.scrollh-self.t.h-self.titlebarsize)}
    self.layoutscrolloffset = {x=0, y=0}

    self.initstage = "end"; self:InitializeElement({style=true,children=true})
end
function Panel:BaseInitializeElement()
    if self.initstage == "start" then
        self.font = self.s:GetStyleData(self,"font",nil,nil)
        return
    end

    self.panel = Utils.GenerateElement({"base"},self,self.t)
    self.panelbar = Utils.GenerateElement({"titlebar","base"},self,self.titlebar)
    local scrollt = {x=self.t.x+self.t.w-self.scrollbarwidth, y=(self.t.y+self.titlebarsize)+(self.scrollbargap*(self.scrolly/self.scrollymax)), w=self.scrollbarwidth, h=self.scrollbarheight}
    self.scrollg = Utils.GenerateElement({"scroll","cosmetic"},self,scrollt)
    self.labelg = Utils.GenerateElement({"cosmetic"},self,self.t)

    if self.collapsable then self.siblings[1]:InitializeElement() end
    self:Calculate()
end

function Panel:BaseUpdate(dt)
    if self.scrollopacity > 0 then
        self.scrollopacity = self.scrollopacity - (dt*2)
        if self.scrollopacity <= 0 then
            self.scrollopacity = 0
        end
    end

    if not self.moveable then return end
    if self.pressing and (not self.dragging) then
        local mx, my = Utils.GetMouse(self)
        self.dragging = {x=mx, y=my}
    elseif self.pressing and self.dragging then
        local mx, my = Utils.GetMouse(self,true)
        self.t.x = mx-self.dragging.x
        self.t.y = my-self.dragging.y
        self:UpdateTitlebar()
        self:Calculate()
    elseif self.dragging then
        self.dragging = false
    end
end

function Panel:Draw()
    if not self:IsVisible() then return end
    self:BaseDraw()
    self:ForEachSibling(function(v) v:Draw() end)
    love.graphics.setScissor(
        self.t.x*LAYOUT_SETTINGS.scale, (self.t.y+self.titlebarsize)*LAYOUT_SETTINGS.scale,
        self.t.w*LAYOUT_SETTINGS.scale, (self.t.h-self.titlebarsize)*LAYOUT_SETTINGS.scale
    )
    self:ForEachChild(function(v) v:Draw() end)
    love.graphics.setScissor()
end
function Panel:BaseDraw()
    if not self.collapsed then
        Utils.DrawBase(self,self.t,LAYOUT_STATES.FOCUS,self.panel)
    end
    Utils.DrawBase(self,self.titlebar,Utils.GetState(self),self.panelbar)
    Utils.DrawText(self,self.titlebar,Utils.GetState(self),self.labelg,self.title)
    if self.scrollopacity > 0 then
        local scrollt = {x=self.t.x+self.t.w-self.scrollbarwidth, y=(self.t.y+self.titlebarsize)+(self.scrollbargap*(self.scrolly/self.scrollymax)), w=self.scrollbarwidth, h=self.scrollbarheight}
        Utils.DrawBase(self,scrollt,LAYOUT_STATES.BASE,self.scrollg,self.scrollopacity)
    end
end

function Panel:Click()
    if self.g then self.g:PopAndPush(self) end
end

function Panel:Collapse()
    self.collapsed = not self.collapsed
    if self.collapsed then
        self.siblings[1].children[1].label = "o"
        self.childactive, self.childvisible = false, false
    else
        self.siblings[1].children[1].label = "-"
        self.childactive, self.childvisible = nil, nil
    end
end

function Panel:Scroll(sx,sy)
    if self.scrollable and (not self.collapsed) then
        self.scrolly = self.scrolly - (sy*self.scrollspeed)
        self.scrolly = math.max(0,math.min(self.scrolly,self.scrollymax))
        self:UpdateScrollOffset()
    end
end

-----------------------------------------------------------------

function Panel:UpdateTitlebar()
    if self.collapsable then
        self.titlebar = {x=self.t.x, y=self.t.y, w=self.t.w-self.titlebarsize, h=self.titlebarsize}
        self.siblings[1].t = {x=self.t.x+self.t.w-self.titlebarsize, y=self.t.y, w=self.titlebarsize, h=self.titlebarsize}
        self.siblings[1]:Modified()
    else
        self.titlebar = {x=self.t.x, y=self.t.y, w=self.t.w, h=self.titlebarsize}
    end
end

function Panel:UpdateScrollOffset()
    self.layoutscrolloffset.y = -self.scrolly
    self:Calculate(true)
    self.scrollopacity = 1.25
end

function Panel:PointInsideBase(x,y)
    if self.collapsed then
        return self:PointInsideInteraction(x,y)
    end
    return (x > 0 and y > 0 and x < self.t.w and y < self.t.h)
end
function Panel:PointInsideInteraction(x,y)
    return (x > 0 and y > 0 and x < self.titlebar.w and y < self.titlebar.h)
end

function Panel:GetContentBounds(transform,label)
    transform, label = transform or self.titlebar, label or self.title
    local scale = self.s:GetStyleData(self,"fontscale",nil,1)
    local w,h = (self.font:getWidth(label)-1)*scale, (Utils.LineCount(self.font,label,transform.w,self.mx)*self.font:getHeight())*scale
    local x,y = Utils.GetAllignX(transform.x, transform.w, w, self.ax, self.mx), Utils.GetAllignY(transform.y, transform.h, h, self.ay, self.my)
    return x,y,w,h
end

return Panel