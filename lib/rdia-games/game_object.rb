
module RdiaGames

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

        def red(text)  HighLine::color(text, :red)  end
        def blue(text)  HighLine::color(text, :blue)  end
        def cyan(text)  HighLine::color(text, :cyan)  end
        def magenta(text)  HighLine::color(text, :magenta)  end
        def gray(text)    HighLine::color(text, :gray)  end
        def yellow(text)  HighLine::color(text, :yellow)  end
        def green(text)  HighLine::color(text, :green)  end

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

        def overlaps_with_proposed(proposed_x, proposed_y, other_object)
            # Darren
            delta_x = proposed_x - @x
            delta_y = proposed_y - @y

            return true if other_object.contains_click(@x + delta_x, @y + delta_y)
            return true if other_object.contains_click(right_edge + delta_x, @y + delta_y)
            return true if other_object.contains_click(right_edge + delta_x, bottom_edge - 1 + delta_y)
            return true if other_object.contains_click(@x + delta_x, bottom_edge - 1 + delta_y)
            return true if other_object.contains_click(center_x + delta_x, center_y + delta_y)
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
end
