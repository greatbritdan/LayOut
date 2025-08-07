local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")
local Base = require(LAYOUT_REQUIREPATH..".Elements.Base")

-----------------------------------------------------------------

local Tooltip = Class("LayOut_Tooltip",Base)

function Tooltip:initialize(instance,transform,args,parent)
    args = args or {}
    self.type = LAYOUT_TYPES.TOOLTIP
    Base.initialize(self,instance,transform,args,parent)

    self.text = "test tooltip"
    self.queuetext = nil
    self.timer = false
    self.opacity = 0

    self:InitializeElement()
end
function Tooltip:BaseInitializeElement()
    self.font = self.s:GetStyleData(self,"font",nil,nil)
    local _,_,w,h = self:GetContentBounds()
    self.t.w, self.t.h = w+(self.mx*2), h+(self.my*2)

    self.base = Utils.GenerateElement({"base"},self,self.t)
    self.baselabel = Utils.GenerateElement({"cosmetic"},self,self.t)
end

function Tooltip:BaseUpdate(dt)
    if self.timer then
        self.timer = self.timer + (2*dt)
        if self.timer > 1 then
            if self.queuetext then
                self.text = self.queuetext
                self.queuetext = nil
                self:InitializeElement()
            end
            self.opacity = math.max(0, math.min(self.timer-1, 1))
        end
    end
    if ((not self.timer) or self.queuetext) and self.opacity > 0 then
        self.opacity = self.opacity - (2*dt)
        if self.opacity < 0 then self.opacity = 0 end
    end

    if self.opacity > 0 then
        local mx, my = Utils.GetMouse(self,true)
        self.t.x, self.t.y = mx, my
    end
end

function Tooltip:BaseDraw()
    if self.opacity > 0 then
        Utils.DrawBase(self,self.t,LAYOUT_STATES.BASE,self.base,self.opacity)
        Utils.DrawText(self,self.t,Utils.GetState(self),self.baselabel,self.text,self.opacity)
    end
end

-----------------------------------------------------------------

function Tooltip:GetContentBounds(transform,label)
    transform, label = transform or self.t, label or self.text
    local scale = self.s:GetStyleData(self,"fontscale",nil,1)
    local w,h = (self.font:getWidth(label)-1)*scale, (Utils.LineCount(self.font,label,transform.w,self.mx)*self.font:getHeight())*scale
    local x,y = Utils.GetAllignX(transform.x, transform.w, w, self.ax, self.mx), Utils.GetAllignY(transform.y, transform.h, h, self.ay, self.my)
    return x,y,w,h
end

return Tooltip