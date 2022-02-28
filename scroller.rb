#
#    SCROLLER    SCROLLER    SCROLLER    SCROLLER
#
#         Main Game Logic for Overlord
#

require_relative 'worldmap'
# require_relative 'bindings'

class Scroller < Widget
    def initialize
        super(0, 0, GAME_WIDTH, GAME_HEIGHT)
        set_layout(LAYOUT_HEADER_CONTENT)
        set_theme(OverTheme.new)
#        disable_border
        enable_border
        enable_background
        @pause = false
        @game_mode = RDIA_MODE_START
        @score = 0
        @level = 1
        @camera_x = 0
        @camera_y = 0

        pause_game
        add_overlay(WelcomeScreen.new(
                        "         Overlord Castle", 
                        "intro"))


        # TODO put this back when we are ready 
        # to release, instructions to the user
        # add_overlay(create_overlay_widget)

        # initialize

        @grid = GridDisplay.new(0, 0, 16, 80, 38, {ARG_SCALE => 2})
        @worldmap = WorldMap.new(@grid)

        load_panels

        @worldmap.load_tiles

        load_char
        load_ball

        load_mobs
#        load_bindings

        load_map  # LOAD MAP

        load_sounds

        @bouncing = false
        load_goal_text
        reset_level
    end 

    def reset_level
        @score = 0
        @level = 1
        @camera_x = 0
        @camera_y = 0
        @char.set_absolute_position(500, 150)
        @ball.init_direction_and_speed
        @ball.set_absolute_position(150, 200)
    end

    def restart_level
        reset_level
        @pause = true
    end

    def continue
        play_chime
        if @pause
            unpause_game
        else
            pause_game
        end
    end

    def load_goal_text
        @goal_text = add_text("GOAL", 1350, 900)
    end

    def load_panels                     #  LOAD_PANELS    LOAD_PANELS
        header_panel = add_panel(SECTION_NORTH)
        header_panel.get_layout.add_text("OVERLORD    ",
                                         { ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER,
                                           ARG_USE_LARGE_FONT => true})
        subheader_panel = header_panel.get_layout.add_vertical_panel({ARG_LAYOUT => LAYOUT_EAST_WEST,
                                                                      ARG_DESIRED_WIDTH => GAME_WIDTH - 100})
