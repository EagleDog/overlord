require 'gosu'
require_relative 'lib/wads'
#require 'rdia-games'
require_relative 'lib/rdia-games'

include Wads
include RdiaGames

require_relative 'display'
require_relative 'characters'
require_relative 'items'
require_relative 'themes'

GAME_WIDTH = 800
GAME_HEIGHT = 700
GAME_START_X = 10
GAME_START_Y = 10

DIRECTION_TOWARDS = 0
DIRECTION_LEFT = 1
DIRECTION_AWAY = 2
DIRECTION_RIGHT = 3

MEDIA_PATH = File.join(File.dirname(File.dirname(__FILE__)), 'overlord/media/')

class Scroller3 < RdiaGame
    def initialize
        super(GAME_WIDTH, GAME_HEIGHT, "Overlord", ScrollerDisplay.new) #OverDisplay.new)
        keybindings
    end 

    def keybindings
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


class OverDisplay < ScrollerDisplay

    def initialize
        super
        @left = ''
        @right = ''
        @up = ''
        @down = ''
        # @ball = Ball.new(200, 200)
        # @ball.start_move_in_direction(DEG_90 - 0.2)
        # add_child(@ball)
    end

    def action_map id
        return @left if id == Gosu::KbA or id == Gosu::KbLeft
        return @right if id == Gosu::KbD or id == Gosu::KbRight
        return @up if id == Gosu::KbW or id == Gosu::KbUp
        return @down if id == Gosu::KbS or id == Gosu::KbDown
    end

    def handle_key_held_down id, mouse_x, mouse_y
        @player.move_left(@grid) if action_map(id) == @left
        @player.move_right(@grid) if action_map(id) == @right
        @player.move_up(@grid) if action_map(id) == @up
        @player.move_down(@grid) if action_map(id) == @down
        #puts "#{@player.x}, #{@player.y}    Camera: #{@camera_x}, #{@camera_y}   Tile: #{@grid.tile_at_absolute(@player.x, @player.y)}"
    end

    def handle_key_press id, mouse_x, mouse_y
        @player.start_move_left if action_map(id) == @left
        @player.start_move_right if action_map(id) == @right
        @player.start_move_up if action_map(id) == @up
        @player.start_move_down if action_map(id) == @down
    end

    def handle_key_up id, mouse_x, mouse_y
        if id == Gosu::KbA or id == Gosu::KbD or id == Gosu::KbW or id == Gosu::KbS or
           id == Gosu::KbLeft or id == Gosu::KbRight or id == Gosu::KbUp or id == Gosu::KbDown
            @player.stop_move
        end
    end

    def handle_update update_count, mouse_x, mouse_y
        # Scrolling follows player
        # @camera_x = [[@cptn.x - WIDTH / 2, 0].max, @map.width * 50 - WIDTH].min
        # @camera_y = [[@cptn.y - HEIGHT / 2, 0].max, @map.height * 50 - HEIGHT].min 
        @camera_x = [[@player.x - (GAME_WIDTH.to_f / 2), 0].max, @grid.grid_width * 32 - GAME_WIDTH].min
        @camera_y = [[@player.y - (GAME_HEIGHT.to_f / 2), 0].max, @grid.grid_height * 32 - GAME_HEIGHT].min
        #puts "#{@player.x}, #{@player.y}    Camera: #{@camera_x}, #{@camera_y}"
    end

end
