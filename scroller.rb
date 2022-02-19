#
#    SCROLLER    SCROLLER    SCROLLER    SCROLLER
#
#         Main Game Logic for Overlord
#

require_relative 'worldmap'

class Scroller < Widget
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

        # @left, @right, @up, @down = ''
        # TODO put this back when we are ready 
        # to release, instructions to the user
        # add_overlay(create_overlay_widget)

        # initialize




        @grid = GridDisplay.new(0, 0, 16, 50, 38, {ARG_SCALE => 2})
        @worldmap = WorldMap.new(@grid)

        load_panels

        @worldmap.load_tiles

        load_player
        load_ball

        load_map

    end 

    def load_player                          # LOAD_PLAYER
        @player = Character.new
        @player.set_absolute_position(500, 150)
        add_child(@player)
    end

    def load_ball                             # LOAD_BALL
        @ball = Ballrag.new
        add_child(@ball)
    end


    def load_map                              # LOAD_MAP


        @worldmap.create_board(File.readlines("maps/maps/aboard1.txt"))

        add_child(@grid)

    end


    def draw                       #  DRAW   DRAW   DRAW   DRAW
        if @show_border
            draw_border
        end
        @children.each do |child|
            if child.is_a? GridDisplay or child.is_a? Character or child.is_a? Ballrag
                # skip
            else
                child.draw
            end
        end

        Gosu.translate(-@camera_x, -@camera_y) do
            @grid.draw
            @player.draw
            @ball.draw
        end
    end 

    #   HANDLE_UPDATE              HANDLE_UPDATE   HANDLE_UPDATE
    def handle_update update_count, mouse_x, mouse_y
        ball_logic
        # Scrolling follows player
        # @camera_x = [[@cptn.x - WIDTH / 2, 0].max, @map.width * 50 - WIDTH].min
        # @camera_y = [[@cptn.y - HEIGHT / 2, 0].max, @map.height * 50 - HEIGHT].min 
        @camera_x = [[@player.x - (GAME_WIDTH.to_f / 2), 0].max, @grid.grid_width * 32 - GAME_WIDTH].min
        @camera_y = [[@player.y - (GAME_HEIGHT.to_f / 2), 0].max, @grid.grid_height * 32 - GAME_HEIGHT].min
        #puts "#{@player.x}, #{@player.y}    Camera: #{@camera_x}, #{@camera_y}"

        interact_with_widgets(children)
    end

    def ball_logic              #  BALL_LOGIC   BALL_LOGIC  BALL_LOGIC
        proposed_next_x, proposed_next_y = @ball.proposed_move
        widgets_at_proposed_spot = @grid.proposed_widget_at(@ball, proposed_next_x, proposed_next_y)
        if widgets_at_proposed_spot.empty?
            if @ball.overlaps_with_proposed(proposed_next_x, proposed_next_y, @player)
                #info("We hit the player!")
                bounce_off_player(proposed_next_x, proposed_next_y)
            else
                @ball.set_absolute_position(proposed_next_x, proposed_next_y)
            end
        else 
            #info("Found candidate widgets to interact")
            if interact_with_widgets(widgets_at_proposed_spot) #, update_count)
                @ball.set_absolute_position(proposed_next_x, proposed_next_y) 
            end
        end
    end



    def interact_with_widgets(widgets)      #  INTERACT     INTERACT
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

    def action_map(id)
        return 'left' if id == Gosu::KbA or id == Gosu::KbLeft
        return 'right' if id == Gosu::KbD or id == Gosu::KbRight
        return 'up' if id == Gosu::KbW or id == Gosu::KbUp
        return 'down' if id == Gosu::KbS or id == Gosu::KbDown
    end

    def handle_key_held_down(id, mouse_x, mouse_y)
        @player.move_left(@grid) if action_map(id) == 'left'
        @player.move_right(@grid) if action_map(id) == 'right'
        @player.move_up(@grid) if action_map(id) == 'up'
        @player.move_down(@grid) if action_map(id) == 'down'
        #puts "#{@player.x}, #{@player.y}    Camera: #{@camera_x}, #{@camera_y}   Tile: #{@grid.tile_at_absolute(@player.x, @player.y)}"
    end

    def handle_key_press(id, mouse_x, mouse_y)
        @player.start_move_left if action_map(id) == 'left'
        @player.start_move_right if action_map(id) == 'right'
        @player.start_move_up if action_map(id) == 'up'
        @player.start_move_down if action_map(id) == 'down'
    end

    def handle_key_up(id, mouse_x, mouse_y)
        if id == Gosu::KbA or id == Gosu::KbD or id == Gosu::KbW or id == Gosu::KbS or
           id == Gosu::KbLeft or id == Gosu::KbRight or id == Gosu::KbUp or id == Gosu::KbDown
            @player.stop_move
        end
    end

    def intercept_widget_event(result)          #  INTERCEPT    INTERCEPT
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


    def load_panels                     #  LOAD_PANELS    LOAD_PANELS
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
    end