#        subheader_panel.disable_border
        west_panel = subheader_panel.add_panel(SECTION_WEST)
        west_panel.get_layout.add_text("Score")
        @score_text = west_panel.get_layout.add_text("#{@score}")
        
        east_panel = subheader_panel.add_panel(SECTION_EAST)
        east_panel.get_layout.add_text("Level", {ARG_TEXT_ALIGN => TEXT_ALIGN_RIGHT})
        @level_text = east_panel.get_layout.add_text("#{@level}",
                                                     {ARG_TEXT_ALIGN => TEXT_ALIGN_RIGHT})
    end


    def load_char                          # LOAD_CHAR
        @char = Character.new
        @char.set_absolute_position(500, 150)
        add_child(@char)
    end

    def load_ball                          # LOAD_BALL
        @ball = Ballrag.new
        @ball.speed = 2
        add_child(@ball)
    end

    # def load_bindings
    #     @bindings = KeyBindings.new(@char)
    # end

    def load_map    # LOAD MAP             # LOAD_MAP  __________________

        @worldmap.create_board(File.readlines("maps/maps/a1.txt"))

        add_child(@grid)                    #        ____________________
    end

    #
    #
    #   HANDLE_UPDATE              HANDLE_UPDATE   HANDLE_UPDATE   HANDLE_UPDATE   HANDLE_UPDATE   HANDLE_UPDATE
    #
    def handle_update update_count, mouse_x, mouse_y
        return if @pause
        ball_logic
        move_camera
        collision_detection(children)
        move_mobs
    end
    
    #   MOVE_MOBS                  MOVE_MOBS
    def move_mobs
        @mobs.each do |mob|
            mob.move_it(@grid)
        end
    end

    def load_mobs                          # LOAD_MOBS
        @mob1 = Mob.new("media/sprites/bat.png")
        @mob2 = Mob.new("media/sprites/blob.png")
        @mob3 = Mob.new("media/sprites/ghost.png")
        @mob4 = Mob.new("media/sprites/ghoul.png")
        @mob5 = Mob.new("media/sprites/ghoul2.png")
        @mob6 = Mob.new("media/sprites/girl.png")
        @mob7 = Mob.new("media/sprites/skeleton.png")
        @mob8 = Mob.new("media/sprites/spider.png")
        @mob1.set_absolute_position(250, 380)
        @mob2.set_absolute_position(300, 380)
        @mob3.set_absolute_position(350, 380)
        @mob4.set_absolute_position(400, 380)
        @mob5.set_absolute_position(450, 380)
        @mob6.set_absolute_position(500, 380)
        @mob7.set_absolute_position(550, 380)
        @mob8.set_absolute_position(600, 380)
        @mobs = [@mob1, @mob2, @mob3, @mob4,
                 @mob5, @mob6, @mob7, @mob8 ]
        @mobs.each do |mob|
            add_child(mob)
        end
    end


    def render   # RENDER   # RENDER   # RENDER   RENDER   RENDER   RENDER
    end

    def draw   # DRAW   # DRAW   #  DRAW   DRAW   DRAW   DRAW   DRAW   DRAW
        if @show_border
            draw_border
        end
        @children.each do |child|
            if child.is_a? GridDisplay or child.is_a? Character or 
               child.is_a? Ballrag or child.is_a? Mob or
               child == @goal_text
                # skip
            else
                child.draw
            end
        end

        Gosu.translate(-@camera_x, -@camera_y) do
            @grid.draw
            @char.draw
            @ball.draw
            @goal_text.draw
            @mobs.each do |mob|
                mob.draw
            end
        end
    end 

    #   MOVE_CAMERA               # MOVE_CAMERA
    def move_camera
        # Scrolling follows char  # @camera_x = [[@char.x - (GAME_WIDTH.to_f / 2), 0].max, @grid.grid_width * 32 - GAME_WIDTH].min
                                  # @camera_y = [[@char.y - (GAME_HEIGHT.to_f / 2), 0].max, @grid.grid_height * 32 - GAME_HEIGHT].min
        if @char.x >= 1050; @camera_x = 1050
        else @camera_x = 0;
        end

        if @char.y >= 600; @camera_y = 500
        else @camera_y = 0;
        end

        #puts "#{@char.x}, #{@char.y}    Camera: #{@camera_x}, #{@camera_y}"
    end


    def action_map(id)
        return 'left' if id == Gosu::KbA or id == Gosu::KbLeft
        return 'right' if id == Gosu::KbD or id == Gosu::KbRight
        return 'up' if id == Gosu::KbW or id == Gosu::KbUp
        return 'down' if id == Gosu::KbS or id == Gosu::KbDown
        return 'kick' if id == Gosu::KbSpace

    end

    def handle_key_held_down(id, mouse_x, mouse_y)
        @char.move_left(@grid) if action_map(id) == 'left'
        @char.move_right(@grid) if action_map(id) == 'right'
        @char.move_up(@grid) if action_map(id) == 'up'
        @char.move_down(@grid) if action_map(id) == 'down'
        # puts "key down"
        # puts "#{@char.x}, #{@char.y}    Camera: #{@camera_x}, #{@camera_y}   Tile: #{@grid.tile_at_absolute(@char.x, @char.y)}"
        # @bindings.handle_key_held_down(id, mouse_x, mouse_y)
    end

    def handle_key_press(id, mouse_x, mouse_y)
        @char.press_z if id == Gosu::KbZ
        @char.press_y if id == Gosu::KbY
        @char.press_f if id == Gosu::KbF

        @char.press_q if id == Gosu::KbQ
        @char.press_e if id == Gosu::KbE
        @char.press_r if id == Gosu::KbR
        @char.press_t if id == Gosu::KbT
        @char.press_x if id == Gosu::KbX
        @char.press_c if id == Gosu::KbC
        @char.press_v if id == Gosu::KbV

        @char.press_u if id == Gosu::KbU
        @char.press_i if id == Gosu::KbI
        @char.press_o if id == Gosu::KbO
        @char.press_p if id == Gosu::KbP
        @char.press_g if id == Gosu::KbG
        @char.press_h if id == Gosu::KbH
        @char.press_j if id == Gosu::KbJ
        @char.press_k if id == Gosu::KbK
        @char.press_l if id == Gosu::KbL

        @char.press_b if id == Gosu::KbB
        @char.press_n if id == Gosu::KbN
        @char.press_m if id == Gosu::KbM

        @char.start_move_left if action_map(id) == 'left'
        @char.start_move_right if action_map(id) == 'right'
        @char.start_move_up if action_map(id) == 'up'
        @char.start_move_down if action_map(id) == 'down'
        # puts "key press"
        # @bindings.handle_key_press(id, mouse_x, mouse_y)

        continue if id == Gosu::KbSpace
    end


     def load_sounds
         @beep0 = Gosu::Sample.new('media/sounds/beep0.ogg')
         @chime = Gosu::Sample.new('media/sounds/chime.ogg')
         @click_low = Gosu::Sample.new('media/sounds/click_low.ogg')
         @slice = Gosu::Sample.new('media/sfx/slice.ogg')
         @zap2 = Gosu::Sample.new('media/beeps/zap2.ogg')
     end

     #   PLAY_SOUNDS                     # PLAY_SOUNDS    PLAY_SOUNDS   PLAY_SOUNDS
     def play_beep0;  @beep0.play;  end
     def play_chime;  @chime.play;   end
     def play_click;  @click_low.play;  end
     def play_slice;  @slice.play;  end
     def play_zap2;  @zap2.play;  end


    def handle_key_up(id, mouse_x, mouse_y)
