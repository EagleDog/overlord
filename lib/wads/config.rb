
module Wads

    #
    # WadsConfig is the one singleton that provides access to resources
    # used throughput the application, including fonts, themes, and layouts.
    #
    class WadsConfig 
        include Singleton

        attr_accessor :logger
        attr_accessor :window

        def get_logger
            if @logger.nil?
                @logger = Logger.new(STDOUT)
            end 
            @logger 
        end

        #
        # Wads uses the Ruby logger, and you can conrol the log level using this method.
        # Valid values are 'debug', 'info', 'warn', 'error'
        def set_log_level(level)
            get_logger.level = level
        end

        def set_window(w)
            @window = w 
        end

        def get_window
            if @window.nil?
                raise "The WadsConfig.instance.set_window(window) needs to be invoked first"
            end
            @window 
        end

        #
        # Get the default theme which is white text on a black background
        # that uses icons (primarily used in the Graph display widget currently)
        #
        def get_default_theme 
            if @default_theme.nil?
                @default_theme = GuiTheme.new(COLOR_WHITE,                # text color
                                              COLOR_HEADER_BRIGHT_BLUE,   # graphic elements
                                              COLOR_BORDER_BLUE,          # border color
                                              COLOR_BLACK,                # background
                                              COLOR_LIGHT_GRAY,           # selected item
                                              true,                       # use icons
                                              Gosu::Font.new(22),         # regular font
                                              Gosu::Font.new(38))         # large font
            end 
            @default_theme
        end

        #
        # Get a reference to the current theme. If one has not been set using
        # set_current_theme(theme), the default theme will be used.
        #
        def current_theme 
            if @current_theme.nil? 
                @current_theme = get_default_theme 
            end 
            @current_theme 
        end 

        #
        # Set the theme to be used by wads widgets
        #
        def set_current_theme(theme) 
            @current_theme = theme 
        end

        #
        # This method returns the default dimensions for the given widget type
        # as a two value array of the form [width, height].
        # This helps the layout manager allocate space to widgets within a layout
        # and container. The string value max tells the layout to use all available
        # space in that dimension (either x or y)
        #
        def default_dimensions(widget_type)
            if @default_dimensions.nil? 
                @default_dimensions = {}
                @default_dimensions[ELEMENT_TEXT] = [100, 20]
                @default_dimensions[ELEMENT_TEXT_INPUT] = [100, 20]
                @default_dimensions[ELEMENT_IMAGE] = [100, 100]
                @default_dimensions[ELEMENT_TABLE] = ["max", "max"]
                @default_dimensions[ELEMENT_HORIZONTAL_PANEL] = ["max", 100]
                @default_dimensions[ELEMENT_VERTICAL_PANEL] = [100, "max"]
                @default_dimensions[ELEMENT_MAX_PANEL] = ["max", "max"]
                @default_dimensions[ELEMENT_DOCUMENT] = ["max", "max"]
                @default_dimensions[ELEMENT_GRAPH] = ["max", "max"]
                @default_dimensions[ELEMENT_BUTTON] = [100, 26]
                @default_dimensions[ELEMENT_GENERIC] = ["max", "max"]
                @default_dimensions[ELEMENT_PLOT] = ["max", "max"]
            end
            @default_dimensions[widget_type]
        end
    
        def create_layout_for_widget(widget, layout_type = nil, args = {})
            create_layout(widget.x, widget.y, widget.width, widget.height, widget, layout_type, args)
        end 

        def create_layout(x, y, width, height, widget, layout_type = nil, args = {})
            if layout_type.nil? 
                if @default_layout_type.nil?
                    layout_type = LAYOUT_VERTICAL_COLUMN
                else 
                    layout_type = @default_layout_type 
                end 
            end
 
            if not @default_layout_args.nil?
                if args.nil? 
                    args = @default_layout_args 
                else 
                    args.merge(@default_layout_args)
                end 
            end

            if layout_type == LAYOUT_VERTICAL_COLUMN
                return VerticalColumnLayout.new(x, y, width, height, widget, args)
            elsif layout_type == LAYOUT_TOP_MIDDLE_BOTTOM
                return TopMiddleBottomLayout.new(x, y, width, height, widget, args)
            elsif layout_type == LAYOUT_BORDER
                return BorderLayout.new(x, y, width, height, widget, args)
            elsif layout_type == LAYOUT_HEADER_CONTENT
                return HeaderContentLayout.new(x, y, width, height, widget, args)
            elsif layout_type == LAYOUT_CONTENT_FOOTER
                return ContentFooterLayout.new(x, y, width, height, widget, args)
            elsif layout_type == LAYOUT_EAST_WEST
                return EastWestLayout.new(x, y, width, height, widget, args)
            end
            raise "#{layout_type} is an unsupported layout type" 
        end 
    
        def set_default_layout(layout_type, layout_args = {}) 
            @default_layout_type = layout_type 
            @default_layout_args = layout_args
        end

        #
        # Get a Gosu images instance for the specified color, i.e. COLOR_AQUA ir COLOR_BLUE
        #
        def circle(color)
            create_circles 
            if color.nil?
                return nil 
            end
            img = @wads_image_circles[color]
            if img.nil?
                get_logger.error("ERROR: Did not find circle image with color #{color}")
            end
            img
        end 

        def create_circles
            return unless @wads_image_circles.nil?
            @wads_image_circle_aqua = Gosu::Image.new("../media/CircleAqua.png")
            @wads_image_circle_blue = Gosu::Image.new("../media/CircleBlue.png")
            @wads_image_circle_green = Gosu::Image.new("../media/CircleGreen.png")
            @wads_image_circle_purple = Gosu::Image.new("../media/CirclePurple.png")
            @wads_image_circle_red = Gosu::Image.new("../media/CircleRed.png")
            @wads_image_circle_yellow = Gosu::Image.new("../media/CircleYellow.png")
            @wads_image_circle_gray = Gosu::Image.new("../media/CircleGray.png")
            @wads_image_circle_white = Gosu::Image.new("../media/CircleWhite.png")
            @wads_image_circle_alpha = Gosu::Image.new("../media/CircleAlpha.png")
            @wads_image_circles = {}
            @wads_image_circles[COLOR_AQUA] = @wads_image_circle_aqua
            @wads_image_circles[COLOR_BLUE] = @wads_image_circle_blue
            @wads_image_circles[COLOR_GREEN] = @wads_image_circle_green
            @wads_image_circles[COLOR_PURPLE] = @wads_image_circle_purple
            @wads_image_circles[COLOR_RED] = @wads_image_circle_red
            @wads_image_circles[COLOR_YELLOW] = @wads_image_circle_yellow
            @wads_image_circles[COLOR_GRAY] = @wads_image_circle_gray
            @wads_image_circles[COLOR_WHITE] = @wads_image_circle_white
            @wads_image_circles[COLOR_ALPHA] = @wads_image_circle_alpha
            @wads_image_circles[4294956800] = @wads_image_circle_yellow
            @wads_image_circles[4281893349] = @wads_image_circle_blue
            @wads_image_circles[4294967295] = @wads_image_circle_gray
            @wads_image_circles[4286611584] = @wads_image_circle_gray
            @wads_image_circles[4282962380] = @wads_image_circle_aqua
            @wads_image_circles[4294939648] = @wads_image_circle_red
            @wads_image_circles[4292664540] = @wads_image_circle_white    
        end
    end
end
