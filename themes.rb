
class OverTheme < GuiTheme
    def initialize
        super(COLOR_WHITE,                # text color
              COLOR_HEADER_BRIGHT_BLUE,   # graphic elements
              COLOR_LIGHT_BLACK,          # border color
              COLOR_LIGHT_GRAY,                # background
              COLOR_LIGHT_GRAY,           # selected item
              true,                       # use icons
              # Gosu::Font.new(40,  :name => "TimesNewRoman"),   # regular font
              # Gosu::Font.new(50,  :name => "Consolas") )  # large font
              # Gosu::Font.new(80, {:name => "media/MutatorSans.ttf"}))  # large font
              Gosu::Font.new(30, {:name => "media/CourierNewBold.ttf"}),  # regular font
              Gosu::Font.new(80, {:name => "media/MutatorSans.ttf"}))  # large font
    end

end

class BricksTheme < GuiTheme
    def initialize
        super(COLOR_WHITE,                # text color
              COLOR_HEADER_BRIGHT_BLUE,   # graphic elements
              COLOR_BORDER_BLUE,          # border color
              COLOR_BLACK,                # background
              COLOR_LIGHT_GRAY,           # selected item
              true,                       # use icons
              Gosu::Font.new(22, {:name => media_path("armalite_rifle.ttf")}),  # regular font
              Gosu::Font.new(38, {:name => media_path("armalite_rifle.ttf")}))  # large font
    end

    def media_path(file)
        File.join(File.dirname(File.dirname(__FILE__)), 'overlord/media', file)
    end
end

class OverlayTheme < GuiTheme
    def initialize
        super(COLOR_WHITE,                # text color
              COLOR_HEADER_BRIGHT_BLUE,   # graphic elements
              COLOR_VERY_LIGHT_BLUE,      # border color
              COLOR_BLACK,                # background
              COLOR_LIGHT_GRAY,           # selected item
              true,                       # use icons
              Gosu::Font.new(22),  # regular font
              Gosu::Font.new(38))  # large font
    end

    def media_path(file)
        File.join(File.dirname(File.dirname(__FILE__)), 'media', file)
    end
end

# WadsConfig.instance.set_current_theme(OverTheme.new)
