
class Character < GameObject 

    def initialize(args = {})
        @animation_count = 1
        @direction = DIRECTION_TOWARDS
        @character_tileset = Gosu::Image.load_tiles(MEDIA_PATH + "characters.png", 16, 16, tileable: true)
        @img_towards = [@character_tileset[3], @character_tileset[4], @character_tileset[5]]
        @img_left = [@character_tileset[15], @character_tileset[16], @character_tileset[17]]
        @img_right = [@character_tileset[27], @character_tileset[28], @character_tileset[29]]
        @img_away = [@character_tileset[39], @character_tileset[40], @character_tileset[41]]
        @img_array = @img_towards
        super(@img_array[@animation_count])
        disable_border
        @scale = 2     # might need this until we can scale the whole game to 2
        @max_speed = 5
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

    def stop_move 
        @speed = 0
    end 

    def start_move_right
        @img_array = @img_right
        start_move_in_direction(DEG_0)
        @acceleration = 0
        @speed = 1
    end

    def start_move_left
        @img_array = @img_left
        start_move_in_direction(DEG_180)
        @acceleration = 0
        @speed = 1
    end 

    def start_move_up
        @img_array = @img_away
        start_move_in_direction(DEG_90)
        @acceleration = 0
        @speed = 1
    end

    def start_move_down
        @img_array = @img_towards
        start_move_in_direction(DEG_270)
        @acceleration = 0
        @speed = 1
    end

    def internal_move(grid) 
        if @speed < @max_speed
            speed_up
        end
        player_move(grid)
    end 

    def move_right(grid)
        internal_move(grid) 
    end

    def move_left(grid)
        internal_move(grid)
    end

    def move_up(grid)
        internal_move(grid) 
    end

    def move_down(grid)
        internal_move(grid) 
    end

    def player_move(grid)
        @speed.round.times do
            proposed_next_x, proposed_next_y = proposed_move
            widgets_at_proposed_spot = grid.proposed_widget_at(self, proposed_next_x, proposed_next_y)
            if widgets_at_proposed_spot.empty?
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
                widgets_at_proposed_spot.each do |waps|
                    if waps.interaction_results.include? RDIA_REACT_STOP
                        stop_motion = true 
                    end 
                end 
                if !stop_motion
                    set_absolute_position(proposed_next_x, proposed_next_y)
                end
                # 
                #    info("Can't move any further because #{widgets_at_proposed_spot.size} widget(s) are there ")
            end
        end
    end
end 
