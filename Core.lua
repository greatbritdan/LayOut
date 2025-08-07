local Style = require(LAYOUT_REQUIREPATH..".Utilities.Style")
local Group = require(LAYOUT_REQUIREPATH..".Utilities.Group")

local Label =  require(LAYOUT_REQUIREPATH..".Elements.Label")
local Button = require(LAYOUT_REQUIREPATH..".Elements.Button")
local Image =  require(LAYOUT_REQUIREPATH..".Elements.Image")
local Toggle = require(LAYOUT_REQUIREPATH..".Elements.Toggle")
local Cycle =  require(LAYOUT_REQUIREPATH..".Elements.Cycle")
local Slider = require(LAYOUT_REQUIREPATH..".Elements.Slider")
local Input =  require(LAYOUT_REQUIREPATH..".Elements.Input")
local Layout = require(LAYOUT_REQUIREPATH..".Elements.Layout")
local Empty =  require(LAYOUT_REQUIREPATH..".Elements.Empty")
local Panel =  require(LAYOUT_REQUIREPATH..".Elements.Panel")
local Tooltip = require(LAYOUT_REQUIREPATH..".Elements.Tooltip")

--[[
    TODO:
    Redo active/visible to work with panels (siblings, don't un-disable children) [ ]
]]

-----------------------------------------------------------------

local LayOut = {}
function LayOut:initialize()
    self.styles = {}
    self.instances = {}
    self.groups = {}

    self.tooltip = nil
    self.tooltipelement = nil
end

function LayOut:Update(dt)
    self:ResetHover()
    self:ForEach(function(v) v:Update(dt) end)
    self.tooltip:Update(dt)

    if (not self.tooltipelement) and self.hover and self.hover.tooltip and self.hover.tooltipmode == "hover" then
        self:UpdateTooltip(self.hover.tooltip)
    end
    if (self.tooltipelement) and self.hover ~= self.tooltipelement and self.tooltipelement.tooltipmode == "hover" then
        self:UpdateTooltip()
    end
end
function LayOut:Draw(debug)
    love.graphics.push(); love.graphics.scale(LAYOUT_SETTINGS.scaleui,LAYOUT_SETTINGS.scaleui)
    self:ForEach(function(v) v:Draw(debug) end)
    self.tooltip:Draw(debug)
    love.graphics.pop()
end
function LayOut:Mousepressed()
    self:ResetFocus()
    self:ForEach(function(v) v:Mousepressed() end)

    if (not self.tooltipelement) and self.focus and self.focus.tooltip and self.focus.tooltipmode == "focus" then
        self:UpdateTooltip(self.focus.tooltip)
    end
    if (self.tooltipelement) and self.focus ~= self.tooltipelement and self.tooltipelement.tooltipmode == "focus" then
        self:UpdateTooltip()
    end
end
function LayOut:Mousereleased()
    self:ForEach(function(v) v:Mousereleased() end)
end
function LayOut:Wheelmoved(sx,sy)
    self:ForEach(function(v) v:Wheelmoved(sx,sy) end)
end
function LayOut:Keypressed(key)
    self:ForEach(function(v) v:Keypressed(key) end)
end
function LayOut:Textinput(key)
    self:ForEach(function(v) v:Textinput(key) end)
end

function LayOut:ForEach(func)
    if #self.groups == 0 then return end
    for i = 1, #self.groups do func(self.groups[i]) end
end

-----------------------------------------------------------------

function LayOut:NewStyle(key,path)
    if not self.styles[key] then
        local style = Style:new(path)
        if style.style ~= nil then
            self.styles[key] = style
            return style
        end
    end
    return false
end
function LayOut:SetStyle(key,update)
    if not self.styles[key] then
        error("[LayOut - Core] Unable to set style '"..key.."', key does not match a valid style, please initialize style first with :NewStyle(<key>,<path>)")
    end
    self.style = self.styles[key]
    if not self.tooltip then
        self.tooltip = Tooltip:new(self)
    else
        self.tooltip.s = self.style; self.tooltip:Modified()
    end
    if update then
        for _,v in pairs(self.instances) do
            local pass = (update.all ~= nil) or false
            if update.tag and v.tag == update.tag then pass = true end
            if update.tag and v.tag == update.tag then pass = true end
            if pass then
                v.s = self.style; v:Modified()
            end
        end
    end
end
function LayOut:RandomStyle()
    local keys = {}
    for i,_ in pairs(self.styles) do table.insert(keys,i) end
    self.style = self.styles[keys[math.random(#keys)]]
end

-----------------------------------------------------------------

function LayOut:ResetHover()
    if self.hover then self.hover._IsHovering = nil end
    self.hover = nil
end
function LayOut:SetHover(element)
    self.hover = element; element._IsHovering = true
end
function LayOut:ResetFocus()
    if self.focus then
        if self.focus.Unfocus then self.focus:Unfocus() end
        self.focus._isFocused = nil
    end
    self.focus = nil
end
function LayOut:SetFocus(element)
    if element.Focus then element:Focus() end
    self.focus = element; element._isFocused = true
end

function LayOut:UpdateTooltip(message)
    if message == nil then
        self.tooltip.timer = nil
        self.tooltipelement = nil
    else
        self.tooltip.queuetext = message
        self.tooltip.timer = 0
        self.tooltipelement = self.hover
    end
end

-----------------------------------------------------------------

function LayOut:Group()
    local group = Group:new(self)
    table.insert(self.groups,group)
    return group
end

function LayOut:Label(transform,args)    return self:CreateElement(LAYOUT_TYPES.LABEL,   transform,args) end
function LayOut:Button(transform,args)   return self:CreateElement(LAYOUT_TYPES.BUTTON,  transform,args) end
function LayOut:Image(transform,args)    return self:CreateElement(LAYOUT_TYPES.IMAGE,   transform,args) end
function LayOut:Toggle(transform,args)   return self:CreateElement(LAYOUT_TYPES.TOGGLE,  transform,args) end
function LayOut:Cycle(transform,args)    return self:CreateElement(LAYOUT_TYPES.CYCLE,   transform,args) end
function LayOut:Slider(transform,args)   return self:CreateElement(LAYOUT_TYPES.SLIDER,  transform,args) end
function LayOut:Input(transform,args)    return self:CreateElement(LAYOUT_TYPES.INPUT,   transform,args) end
function LayOut:Layout(transform,args)   return self:CreateElement(LAYOUT_TYPES.LAYOUT,  transform,args) end
function LayOut:Empty(transform,args)    return self:CreateElement(LAYOUT_TYPES.EMPTY,   transform,args) end
function LayOut:Panel(transform,args)    return self:CreateElement(LAYOUT_TYPES.PANEL,   transform,args) end

local types = {Label,Button,Image,Toggle,Cycle,Slider,Input,Layout,Empty,Panel}
function LayOut:CreateElement(type,transform,args)
    if not self.style then
        error("[LayOut - Core] Unable to create element as no style has been selected, please set style first with :SetStyle(<key>)")
    end
    if types[type] then
        local element = types[type]:new(self,transform,args)
        table.insert(self.instances,element)
        return element
    end
end

function LayOut:Find(tag)
    local results = {}
    for _,v in pairs(self.instances) do
        if v.tag == tag then table.insert(results,v) end
    end
    return results
end

LayOut:initialize()
return LayOut