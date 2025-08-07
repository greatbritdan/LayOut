local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")
local Base = require(LAYOUT_REQUIREPATH..".Elements.Base")

-----------------------------------------------------------------

local Toggle = Class("LayOut_Toggle",Base)

function Toggle:initialize(instance,transform,args,parent)
    args = args or {}
    self.type = LAYOUT_TYPES.TOGGLE
    Base.initialize(self,instance,transform,args,parent)

    self.value = args.value or false
    self.square = args.square or false

    self:InitializeElement()
end
function Toggle:BaseInitializeElement()
    local w,h = (self.t.w-(self.mx*2))/2, self.t.h-(self.my*2)
    if self.square then w = h end

    self.toff = {x=self.t.x+self.mx, y=self.t.y+self.my, w=w, h=h}
    self.ton = {x=self.t.x+self.t.w-self.mx-self.toff.w, y=self.toff.y, w=self.toff.w, h=self.toff.h}
    self.togglebackoff = Utils.GenerateElement({"baseoff","base"},self,self.t)
    self.toggleoff = Utils.GenerateElement({"bulboff","bulb"},self,self.toff)
    self.togglebackon = Utils.GenerateElement({"baseon","base"},self,self.t)
    self.toggleon = Utils.GenerateElement({"bulbon","bulb"},self,self.ton)
end

function Toggle:BaseDraw()
    love.graphics.setColor(1,1,1)
    if self.value then
        Utils.DrawBase(self,self.t,Utils.GetState(self),self.togglebackon)
        Utils.DrawBase(self,self.ton,Utils.GetState(self),self.toggleon)
    else
        Utils.DrawBase(self,self.t,Utils.GetState(self),self.togglebackoff)
        Utils.DrawBase(self,self.toff,Utils.GetState(self),self.toggleoff)
    end
end

function Toggle:Release()
    self.value = not self.value
    if self.callback then self.callback(self) end
end

-----------------------------------------------------------------

function Toggle:GetValue()
    return self.value
end

return Toggle