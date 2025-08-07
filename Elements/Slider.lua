local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")
local Base = require(LAYOUT_REQUIREPATH..".Elements.Base")

-----------------------------------------------------------------

local Slider = Class("LayOut_Slider",Base)

function Slider:initialize(instance,transform,args,parent)
    args = args or {}
    self.type = LAYOUT_TYPES.SLIDER
    Base.initialize(self,instance,transform,args,parent)

    if args.dir and (args.dir == "hor" or args.dir == "ver") then
        self.dir = args.dir == "hor" and LAYOUT_DIRECTION.HOR or LAYOUT_DIRECTION.VER
    else
        self.dir = self.t.w > self.t.h and LAYOUT_DIRECTION.HOR or LAYOUT_DIRECTION.VER
    end
    self.fill = args.fill or 0.1
    self.limit = args.limit or {0,10,1,1}
    self.value = args.value or 0

    self.bulb, self.bulbstart, self.bulbend = 0, 0, 0
    self.dragging = false

    self:InitializeElement()
end
function Slider:BaseInitializeElement()
    self:SliderUpdateBlub()
    self.slider = Utils.GenerateElement({"base"},self,self.t)
    self.sliderbulb = Utils.GenerateElement({"bulb"},self,self:SliderGetBulb())
end

function Slider:BaseUpdate(dt)
    if self.pressing then
        local mx, my = Utils.GetMouse(self)
        if self.dir == LAYOUT_DIRECTION.HOR then
            self.bulb = mx-self.mx-(self.bulbsize/2)
        else
            self.bulb = my-self.my-(self.bulbsize/2)
        end
        self:SliderUpdateValue()
        self.dragging = true
    elseif self.dragging then
        if self.callback then self.callback(self) end
        self.dragging = false
    end
end

function Slider:BaseDraw()
    Utils.DrawBase(self,self.t,Utils.GetState(self),self.slider)
    Utils.DrawBase(self,self:SliderGetBulb(),Utils.GetState(self),self.sliderbulb)
end

function Slider:Scroll(sx,sy)
    self.value = self.value + self.limit[4] * -sy
    self.value = math.max(self.limit[1],math.min(self.value,self.limit[2]))
    if self.callback then self.callback(self) end
    self:SliderUpdateBlub()
end

-----------------------------------------------------------------

function Slider:SliderGetBulb()
    if self.dir == LAYOUT_DIRECTION.HOR then
        return {x=self.t.x+self.bulbstart+self.bulb, y=self.t.y+self.my, w=self.bulbsize, h=self.t.h-(self.my*2)}
    else
        return {x=self.t.x+self.mx, y=self.t.y+self.bulbstart+self.bulb, w=self.t.w-(self.mx*2), h=self.bulbsize}
    end
end

function Slider:SliderLimitBulb()
    if self.bulb < 0 then self.bulb = 0 end
    if self.bulb > self.bulbgap then self.bulb = self.bulbgap end
end

function Slider:SliderUpdateBlub()
    if self.dir == LAYOUT_DIRECTION.HOR then
        self.bulbstart, self.bulbend = self.mx, self.t.w-self.mx
    else
        self.bulbstart, self.bulbend = self.my, self.t.h-self.my
    end
    if self.fill > 1 then
        self.bulbsize = self.fill
    else
        self.bulbsize = (self.bulbend-self.bulbstart)*self.fill
    end
    self.bulbgap = (self.bulbend-self.bulbstart)-self.bulbsize
    self.bulb = (self.value-self.limit[1]) / (self.limit[2]-self.limit[1]) * self.bulbgap
    self:SliderLimitBulb()
end

function Slider:SliderUpdateValue()
    self:SliderLimitBulb()
    local value = self.limit[1] + (self.bulb / (self.bulbgap)) * (self.limit[2]-self.limit[1])
    self.value = math.floor(((value - self.limit[1]) / self.limit[3])+0.5) * self.limit[3] + self.limit[1]
end

-----------------------------------------------------------------

function Slider:GetValue()
    return self.value
end

return Slider