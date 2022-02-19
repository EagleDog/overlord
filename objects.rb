# objects.rb  Ballrag

class Ballrag < GameObject
    def initialize
        super(COLOR_WHITE)
        @x = 150
        @y = 200
        set_dimensions(15, 15)
        init_direction_and_speed
    end

    def init_direction_and_speed 
        @direction = DEG_45
        @acceleration = 0
        @speed = 10
    end


    def interaction_results
        [RDIA_REACT_BOUNCE, RDIA_REACT_BOUNCE_DIAGONAL]
    end

    def bounce_x
        @direction = calculate_bounce(DEG_270)
    end

    def bounce_y
        @direction = calculate_bounce(DEG_360)
    end


    def handle_update(update_count, mouse_x, mouse_y)
#        @x += @speed
#        @y += @speed
        @speed -= 1.0 if @speed > 0

    end

end

