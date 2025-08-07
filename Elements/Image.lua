local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")
local Base = require(LAYOUT_REQUIREPATH..".Elements.Base")

-----------------------------------------------------------------

local Image = Class("LayOut_Image",Base)

function Image:initialize(instance,transform,args,parent)
    args = args or {}
    self.type = LAYOUT_TYPES.IMAGE
    Base.initialize(self,instance,transform,args,parent)

    self.image = args[1] or args.image or nil
    self.quad = args[2] or args.quad or nil

    self:InitializeElement()
end
function Image:BaseInitializeElement()
    self.imageg = Utils.GenerateElement({"cosmetic"},self,self.t)
end

function Image:BaseDraw()
    Utils.DrawImage(self,self.t,Utils.GetState(self),self.imageg,self.image,self.quad)
end

-----------------------------------------------------------------

function Image:GetContentBounds(transform,image,quad)
    transform, image, quad = transform or self.t, image or self.image, quad or self.quad
    local w,h
    if image and quad then
        local _,_,qw,qh = self.quad:getViewport()
        w,h = qw, qh
    elseif image then
        w,h = self.image:getWidth(), self.image:getHeight()
    end
    if w and h then
        local scale = self.s:GetStyleData(self,"imagescale",nil,1)
        local x,y = Utils.GetAllignX(transform.x, transform.w, w, self.ax, self.mx), Utils.GetAllignY(transform.y, transform.h, h, self.ay, self.my)
        return x,y,w*scale,h*scale
    end
    return nil
end

return Image