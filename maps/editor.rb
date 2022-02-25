# maps/editor/editor.rb
#
#     @current_mouse_text = Text.new(10, 700, "0, 0")
#
#     @grid = GridDisplay.new(0, 0, 16, 21, 95)
#     create_board(File.readlines(board_file))
#     add_child(@grid)
#
#    @pallette = TilePalletteDisplay.new / add_child(@pallette)
#    add_text("Current Tile:", 900, 630)
#    add_button("Use Eraser", 940, 680, 120)
#

class Editor < Widget
    def initialize()
        super(0, 0, GAME_WIDTH, GAME_HEIGHT)
        disable_border
        @board_file = 'maps/editor_board.txt'

        @camera_x = 0
        @camera_y = 0

        @center_x = 0   # this is what the buttons will cause to move
        @center_y = 0
        @speed = 4

        @mouse_dragging = false
        @use_eraser = false

        @current_mouse_text = Text.new(400, 400, "0, 0")  #(10, 700, "0, 0")
        add_child(@current_mouse_text)

        @selected_tile = nil

        @tileset = Gosu::Image.load_tiles("../media/basictiles.png", 16, 16, tileable: true)
        @diagonal_tileset = Gosu::Image.load_tiles("../media/diagonaltiles.png", 16, 16, tileable: true)


        @grid = Grid.new(0, 0, 16, 21, 40)   #21, 95)


        @grid.display_grid = true
        #@grid = GridDisplay.new(0, 0, 16, 50, 38, {ARG_SCALE => 2})
        create_board(File.readlines(@board_file))
        add_child(@grid)

        @pallette = TilePalletteDisplay.new 
        add_child(@pallette)

        add_text("Current Tile:", 400, 100)  #900, 630)

        add_erasor_button
        add_clear_button

        add_shadow_boxes
        debug

        load_sounds
    end 

    def add_erasor_button
        add_button("Use Eraser", 400, 200, 120) do  #940, 680, 120) do
            if @use_eraser 
                @use_eraser = false 
            else 
                @use_eraser = true
                WidgetResult.new(false)
            end
        end
    end

    def add_clear_button
        add_button("Clear", 400, 300, 120) do  # 1080, 680, 120) do
            (1..@grid.grid_height-3).each do |y|
                (1..@grid.grid_width-2).each do |x|
                    @grid.remove_tile(x, y)
                end 
            end
            WidgetResult.new(false)
        end
    end

    def add_shadow_box(tile_index)
        x, y = @pallette.get_coords_for_index(tile_index)
        # Draw a box that extends past the widget, because the tile can cover the whole box
        shadow_box = Widget.new(@pallette.x + x - 5, @pallette.y + y - 5, 42, 42)
        shadow_box.set_theme(WadsAquaTheme.new)
        shadow_box.set_selected
        shadow_box.disable_border
        add_child(shadow_box)
    end

    def add_shadow_boxes       # highlight the key tiles we use
        add_shadow_box(5)      # the rest are background
        add_shadow_box(18)
        add_shadow_box(19)
        add_shadow_box(38)
        add_shadow_box(59)
        add_shadow_box(64)
        add_shadow_box(66)
    end




    def draw 
        @children.each do |child|
            if child.is_a? GridDisplay
                # skip
            else
                child.draw
            end
        end

        if @selected_tile
            @selected_tile.draw 
        end

        Gosu.translate(-@camera_x, -@camera_y) do
            @grid.draw
        end
    end 

    def handle_update update_count, mouse_x, mouse_y
        # Scrolling follows player
        # @camera_x = [[@cptn.x - WIDTH / 2, 0].max, @map.width * 50 - WIDTH].min
        # @camera_y = [[@cptn.y - HEIGHT / 2, 0].max, @map.height * 50 - HEIGHT].min 
        @camera_x = [[@center_x - (GAME_WIDTH.to_f / 2), 0].max, @grid.grid_width * 64 - GAME_WIDTH].min
        @camera_y = [[@center_y - (GAME_HEIGHT.to_f / 2), 0].max, @grid.grid_height * 16 - GAME_HEIGHT].min

        @current_mouse_text.label = "cen: #{@center_x}, #{@center_y}  cam: #{@camera_x}, #{@camera_y}  mou: #{mouse_x}, #{mouse_y}   "

        if @mouse_dragging and @grid.contains_click(mouse_x, mouse_y)
            grid_x = @grid.determine_grid_x(mouse_x)
            grid_y = @grid.determine_grid_y(mouse_y)
            #puts "The mouse is dragging through tile #{grid_x}, #{grid_y}"
            if @use_eraser 
                @grid.remove_tile(grid_x, grid_y)
            elsif @selected_tile
                new_tile = PalletteTile.new(@grid.grid_to_relative_pixel(grid_x),
                                            @grid.grid_to_relative_pixel(grid_y),
                                            @selected_tile.img,
                                            1,   # scale
                                            @selected_tile.index)
                @grid.set_tile(grid_x, grid_y, new_tile)
            end
        end
    end

    def handle_key_held_down id, mouse_x, mouse_y
        press_a if id == Gosu::KbA
        press_d if id == Gosu::KbD
        press_w if id == Gosu::KbW
        press_s if id == Gosu::KbS
        puts "moved center to #{@center_x}, #{@center_y}"
    end

    def press_a;  @center_x = @center_x - @speed;  end
    def press_d;  @center_x = @center_x + @speed;  end
    def press_w;  @center_y = @center_y - @speed;  end

    def press_g
        @grid.display_grid = !@grid.display_grid
    end

    def press_s
        @center_y = @center_y + @speed
        @click_low.play
        puts "editor press_s"
    end

    def press_p
        @click_high.play
        save_board
    end

    def handle_key_press(id, mouse_x, mouse_y)
        press_a if id == Gosu::KbA
        press_d if id == Gosu::KbD
        press_w if id == Gosu::KbW
        press_s if id == Gosu::KbS
        press_g if id == Gosu::KbG
        press_p if id == Gosu::KbP
    end

    def handle_key_up id, mouse_x, mouse_y
    end

    ### LOAD_SOUNDS ###                LOAD_SOUNDS
    def load_sounds
         @click_low = Gosu::Sample.new('../media/sounds/click_low.ogg')
         @click_high = Gosu::Sample.new('../media/sounds/click_high.ogg')
    end


    ### SAVE_BOARD ###                  SAVE_BOARD
    def save_board 
        puts "Going to save board"
        open("dump/dump1.txt", 'w') { |f|
            (0..@grid.grid_height-1).each do |y|
                str = ""
                (0..@grid.grid_width-1).each do |x|
                    pallette_tile = @grid.get_tile(x, y)
                    if pallette_tile.nil?
                        str = "#{str}. "
                    else
                        if pallette_tile.index.to_i < 10
                            str = "#{str}#{pallette_tile.index} "
                        else
                            str = "#{str}#{pallette_tile.index}"
                        end
                    end
                end
                f.puts str
            end
        }
    end


    ### HANDLE_MOUSE_DOWN ###        HANDLE_MOUSE_DOWN

    def handle_mouse_down mouse_x, mouse_y
        @mouse_dragging = true
        @pallette.children.each do |pi|
            if pi.contains_click(mouse_x, mouse_y)
                @selected_tile = PalletteTile.new(550, 100, pi.img, 4, pi.index)  #1100, 630
            end 
        end
        if @grid.contains_click(mouse_x, mouse_y)
            # Calculate which grid square this is
            # In the future with scrolling, we will need to consider CenterX
            # but for now without scrolling, its a simple calculation
            grid_x = @grid.determine_grid_x(mouse_x)
            grid_y = @grid.determine_grid_y(mouse_y)
            #puts "We have a selcted tile. Click was on #{grid_x}, #{grid_y}"
            if @use_eraser 
                @grid.remove_tile(grid_x, grid_y)
            elsif @selected_tile
                new_tile = PalletteTile.new(@grid.grid_to_relative_pixel(grid_x),
                                            @grid.grid_to_relative_pixel(grid_y),
                                            @selected_tile.img,
                                            1,   # scale
                                            @selected_tile.index)
                @grid.set_tile(grid_x, grid_y, new_tile)
            end
        end
        #return WidgetResult.new(false)
    end

    def handle_mouse_up mouse_x, mouse_y
        @mouse_dragging = false
    end

    ### CREATE_BOARD ###                  CREATE_BOARD

    # Takes an array of strings that represents the board
    def create_board(map_array)         
        @grid.clear_tiles
        grid_y = 0
        grid_x = 0
        map_array.each do |line|
            index = 0
            while index < line.size
                char = line[index..index+1].strip
                #puts "[#{index}]  #{grid_x},#{grid_y} = #{char}."
                img = nil

                # If the token is a number, use it as the tile index
                if char.match?(/[[:digit:]]/)
                    tile_index = char.to_i
                    #puts "Using index #{tile_index}."
                    img = PalletteTile.new(0, 0, @tileset[tile_index], 1, tile_index)
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



    ### DEBUG ###                           DEBUG
    def debug
        puts 'tile_size: ' + @grid.tile_size.to_s
        puts 'grid_width: ' + @grid.grid_width.to_s
        puts 'grid_height: ' + @grid.grid_height.to_s
#        puts 'tiles: ' + @grid.tiles.to_s
        puts 'scale: ' + @grid.scale.to_s
        puts 'display_grid: ' + @grid.display_grid.to_s
        puts 'grid_x_offset: ' + @grid.grid_x_offset.to_s    # so that we can use negative coordinates 
        puts 'grid_y_offset: ' + @grid.grid_y_offset.to_s    

    end

end
