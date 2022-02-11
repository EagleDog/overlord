#require 'wads'
require 'securerandom'
require 'set'
require 'highline'

include Wads 

require_relative 'grid_display'

# class ProgressBar < Widget
# class Point
# class GameObject < ImageWidget
# class Ball < GameObject
# class Player < GameObject
# class GridDisplay < Widget



module RdiaGames

    # Possible interactions when one object hits another
    RDIA_REACT_BOUNCE = "bounce"
    RDIA_REACT_ONE_WAY = "oneway"
    RDIA_REACT_BOUNCE_DIAGONAL = "diagonal"
    RDIA_REACT_CONSUME = "consume"
    RDIA_REACT_GOAL = "goal"
    RDIA_REACT_STOP = "stop"
    RDIA_REACT_SCORE = "score"
    RDIA_REACT_LOSE = "lose"

    QUAD_NW = 1
    QUAD_N = 2
    QUAD_NE = 3
    QUAD_E = 4
    QUAD_SE = 5
    QUAD_S = 6
    QUAD_SW = 7
    QUAD_W = 8

    TIE_DIM = 0
    X_DIM = 1
    Y_DIM = 2

    AXIS_VALUES = {}
    AXIS_VALUES[QUAD_NW] = DEG_45 
    AXIS_VALUES[QUAD_SW] = DEG_135 
    AXIS_VALUES[QUAD_SE] = DEG_225 
    AXIS_VALUES[QUAD_NE] = DEG_315

    class ProgressBar < Widget
        attr_accessor :percent_full
        attr_accessor :counter_delay

        def initialize(x, y, w, h, args = {})
            super(x, y, w, h)
            @percent_full = 1
            @timer_start_count = nil
            @pause = true
            if args[ARG_DELAY]
                @counter_delay = args[ARG_DELAY]
            else
                @counter_delay = 360
            end
            if args[ARG_PROGRESS_AMOUNT]
                @increment_amount = args[ARG_PROGRESS_AMOUNT]
            else 
                @increment_amount = 0.05
            end
            if args[ARG_THEME]
                @gui_theme = args[ARG_THEME]
            end
        end

        def start
            @pause = false 
        end 

        def stop 
            @pause = true 
        end 

        def is_done 
            @percent_full <= 0
        end 

        def scale(value, max_value)
            @percent_full = value.to_f / max_value.to_f 
        end

        def render 
            x_width = (@width.to_f * @percent_full).round - 1
            if x_width < 0
                x_width = 0
            end
            Gosu::draw_rect(@x, @y + 1, x_width, @height - 1, graphics_color, relative_z_order(Z_ORDER_GRAPHIC_ELEMENTS))
        end

        def handle_update update_count, mouse_x, mouse_y
            if @pause 
                # do nothing 
            else 
                if @timer_start_count.nil?
                    @timer_start_count = 0 
                else 
                    @timer_start_count = @timer_start_count + 1
                    if @timer_start_count > @counter_delay
                        decrease_percent_full 
                        @timer_start_count = 0
                    end
                end
            end
        end

        def decrease_percent_full(amount = @increment_amount)
            if amount > 1
                amount = amount / 100
            end
            @percent_full = @percent_full - amount
            result = is_done 
            if result 
                @pause = true 
            end
            result
        end

        def reset 
            @percent_full = 1
        end
    end

    class Point
        attr_accessor :x
        attr_accessor :y 
    
        def initialize(x, y) 
            @x = x 
            @y = y 
        end
    
        def distance_x(other_point)
            other_point.x - @x
        end 

        def distance_y(other_point)
            other_point.y - @y
        end 
    
        def abs_distance(other_point)
            (other_point.x - @x).abs + (other_point.y - @y).abs
        end 

        def abs_distance_x(other_point)
            (other_point.x - @x).abs
        end 

        def abs_distance_y(other_point)
            (other_point.y - @y).abs
        end 
    end 
    
    class GameObject < ImageWidget 
        attr_accessor :direction
        attr_accessor :speed
        attr_accessor :acceleration
        attr_accessor :can_move
        attr_accessor :object_id
        attr_accessor :last_element_bounce
        attr_accessor :max_speed

        def initialize(image, args = {})
            super(0, 0, image)
            @last_x = 0 
            @last_y = 0
            @object_id = SecureRandom.uuid[-6..-1]
            init_direction_and_speed
            @can_move = true  # Set to false if this is a wall or other immovable object
            @max_speed = 20
        end

        def interaction_results
            []
        end

        def no_interactions
            interaction_results.empty?
        end

        def red(text)
            HighLine::color(text, :red)
        end
        def blue(text)
            HighLine::color(text, :blue)
        end
        def cyan(text)
            HighLine::color(text, :cyan)
        end
        def magenta(text)
            HighLine::color(text, :magenta)
        end
        def gray(text)
            HighLine::color(text, :gray)
        end
        def yellow(text)
            HighLine::color(text, :yellow)
        end
        def green(text)
            HighLine::color(text, :green)
        end

        def log_debug(update_count, loop_count)
            if @last_log_debug.nil?
                @last_log_debug = Gosu.milliseconds 
            else 
                current_time = Gosu.milliseconds 
                if (current_time - @last_log_debug) > 100
                    puts gray "#{pad("Count", 8)}  #{pad("x",6)}, #{pad("y",6)} (#{pad("delx",4)}, #{pad("dely",4)}) #{pad("dir",5)}  #{pad("speed",5)}  #{pad("accel",5)}" 
                    puts gray "#{pad("-----", 8)}  #{pad("------",6)}, #{pad("------",6)} (#{pad("----",4)}, #{pad("----",4)}) #{pad("---",5)}  #{pad("-----",5)}  #{pad("-----",5)}" 
                    @last_log_debug = current_time 
                end
            end

            delta_x = @x - @last_x
            delta_y = @y - @last_y
            puts "#{pad(update_count, 5)}.#{pad(loop_count,2,true)}  #{pad(@x,6)}, #{pad(@y,6)} (#{pad(delta_x,4)}, #{pad(delta_y,4)}) #{pad(@direction,5)}  #{pad(@speed,5)}  #{pad(@acceleration,5)}" 
            @last_x = @x 
            @last_y = @y 
        end 

        def center_mass 
            Point.new(center_x, center_y)
        end

        def top_left
            Point.new(@x, @y)
        end

        def top_right
            Point.new(right_edge, @y)
        end

        def bottom_left
            Point.new(@x, bottom_edge)
        end

        def bottom_right
            Point.new(right_edge, bottom_edge)
        end

        def contains_point(point)
            point.x >= @x and point.x <= right_edge and point.y >= @y and point.y <= bottom_edge
        end
    
        def init_direction_and_speed 
            @direction = DEG_0
            @acceleration = 0
            @speed = 0
        end

        def is_stopped 
            @speed < 0.001
        end

        def speed_up 
            if @acceleration < 4
                @acceleration = @acceleration + 0.1
            end
            @speed = @speed + @acceleration
            if @speed > @max_speed
                @speed = @max_speed
            end
        end 
    
        def slow_down 
            if @acceleration > 0
                @acceleration = @acceleration - 0.1
            end
            @speed = @speed - @acceleration
            if @speed < 0
                @speed = 0
            end
        end 

        def start_move_in_direction(direction)
            if direction.is_a? Numeric
                @direction = direction 
            else 
                raise "move_in_direction takes a numeric value in radians"
            end 
        end 

        def start_move_right
            start_move_in_direction(DEG_0)
            @acceleration = 0
            @speed = 0
        end

        def start_move_left
            start_move_in_direction(DEG_180)
            @acceleration = 0
            @speed = 0
        end

        def proposed_move
            [@x + Math.cos(@direction), @y - Math.sin(@direction)]
        end

        def stop_move
            @acceleration = 0
            @speed = 0
        end

        def inner_contains_ball(ball)
            true
        end

        def distance_between_center_mass(other_object)
            (other_object.center_x - center_x).abs + (other_object.center_y - center_y).abs
        end 

        def relative_quad(other_object)
            # TODO we don't consider N, S, E, W right now
            if @x < other_object.x
                # West side
                if @y < other_object.y 
                    return QUAD_NW 
                else 
                    return QUAD_SW 
                end
            else 
                # East side
                if @y < other_object.y 
                    return QUAD_NE
                else 
                    return QUAD_SE 
                end
            end
        end
    
        def x_or_y_dimension_greater_distance(x, y)
            dx = (x - center_x).abs
            dy = (y - center_y).abs
            if dx == dy 
                return TIE_DIM 
            elsif dx < dy 
                return Y_DIM 
            end  
            return X_DIM
        end

        def overlaps_with_proposed(proposed_x, proposed_y, other_widget)
            # Darren
            delta_x = proposed_x - @x
            delta_y = proposed_y - @y

            if other_widget.contains_click(@x + delta_x, @y + delta_y)
                return true
            end
            if other_widget.contains_click(right_edge + delta_x, @y + delta_y)
                return true
            end
            if other_widget.contains_click(right_edge + delta_x, bottom_edge - 1 + delta_y)
                return true
            end
            if other_widget.contains_click(@x + delta_x, bottom_edge - 1 + delta_y)
                return true
            end
            if other_widget.contains_click(center_x + delta_x, center_y + delta_y)
                return true
            end
            return false
        end

        #
        # Radians bounce helpers
        #
        def will_hit_axis(axis) 
            begin_range = axis 
            end_range = axis - DEG_180
            if end_range < DEG_0
                end_range = DEG_360 - end_range.abs
            end 
            #puts "Axis #{axis}  Begin/end  #{begin_range}/#{end_range}   #{radians}"
            if begin_range < end_range 
                return (@direction < begin_range or @direction > end_range)
            end
            @direction < begin_range and @direction > end_range
        end 
        
        def bounce_x
            @direction = calculate_bounce(DEG_270)
        end
    
        def bounce_y
            @direction = calculate_bounce(DEG_360)
        end

        def bounce(axis)
            #puts "START bounce #{axis}. Direction #{@direction}"
            @direction = calculate_bounce(axis)
            #puts "END bounce #{axis}. Direction #{@direction}"
        end

        def calculate_bounce(axis)
            truncate_bounce(reflect_bounce(axis, @direction))
        end
        
        def truncate_bounce(radians)
            if radians < DEG_0
                return DEG_360 - radians.abs 
            elsif radians > DEG_360 
                return radians - DEG_360 
            end
            radians 
        end
        
        def reflect_bounce(axis, radians)
            amount_reflection = axis - radians
            radians = axis + amount_reflection
        end
    end 

    class Ball < GameObject
        def initialize(x, y)
            super(COLOR_WHITE)
            init_direction_and_speed 
            set_absolute_position(x, y)
            set_dimensions(12, 12)
        end

        def calc_aim_point(aim_rad, proposed_speed) 
            aim_x = center_x + (proposed_speed.to_f * Math.cos(aim_rad))
            aim_y = center_y - (proposed_speed.to_f * Math.sin(aim_rad))
            Point.new(aim_x, aim_y)
        end
    end 

    class Player < GameObject 
        attr_accessor :tile_width 
        attr_accessor :tile_height 

        def initialize(image, tile_width, tiles_height, args = {})
            super(image)
            @tile_width = tile_width 
            @tile_height = tile_height
            width = image.width * tile_width
            height = image.height * tiles_height
            set_dimensions(width, height)
            disable_border
        end

        def render 
            x = @x
            tile_width.times do 
                @img.draw x, @y, relative_z_order(Z_ORDER_GRAPHIC_ELEMENTS)
                x = x + @img.width 
            end
        end

        def move_right(grid)
            speed_up
            player_move(grid)
        end

        def move_left(grid)
            speed_up
            player_move(grid)
        end

        def player_move(grid)
            @speed.round.times do
                proposed_next_x, proposed_next_y = proposed_move
                widgets_at_proposed_spot = grid.proposed_widget_at(self, proposed_next_x, proposed_next_y)
                if widgets_at_proposed_spot.empty?
                    set_absolute_position(proposed_next_x, proposed_next_y)
                else 
                    debug("Can't move any further because widget(s) are there #{widgets_at_proposed_spot}")
                end
            end
        end
    end 

end
