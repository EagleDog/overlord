
class Mob < GameObject

    def initialize(args = {})
        @animation_count = 1
        @direction = DIRECTION_TOWARDS
        @mob_sheet =
          Gosu::Image.load_tiles(
            args, 
            16, 16, 
            tileable: true)
        @img_towards = [@mob_sheet[0], @mob_sheet[1], @mob_sheet[2]]
        @img_left = [@mob_sheet[3], @mob_sheet[4], @mob_sheet[4]]
        @img_right = [@mob_sheet[6], @mob_sheet[7], @mob_sheet[8]]
        @img_away = [@mob_sheet[9], @mob_sheet[10], @mob_sheet[11]]
        @img_array = @img_towards
        super(@img_array[@animation_count])
        disable_border
        @scale = 2     # might need this until we can scale the whole game to 2
        @max_speed = 20
        @speed = 10
        puts args
    end


    def choose_direction
        if rand(8) == 4; @direction = DIRECTION_TOWARDS; end
    end

    def move_it(grid)
        return if choice(2)
        return if choice(2)
        return if choice(2)
        return if choice(2)
        return if choice(2)
        if choice(4);   go_left(grid)
        elsif choice(3);   go_right(grid)
        elsif choice(2);   go_up(grid)
        elsif choice(2);   go_down(grid)
        end

    end

    def choice(probability)
        if rand(4) == 1
           return true
        end
    end

    def handle_update update_count, mouse_x, mouse_y
#        move

        if @speed < 0.01
            @img = @img_array[1]
        elsif update_count % 10 == 0    # if we do this every count, you can't even see it
            @animation_count = @animation_count + 1
            if @animation_count > 2
                @animation_count = 0
            end
            @img = @img_array[@animation_count]
        end
    end 

    def kick
        puts "kick"
        @chirp1.play
    end


    def stop_move 
        @speed = 0
        puts "stop move"
#        @click2.play
#        @typing7.play
    end 

    def start_move_right
        @img_array = @img_right
        start_move_in_direction(DEG_0)
        @acceleration = 1
        @speed = 2
    end

    def start_move_left
        @img_array = @img_left
        start_move_in_direction(DEG_180)
        @acceleration = 1
        @speed = 1
    end 

    def start_move_up
        @img_array = @img_away
        start_move_in_direction(DEG_90)
        @acceleration = 1
        @speed = 1
    end

    def start_move_down
        @img_array = @img_towards
        start_move_in_direction(DEG_270)
        @acceleration = 1
        @speed = 1
    end

    def internal_move(grid) 
        if @speed < @max_speed
            speed_up
        end
        move(grid)
    end 

    def move_right(grid);    internal_move(grid) ;    end
    def move_left(grid);     internal_move(grid);    end
    def move_up(grid);      internal_move(grid);    end
    def move_down(grid);    internal_move(grid);    end

    def go_left(grid)
        start_move_left
        internal_move(grid)
    end
    def go_right(grid)
        start_move_right
        internal_move(grid)
    end
    def go_up(grid)
        start_move_up
        internal_move(grid)
    end
    def go_down(grid)
        start_move_down
        internal_move(grid)
    end



    def move(grid)
#        @click3.play
        @speed.round.times do
            proposed_next_x, proposed_next_y = proposed_move
            occupants = grid.proposed_widget_at(self, proposed_next_x, proposed_next_y)
            if occupants.empty?
                set_absolute_position(proposed_next_x, proposed_next_y)
            else 
                # determine what interactions occur with this object
                # List of possible interactions
                # RDIA_REACT_BOUNCE
                # RDIA_REACT_ONE_WAY
                # RDIA_REACT_BOUNCE_DIAGONAL
                # RDIA_REACT_CONSUME
                # RDIA_REACT_GOAL
                # RDIA_REACT_STOP
                # RDIA_REACT_SCORE
                # RDIA_REACT_LOSE
                stop_motion = false
                occupants.each do |waps|
                    if waps.interaction_results.include? RDIA_REACT_STOP
                        stop_motion = true 
                    end 
                end 
                if !stop_motion
                    set_absolute_position(proposed_next_x, proposed_next_y)
                end
                # 
# Player debug     info("Player can't move any further: " +
#                        "#{occupants.size} " +
#                        "widget(s) are there ")
            end
        end
    end

    def load_sounds
        @beep = Gosu::Sample.new('media/sounds/beep.ogg')
        @chime = Gosu::Sample.new('media/sounds/chime.ogg')
        @explosion = Gosu::Sample.new('media/sounds/explosion.ogg')
        @typing3 = Gosu::Sample.new('media/sounds/typing3.ogg')
        @typing4 = Gosu::Sample.new('media/sounds/typing4.ogg')
        @typing5 = Gosu::Sample.new('media/sounds/typing5.ogg')
        @typing6 = Gosu::Sample.new('media/sounds/typing6.ogg')
        @typing7 = Gosu::Sample.new('media/sounds/typing7.ogg')
        @click = Gosu::Sample.new('media/sounds/click.ogg')
        @click2 = Gosu::Sample.new('media/sounds/click2.ogg')
        @click3 = Gosu::Sample.new('media/sounds/cancel_sine1.ogg')

        @beep1 = Gosu::Sample.new('media/beeps/beep1.ogg')
        @beep2 = Gosu::Sample.new('media/beeps/beep2.ogg')
        @beep3 = Gosu::Sample.new('media/beeps/beep3.ogg')
        @beep4 = Gosu::Sample.new('media/beeps/beep4.ogg')
        @beep5 = Gosu::Sample.new('media/beeps/beep5.ogg')
        @beep6 = Gosu::Sample.new('media/beeps/beep6.ogg')
        @beep7 = Gosu::Sample.new('media/beeps/beep7.ogg')

        @chirp1 = Gosu::Sample.new('media/beeps/chirp1.ogg')
        @chirp2 = Gosu::Sample.new('media/beeps/chirp2.ogg')


    end

end 
