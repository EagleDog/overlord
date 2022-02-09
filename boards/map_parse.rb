# map_parse.rb
#
#
class MapParse
  def setup
    puts __dir__
    puts __FILE__

    @multiline = []
    step1
  end

  def step1
    @multiline = File.readlines("aboard1.txt")
  end

  def step2
    delaminate_map(File.readlines("data/alphaboard1.txt"))
  end

  def delaminate_map(linefood)         
    linefood.each do |line|
      index = 0
      while index < line.size
        char = line[index..index+1].strip
        #puts "[#{index}  #{grid_x},#{grid_y} = #{char}."
        img = nil


        # # If the token is a number, use it as the tile index
        # if char.match?(/[[:digit:]]/)
        #     tile_index = char.to_i
        #     #puts "Using index #{tile_index}."
        #     # This is temporary, we need a way to define and store metadata for tiles
        #     if tile_index == 5
        #         img = Wall.new(@tileset[tile_index])
        #     else
        #         img = BackgroundArea.new(@tileset[tile_index])
        #     end
        # #elsif char == "B"
        # #    img = Brick.new(@blue_brick)
        # elsif char == "W"
        #     img = Wall.new(@blue_brick)
        # elsif char == "Y"
        #     img = Dot.new(@yellow_dot)
        # elsif char == "G"
        #     img = Dot.new(@green_dot)
        # elsif char == "F"
        #     img = OutOfBounds.new(@fire_transition_tile)
        # end
        
        # if img.nil?
        #     # nothing to do
        # else
        #     @grid.set_tile(grid_x, grid_y, img)
        # end

        grid_x = grid_x + 1
        index = index + 2
      end
    grid_x = 0
    grid_y = grid_y + 1
  end
end 

end

@mapparse = MapParse.new
@mapparse.setup