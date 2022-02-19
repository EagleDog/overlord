
class WorldMap
    def initialize(grid)
#        super(0, 0, GAME_WIDTH, GAME_HEIGHT)
        @grid = grid
        load_tiles
        assign_numbers
    end

    def load_tiles      #     LOAD_TILES     LOAD_TILES     LOAD_TILES
        @tileset = Gosu::Image.load_tiles(
            "media/basictiles.png", 
            16, 16, 
            tileable: true)

        @diagonal_tileset = 
            Gosu::Image.load_tiles( 
            "media/diagonaltiles.png", 
            16, 16, 
            tileable: true)
    end

    def assign_numbers              # ASSIGN_NUMBERS
        @blue_brick = @tileset[1]   # the brick with an empty pixel on the left and right, so there is a gap

        @block1 = @tileset[7]
        @b2 = @tileset[8]
        @b3 = @tileset[9]
        @b4 = @tileset[10]
        @b5 = @tileset[11]
        @b6 = @tileset[12]

        @red_wall = @tileset[7]
        @yellow_dot = @tileset[18]
        @green_dot = @tileset[19]
        @fire_transition_tile = @tileset[66]

        @red_wall_se = @diagonal_tileset[0]
        @red_wall_sw = @diagonal_tileset[7]
        @red_wall_nw = @diagonal_tileset[13]
        @red_wall_ne = @diagonal_tileset[10]
    end

    # Takes an array of strings that represents the board
    def create_board(map_array)
        @grid.clear_tiles                  # CREATE_BOARD
        grid_y = 0
        grid_x = 0
        map_array.each do |line|
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
                    img = Wall.new(@tileset[tile_index]) if tile_index == 5
                    img = BackgroundArea.new(@tileset[tile_index]) if tile_index != 5

                else
                    img = Brick.new(@blue_brick) if char == "B"
                    img = Wall.new(@blue_brick) if char == "W"
                    img = Dot.new(@yellow_dot) if char == "Y"
                    img = Dot.new(@green_dot) if char == "G"
                    img = OutOfBounds.new(@fire_transition_tile) if char == "F"

                    img = Block.new(@block1) if char == "p"
                    img = Block.new(@b2) if char == "o"
                    img = Block.new(@b3) if char == "k"
                    img = Block.new(@b4) if char == "k"
                    img = Block.new(@b5) if char == "m"
                    img = Block.new(@b6) if char == "n"

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