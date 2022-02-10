# maps/editor/pallette.rb
#

class PalletteTile < ImageWidget 
    attr_accessor :index
    def initialize(x, y, image, scale, index)
        super(x, y, image)
        set_dimensions(32, 32)
        @index = index 
        @scale = scale
    end

    def handle_mouse_down mouse_x, mouse_y
        puts "In #{@index}, checking for click"
        if contains_click(mouse_x, mouse_y)
            puts "Got it #{@index}"
            return WidgetResult.new(false, "select", self)
        end
    end
end 

class TilePalletteDisplay < Widget
    def initialize
        super(900, 10, 360, 600)
        #disable_border
        determineTileCords
        addPalletteItems
    end 

    def determineTileCords
        tempX = 10
        tempY = 10
        tempCounter = 0
        tileQuantity = 100
        @tileCords = []
        tileQuantity.times do
            @tileCords += [[tempX, tempY, tempCounter]]
            tempX += 40
            tempCounter += 1
            if tempX > 310
                tempX = 10
                tempY += 40
            end
        end
    end

    def get_coords_for_index(index)
        @tileCords.each do |x, y, order|
            if order == index 
                # We found it
                return [x, y]
            end 
        end 
        raise "Pallette display does not have tile with index #{index}"
    end

    def addPalletteItems 
        @tileCords.map do |x, y, order|
            add_child(PalletteTile.new(@x + x, @y + y, "./media/tile#{order.to_s}.png", 2, order))
        end
    end
end
