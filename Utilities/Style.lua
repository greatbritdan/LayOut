local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")

-----------------------------------------------------------------

local Style = Class("LayOut_Style")

function Style:initialize(path)
    self.style = nil
    local suc, err = pcall(love.filesystem.load(path))
    if suc then
        self.style = err
    else
        error("[LayOut - Style] Unable to load style '"..path.."', returned nil with error: "..err)
    end
end

function Style:GetStyleCategory(typ)
    local lookup = {"label","button","image","toggle","cycle","slider","input","layout","empty","panel","tooltip"}
    if lookup[typ] then return lookup[typ] end
    return "base" -- ID: 0
end

function Style:GetStyleData(element,key,subkey,default)
    local typ = (element.parent and Utils.IsCosmetic(element)) and element.parent.type or element.type
    local elementtable = self.style[self:GetStyleCategory(typ)]
    local basetable = self.style[self:GetStyleCategory(LAYOUT_TYPES.BASE)]
    if key == "visual" then
        if elementtable and elementtable.visual and elementtable.visual[subkey] then return elementtable.visual[subkey] end
        if basetable and basetable.visual and basetable.visual[subkey] then return basetable.visual[subkey] end
    else
        if elementtable and elementtable[key] then return elementtable[key] end
        if basetable and basetable[key] then return basetable[key] end
        if subkey and elementtable and elementtable[subkey] then return elementtable[subkey] end
        if subkey and basetable and basetable[subkey] then return basetable[subkey] end
    end
    return default
end

return Style