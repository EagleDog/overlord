# widgets.rb
#   Coordinates, GuiContainer, Widgets
#
require 'singleton'
require 'logger'
require_relative 'config'
require_relative 'data_structures'
require_relative 'constants'
require_relative 'widgets/themes'
require_relative 'widgets/layouts'
#require_relative 'image_widget'
#require_relative 'other'
#require_relative 'graph'



#
# All wads classes are contained within the wads module.
#
module Wads

    # __Coordinates__
    # An instance of Coordinates references
    # an x, y position on the screen, as well
    # as the width and height of the widget,
    # thus providing the outer dimensions of
    # a rectangular widget.
    #
    class Coordinates 
        attr_accessor :x
        attr_accessor :y
        attr_accessor :width
        attr_accessor :height 
        def initialize(x, y, w, h) 
            @x = x 
            @y = y 
            @width = w 
            @height = h 
        end
    end

    # __GuiContainer__
    # A Gui container is used to allocate space
    # in the x, y two dimensional space to widgets
    # and keep track of where the next widget in
    # the container will be placed.
    #
    # The fill type is one of FILL_VERTICAL_STACK,
    # FILL_HORIZONTAL_STACK, or FILL_FULL_SIZE.
    # Layouts used containers to allocate space
    # across the entire visible application.
    #
    class GuiContainer 
        attr_accessor :start_x
        attr_accessor :start_y
        attr_accessor :next_x
        attr_accessor :next_y
        attr_accessor :max_width 
        attr_accessor :max_height 
        attr_accessor :padding 
        attr_accessor :fill_type 
        attr_accessor :elements

        def initialize(start_x, start_y, width, height, fill_type = FILL_HORIZONTAL_STACK, padding = 5)
            @start_x = start_x
            @start_y = start_y
            @next_x = start_x
            @next_y = start_y
            @max_width = width 
            @max_height = height 
            @padding = padding
            if [FILL_VERTICAL_STACK, FILL_HORIZONTAL_STACK, FILL_FULL_SIZE].include? fill_type
                @fill_type = fill_type 
            else 
                raise "#{fill_type} is not a valid fill type"
            end
            @elements = []
        end 

        def get_coordinates(element_type, args = {})
            default_dim =  WadsConfig.instance.default_dimensions(element_type)
            if default_dim.nil?
                raise "#{element_type} is an undefined element type"
            end
            default_width = default_dim[0]
            default_height = default_dim[1]
            specified_width = args[ARG_DESIRED_WIDTH]
            if specified_width.nil?
                if default_width == "max"
                    if fill_type == FILL_VERTICAL_STACK or fill_type == FILL_FULL_SIZE
                        the_width = max_width
                    else 
                        the_width = (@start_x + @max_width) - @next_x
                    end
                else
                    the_width = default_width 
                end
            else 
                if specified_width > @max_width 
                    the_width = @max_width
                else
                    the_width = specified_width
                end
            end

            specified_height = args[ARG_DESIRED_HEIGHT]
            if specified_height.nil?
                if default_height == "max"
                    if fill_type == FILL_VERTICAL_STACK
                        the_height = (@start_y + @max_height) - @next_y
                    else
                        the_height = max_height
                    end
                else
                    the_height = default_height 
                end
            else
                if specified_height > @max_height
                    the_height = @max_height 
                else
                    the_height = specified_height 
                end
            end

            # Not all elements require padding
            padding_exempt = [ELEMENT_IMAGE, ELEMENT_HORIZONTAL_PANEL, ELEMENT_PLOT,
                ELEMENT_VERTICAL_PANEL, ELEMENT_GENERIC, ELEMENT_MAX_PANEL].include? element_type
            if padding_exempt
                # No padding
                width_to_use = the_width
                height_to_use = the_height
                x_to_use = @next_x 
                y_to_use = @next_y
            else
                # Apply padding only if we are the max, i.e. the boundaries
                x_to_use = @next_x + @padding
                y_to_use = @next_y + @padding
                if the_width == @max_width 
                    width_to_use = the_width - (2 * @padding)
                else 
                    width_to_use = the_width
                end 
                if the_height == @max_height
                    height_to_use = the_height - (2 * @padding)
                else 
                    height_to_use = the_height
                end 
            end

            # Text elements also honor ARG_TEXT_ALIGN 
            arg_text_align = args[ARG_TEXT_ALIGN]
            if not arg_text_align.nil?
                # left is the default, so check for center or right
                if arg_text_align == TEXT_ALIGN_CENTER 
                    x_to_use = @next_x + ((@max_width - specified_width) / 2)
                elsif arg_text_align == TEXT_ALIGN_RIGHT 
                    x_to_use = @next_x + @max_width - specified_width - @padding
                end
            end

            coords = Coordinates.new(x_to_use, y_to_use,
                                     width_to_use, height_to_use)

            if fill_type == FILL_VERTICAL_STACK
                @next_y = @next_y + the_height + (2 * @padding)
            elsif fill_type == FILL_HORIZONTAL_STACK
                @next_x = @next_x + the_width + (2 * @padding)
            end

            @elements << coords
            coords
        end
    end

    # __Widget__
    # The base class for all widgets. This
    # class provides basic functionality for
    # all gui widgets including maintaining the
    # coordinates and layout used.
    #
    # A widget has a border and background,
    # whose colors are defined by the theme.
    # These can be turned off using the
    # `disable_border` and `disable_background`
    # methods.
    #
    # Widgets support a hierarchy of visible
    # elements on the screen. For example,
    # a parent widget may be a form, and it
    # may contain many child widgets such as
    # text labels, input fields, and a submit
    # button. You can add children to a 
    # widget using the add or `add_child` methods.
    #
    # Children are automatically rendered,
    # so any child does not need an explicit
    # call to its `draw` or `render` method.
    # Children can be placed with x, y positioning
    # relative to their parent for convenience
    # (see the relative_x and relative_y methods).
    #
    # The draw and update methods are used
    # by their Gosu counterparts.
    # Typically there is one parent Wads widget
    # used by a Gosu app, and it controls
    # drawing all of the child widgets, invoking
    # update on all widgets, and delegating
    # user events. Widgets can override a render
    # method for any specific drawing logic.
    #
    # It is worth showing the draw method here
    # to amplify the point. You do not need
    # to specifically call draw or render on
    # any children. If you want to manage GUI
    # elements outside of the widget hierarchy,
    # then render is the best place to do it.
    #
    # Likewise, the `update` method recursively
    # calls the `handle_update` method on all
    # children in this widget's hierarchy.
    #
    # A commonly used method is
    # `contains_click(mouse_x, mouse_y)`
    # which returns whether this widget contained
    # the mouse event. For a example, a button widget
    # uses this method to determine if it was clicked.
    # 
    class Widget 
        attr_accessor :x
        attr_accessor :y 
        attr_accessor :base_z 
        attr_accessor :gui_theme 
        attr_accessor :layout 
        attr_accessor :width
        attr_accessor :height 
        attr_accessor :visible 
        attr_accessor :children
        attr_accessor :overlay_widget
        attr_accessor :override_color
        attr_accessor :is_selected
        attr_accessor :text_input_fields

        def initialize(x, y, width = 10, height = 10, layout = nil, theme = nil) 
            set_absolute_position(x, y)  
            set_dimensions(width, height)
            @base_z = 0
            if uses_layout
                if layout.nil? 
                    @layout = WadsConfig.instance.create_layout(x, y, width, height, self)
                else
                    @layout = layout
                end
            end
            if theme.nil?
                @gui_theme = WadsConfig.instance.current_theme
            else 
                @gui_theme = theme 
            end
            @visible = true 
            @children = []
            @show_background = true
            @show_border = true 
            @is_selected = false
            @text_input_fields = []
        end

        def pad(str, size, left_align = false)
            str = str.to_s
            if left_align
                str[0, size].ljust(size, ' ')
            else
                str[0, size].rjust(size, ' ')
            end
        end
        def debug(message)
            WadsConfig.instance.get_logger.debug message 
        end
        def info(message)
            WadsConfig.instance.get_logger.info message 
        end
        def warn(message)
            WadsConfig.instance.get_logger.warn message 
        end
        def error(message)
            WadsConfig.instance.get_logger.error message 
        end

        def set_absolute_position(x, y) 
            @x = x 
            @y = y 
        end 

        def set_dimensions(width, height)
            @width = width
            @height = height 
        end

        def uses_layout
            true 
        end

        def get_layout 
            if not uses_layout 
                raise "The widget #{self.class.name} does not support layouts"
            end
            if @layout.nil? 
                raise "No layout was defined for #{self.class.name}"
            end 
            @layout 
        end 

        def set_layout(layout_type, args = {})
            @layout = WadsConfig.instance.create_layout_for_widget(self, layout_type, args)
        end

        def add_panel(section, args = {})
            new_panel = get_layout.add_max_panel({ ARG_SECTION => section,
                                                   ARG_THEME => @gui_theme}.merge(args))
            new_panel.disable_border
            new_panel
        end

        def get_theme 
            @gui_theme
        end

        def set_theme(new_theme)
            @gui_theme = new_theme
        end

        def set_selected 
            @is_selected = true
        end 

        def unset_selected 
            @is_selected = false
        end 

        def graphics_color 
            if @override_color 
                return @override_color 
            end 
            @gui_theme.graphic_elements_color 
        end 

        def text_color 
            if @override_color 
                return @override_color 
            end 
            @gui_theme.text_color 
        end 

        def selection_color 
            @gui_theme.selection_color 
        end 

        def border_color 
            @gui_theme.border_color 
        end 

        #
        # The z order is determined by taking the base_z and adding the widget specific value.
        # An overlay widget has a base_z that is +10 higher than the widget underneath it.
        # The widget_z method provides a relative ordering that is common for user interfaces.
        # For example, text is higher than graphic elements and backgrounds.
        #
        def z_order 
            @base_z + widget_z
        end

        def relative_z_order(relative_order)
            @base_z + relative_order 
        end

        #
        # Add a child widget that will automatically be drawn by this widget and will received
        # delegated events. This is an alias for add_child
        #
        def add(child) 
            add_child(child)
        end 

        #
        # Add a child widget that will automatically be drawn by this widget and will received
        # delegated events.
        #
        def add_child(child) 
            @children << child 
        end

        #
        # Remove the given child widget
        #
        def remove_child(child)
            @children.delete(child)
        end

        #
        # Remove a list of child widgets
        #
        def remove_children(list)
            list.each do |child|
                @children.delete(child)
            end
        end 

        #
        # Remove all children whose class name includes the given token.
        # This method can be used if you do not have a saved list of the
        # widgets you want to remove.
        #
        def remove_children_by_type(class_name_token)
            children_to_remove = []
            @children.each do |child|
                if child.class.name.include? class_name_token 
                    children_to_remove << child 
                end 
            end 
            children_to_remove.each do |child|
                @children.delete(child)
            end
        end

        #
        # Remove all children from this widget
        #
        def clear_children 
            @children = [] 
        end

        #
        # Drawing the background is on by default. Use this method to prevent drawing a background.
        #
        def disable_background
            @show_background = false
        end

        #
        # Drawing the border is on by default. Use this method to prevent drawing a border.
        #
        def disable_border
            @show_border = false 
        end

        #
        # Turn back on drawing of the border
        #
        def enable_border
            @show_border = true 
        end

        #
        # Turn back on drawing of the background
        #
        def enable_background
            @show_background = true 
        end

        #
        # A convenience method, or alias, to return the left x coordinate of this widget.
        #
        def left_edge
            @x
        end

        #
        # A convenience method to return the right x coordinate of this widget.
        #
        def right_edge
            @x + @width - 1
        end

        #
        # A convenience method, or alias, to return the top y coordinate of this widget.
        #
        def top_edge
            @y
        end

        #
        # A convenience method to return the bottom y coordinate of this widget
        #
        def bottom_edge
            @y + @height - 1
        end

        #
        # A convenience method to return the center x coordinate of this widget
        #
        def center_x
            @x + ((right_edge - @x) / 2)
        end 

        #
        # A convenience method to return the center y coordinate of this widget
        #
        def center_y
            @y + ((bottom_edge - @y) / 2)
        end 

        #
        # Move this widget to an absolute
        # x, y position on the screen.
        # It will automatically move all
        # child widgets, however be warned
        # that if you are manually rendering
        # any elements within your own render
        # logic, you will need to deal with
        # that seperately as the base class
        # does not have access to its coordinates.
        #
        def move_recursive_absolute(new_x, new_y)
            delta_x = new_x - @x 
            delta_y = new_y - @y
            move_recursive_delta(delta_x, delta_y)
        end

        #
        # Move this widget to a relative number
        # of x, y pixels on the screen.
        # It will automatically move all child
        # widgets, however be warned that if
        # you are manually rendering any elements
        # within your own render logic, you will
        # need to deal with that seperately as
        # the base class does not have access to
        # its coordinates.
        #
        def move_recursive_delta(delta_x, delta_y)
            @x = @x + delta_x
            @y = @y + delta_y
            @children.each do |child| 
                child.move_recursive_delta(delta_x, delta_y) 
            end 
        end

        #
        # The primary draw method, used by
        # the main Gosu loop draw method.
        # A common usage pattern is to have
        # a primary widget in your Gosu app
        # that calls this draw method. All
        # children of this widget are then
        # automatically drawn by this method
        # recursively.
        #
        # Note that as a widget author, you
        # should only implement/override the
        # render method. This is a framework
        # implementation that will handle
        # child rendering and invoke render
        # as a user-implemented callback.
        #
        def draw 
            if @visible 
                render
                if @is_selected
                    draw_background(Z_ORDER_SELECTION_BACKGROUND, @gui_theme.selection_color)
                elsif @show_background
                    draw_background
                end
                if @show_border
                    draw_border
                end
                @children.each do |child| 
                    child.draw 
                end 
            end 
        end

        def draw_background(z_override = nil, color_override = nil)
            if color_override.nil? 
                bgcolor = @gui_theme.background_color
            else 
                bgcolor = color_override
            end
            if z_override 
                z = relative_z_order(z_override)
            else 
                z = relative_z_order(Z_ORDER_BACKGROUND) 
            end
            Gosu::draw_rect(@x + 1, @y + 1, @width - 3, @height - 3, bgcolor, z) 
        end

        def draw_border
            Gosu::draw_line @x, @y, @gui_theme.border_color, right_edge, @y, @gui_theme.border_color, relative_z_order(Z_ORDER_BORDER)
            Gosu::draw_line @x, @y, @gui_theme.border_color, @x, bottom_edge, @gui_theme.border_color, relative_z_order(Z_ORDER_BORDER)
            Gosu::draw_line @x,bottom_edge, @gui_theme.border_color, right_edge, bottom_edge, @gui_theme.border_color, relative_z_order(Z_ORDER_BORDER)
            Gosu::draw_line right_edge, @y, @gui_theme.border_color, right_edge, bottom_edge, @gui_theme.border_color, relative_z_order(Z_ORDER_BORDER)
        end

        def contains_click(mouse_x, mouse_y)
            mouse_x >= @x and mouse_x <= right_edge and mouse_y >= @y and mouse_y <= bottom_edge
        end

        #
        # Return true if any part of
        # the given widget overlaps
        # on the screen with this widget
        # as defined by the rectangle
        # from the upper left corner to
        # the bottom right.
        #
        # Note that your widget may not
        # necessariliy draw pixels in
        # this entire space.
        #
        def overlaps_with(other_widget)
            if other_widget.contains_click(@x, @y)
                return true 
            end 
            if other_widget.contains_click(right_edge, @y)
                return true 
            end 
            if other_widget.contains_click(right_edge, bottom_edge - 1)
                return true 
            end 
            if other_widget.contains_click(@x, bottom_edge - 1)
                return true 
            end 
            if other_widget.contains_click(center_x, center_y)
                return true 
            end 
            return false
        end

        #
        # The framework implementation of the main
        # Gosu update loop. This method propagates
        # the event to all child widgets as well.
        #
        # As a widget author, do not override this method.
        #
        # Your callback to implement is the
        # `handle_update(update_count, mouse_x, mouse_y)`
        # method.
        #
        def update(update_count, mouse_x, mouse_y)
            if @overlay_widget 
                @overlay_widget.update(update_count, mouse_x, mouse_y)
            end
            handle_update(update_count, mouse_x, mouse_y) 
            @children.each do |child| 
                child.update(update_count, mouse_x, mouse_y) 
            end 
        end

        #
        # The framework implementation of
        # the main Gosu button down method.
        # This method separates out mouse
        # events from keyboard events, and
        # calls the appropriate callback.
        #
        # As a widget author, do not override this method.
        #
        # Your callbacks to implement are:
        #   handle_mouse_down(mouse_x, mouse_y)
        #   handle_right_mouse(mouse_x, mouse_y)
        #   handle_key_press(id, mouse_x, mouse_y)
        #
        def button_down(id, mouse_x, mouse_y)
            if @overlay_widget 
                result = @overlay_widget.button_down(id, mouse_x, mouse_y)
                if not result.nil? and result.is_a? WidgetResult
                    intercept_widget_event(result)
                    if result.close_widget
                        # remove the overlay widget frmo children, set to null
                        # hopefully this closes and gets us back to normal
                        remove_child(@overlay_widget)
                        @overlay_widget = nil
                    end
                end
                return
            end

            if id == Gosu::MsLeft
                # Special handling for text input fields
                # Mouse click: Select text field based on mouse position.
                if not @text_input_fields.empty?
                    WadsConfig.instance.get_window.text_input = @text_input_fields.find { |tf| tf.under_point?(mouse_x, mouse_y) }
                    # Advanced: Move caret to clicked position
                    WadsConfig.instance.get_window.text_input.move_caret(mouse_x) unless WadsConfig.instance.get_window.text_input.nil?
                end

                result = handle_mouse_down mouse_x, mouse_y
            elsif id == Gosu::MsRight
                result = handle_right_mouse mouse_x, mouse_y
            else 
                result = handle_key_press id, mouse_x, mouse_y
            end

            if not result.nil? and result.is_a? WidgetResult
                return result 
            end

            @children.each do |child| 
                if id == Gosu::MsLeft
                    if child.contains_click(mouse_x, mouse_y) 
                        result = child.button_down id, mouse_x, mouse_y
                        if not result.nil? and result.is_a? WidgetResult
                            intercept_widget_event(result)
                            return result 
                        end
                    end 
                else 
                    result = child.button_down id, mouse_x, mouse_y
                    if not result.nil? and result.is_a? WidgetResult
                        intercept_widget_event(result)
                        return result 
                    end
                end
            end 
        end

        #
        # The framework implementation of
        # the main Gosu button up method.
        # This method separates out mouse
        # events from keyboard events.
        # Only the mouse up event is
        # propagated through the child hierarchy.
        #
        # As a widget author, do not override this method.
        #
        # Your callback to implement is:
        #   handle_mouse_up(mouse_x, mouse_y)
        #
        def button_up(id, mouse_x, mouse_y)
            if @overlay_widget 
                return @overlay_widget.button_up(id, mouse_x, mouse_y)
            end
            
            if id == Gosu::MsLeft
                result = handle_mouse_up mouse_x, mouse_y
                if not result.nil? and result.is_a? WidgetResult
                    return result 
                end
            else 
                result = handle_key_up id, mouse_x, mouse_y
                if not result.nil? and result.is_a? WidgetResult
                    return result 
                end
            end

            @children.each do |child| 
                if id == Gosu::MsLeft
                    if child.contains_click(mouse_x, mouse_y) 
                        result = child.handle_mouse_up mouse_x, mouse_y
                        if not result.nil? and result.is_a? WidgetResult
                            return result 
                        end
                    end 
                else 
                    result = handle_key_up id, mouse_x, mouse_y
                    if not result.nil? and result.is_a? WidgetResult
                        return result 
                    end
                end
            end
        end

        #
        # Return the absolute x coordinate,
        # given the relative x pixel to this
        # widget.
        def relative_x(x)
            x_pixel_to_screen(x)
        end 

        # An alias for relative_x
        def x_pixel_to_screen(x)
            @x + x
        end

        #
        # Return the absolute y coordinate,
        # given the relative y pixel to this
        # widget.
        def relative_y(y)
            y_pixel_to_screen(y)
        end 

        # An alias for relative_y
        def y_pixel_to_screen(y)
            @y + y
        end

        #
        # Add a child text widget, using x, y
        # positioning, relative to this widget
        def add_text(message, rel_x, rel_y, color = nil, use_large_font = false)
            new_text = Text.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), message,
                                                  { ARG_COLOR => color, ARG_USE_LARGE_FONT => use_large_font})
            new_text.base_z = @base_z
            new_text.gui_theme = @gui_theme
            add_child(new_text)
            new_text
        end 

        #
        # Add a child document widget, using
        # x, y positioning relative to this widget
        def add_document(content, rel_x, rel_y, width, height)
            new_doc = Document.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y),
                                   width, height,
                                   content)
            new_doc.base_z = @base_z
            new_doc.gui_theme = @gui_theme
            add_child(new_doc)
            new_doc
        end

        #
        # Add a child button widget using x, y
        # positioning relative to this widget.
        # The width of the button will be
        # determined based on the label text,
        # unless specified in the optional
        # parameter. The code to execute is
        # provided as a block, as shown in the
        # example below.
        #   add_button("Test Button", 10, 10) do 
        #     puts "User hit the test button"
        #   end
        def add_button(label, rel_x, rel_y, width = nil, &block)
            if width.nil?
                args = {}
            else 
                args = { ARG_DESIRED_WIDTH => width }
            end
            new_button = Button.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), label, args)
            new_button.set_action(&block)
            new_button.base_z = @base_z
            new_button.gui_theme = @gui_theme
            add_child(new_button)
            new_button
        end

        #
        # Add a child delete button widget, using
        # x, y positioning relative to this widget.
        # A delete button is a regular button that
        # is rendered as a red X, instead of a text
        # label.
        def add_delete_button(rel_x, rel_y, &block)
            new_delete_button = DeleteButton.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y))
            new_delete_button.set_action(&block)
            new_delete_button.base_z = @base_z
            new_delete_button.gui_theme = @gui_theme
            add_child(new_delete_button)
            new_delete_button 
        end

        #
        # Add a child table widget, using x, y
        # positioning relative to this widget.
        def add_table(rel_x, rel_y, width, height, column_headers, max_visible_rows = 10)
            new_table = Table.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y),
                              width, height, column_headers, max_visible_rows)
            new_table.base_z = @base_z
            new_table.gui_theme = @gui_theme
            add_child(new_table)
            new_table
        end 

        #
        # Add a child table widget using x, y
        # positioning relative to this widget.
        # The user can select up to one and
        # only one item in the table.
        def add_single_select_table(rel_x, rel_y, width, height, column_headers, max_visible_rows = 10)
            new_table = SingleSelectTable.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y),
                              width, height, column_headers, max_visible_rows)
            new_table.base_z = @base_z
            new_table.gui_theme = @gui_theme
            add_child(new_table)
            new_table
        end 

        #
        # Add a child table widget using x, y
        # positioning relative to this widget.
        # The user can zero to many items in the table.
        # 
        def add_multi_select_table(rel_x, rel_y, width, height, column_headers, max_visible_rows = 10)
            new_table = MultiSelectTable.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y),
                              width, height, column_headers, max_visible_rows)
            new_table.base_z = @base_z
            new_table.gui_theme = @gui_theme
            add_child(new_table)
            new_table
        end 

        #
        # Add a child graph display widget using x, y positioning relative to this widget.
        # 
        def add_graph_display(rel_x, rel_y, width, height, graph)
            new_graph = GraphWidget.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), width, height, graph) 
            new_graph.base_z = @base_z
            add_child(new_graph)
            new_graph
        end

        #
        # Add a child plot display widget using x, y positioning relative to this widget.
        # 
        def add_plot(rel_x, rel_y, width, height)
            new_plot = Plot.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), width, height) 
            new_plot.base_z = @base_z
            new_plot.gui_theme = @gui_theme
            add_child(new_plot)
            new_plot
        end

        #
        # Add child axis lines widget using x, y positioning relative to this widget.
        # 
        def add_axis_lines(rel_x, rel_y, width, height)
            new_axis_lines = AxisLines.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), width, height) 
            new_axis_lines.base_z = @base_z
            new_axis_lines.gui_theme = @gui_theme
            add_child(new_axis_lines)
            new_axis_lines
        end

        #
        # Add a child image widget using x, y positioning relative to this widget.
        # 
        def add_image(filename, rel_x, rel_y)
            new_image = ImageWidget.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), img)
            new_image.base_z = @base_z
            new_image.gui_theme = @gui_theme
            add_child(new_image)
            new_image
        end

        #
        # Add an overlay widget that is drawn
        # on top of (at a higher z level) this
        # widget.
        #
        def add_overlay(overlay)
            overlay.base_z = @base_z + 10
            add_child(overlay)
            @overlay_widget = overlay
        end

        # For all child widgets, adjust the
        # x coordinate so that they are centered.
        def center_children
            if @children.empty?
                return 
            end
            number_of_children = @children.size 
            total_width_of_children = 0
            @children.each do |child|
                total_width_of_children = total_width_of_children + child.width + 5
            end
            total_width_of_children = total_width_of_children - 5

            start_x = (@width - total_width_of_children) / 2
            @children.each do |child|
                child.x = start_x 
                start_x = start_x + child.width + 5
            end
        end

        #
        # Override this method in your
        # subclass to process mouse down events.
        # The base implementation is empty
        #
        def handle_mouse_down mouse_x, mouse_y
            # empty base implementation
        end

        #
        # Override this method in your
        # subclass to process mouse up events.
        # The base implementation is empty
        #
        def handle_mouse_up mouse_x, mouse_y
            # empty base implementation
        end

        #
        # Override this method in your
        # subclass to process the right
        # mouse click event.
        # Note we do not differentiate
        # between up and down for the
        # right mouse button.
        # The base implementation is empty
        #
        def handle_right_mouse mouse_x, mouse_y
            # empty base implementation
        end

        #
        # Override this method in your
        # subclass to process keyboard events.
        # The base implementation is empty.
        # Note that the mouse was not necessarily positioned over this widget.
        # You can check this using the contains_click(mouse_x, mouse_y) method
        # and decide if you want to process the event based on that, if desired.
        #
        def handle_key_press id, mouse_x, mouse_y
            # empty base implementation
        end

        #
        # This callback is invoked for any key registered by the
        # register_hold_down_key(id) method.
        #
        def handle_key_held_down id, mouse_x, mouse_y
            # empty base implementation
        end

        #
        # Override this method in your subclass to process when a key is released.
        # The base implementation is empty.
        # Note that the mouse was not necessarily positioned over this widget.
        # You can check this using the contains_click(mouse_x, mouse_y) method
        # and decide if you want to process the event based on that, if desired.
        #
        def handle_key_up id, mouse_x, mouse_y
            # empty base implementation
        end

        #
        # Override this method in your subclass to perform any logic needed
        # as part of the main Gosu update loop. In most cases, this method is
        # invoked 60 times per second.
        #
        def handle_update update_count, mouse_x, mouse_y
            # empty base implementation
        end

        #
        # Override this method in your subclass to perform any custom rendering logic.
        # Note that child widgets are automatically drawn and you do not need to do
        # that yourself.
        #
        def render 
            # Base implementation is empty
        end 

        #
        # Return the relative z order compared to other widgets.
        # The absolute z order is the base plus this value.
        # Its calculated relative so that overlay widgets can be 
        # on top of base displays.
        #
        def widget_z 
            0
        end

        def intercept_widget_event(result)
            # Base implementation just relays the event
            result
        end
    end 

    #
    # A panel is simply an alias for a widget, although you can optionally
    # treat them differently if you wish. Generally a panel is used to 
    # apply a specific layout to a sub-section of the screen.
    #
    class Panel < Widget
        def initialize(x, y, w, h, layout = nil, theme = nil) 
            super(x, y, w, h, layout, theme)
        end
    end 

end
