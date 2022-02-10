# constants.rb
#
#
module Wads
    # colors moved to bottom

    Z_ORDER_BACKGROUND = 2
    Z_ORDER_BORDER = 3
    Z_ORDER_SELECTION_BACKGROUND = 4
    Z_ORDER_GRAPHIC_ELEMENTS = 5
    Z_ORDER_PLOT_POINTS = 6
    Z_ORDER_FOCAL_ELEMENTS = 8
    Z_ORDER_TEXT = 9

    EVENT_OK = "ok"
    EVENT_TEXT_INPUT = "textinput"
    EVENT_TABLE_SELECT = "tableselect"
    EVENT_TABLE_UNSELECT = "tableunselect"
    EVENT_TABLE_ROW_DELETE = "tablerowdelete"

    IMAGE_CIRCLE_SIZE = 104

    ELEMENT_TEXT = "text"
    ELEMENT_TEXT_INPUT = "text_input"
    ELEMENT_BUTTON = "button"
    ELEMENT_IMAGE = "image"
    ELEMENT_TABLE = "table"
    ELEMENT_HORIZONTAL_PANEL = "hpanel"
    ELEMENT_VERTICAL_PANEL = "vpanel"
    ELEMENT_MAX_PANEL = "maxpanel"
    ELEMENT_DOCUMENT = "document"
    ELEMENT_GRAPH = "graph"
    ELEMENT_GENERIC = "generic"
    ELEMENT_PLOT = "plot"

    ARG_SECTION = "section"
    ARG_COLOR = "color"
    ARG_DESIRED_WIDTH = "desired_width"
    ARG_DESIRED_HEIGHT = "desired_height"
    ARG_PANEL_WIDTH = "panel_width"
    ARG_LAYOUT = "layout"
    ARG_TEXT_ALIGN = "text_align"
    ARG_USE_LARGE_FONT = "large_font"
    ARG_THEME = "theme"

    TEXT_ALIGN_LEFT = "left"
    TEXT_ALIGN_CENTER = "center"
    TEXT_ALIGN_RIGHT = "right"

    SECTION_TOP = "north"
    SECTION_MIDDLE = "center"
    SECTION_BOTTOM = "south"
    SECTION_LEFT = "west"
    SECTION_RIGHT = "east"
    SECTION_NORTH = SECTION_TOP
    SECTION_HEADER = SECTION_TOP
    SECTION_SOUTH = SECTION_BOTTOM
    SECTION_FOOTER = SECTION_BOTTOM
    SECTION_WEST = "west"
    SECTION_EAST = "east"
    SECTION_CENTER = "center"
    SECTION_CONTENT = SECTION_CENTER

    LAYOUT_VERTICAL_COLUMN = "vcolumn"
    LAYOUT_TOP_MIDDLE_BOTTOM = "top_middle_bottom"
    LAYOUT_HEADER_CONTENT = "header_content"
    LAYOUT_CONTENT_FOOTER = "content_footer"
    LAYOUT_BORDER = "border"
    LAYOUT_EAST_WEST = "east_west"
    LAYOUT_LEFT_RIGHT = LAYOUT_EAST_WEST

    FILL_VERTICAL_STACK = "fill_vertical"
    FILL_HORIZONTAL_STACK = "fill_horizontal"
    FILL_FULL_SIZE = "fill_full_size"

    GRAPH_DISPLAY_ALL = "all"
    GRAPH_DISPLAY_EXPLORER = "explorer"
    GRAPH_DISPLAY_TREE = "tree"

    COLOR_PEACH = Gosu::Color.argb(0xffe6b0aa)
    COLOR_LIGHT_PURPLE = Gosu::Color.argb(0xffd7bde2)
    COLOR_LIGHT_BLUE = Gosu::Color.argb(0xffa9cce3)
    COLOR_VERY_LIGHT_BLUE = Gosu::Color.argb(0xffd0def5)
    COLOR_LIGHT_GREEN = Gosu::Color.argb(0xffa3e4d7)
    COLOR_GREEN = COLOR_LIGHT_GREEN
    COLOR_LIGHT_YELLOW = Gosu::Color.argb(0xfff9e79f)
    COLOR_LIGHT_ORANGE = Gosu::Color.argb(0xffedbb99)
    COLOR_WHITE = Gosu::Color::WHITE
    COLOR_OFF_WHITE = Gosu::Color.argb(0xfff8f9f9)
    COLOR_PINK = Gosu::Color.argb(0xffe6b0aa)
    COLOR_LIME = Gosu::Color.argb(0xffDAF7A6)
    COLOR_YELLOW = Gosu::Color.argb(0xffFFC300)
    COLOR_MAROON = Gosu::Color.argb(0xffC70039)
    COLOR_PURPLE = COLOR_MAROON
    COLOR_LIGHT_GRAY = Gosu::Color.argb(0xff2c3e50)
    COLOR_LIGHTER_GRAY = Gosu::Color.argb(0xff364d63)
    COLOR_LIGHTEST_GRAY = Gosu::Color.argb(0xff486684)
    COLOR_GRAY = Gosu::Color::GRAY
    COLOR_OFF_GRAY = Gosu::Color.argb(0xff566573)
    COLOR_LIGHT_BLACK = Gosu::Color.argb(0xff111111)
    COLOR_LIGHT_RED = Gosu::Color.argb(0xffe6b0aa)
    COLOR_CYAN = Gosu::Color::CYAN
    COLOR_AQUA = COLOR_CYAN
    COLOR_HEADER_BLUE = Gosu::Color.argb(0xff089FCE)
    COLOR_HEADER_BRIGHT_BLUE = Gosu::Color.argb(0xff0FAADD)
    COLOR_BLUE = Gosu::Color::BLUE
    COLOR_DARK_GRAY = Gosu::Color.argb(0xccf0f3f4)
    COLOR_RED = Gosu::Color::RED
    COLOR_BLACK = Gosu::Color::BLACK
    COLOR_FORM_BUTTON = Gosu::Color.argb(0xcc2e4053)
    COLOR_ERROR_CODE_RED = Gosu::Color.argb(0xffe6b0aa)
    COLOR_BORDER_BLUE = Gosu::Color.argb(0xff004D80)
    COLOR_ALPHA = "alpha"

end
