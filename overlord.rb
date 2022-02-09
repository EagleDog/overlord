require_relative 'scroller3'
require_relative 'bin/pathfinder'
require_relative 'objects'


class Overlord < Scroller3
	def initialize
#		@scroller = ScrollerDisplay.new
		super #(GAME_WIDTH, GAME_HEIGHT, "Test Scroller", @scroller) # ScrollerDisplay.new)
        setup
	end 

	def setup
        @pathfinder = Pathfinder.new
        @pathfinder.setup
		@balljack = Ballrag.new
		@balljack.set_absolute_position(300, 100)
#		@scroller.add_child(@balljack)
	end

end

Overlord.new.show



###
### REFERENCE ###
###
class CodeBase
	class Widgetty
		def update(update_count, mouse_x, mouse_y)
			if @overlay_widget 
				@overlay_widget.update(update_count, mouse_x, mouse_y)
			end
			handle_update(update_count, mouse_x, mouse_y) 
			@children.each do |child| 
				child.update(update_count, mouse_x, mouse_y) 
			end
		end
	end
end
###
###
###
class WattsApp < Gosu::Window
    def initialize(width, height, caption, widget)
        super(width, height)
        self.caption = caption
        @update_count = 0
        WadsConfig.instance.set_window(self)
        set_display(widget) 
        WadsConfig.instance.set_log_level("info")
        @registered_hold_down_buttons = []
    end 

    #
    # This method must be invoked with any Wads::Widget instance. It then handles
    # delegating all events and drawing all child widgets.
    #
    def set_display(widget) 
        @main_widget = widget 
    end

    def get_display
        @main_widget
    end

    # Register a key (identified by the Gosu id) to check if it is being held down.
    # If so, the handle_key_held_down callback will be invoked on widgets
    # For example, register_hold_down_key(Gosu::KbLeft)
    def register_hold_down_key(id)
        @registered_hold_down_buttons << id 
    end

    def update
        @main_widget.update(@update_count, mouse_x, mouse_y)

        # Look for keys that are held down and delegate those events
        @registered_hold_down_buttons.each do |id|
            if button_down?(id)
                @main_widget.handle_key_held_down id, mouse_x, mouse_y 
            end
        end

        @update_count = @update_count + 1
    end 

    def draw
        @main_widget.draw
    end

    def button_down id
        close if id == Gosu::KbEscape
        # Delegate button events to the primary display widget
        result = @main_widget.button_down id, mouse_x, mouse_y
        if not result.nil? and result.is_a? WidgetResult
            if result.close_widget
                close
            end
        end
    end

    def button_up id
        @main_widget.button_up id, mouse_x, mouse_y
    end
end
###
###
###