local Utils = {}

function Utils.Transform(transform)
    transform = transform or {0,0,0,0}
    local t = {}
    if #transform == 2 then
        t.x, t.y = 0, 0
        t.w = transform[1] or transform.w or 0
        t.h = transform[2] or transform.h or 0
    else
        t.x = transform[1] or transform.x or 0
        t.y = transform[2] or transform.y or 0
        t.w = transform[3] or transform.w or 0
        t.h = transform[4] or transform.h or 0
    end
    return t
end

function Utils.CreateImageElement(path,cs)
    local image = love.graphics.newImage(path)
    local iw,ih = image:getWidth(), image:getHeight()
    local cs = cs or 1
    local qs = 1+cs*2

    local createquadgroup = function(sy)
        return {
            tl = love.graphics.newQuad(0,     sy,      cs, cs, iw, ih),
            tm = love.graphics.newQuad(cs,    sy,      1,  cs, iw, ih),
            tr = love.graphics.newQuad(iw-cs, sy,      cs, cs, iw, ih),
            cl = love.graphics.newQuad(0,     sy+cs,   cs, 1,  iw, ih),
            cm = love.graphics.newQuad(cs,    sy+cs,   1,  1,  iw, ih),
            cr = love.graphics.newQuad(iw-cs, sy+cs,   cs, 1,  iw, ih),
            bl = love.graphics.newQuad(0,     sy+cs+1, cs, cs, iw, ih),
            bm = love.graphics.newQuad(cs,    sy+cs+1, 1,  cs, iw, ih),
            br = love.graphics.newQuad(iw-cs, sy+cs+1, cs, cs, iw, ih),
        }
    end

    local quads = {}
    local qc = ih/qs
    for i = 1, 4 do
        if i <= qc then
            quads[i] = createquadgroup((i-1)*qs)
        else
            quads[i] = Utils.Deepcopy(quads[qc])
        end
    end
    return {image=image, quads=quads, cornersize=cs}
end
function Utils.GenerateElement(datanames,element,transform)
    local elementdata
    for _,v in pairs(datanames) do
        elementdata = element.s:GetStyleData(element,"visual",v)
        if elementdata then break end
    end
    if not elementdata then return nil end

    if not elementdata.image then
        return {type="color", states=elementdata}
    end

    local image,quad,cs = elementdata.image, elementdata.quads, elementdata.cornersize
    local x,y,w,h = 0, 0, transform.w, transform.h
    local quads = {}
    for i = 1, 4 do
        quads[i] = love.graphics.newSpriteBatch(image,9)
        quads[i]:add(quad[i].tl, x,      y)
        quads[i]:add(quad[i].tm, x+cs,   y, 0, w-cs*2, 1)
        quads[i]:add(quad[i].tr, x+w-cs, y)
        quads[i]:add(quad[i].cl, x,      y+cs, 0, 1,      h-cs*2)
        quads[i]:add(quad[i].cm, x+cs,   y+cs, 0, w-cs*2, h-cs*2)
        quads[i]:add(quad[i].cr, x+w-cs, y+cs, 0, 1,      h-cs*2)
        quads[i]:add(quad[i].bl, x,      y+h-cs)
        quads[i]:add(quad[i].bm, x+cs,   y+h-cs, 0, w-cs*2, 1)
        quads[i]:add(quad[i].br, x+w-cs, y+h-cs)
    end
    return {type="image", states=quads}
end

function Utils.GetAlignValue(align) -- l/t,m/c,r/b (This also works for Y but shhh)
    if align == "m" or align == "c" then return LAYOUT_ALIGNHOR.MIDDLE end
    if align == "r" or align == "b" then return LAYOUT_ALIGNHOR.RIGHT end
    return LAYOUT_ALIGNHOR.LEFT
end
function Utils.GetAllignX(x,w,cw,allign,margin)
    if allign == LAYOUT_ALIGNHOR.LEFT then
        return x+margin
    elseif allign == LAYOUT_ALIGNHOR.MIDDLE then
        return x+(w/2)-(cw/2)
    elseif allign == LAYOUT_ALIGNHOR.RIGHT then
        return x+w-margin-cw
    end
end
function Utils.GetAllignY(y,h,ch,allign,margin)
    if allign == LAYOUT_ALIGNVER.TOP then
        return y+margin
    elseif allign == LAYOUT_ALIGNVER.CENTER then
        return y+(h/2)-(ch/2)
    elseif allign == LAYOUT_ALIGNVER.BOTTOM then
        return y+h-margin-ch
    end
