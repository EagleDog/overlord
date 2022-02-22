# objects.rb  Ballrag

class Ballrag < BallObject
    def initialize
        super("media/ball.png")
        @x = 150
        @y = 200
        set_dimensions(15, 15)
        setup
        init_direction_and_speed
        puts "initialize ball"
    end

    def setup
        @bouncing = false
    end

    def thrust
        puts "thrust"
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
        @bouncing = true
    end

    def bounce_y
        @direction = calculate_bounce(DEG_360)
        @bouncing = true
    end

    def render 
        @img.draw @x, @y, z_order, @scale, @scale
    end

#     def handle_update(update_count, mouse_x, mouse_y)
# #        @x += @speed
# #        @y += @speed
#         @speed -= 1.0 if @speed > 0

#     end

end