#        @bindings.handle_key_up(id, mouse_x, mouse_y)
        if id == Gosu::KbA or id == Gosu::KbD or 
           id == Gosu::KbW or id == Gosu::KbS or 
           id == Gosu::KbLeft or id == Gosu::KbRight or 
           id == Gosu::KbUp or id == Gosu::KbDown
            @char.stop_move
            # puts "key up"
        end
    end




    def pause_game                     # PAUSE
#        return if @pause 
        @pause = true 
#        @progress_bar.stop
    end 

    def unpause_game                   # UNPAUSE
        @pause = false
        # return if !@pause 
        # @pause = false if @pause == true
#        @progress_bar.start
    end 

    def tilt 
        r = ((rand(10) * 0.01) - 0.05) # * 20
        @ball.direction = @ball.direction + r
        @ball.speed -= 0.4 if @ball.speed > 0
    end




    ##              ##
    #   BALL_LOGIC   #
    def ball_logic              #  BALL_LOGIC   BALL_LOGIC  BALL_LOGIC
        next_x, next_y = @ball.proposed_move
        occupant = @grid.proposed_widget_at(@ball, next_x, next_y)

        if occupant.empty?

            @mobs.each do |mob|         # bounce mob  # bounce mob  # bounce mob
                if @ball.overlaps(next_x, next_y, mob)
                    bounce_char(next_x, next_y)
                    play_chime
                    @ball.speed = 4
                end
            end

            if @ball.overlaps(next_x, next_y, @char)
                bounce_char(next_x, next_y)   # bounce char  # bounce char  # bounce char
                @char.kick
                @ball.speed = 6

                # puts "ball hit char"

            else
                # puts "bounce other"
                @ball.set_absolute_position(next_x, next_y)
            end

        else 
            objs = occupant.map { |oo| oo.class }
            # puts "Found candidate objects to interact #{objs}"
            if collision_detection(occupant) #, update_count)
                # puts "^^^^^ bounce wall or block"
                @ball.set_absolute_position(next_x, next_y) 
                # play_beep0
            else
                # puts "^^^^^ NO GRID BOUNCE ???"
            end
        end
    end



######                                  ########
######   BOUNCE     BOUNCE   BOUNCE     ########
######                                  ########
    def is_bouncing?(w)
        true if x_bounce?(w)
        true if y_bounce?(w)
    end

    def x_bounce?(w)
        true if @ball.center_y >= w.y and 
                @ball.center_y <= w.bottom_edge
    end
    def y_bounce?(w)
        true if @ball.center_x >= w.x and 
                @ball.center_x <= w.right_edge
    end

    def square_bounce(w)
        # @ball.speed = 4
        if is_bouncing?(w)
            @bouncing = true
            @ball.bounce_y if y_bounce?(w)
        #    puts "bounce_y" if y_bounce?(w)
            @ball.bounce_x if x_bounce?(w)
        #    puts "bounce_x" if x_bounce?(w)
        else 
            info("wall doesnt know how to bounce ball. " + 
                 "#{w.x}  #{@ball.center_x}  #{w.right_edge}")
#            play_chime
            quad = @ball.relative_quad(w)
