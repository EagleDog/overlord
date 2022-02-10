#
#  Themes
#
module Wads

    #
    # An instance of GuiTheme directs wads widgets as to what colors and fonts
    # should be used. This accomplishes two goals: one, we don't need to constantly
    # pass around these instances. They can be globally accessed using WadsConfig.
    # It also makes it easy to change the look and feel of your application.
    # 
    class GuiTheme 
        attr_accessor :text_color
        attr_accessor :graphic_elements_color
        attr_accessor :border_color
        attr_accessor :background_color
        attr_accessor :selection_color
        attr_accessor :use_icons
        attr_accessor :font
        attr_accessor :font_large

        def initialize(text, graphics, border, background, selection, use_icons, font, font_large) 
            @text_color = text 
            @graphic_elements_color = graphics
            @border_color = border 
            @background_color = background 
            @selection_color = selection 
            @use_icons = use_icons
            @font = font
            @font_large = font_large
        end

        def pixel_width_for_string(str)
            @font.text_width(str)
        end

        def pixel_width_for_large_font(str)
            @font_large.text_width(str)
        end
    end

    #
    # Theme with black text on a white background
    #
    class WadsBrightTheme < GuiTheme 
        def initialize 
            super(COLOR_BLACK,                # text color
                  COLOR_HEADER_BRIGHT_BLUE,   # graphic elements
                  COLOR_BORDER_BLUE,          # border color
                  COLOR_WHITE,                # background
                  COLOR_VERY_LIGHT_BLUE,      # selected item
                  true,                       # use icons
                  Gosu::Font.new(22),         # regular font
                  Gosu::Font.new(38))         # large font
        end 
    end

    class WadsDarkRedBrownTheme < GuiTheme 
        def initialize 
            super(COLOR_WHITE,                  # text color
                  Gosu::Color.argb(0xffD63D41), # graphic elements - dark red
                  Gosu::Color.argb(0xffEC5633), # border color - dark orange
                  Gosu::Color.argb(0xff52373B), # background - dark brown
                  Gosu::Color.argb(0xffEC5633), # selected item - dark orange
                  true,                         # use icons
                  Gosu::Font.new(22),           # regular font
                  Gosu::Font.new(38))           # large font
        end 
    end

    class WadsEarthTonesTheme < GuiTheme 
        def initialize 
            super(COLOR_WHITE,                  # text color
                  Gosu::Color.argb(0xffD0605E), # graphic elements
                  Gosu::Color.argb(0xffFF994C), # border color
                  Gosu::Color.argb(0xff98506D), # background
                  Gosu::Color.argb(0xffFF994C), # selected item
                  true,                         # use icons
                  Gosu::Font.new(22),           # regular font
                  Gosu::Font.new(38))           # large font
        end 
    end

    class WadsNatureTheme < GuiTheme 
        def initialize 
            super(COLOR_WHITE,                  # text color
                  Gosu::Color.argb(0xffA9B40B), # graphic elements
                  Gosu::Color.argb(0xffF38B01), # border color
                  Gosu::Color.argb(0xffFFC001), # background
                  Gosu::Color.argb(0xffF38B01), # selected item
                  true,                         # use icons
                  Gosu::Font.new(22, { :bold => true}), # regular font
                  Gosu::Font.new(38, { :bold => true})) # large font
        end 
    end

    class WadsPurpleTheme < GuiTheme 
        def initialize 
            super(COLOR_WHITE,                  # text color
                  Gosu::Color.argb(0xff5A23B4), # graphic elements
                  Gosu::Color.argb(0xffFE01EA), # border color
                  Gosu::Color.argb(0xffAA01FF), # background
                  Gosu::Color.argb(0xffFE01EA), # selected item
                  true,                         # use icons
                  Gosu::Font.new(22), # regular font
                  Gosu::Font.new(38, { :bold => true})) # large font
        end 
    end

    class WadsAquaTheme < GuiTheme 
        def initialize 
            super(COLOR_WHITE,                  # text color
                  Gosu::Color.argb(0xff387CA3), # graphic elements
                  Gosu::Color.argb(0xff387CA3), # border color
                  Gosu::Color.argb(0xff52ADC8), # background
                  Gosu::Color.argb(0xff55C39E), # selected item
                  true,                         # use icons
                  Gosu::Font.new(22), # regular font
                  Gosu::Font.new(38, { :bold => true})) # large font
        end 
    end

    #
    # Theme with white text on a black background that also does not use icons.
    # Currently, icons are primarily used in the Graph display widget.
    #
    class WadsNoIconTheme < GuiTheme 
        def initialize 
            super(COLOR_WHITE,                # text color
                  COLOR_HEADER_BRIGHT_BLUE,   # graphic elements
                  COLOR_BORDER_BLUE,          # border color
                  COLOR_BLACK,                # background
                  COLOR_LIGHT_GRAY,           # selected item
                  false,                      # use icons
                  Gosu::Font.new(22),         # regular font
                  Gosu::Font.new(38))         # large font
        end 
    end
end
