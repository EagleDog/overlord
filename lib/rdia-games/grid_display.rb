
module RdiaGames

    class GridDisplay < Widget 
        attr_accessor :tile_size 
        attr_accessor :grid_width 
        attr_accessor :grid_height 
        attr_accessor :tiles
        attr_accessor :scale
        attr_accessor :display_grid
        attr_accessor :grid_x_offset    # so that we can use negative coordinates 
        attr_accessor :grid_y_offset    

    #
    #
    #
        def initialize(x, y, tile_size, grid_width, grid_height, args = {})
            @scale = 1
            if args[ARG_SCALE]
                @scale = args[ARG_SCALE]
            end
            if args[ARG_X_OFFSET]
                @grid_x_offset = args[ARG_X_OFFSET]
            else 
                @grid_x_offset = 0
            end
            if args[ARG_Y_OFFSET]
                @grid_y_offset = args[ARG_Y_OFFSET]
            else 
                @grid_y_offset = 0
            end
            @tile_size = tile_size * @scale
            @grid_width = grid_width 
            @grid_height = grid_height
            width = @tile_size * @grid_width 
            height = @tile_size * @grid_height
            super(x, y, width, height)
            if args[ARG_THEME]
                @gui_theme = args[ARG_THEME]
            end
            clear_tiles
            @display_grid = false
        end

        def clear_tiles
            @tiles = Array.new(@grid_width) do |x|
                Array.new(@grid_height) do |y|
                    nil
                end 
            end 
        end

        def grid_to_relative_pixel(val)
            # TODO Doesn't this need to factor in scale
            # val * (@tile_size * @scale)
            val * @tile_size
        end

        def determine_grid_x(pixel_x)
            # TODO handle scrolling? Right now we are assuming that the
            # visible area is static, and we don't need to consider
            # where the camera is for this component.
            delta_x = pixel_x - @x 
            tile_x = (delta_x / @tile_size).floor
            #puts "Delta_x: #{delta_x} / #{@tile_size} = #{tile_x} "
            tile_x   
        end

        def determine_grid_y(pixel_y)
            # TODO handle scrolling? Right now we are assuming that the
            # visible area is static, and we don't need to consider
            # where the camera is for this component.
            delta_y = pixel_y - @y 
            tile_y = (delta_y / @tile_size).floor      
            tile_y
        end

        def get_tile(tile_x, tile_y)
            #adjusted_tile_x = tile_x + @grid_x_offset
            #adjusted_tile_y = tile_y + @grid_y_offset
            row = @tiles[tile_x]
            #puts "Get tile #{tile_x}, #{tile_y}   row: #{row}"
            if row.nil?
                return nil 
            end
            #puts "Get tile #{tile_x}, #{tile_y}   going to return: #{row[tile_y]}"
            row[tile_y]
        end 

        def set_tile(tile_x, tile_y, tilepiece)
            adjusted_tile_x = tile_x + @grid_x_offset
            adjusted_tile_y = tile_y + @grid_y_offset
            if adjusted_tile_x < 0 or adjusted_tile_y < 0
                raise "Cannot set tile at negative numbers #{adjusted_tile_x}, #{adjusted_tile_y}"
            end
            # if adjusted_tile_x >= @grid_width
            #     raise "Cannot set tile at x #{adjusted_tile_x}, max width index is #{@grid_width - 1}"
            # elsif adjusted_tile_y >= @grid_height
            #     raise "Cannot set tile at y #{adjusted_tile_y}, max height index is #{@grid_height - 1}"
            # end
            if tilepiece.is_a? Widget
                tilepiece.x = relative_x(grid_to_relative_pixel(adjusted_tile_x))
                tilepiece.y = relative_y(grid_to_relative_pixel(adjusted_tile_y))
                tilepiece.scale = @scale
            end
            @tiles[tile_x][tile_y] = tilepiece 
        end

        def remove_tile_at_absolute(x, y)
            tile_x = (x - @x) / @tile_size
            tile_y = (y - @y) / @tile_size
            remove_tile(tile_x, tile_y)
        end 

        def remove_tile(tile_x, tile_y)
            @tiles[tile_x][tile_y] = nil 
        end

        def render
            (0..grid_width-1).each do |x|
                (0..grid_height-1).each do |y|
                    img = @tiles[x][y]
                    if img.nil?
                        # nothing to do 
                    else 
                        img.draw
                    end 
                end 
            end
            if @display_grid
                display_grid_lines
            end
        end

        def display_grid_lines
            grid_tiles = []

            first_x = relative_x(grid_to_relative_pixel(0))
            last_x = relative_x(grid_to_relative_pixel(@grid_width))
            first_y = relative_y(grid_to_relative_pixel(0))
            last_y = relative_y(grid_to_relative_pixel(@grid_height))

            (0..@grid_width).each do |grid_x|
                dx = relative_x(grid_to_relative_pixel(grid_x))
                line = Line.new(dx, first_y, dx, last_y, COLOR_LIGHT_GRAY)
                line.base_z = 10
                grid_tiles << line
            end

            (0..@grid_height).each do |grid_y|
                dy = relative_y(grid_to_relative_pixel(grid_y))
                line = Line.new(first_x, dy, last_x, dy, COLOR_LIGHT_GRAY)
                line.base_z = 10
                grid_tiles << line
            end

            grid_tiles.each do |gw|
                gw.draw
            end
        end

        # Returns nil if there is no widget at the given pixel position
        # or if it this pixel is occupied, return the widget at that position
        def widget_at_absolute(x, y)
            widget_at_relative(x - @x, y - @y)
        end

        # Returns nil if there is no widget at the given pixel position
        # or if it this pixel is occupied, return the widget at that position
        def widget_at_relative(x, y)
            x_index = x / @tile_size
            y_index = y / @tile_size
            if x_index > @grid_width
                error("Asking for relative widget beyond width: #{x}")
                return nil 
            end
            if y_index > @grid_height
                error("Asking for relative widget beyond height: #{y}")
                return nil 
            end
            @tiles[x_index][y_index]
        end

        def tile_at_absolute(x, y)
            x_index = x / @tile_size
            y_index = y / @tile_size
            [x_index.round, y_index.round, x_index.round * @tile_size, y_index.round * @tile_size]
        end

        def proposed_widget_at(ball, proposed_next_x, proposed_next_y)
            widgets = []
            delta_x = proposed_next_x - ball.x
            delta_y = proposed_next_y - ball.y

            other_widget = widget_at_absolute(ball.x + delta_x, ball.y + delta_y)  # Top left corner check
            if not other_widget.nil?
                widgets << other_widget unless other_widget.no_interactions
            end
            other_widget = widget_at_absolute(ball.right_edge + delta_x, ball.y + delta_y) # Top right corner check
            if not other_widget.nil?
                widgets << other_widget unless other_widget.no_interactions
            end
            other_widget = widget_at_absolute(ball.right_edge + delta_x, ball.bottom_edge + delta_y) # Lower right corner check
            if not other_widget.nil?
                widgets << other_widget unless other_widget.no_interactions
            end
            other_widget = widget_at_absolute(ball.x + delta_x, ball.bottom_edge + delta_y) # Lower left corner check
            if not other_widget.nil?
                widgets << other_widget unless other_widget.no_interactions
            end
            other_widget = widget_at_absolute(ball.center_x + delta_x, ball.center_y + delta_y) # Center check
            if not other_widget.nil?
                widgets << other_widget unless other_widget.no_interactions
            end
            # TODO Make dedup more efficient
            #info("Before Deduped there are #{widgets.size} widgets")
            ids = Set.new
            deduped_widgets = []
            widgets.each do |w|
                if ids.include? w.object_id 
                    # skip
                else 
                    ids.add(w.object_id)
                    if w.inner_contains_ball(ball)
                        deduped_widgets << w 
                    end
                end 
            end
            #info("Deduped there are #{deduped_widgets.size} widgets")
            deduped_widgets
        end

    end
end