######                                  ########
######   BOUNCE     BOUNCE   BOUNCE     ########
######                                  ########

    def square_bounce(w)
        @ball.speed = 20
        if @ball.center_x >= w.x and @ball.center_x <= w.right_edge
            @ball.bounce_y
        elsif @ball.center_y >= w.y and @ball.center_y <= w.bottom_edge
            @ball.bounce_x
        else 
            #info("wall doesnt know how to bounce ball. #{w.x}  #{@ball.center_x}  #{w.right_edge}")
            quad = @ball.relative_quad(w)
            #info("Going to bounce off relative quad #{quad}")
            gdd = nil
            if quad == QUAD_NW 
                gdd = @ball.x_or_y_dimension_greater_distance(w.x, w.y)        
            elsif quad == QUAD_NE
                gdd = @ball.x_or_y_dimension_greater_distance(w.right_edge, w.y)
            elsif quad == QUAD_SE
                gdd = @ball.x_or_y_dimension_greater_distance(w.right_edge, w.bottom_edge)
            elsif quad == QUAD_SW
                gdd = @ball.x_or_y_dimension_greater_distance(w.x, w.bottom_edge)
            else 
                info("ERROR adjust for ball accel from quad #{quad}")
            end

            if gdd == X_DIM
                @ball.bounce_x
            else 
                # Right now, if it is not defined, one of the diagonal quadrants
                # we are bouncing on the y dimension.
                # Not technically accurate, but probably good enough for now
                @ball.bounce_y
            end
        end
    end 

    def diagonal_bounce(w)
        if @ball.direction > DEG_360 
            raise "ERROR ball radians are above double pi #{@ball.direction}. Cannot adjust triangle accelerations"
        end

        axis = AXIS_VALUES[w.orientation]
        if @ball.will_hit_axis(axis)
            #puts "Triangle bounce"
            @ball.bounce(axis)
        else 
            #puts "Square bounce"
            square_bounce(w)
        end
    end 

    def bounce_off_player(proposed_next_x, proposed_next_y)
        in_radians = @ball.direction
        cx = @ball.center_x 
        scale_length = @player.width + @ball.width
        impact_on_scale = ((@player.right_edge + (@ball.width / 2)) - cx) + 0.25
        pct = impact_on_scale.to_f / scale_length.to_f
        @ball.direction = 0.15 + (pct * (Math::PI - 0.3.to_f))
        #info("Scale length: #{scale_length}  Impact on Scale: #{impact_on_scale.round}  Pct: #{pct.round(2)}  rad: #{@ball.direction.round(2)}  speed: #{@ball.speed}")
        #info("#{impact_on_scale.round}/#{scale_length}:  #{pct.round(2)}%")
        @ball.last_element_bounce = @player.object_id
        # if @progress_bar.is_done
        #     @update_fire_after_next_player_hit = true 
        # end
    end



end