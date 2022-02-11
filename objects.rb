# objects.rb
#
#

class Ballrag < GameObject
    def initialize
        def initialize(x, y)
            super(COLOR_WHITE)
            @x = x
            @y = y
            init_direction_and_speed 
            set_absolute_position(x, y)
            set_dimensions(12, 12)
        end
    end

    def update(update_count, mouse_x, mouse_y)


    end

end
