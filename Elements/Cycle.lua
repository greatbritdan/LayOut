local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")
local Base = require(LAYOUT_REQUIREPATH..".Elements.Base")

-----------------------------------------------------------------

local Cycle = Class("LayOut_Cycle",Base)

function Cycle:initialize(instance,transform,args,parent)
    args = args or {}
    self.type = LAYOUT_TYPES.CYCLE
    Base.initialize(self,instance,transform,args,parent)

    self.values = args.values or {"no values"}
    self.value = args.value or 1

    self:InitializeElement()
end
function Cycle:BaseInitializeElement()
    self.cycle = Utils.GenerateElement({"base"},self,self.t)
end

function Cycle:BaseDraw()
    Utils.DrawBase(self,self.t,Utils.GetState(self),self.cycle)
end

function Cycle:Release()
    self:CycleShift(1)
    if self.callback then self.callback(self) end
end

-----------------------------------------------------------------

function Cycle:CycleShift(dir)
    self.value = self.value + dir
    if self.value > #self.values then self.value = 1 end
    if self.value < 1 then self.value = #self.values end
end

function Cycle:GetValue(idx)
    if idx then
        return self.value
    end
    return self.values[self.value]
end

return Cycle