
class Character < GameObject 

    def initialize(args = {})
        @animation_count = 1
        @direction = DIRECTION_TOWARDS
        @character_tileset =
          Gosu::Image.load_tiles(
            "media/characters.png", 
            16, 16, 
            tileable: true)
        @img_towards = [@character_tileset[3], @character_tileset[4], @character_tileset[5]]
        @img_left = [@character_tileset[15], @character_tileset[16], @character_tileset[17]]
        @img_right = [@character_tileset[27], @character_tileset[28], @character_tileset[29]]
        @img_away = [@character_tileset[39], @character_tileset[40], @character_tileset[41]]
        @img_array = @img_towards
        super(@img_array[@animation_count])
        disable_border
        @scale = 2     # might need this until we can scale the whole game to 2
        @max_speed = 8
        load_sounds
    end

    def handle_update update_count, mouse_x, mouse_y
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
##        @click1.play
    end 

    def start_move_right
        @img_array = @img_right
        start_move_in_direction(DEG_0)
        @acceleration = 0
        @speed = 1
#        @click1.play
        @typing5.play
    end

    def start_move_left
        @img_array = @img_left
        start_move_in_direction(DEG_180)
        @acceleration = 0
        @speed = 1
#        @click1.play
        @typing5.play
    end 

    def start_move_up
        @img_array = @img_away
        start_move_in_direction(DEG_90)
        @acceleration = 0
        @speed = 1
#        @click1.play
        @typing4.play
    end

    def start_move_down
        @img_array = @img_towards
        start_move_in_direction(DEG_270)
        @acceleration = 0
        @speed = 1
#        @click1.play
        @typing4.play
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
        @typing1 = Gosu::Sample.new('media/sounds/typing3.ogg')
        @typing2 = Gosu::Sample.new('media/sounds/typing3.ogg')
        @typing3 = Gosu::Sample.new('media/sounds/typing3.ogg')
        @typing4 = Gosu::Sample.new('media/sounds/typing4.ogg')
        @typing5 = Gosu::Sample.new('media/sounds/typing5.ogg')
        @typing6 = Gosu::Sample.new('media/sounds/typing6.ogg')
        @typing7 = Gosu::Sample.new('media/sounds/typing7.ogg')
        @click1= Gosu::Sample.new('media/sounds/click.ogg')
        @click2 = Gosu::Sample.new('media/sounds/click2.ogg')
        @click3 = Gosu::Sample.new('media/sounds/rasp_click.ogg')
        @click4 = Gosu::Sample.new('media/sounds/rasp_click2.ogg')
        @click5 = Gosu::Sample.new('media/sounds/rasp_click3.ogg')

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

    def press_z; @typing5.play; end
    def press_y; @typing5.play; end
    def press_f; @typing5.play; end

    def press_q; @typing5.play; end
    def press_e; @typing5.play; end
    def press_r; @typing5.play; end
    def press_t; @typing5.play; end
    def press_x; @typing5.play; end
    def press_c; @typing5.play; end
    def press_v; @typing5.play; end


end 