#            info("Going to bounce off relative quad #{quad}")
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
                # @ball.speed = 3
            else 
                # Right now, if it is not defined, one of the diagonal quadrants
                # we are bouncing on the y dimension.
                # Not technically accurate, but probably good enough for now
                @ball.bounce_y
                # @ball.speed = 3
            end
        end
    end 

    def diagonal_bounce(w)
        if @ball.direction > DEG_360 
            raise "ERROR ball radians are above double pi #{@ball.direction}. " +
                  "Cannot adjust triangle accelerations"
        end

        axis = AXIS_VALUES[w.orientation]
        if @ball.will_hit_axis(axis)
            puts "Triangle bounce"
            @ball.bounce(axis)
        else 
            puts "Square bounce"
            square_bounce(w)
        end
    end 

    def bounce_char(next_x, next_y)
        # puts "bounce_char"
        in_radians = @ball.direction
        cx = @ball.center_x 
        scale_length = @char.width + @ball.width
        impact_on_scale = ((@char.right_edge + (@ball.width / 2)) - cx) + 0.25
        pct = impact_on_scale.to_f / scale_length.to_f
#        @ball.direction = 0.15 + (pct * (Math::PI - 0.3.to_f))
        @ball.direction = rand(360)
#        @ball.speed = 8
        # info("Scale length: #{scale_length}  " + 
        #      "Impact on Scale: #{impact_on_scale.round}  "+
        #      "Pct: #{pct.round(2)}  rad: #{@ball.direction.round(2)}  "+
        #      "speed: #{@ball.speed}")
        # info("#{impact_on_scale.round}/#{scale_length}:  #{pct.round(2)}%")
        @ball.last_element_bounce = @char.object_id
    end


    #   INTERCEPT_WIDGET_EVENT                  # INTERCEPT   # INTERCEPT          
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



    ###########################
    #                         #
    #   COLLISION_DETECTION   #
    #                         #
    def collision_detection(objects)      #  COLLISION_DETECTION
        if objects.size == 1
            w = objects[0]
            if w.object_id == @ball.last_element_bounce
                # Don't bounce off the same element twice
				puts "NOT bouncing off #{w}"
                w = nil 
            end
        else 
            # Choose the widget with the shortest distance from the center of the ball
            closest_widget = nil 
            closest_distance = 100   # some large number
            objects.each do |candidate_widget| 
				next if candidate_widget == @ball
                d = @ball.distance_between_center_mass(candidate_widget)
                # puts "Comparing #{d} with #{closest_distance}. Candidate #{candidate_widget} (#{candidate_widget.object_id})  last bounce: #{@ball.last_element_bounce}"
                if d < closest_distance and candidate_widget.object_id != @ball.last_element_bounce
                    closest_distance = d 
                    closest_widget = candidate_widget 
                end 
            end 
            w = closest_widget
			# if w.nil?
			# 	objs = objects.map { |oo| oo.class }
			# 	puts "ONLY SELF COLLISION #{objs}"
			# end
        end
        if w.nil?
            return true
        end

        # puts "collision detection'"
		# if w.class == Ballrag
		# 	puts "BALLRAG Reaction #{w.interaction_results} with widget #{w}"
		if !defined?(w.interaction_results)
			# puts "  WEIRD Reaction with widget #{w}"
			return
		elsif w.interaction_results.length == 0
			# puts "  EMPTY Reaction #{w.interaction_results} with widget #{w}"
			return
		else
			puts "        Reaction #{w.interaction_results} with widget #{w}"
		end

        @ball.last_element_bounce = w.object_id

        if w.interaction_results.include? RDIA_REACT_STOP 
            # @ball.stop_move
			square_bounce(w)
        end

        if w.interaction_results.include? RDIA_REACT_BOUNCE 
            square_bounce(w)
        elsif w.interaction_results.include? RDIA_REACT_BOUNCE_DIAGONAL
            diagonal_bounce(w)
        end

        if w.interaction_results.include? RDIA_REACT_CONSUME
            @grid.remove_tile_at_absolute(w.x + 1, w.y + 1)
            @char.press_u
            tilt
        end
# SCORE
        if w.interaction_results.include? RDIA_REACT_SCORE
            @score = @score + w.score
            @score_text.label = "#{@score}"
        end
# LOSE
        if w.interaction_results.include? RDIA_REACT_LOSE 
            @pause = true
            @game_mode = RDIA_MODE_END
            play_slice
            if @overlay_widget.nil?
                add_overlay(create_you_lose_widget)
            end
#            restart_level
        end

# GOAL
        if w.interaction_results.include? RDIA_REACT_GOAL
            @pause = true
            @game_mode = RDIA_MODE_END
            play_zap2
            if @overlay_widget.nil?
                $music.play(false)
                add_overlay(create_you_win_widget)
            end
        end

        play_click
        true
    end


end ### end class Scroller ###
