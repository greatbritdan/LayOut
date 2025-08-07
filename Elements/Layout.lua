local Utils = require(LAYOUT_REQUIREPATH..".Utilities.Utils")
local Base = require(LAYOUT_REQUIREPATH..".Elements.Base")

-----------------------------------------------------------------

local Layout = Class("LayOut_Layout",Base)

function Layout:initialize(instance,transform,args,parent)
    args = args or {}
    self.type = LAYOUT_TYPES.LAYOUT
    Base.initialize(self,instance,transform,args,parent)

    self.layoutat = {anchor="tl",direction="h"}
    self.layout = {}

    self.layoutboundsoffset = {x=0,y=0,w=0,h=0}
    self.layoutscrolloffset = {x=0,y=0}

    self:InitializeElement({children=true}) -- dont initialize children
end
function Layout:Modified()
    self:Calculate()
    self:InitializeElement({children=true})
end

function Layout:Calculate(onlyoffset)
    if onlyoffset then
        self:ForEachChild(function(child)
            child.t.x, child.t.y = child._layout.x+self.layoutscrolloffset.x, child._layout.y+self.layoutscrolloffset.y; child:Modified()
        end)
        return
    end
    for anchorid,_ in pairs(self.layout) do
        self:CalculatePosition(anchorid)
    end
end
function Layout:CalculatePosition(anchorid)
    local fullwidth, fullheight = 0, 0
    local widths, heights = {}, {}
    for _,row in pairs(self.layout[anchorid]) do
        local totalwidth, maxheight = 0, 0
        for _,col in pairs(row) do
            local w, h = col.t.w, col.t.h
            totalwidth = totalwidth + w + self.sx
            maxheight = math.max(maxheight, h)
        end
        fullwidth = math.max(fullwidth, totalwidth - self.sx)
        fullheight = fullheight + maxheight + self.sy
        table.insert(widths, totalwidth - self.sx)
        table.insert(heights, maxheight)
    end
    fullheight = fullheight - self.sy

    local anchorver, anchorhor = anchorid:sub(1,1):lower(), anchorid:sub(2,2):lower()
    local x = Utils.GetAllignX(self.t.x+self.layoutboundsoffset.x,self.t.w+self.layoutboundsoffset.w,fullwidth,Utils.GetAlignValue(anchorhor),self.mx)
    local y = Utils.GetAllignY(self.t.y+self.layoutboundsoffset.y,self.t.h+self.layoutboundsoffset.h,fullheight,Utils.GetAlignValue(anchorver),self.my)

    for rowi,row in pairs(self.layout[anchorid]) do
        local startx = x
        for _,col in pairs(row) do
            local w, h = col.t.w, col.t.h
            local cw, ch = widths[rowi], heights[rowi]
            local cx = Utils.GetAllignX(x,fullwidth,cw,Utils.GetAlignValue(anchorhor),0)
            local cy = Utils.GetAllignY(y,ch,h,Utils.GetAlignValue(anchorver),0)
            col._layout = {x=cx, y=cy}
            col.t.x, col.t.y = cx+self.layoutscrolloffset.x, cy+self.layoutscrolloffset.y
            col:Modified()
            x = x + w +  self.sx
        end
        y = y + heights[rowi] + self.sy
        x = startx
    end
end

-----------------------------------------------------------------

function Layout:Add(child)
    if not self.layout[self.layoutat.anchor] then
        self.layout[self.layoutat.anchor] = {{}}
    end
    local length = #self.layout[self.layoutat.anchor]
    if #self.layout[self.layoutat.anchor][length] > 0 and self.layoutat.direction == "v" then
        table.insert(self.layout[self.layoutat.anchor], {})
        length = length + 1
    end
    table.insert(self.layout[self.layoutat.anchor][length],child)
    table.insert(self.children,child); child.parent = self
    return self
end
function Layout:End() self:Modified(); return self end

function Layout:TopLeft() self.layoutat.anchor = "tl"; return self end
function Layout:TopMiddle() self.layoutat.anchor = "tm"; return self end
function Layout:TopRight() self.layoutat.anchor = "tr"; return self end
function Layout:CenterLeft() self.layoutat.anchor = "cl"; return self end
function Layout:CenterMiddle() self.layoutat.anchor = "cm"; return self end
function Layout:CenterRight() self.layoutat.anchor = "cr"; return self end
function Layout:BottomLeft() self.layoutat.anchor = "bl"; return self end
function Layout:BottomMiddle() self.layoutat.anchor = "bm"; return self end
function Layout:BottomRight() self.layoutat.anchor = "br"; return self end
function Layout:Horizontal() self.layoutat.direction = "h"; return self end
function Layout:Vertical() self.layoutat.direction = "v"; return self end

return Layout