local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")
local Base = require(LAYOUT_REQUIREPATH..".Elements.Base")

-----------------------------------------------------------------

local Empty = Class("LayOut_Empty",Base)

function Empty:initialize(instance,transform,args,parent)
    args = args or {}
    self.type = LAYOUT_TYPES.EMPTY
    Base.initialize(self,instance,transform,args,parent)
    self:InitializeElement()
end

return Empty