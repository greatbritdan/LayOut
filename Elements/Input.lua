local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")
local Base = require(LAYOUT_REQUIREPATH..".Elements.Base")

-----------------------------------------------------------------

local Input = Class("LayOut_Input",Base)

function Input:initialize(instance,transform,args,parent)
    args = args or {}
    self.type = LAYOUT_TYPES.INPUT
    Base.initialize(self,instance,transform,args,parent)

    self.initstage = "start"; self:InitializeElement({children=true})

    self.value = args.value or "no text"
    self.limit = args.limit or {}
    if not self.limit.width then self.limit.width = self.t.w-(self.mx*2) end
    if not self.limit.characters then self.limit.characters = " 1234567890abcdefghijklmnopqrstuvwxyz" end

    self.cursor, self.cursorblink = 0, 0

    self.initstage = "end"; self:InitializeElement({style=true})
end
function Input:BaseInitializeElement()
    if self.initstage == "start" then
        self.font = self.s:GetStyleData(self,"font",nil,nil)
        return
    end
    self.inputoff = Utils.GenerateElement({"baseoff","base"},self,self.t)
    self.inputon = Utils.GenerateElement({"baseon","base"},self,self.t)
    self.labelg = Utils.GenerateElement({"cosmetic"},self,self.t)
end

function Input:BaseUpdate(dt)
    self.cursorblink = (self.cursorblink + dt) % 1
end

function Input:BaseDraw()
    if self._isFocused then
        Utils.DrawBase(self,self.t,Utils.GetState(self),self.inputon)
    else
        Utils.DrawBase(self,self.t,Utils.GetState(self),self.inputoff)
    end
    Utils.DrawText(self,self.t,Utils.GetState(self),self.labelg,self.value)

    if self._isFocused and self.cursorblink < 0.5 then
        local x,y = self:GetContentBounds()
        local scale = self.s:GetStyleData(self,"fontscale",nil,1)
        local cursorx = x + (self.font:getWidth(self.value:sub(1,self.cursor))-1)*scale
        love.graphics.rectangle("fill",cursorx,y,1,self.font:getHeight()*scale)
    end
end

function Input:Focus()
    self.cursor = #self.value
end
function Input:Unfocus()
    if self.callback then self.callback(self) end
end

function Input:Input(key,text)
    local oldcursor, oldvalue = self.cursor, self.value

    if key == "return" then
        self.i:ResetFocus()
    elseif key == "home" then
        self.cursor = 0
    elseif key == "end" then
        self.cursor = #self.value
    elseif key == "right" then
        self.cursor = self.cursor + 1
    elseif key == "left" then
        self.cursor = self.cursor - 1
    elseif key == "backspace" then
        self.value = self.value:sub(1,self.cursor-1)..self.value:sub(self.cursor+1,#self.value)
        self.cursor = self.cursor - 1
    elseif text then
        if (not self.limit.characters) or self.limit.characters:find(text,1,true) then
            self.value = self.value:sub(1,self.cursor)..text..self.value:sub(self.cursor+1,#self.value)
            self.cursor = self.cursor + 1
        else
            return -- not a valid character
        end
    end
    if self.cursor < 0 then self.cursor = 0 end
    if self.cursor > #self.value then self.cursor = #self.value end

    if self.limit.width and self.font:getWidth(self.value)+1 > self.limit.width then
        self.cursor, self.value = oldcursor, oldvalue
    elseif self.limit.length and #self.value > self.limit.length then
        self.cursor, self.value = oldcursor, oldvalue
    elseif oldcursor ~= self.cursor then
        self.cursorblink = 0
    end
end
function Input:InputText(text)
    self:Input(nil,text)
end

-----------------------------------------------------------------

function Input:GetContentBounds(transform,label)
    transform, label = transform or self.t, label or self.value
    local scale = self.s:GetStyleData(self,"fontscale",nil,1)
    local w,h = (self.font:getWidth(label)-1)*scale, self.font:getHeight()*scale
    local x,y = Utils.GetAllignX(transform.x, transform.w, w, self.ax, self.mx), Utils.GetAllignY(transform.y, transform.h, h, self.ay, self.my)
    return x,y,w,h
end

function Input:GetValue()
    return self.value
end

return Input