end
function Utils.LineCount(font,text,w,margin)
    --local _,lines = font:getWrap(text,w-(margin*2))
    local _,lines = font:getWrap(text,9999)
    return #lines
end

function Utils.IsCosmetic(element)
    local cosmetics = {LAYOUT_TYPES.LABEL,LAYOUT_TYPES.IMAGE,LAYOUT_TYPES.EMPTY,LAYOUT_TYPES.LAYOUT,LAYOUT_TYPES.TOOLTIP}
    return Utils.TableContains(cosmetics,element.type)
end
function Utils.HasValue(element)
    local valuefull = {LAYOUT_TYPES.TOGGLE,LAYOUT_TYPES.CYCLE,LAYOUT_TYPES.SLIDER,LAYOUT_TYPES.INPUT}
    return Utils.TableContains(valuefull,element.type)
end

function Utils.GetState(element)
    if element.parent and Utils.IsCosmetic(element) then
        return Utils.GetState(element.parent)
    end
    if Utils.IsCosmetic(element) then
        return LAYOUT_STATES.BASE -- cosmetics should never respond to input
    end
    if not element:IsActive() then
        return LAYOUT_STATES.DISABLED
    else
        if element.pressing then
            return LAYOUT_STATES.FOCUS
        elseif element.hovering then
            return LAYOUT_STATES.HOVER
        end
    end
    return LAYOUT_STATES.BASE
end

function Utils.DrawBase(element,transform,state,elementdata,opacity)
    if not elementdata then return nil end
    if elementdata.type == "image" then
        love.graphics.setColor(1,1,1,opacity)
        love.graphics.draw(elementdata.states[state], transform.x, transform.y)
    elseif elementdata.type == "color" then
        local csize, cseg = element.s:GetStyleData(element,"cornersize",nil,0), element.s:GetStyleData(element,"cornersegments",nil,8)
        local r,g,b,a = unpack(elementdata.states[state])
        love.graphics.setColor(r,g,b,a)
        if opacity then love.graphics.setColor(r,g,b,opacity) end
        love.graphics.rectangle("fill", transform.x, transform.y, transform.w, transform.h, csize, csize, cseg)
    end
end
function Utils.DrawText(element,transform,state,elementdata,label,opacity)
    if not elementdata then return nil end
    if elementdata.type == "image" then -- not supported
    elseif elementdata.type == "color" then
        local x,y,_,_ = element:GetContentBounds(transform,label)
        love.graphics.setFont(element.font)
        local r,g,b,a = unpack(elementdata.states[state])
        love.graphics.setColor(r,g,b,a)
        if opacity then love.graphics.setColor(r,g,b,opacity) end
        local scale = element.s:GetStyleData(element,"fontscale",nil,1)
        --love.graphics.printf(label, x, y, transform.w-(element.mx*2), "left", 0, scale, scale)
        love.graphics.printf(label, x, y, 9999, "left", 0, scale, scale)
    end
end
function Utils.DrawImage(element,transform,state,elementdata,image,quad,opacity)
    if not elementdata then return nil end
    if elementdata.type == "image" then -- not supported (dont think about it)
    elseif elementdata.type == "color" then
        local x,y,_,_ = element:GetContentBounds(transform,image,quad)
        local r,g,b,a = unpack(elementdata.states[state])
        love.graphics.setColor(r,g,b,a)
        if opacity then love.graphics.setColor(r,g,b,opacity) end
        local scale = element.s:GetStyleData(element,"imagescale",nil,1)
        if image and quad then
            love.graphics.draw(image, quad, x, y, 0, scale, scale)
        elseif image then
            love.graphics.draw(image, x, y, 0, scale, scale)
        end
    end
end

function Utils.GetMouse(elm,notrelative)
    local x,y = love.mouse.getX()/LAYOUT_SETTINGS.scale, love.mouse.getY()/LAYOUT_SETTINGS.scale
    if notrelative then return x,y end
    return x - elm.t.x, y - elm.t.y
end
function Utils.AABB(area1,area2)
    return area1.X < area2.X + area2.W and
           area1.X + area1.W > area2.X and
           area1.Y < area2.Y + area2.H and
           area1.Y + area1.H > area2.Y
end

function Utils.TableContains(table, value)
    for i, v in ipairs(table) do
        if v == value then
            return i -- returns the index of the value in the table
        end
    end
    return false
end

function Utils.Deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Utils.Deepcopy(orig_key)] = Utils.Deepcopy(orig_value)
        end
        setmetatable(copy, Utils.Deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return Utils