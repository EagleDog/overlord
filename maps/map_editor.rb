require 'gosu'
require_relative '../lib/wads'
require_relative '../lib/rdia-games'
#require 'wads'
#require 'rdia-games'

include Wads
include RdiaGames

require_relative 'grid'
require_relative 'editor'
require_relative 'pallette'

# GAME_WIDTH = 1280
# GAME_HEIGHT = 720
GAME_WIDTH = 1100
GAME_HEIGHT = 600
BLANK_SPACE = "                                                               "
CAPTION_TEXT = BLANK_SPACE + BLANK_SPACE + "  M A P   E D I T O R  "

# Main Tiles: 0 wall, 5 bricks, 18 yellow, 19 green, 38 tree, 59 torches, 64 grass  


class MapEditor < RdiaGame
    def initialize #(board_file = "maps/maps/editor_board.txt")
        @editor = Editor.new
        super(GAME_WIDTH, GAME_HEIGHT, CAPTION_TEXT, @editor)
#        super(GAME_WIDTH, GAME_HEIGHT, CAPTION_TEXT, Editor.new)
        # register_hold_down_key(Gosu::KbA)    # Move left
        # register_hold_down_key(Gosu::KbD)    # Move right
        # register_hold_down_key(Gosu::KbW)    # Move left
        # register_hold_down_key(Gosu::KbS)    # Move left
        load_sounds
    end 

    def load_sounds
         @click_low = Gosu::Sample.new('../media/sounds/click_low.ogg')
         @click_high = Gosu::Sample.new('../media/sounds/click_high.ogg')
     end

    # def handle_key_press(id, mouse_x, mouse_y)
    #     press_s if id == Gosu::KbS
    # end

    # def press_s
    #     puts "press_s"
    #     @editor.press_s
    #     @click_low.play
    # end

end



if ARGV.size == 0
    puts "No args provided"
    MapEditor.new.show
elsif ARGV.size == 1
    puts "A board filename arg was provided"
    TileEditor.new(ARGV[0]).show
else 
    puts "Too many args provided"
    exit
end
