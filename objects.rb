# objects.rb  Ballrag

class Ballrag < GameObject
    def initialize
        super(COLOR_WHITE)
        @x = 250
        @y = 150
        set_dimensions(15, 15)
        init_direction_and_speed
    end

    def init_direction_and_speed 
        @direction = DEG_0
        @acceleration = 10
        @speed = 1
    end

    def move1; @x += 1; @y += 1; end
    def move2; @x += 1; @y -= 1; end
    def move3; @x += 1; @y += 2; end
    def move4; @x += 1; @y -= 2; end

    def check_sector(n)
        if n <  400;              return 1; end
        if n >= 400 and n < 500;  return 2; end
        if n >= 500 and n < 600;  return 3; end
        if n >= 600 and n < 700;  return 4; end
        if n >= 700 and n < 800;  return 5; end
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


    def update(update_count, mouse_x, mouse_y)
        @x += @speed
        @speed -= 1.0 if @speed > 0

        # move1 if check_sector(@x) == 1
        # move2 if check_sector(@x) == 2
        # move3 if check_sector(@x) == 3
        # move4 if check_sector(@x) == 4
    end

end

