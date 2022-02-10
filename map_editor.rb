require 'gosu'
require_relative 'lib/wads'
require_relative 'lib/rdia-games'
#require 'wads'
#require 'rdia-games'

include Wads
include RdiaGames

require_relative 'maps/editor'
require_relative 'maps/pallette'

# GAME_WIDTH = 1280
# GAME_HEIGHT = 720
GAME_WIDTH = 1200
GAME_HEIGHT = 600
BLANK_SPACE = "                                                               "
CAPTION_TEXT = BLANK_SPACE + BLANK_SPACE + "  M A P   E D I T O R  "

class MapEditor < RdiaGame
    def initialize(board_file = "maps/maps/editor_board.txt")
        super(GAME_WIDTH, GAME_HEIGHT, CAPTION_TEXT, EditorDisplay.new(board_file))
        # register_hold_down_key(Gosu::KbA)    # Move left
        # register_hold_down_key(Gosu::KbD)    # Move right
        # register_hold_down_key(Gosu::KbW)    # Move left
        # register_hold_down_key(Gosu::KbS)    # Move left
    end 
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
