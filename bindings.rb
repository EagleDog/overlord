#
#    bindings.rb
#
#
class KeyBindings
    def initialize(player)
        @player = player
    end 

    def action_map(id)
        return 'left' if id == Gosu::KbA or id == Gosu::KbLeft
        return 'right' if id == Gosu::KbD or id == Gosu::KbRight
        return 'up' if id == Gosu::KbW or id == Gosu::KbUp
        return 'down' if id == Gosu::KbS or id == Gosu::KbDown
        return 'kick' if id == Gosu::KbSpace
    end

    def handle_key_held_down(id, mouse_x, mouse_y)
        @player.move_left(@grid) if action_map(id) == 'left'
        @player.move_right(@grid) if action_map(id) == 'right'
        @player.move_up(@grid) if action_map(id) == 'up'
        @player.move_down(@grid) if action_map(id) == 'down'
        #puts "#{@player.x}, #{@player.y}    Camera: #{@camera_x}, #{@camera_y}   Tile: #{@grid.tile_at_absolute(@player.x, @player.y)}"
    end

    def handle_key_press(id, mouse_x, mouse_y)
        @player.start_move_left if action_map(id) == 'left'
        @player.start_move_right if action_map(id) == 'right'
        @player.start_move_up if action_map(id) == 'up'
        @player.start_move_down if action_map(id) == 'down'
        @player.kick if action_map(id) == 'kick'
    end

    def handle_key_up(id, mouse_x, mouse_y)
        if id == Gosu::KbA or id == Gosu::KbD or id == Gosu::KbW or id == Gosu::KbS or
           id == Gosu::KbLeft or id == Gosu::KbRight or id == Gosu::KbUp or id == Gosu::KbDown
            @player.stop_move
        end
    end


end
