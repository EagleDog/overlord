
class ScrollerDisplay < Widget
    def initialize
        super(0, 0, GAME_WIDTH, GAME_HEIGHT)
        set_layout(LAYOUT_HEADER_CONTENT)
        #set_theme(WadsDarkRedBrownTheme.new)
        disable_border
        @pause = true
        @game_mode = RDIA_MODE_START
        @score = 0
        @level = 1
        @camera_x = 0
        @camera_y = 0

        header_panel = add_panel(SECTION_NORTH)
        header_panel.get_layout.add_text("Test Scroller",
                                         { ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER,
                                           ARG_USE_LARGE_FONT => true})
        subheader_panel = header_panel.get_layout.add_vertical_panel({ARG_LAYOUT => LAYOUT_EAST_WEST,
                                                                      ARG_DESIRED_WIDTH => GAME_WIDTH})
        subheader_panel.disable_border
        west_panel = subheader_panel.add_panel(SECTION_WEST)
        west_panel.get_layout.add_text("Score")
        @score_text = west_panel.get_layout.add_text("#{@score}")
        
        east_panel = subheader_panel.add_panel(SECTION_EAST)
        east_panel.get_layout.add_text("Level", {ARG_TEXT_ALIGN => TEXT_ALIGN_RIGHT})
        @level_text = east_panel.get_layout.add_text("#{@level}",
                                                     {ARG_TEXT_ALIGN => TEXT_ALIGN_RIGHT})
        
        # TODO put this back when we are ready to release, instructions to the user
        #add_overlay(create_overlay_widget)

        @tileset = Gosu::Image.load_tiles(MEDIA_PATH + "basictiles.png", 16, 16, tileable: true)
        @blue_brick = @tileset[1]   # the brick with an empty pixel on the left and right, so there is a gap
        @red_wall = @tileset[7]
        @yellow_dot = @tileset[18]
        @green_dot = @tileset[19]
        @fire_transition_tile = @tileset[66]
        @diagonal_tileset = Gosu::Image.load_tiles(MEDIA_PATH + "diagonaltiles.png", 16, 16, tileable: true)
        @red_wall_se = @diagonal_tileset[0]
        @red_wall_sw = @diagonal_tileset[7]
        @red_wall_nw = @diagonal_tileset[13]
        @red_wall_ne = @diagonal_tileset[10]

        @player = Character.new
        @player.set_absolute_position(400, 150)
        add_child(@player)

        # @ball = Ballrag.new #(200, 200)
        # @ball.start_move_in_direction(DEG_90 - 0.2)
        # add_child(@ball)

        @grid = GridDisplay.new(0, 0, 16, 50, 38, {ARG_SCALE => 2})
        instantiate_elements(File.readlines("maps/maps/aboard1.txt"))
        add_child(@grid)
    end 

    def draw 
        if @show_border
            draw_border
        end
        @children.each do |child|
            if child.is_a? GridDisplay or child.is_a? Character
                # skip
            else
                child.draw
            end
        end

        Gosu.translate(-@camera_x, -@camera_y) do
            @grid.draw
            @player.draw
        end
    end 

    def handle_update update_count, mouse_x, mouse_y
        # Scrolling follows player
        # @camera_x = [[@cptn.x - WIDTH / 2, 0].max, @map.width * 50 - WIDTH].min
        # @camera_y = [[@cptn.y - HEIGHT / 2, 0].max, @map.height * 50 - HEIGHT].min 
        @camera_x = [[@player.x - (GAME_WIDTH.to_f / 2), 0].max, @grid.grid_width * 32 - GAME_WIDTH].min
        @camera_y = [[@player.y - (GAME_HEIGHT.to_f / 2), 0].max, @grid.grid_height * 32 - GAME_HEIGHT].min
        #puts "#{@player.x}, #{@player.y}    Camera: #{@camera_x}, #{@camera_y}"
    end

    def interact_with_widgets(widgets)
        if widgets.size == 1
            w = widgets[0]
            if w.object_id == @ball.last_element_bounce
                # Don't bounce off the same element twice
                w = nil 
            end
        else 
            # Choose the widget with the shortest distance from the center of the ball
            closest_widget = nil 
            closest_distance = 100   # some large number
            widgets.each do |candidate_widget| 
                d = @ball.distance_between_center_mass(candidate_widget)
                debug("Comparing #{d} with #{closest_distance}. Candidate #{candidate_widget.object_id}  last bounce: #{@ball.last_element_bounce}")
                if d < closest_distance and candidate_widget.object_id != @ball.last_element_bounce
                    closest_distance = d 
                    closest_widget = candidate_widget 
                end 
            end 
            w = closest_widget
        end
        if w.nil?
            return true
        end
        puts "Reaction #{w.interaction_results} with widget #{w}"
        @ball.last_element_bounce = w.object_id
        if w.interaction_results.include? RDIA_REACT_STOP 
            @ball.stop_move
        end
        if w.interaction_results.include? RDIA_REACT_LOSE 
            @pause = true
            @game_mode = RDIA_MODE_END
            if @overlay_widget.nil?
                add_overlay(create_you_lose_widget)
            end
        end
        if w.interaction_results.include? RDIA_REACT_BOUNCE 
            square_bounce(w)
        elsif w.interaction_results.include? RDIA_REACT_BOUNCE_DIAGONAL
            diagonal_bounce(w)
        end
        if w.interaction_results.include? RDIA_REACT_CONSUME
            @grid.remove_tile_at_absolute(w.x + 1, w.y + 1)
        end
        if w.interaction_results.include? RDIA_REACT_GOAL
            # TODO end this round
        end
        if w.interaction_results.include? RDIA_REACT_SCORE
            @score = @score + w.score
            @score_text.label = "#{@score}"
        end
        if w.interaction_results.include? RDIA_REACT_GOAL
            @pause = true
            @game_mode = RDIA_MODE_END
            if @overlay_widget.nil?
                add_overlay(create_you_win_widget)
            end
        end
        true
    end

    def handle_key_held_down id, mouse_x, mouse_y
        if id == Gosu::KbA or id == Gosu::KbLeft
            @player.move_left(@grid)
        elsif id == Gosu::KbD or id == Gosu::KbRight
            @player.move_right(@grid)
        elsif id == Gosu::KbW or id == Gosu::KbUp
            @player.move_up(@grid)
        elsif id == Gosu::KbS or id == Gosu::KbDown
            @player.move_down(@grid)
        end
        #puts "#{@player.x}, #{@player.y}    Camera: #{@camera_x}, #{@camera_y}   Tile: #{@grid.tile_at_absolute(@player.x, @player.y)}"
    end

    def handle_key_press id, mouse_x, mouse_y
        if id == Gosu::KbA or id == Gosu::KbLeft
            @player.start_move_left 
        elsif id == Gosu::KbD or id == Gosu::KbRight
            @player.start_move_right 
        elsif id == Gosu::KbW or id == Gosu::KbUp
            @player.start_move_up 
        elsif id == Gosu::KbS or id == Gosu::KbDown
            @player.start_move_down
        end
    end

    def handle_key_up id, mouse_x, mouse_y
        if id == Gosu::KbA or id == Gosu::KbD or id == Gosu::KbW or id == Gosu::KbS or
           id == Gosu::KbLeft or id == Gosu::KbRight or id == Gosu::KbUp or id == Gosu::KbDown
            @player.stop_move
        end
    end

    def intercept_widget_event(result)
        info("We intercepted the event #{result.inspect}")
        info("The overlay widget is #{@overlay_widget}")
        if result.close_widget 
            if @game_mode == RDIA_MODE_START
                @game_mode = RDIA_MODE_PLAY
                @pause = false 
            elsif @game_mode == RDIA_MODE_END
                @game_mode = RDIA_MODE_START
            end
        end
        result
    end

    # Takes an array of strings that represents the board
    def instantiate_elements(dsl)         
        @grid.clear_tiles
        grid_y = 0
        grid_x = 0
        dsl.each do |line|
            index = 0
            while index < line.size
                char = line[index..index+1].strip
                #puts "[#{index}  #{grid_x},#{grid_y} = #{char}."
                img = nil

                # If the token is a number, use it as the tile index
                if char.match?(/[[:digit:]]/)
                    tile_index = char.to_i
                    #puts "Using index #{tile_index}."
                    # This is temporary, we need a way to define and store metadata for tiles
                    if tile_index == 5
                        img = Wall.new(@tileset[tile_index])
                    else
                        img = BackgroundArea.new(@tileset[tile_index])
                    end
                #elsif char == "B"
                #    img = Brick.new(@blue_brick)
                elsif char == "W"
                    img = Wall.new(@blue_brick)
                elsif char == "Y"
                    img = Dot.new(@yellow_dot)
                elsif char == "G"
                    img = Dot.new(@green_dot)
                elsif char == "F"
                    img = OutOfBounds.new(@fire_transition_tile)
                end
                
                if img.nil?
                    # nothing to do
                else
                    @grid.set_tile(grid_x, grid_y, img)
                end

                grid_x = grid_x + 1
                index = index + 2
            end
            grid_x = 0
            grid_y = grid_y + 1
        end
    end 
end
