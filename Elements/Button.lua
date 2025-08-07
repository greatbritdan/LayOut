local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")
local Base = require(LAYOUT_REQUIREPATH..".Elements.Base")

-----------------------------------------------------------------

local Button = Class("LayOut_Button",Base)

function Button:initialize(instance,transform,args,parent)
    args = args or {}
    self.type = LAYOUT_TYPES.BUTTON
    Base.initialize(self,instance,transform,args,parent)
    
    self:InitializeElement()
end
function Button:BaseInitializeElement()
    self.button = Utils.GenerateElement({"base"},self,self.t)
end

function Button:BaseDraw()
    Utils.DrawBase(self,self.t,Utils.GetState(self),self.button)
end

function Button:Release()
    if self.callback then self.callback(self) end
end

return Button