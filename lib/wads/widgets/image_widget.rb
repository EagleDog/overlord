#   ImageWidget

module Wads

    #
    # Displays an image on the screen at the specific x, y location. The image
    # can be scaled by setting the scale attribute. The image attribute to the
    # construcor can be the string file location or a Gosu::Image instance
    #
    class ImageWidget < Widget
        attr_accessor :img 
        attr_accessor :scale

        def initialize(x, y, image, args = {}) 
            super(x, y)
            if image.is_a? String
                @img = Gosu::Image.new(image)
            elsif image.is_a? Gosu::Image 
                @img = image 
            elsif image.is_a? Gosu::Color
                @img = nil
                @override_color = image
            else 
                raise "ImageWidget requires either a filename or a Gosu::Image object"
            end
            if args[ARG_THEME]
                @gui_theme = args[ARG_THEME]
            end
            @scale = 1
            disable_border
            disable_background
            set_dimensions(@img.width, @img.height) if @img
        end

        def render 
            if @img.nil?
                # TODO draw a box
                Gosu::draw_rect(@x, @y, @width - 1, @height - 1, @override_color, relative_z_order(Z_ORDER_GRAPHIC_ELEMENTS))
            else
                @img.draw @x, @y, z_order, @scale, @scale
            end
        end

        def widget_z 
            Z_ORDER_FOCAL_ELEMENTS
        end
    end 
end
