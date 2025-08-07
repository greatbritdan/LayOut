LAYOUT_REQUIREPATH = ...
LAYOUT_LOADPATH = LAYOUT_REQUIREPATH:gsub('%.', '/')

LAYOUT_STATES = {BASE = 1, HOVER = 2, FOCUS = 3, DISABLED = 4}
LAYOUT_TYPES = {BASE = 0, LABEL = 1, BUTTON = 2, IMAGE = 3, TOGGLE = 4, CYCLE = 5, SLIDER = 6, INPUT = 7, LAYOUT = 8, EMPTY = 9, PANEL = 10, TOOLTIP = 11}
LAYOUT_ALIGNHOR = {LEFT = -1, MIDDLE = 0, RIGHT = 1}
LAYOUT_ALIGNVER = {TOP = -1, CENTER = 0, BOTTOM = 1}
LAYOUT_DIRECTION = {HOR = 0, VER = 1}
LAYOUT_SETTINGS = {scale = 1, scaleui = 1, randomstyle = false}

love.keyboard.setKeyRepeat(true)
local layout = require(LAYOUT_REQUIREPATH .. '.Core')
return layout