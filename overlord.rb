require 'gosu'
require_relative 'lib/wads'
#require 'rdia-games'
require_relative 'lib/rdia-games'

include Wads
include RdiaGames

require_relative 'bin/pathfinder'
require_relative 'ball_object'
require_relative 'objects'
require_relative 'scroller'
require_relative 'character'
require_relative 'mob'
require_relative 'tiles'
require_relative 'themes'

GAME_WIDTH = 1200
GAME_HEIGHT = 700
GAME_START_X = 10  
GAME_START_Y = 10

DIRECTION_TOWARDS = 0
DIRECTION_LEFT = 1
DIRECTION_AWAY = 2
DIRECTION_RIGHT = 3

MEDIA_PATH = File.join(File.dirname(File.dirname(__FILE__)), 'overlord/media/')

class Overlord < RdiaGame
    def initialize
        super(GAME_WIDTH, GAME_HEIGHT, "Overlord", Scroller.new) #OverDisplay.new)
        key_bindings
#        setup
#        play_music

    end 

    def play_music
#        self.load_sound(window)
#        @music = Gosu::Song.new('media/sounds/typing7.ogg')
        @music = Gosu::Song.new('media/adventure.ogg')
        @music.volume = 0.1
        @music.play(false)
    end


    # def setup
    #     @pathfinder = Pathfinder.new
    #     @pathfinder.setup
    # end

    def key_bindings
        register_hold_down_key(Gosu::KbA)    # Move left
        register_hold_down_key(Gosu::KbD)    # Move right
        register_hold_down_key(Gosu::KbW)    # Move left
        register_hold_down_key(Gosu::KbS)    # Move left

        register_hold_down_key(Gosu::KbLeft)    # Move left
        register_hold_down_key(Gosu::KbRight)    # Move right
        register_hold_down_key(Gosu::KbUp)    # Move left
        register_hold_down_key(Gosu::KbDown)    # Move left   
    end
end

Overlord.new.show





###
### REFERENCE ###
###
class CodeBase
    class Widgetty
        def update(update_count, mouse_x, mouse_y)
            if @overlay_widget 
                @overlay_widget.update(update_count, mouse_x, mouse_y)
            end
            handle_update(update_count, mouse_x, mouse_y) 
            @children.each do |child| 
                child.update(update_count, mouse_x, mouse_y) 
            end
        end
    end
end
###
### REFERENCE ###
###
class WattsApp < Gosu::Window
    def initialize(width, height, caption, widget)
        super(width, height)
        self.caption = caption
        @update_count = 0
        WadsConfig.instance.set_window(self)
        set_display(widget) 
        WadsConfig.instance.set_log_level("info")
        @registered_hold_down_buttons = []
    end 

    # __set_display(widget)
    # This method must be invoked with any 
    # Wads::Widget instance. It then handles
    # delegating all events and drawing all 
    # child widgets.
    #
    def set_display(widget) 
        @main_widget = widget 
    end

    def get_display
        @main_widget
    end

    # Register a key (identified by the Gosu id) to check if it is being held down.
    # If so, the handle_key_held_down callback will be invoked on widgets
    # For example, register_hold_down_key(Gosu::KbLeft)
    def register_hold_down_key(id)
        @registered_hold_down_buttons << id 
    end

    def update
        @main_widget.update(@update_count, mouse_x, mouse_y)

        # Look for keys that are held down and delegate those events
        @registered_hold_down_buttons.each do |id|
            if button_down?(id)
                @main_widget.handle_key_held_down id, mouse_x, mouse_y 
            end
        end

        @update_count = @update_count + 1
    end 

    def draw
        @main_widget.draw
    end

    def button_down id
        close if id == Gosu::KbEscape
        # Delegate button events to the primary display widget
        result = @main_widget.button_down id, mouse_x, mouse_y
        if not result.nil? and result.is_a? WidgetResult
            if result.close_widget
                close
            end
        end
    end

    def button_up id
        @main_widget.button_up id, mouse_x, mouse_y
    end
end
###
###
###
