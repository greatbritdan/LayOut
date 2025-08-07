local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")
local Base = require(LAYOUT_REQUIREPATH..".Elements.Base")

-----------------------------------------------------------------

local Label = Class("LayOut_Label",Base)

function Label:initialize(instance,transform,args,parent)
    args = args or {}
    self.type = LAYOUT_TYPES.LABEL
    Base.initialize(self,instance,transform,args,parent)

    self.label = args[1] or args.label or "no text"

    self:InitializeElement()
end
function Label:BaseInitializeElement()
    self.font = self.s:GetStyleData(self,"font",nil,nil)
    self.labelg = Utils.GenerateElement({"cosmetic"},self,self.t)
end

function Label:BaseUpdate(dt)
    if self.parent and Utils.HasValue(self.parent) then
        self.label = tostring(self.parent:GetValue())
    end
    local linked = self:GetLinked()
    if linked and Utils.HasValue(linked) then
        self.label = tostring(linked:GetValue())
    end
end

function Label:BaseDraw()
    Utils.DrawText(self,self.t,Utils.GetState(self),self.labelg,self.label)
end

-----------------------------------------------------------------

function Label:GetContentBounds(transform,label)
    transform, label = transform or self.t, label or self.label
    local scale = self.s:GetStyleData(self,"fontscale",nil,1)
    local w,h = (self.font:getWidth(label)-1)*scale, (Utils.LineCount(self.font,label,transform.w,self.mx)*self.font:getHeight())*scale
    local x,y = Utils.GetAllignX(transform.x, transform.w, w, self.ax, self.mx), Utils.GetAllignY(transform.y, transform.h, h, self.ay, self.my)
    return x,y,w,h
end

return Label