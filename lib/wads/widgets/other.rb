# other.rb
#   Text, ErrorMessage, PlotPoint,
#   Button, DeleteButton, Document, InfoBox,
#   Dialog, WidgetResult, Line, AxisLines,
#   VerticalAxisLablel, HorizontalAxisLabel,
#   Table, SingleSelectTable, MultiSelectTable,
#   Plot, NodeWidget(Button), NodeIconWidget,
#   GraphWidget

module Wads

    # __Text__
    # Displays a text label on the screen at the specific x, y location.
    # The font specified by the current theme is used.
    # The theme text color is used, unless the color parameter specifies an override.
    # The small font is used by default, unless the use_large_font parameter is true.
    #
    class Text < Widget
        attr_accessor :label

        def initialize(x, y, label, args = {}) 
            super(x, y) 
            @label = label
            if args[ARG_THEME]
                @gui_theme = args[ARG_THEME]
            end
            if args[ARG_USE_LARGE_FONT]
                @use_large_font = args[ARG_USE_LARGE_FONT] 
            end
            if args[ARG_COLOR]
                @override_color = args[ARG_COLOR]
            end
            disable_border
            if @use_large_font 
                set_dimensions(@gui_theme.font_large.text_width(@label) + 10, 20)
            else 
                set_dimensions(@gui_theme.font.text_width(@label) + 10, 20)
            end
        end

        def set_text(new_text)
            @label = new_text
        end

        def change_text(new_text)
            set_text(new_text)
        end

        def render 
            if @use_large_font 
                get_theme.font_large.draw_text(@label, @x, @y, z_order, 1, 1, text_color)
            else
                get_theme.font.draw_text(@label, @x, @y, z_order, 1, 1, text_color)
            end 
        end

        def widget_z 
            Z_ORDER_TEXT
        end
    end 

    # __ErrorMessage__
    # An ErrorMessage is a subclass of text that uses a red color
    #
    class ErrorMessage < Text
        def initialize(x, y, message) 
            super(x, y, "ERROR: #{message}", COLOR_ERROR_CODE_RED)
        end
    end 

    # __PlotPoint__
    # A data point to be used in a Plot widget. This object holds
    # the x, y screen location as well as the data values for x, y.
    #
    class PlotPoint < Widget
        attr_accessor :data_x
        attr_accessor :data_y
        attr_accessor :data_point_size 

        def initialize(x, y, data_x, data_y, color = COLOR_MAROON, size = 4) 
            super(x, y)
            @override_color = color
            @data_x = data_x
            @data_y = data_y
            @data_point_size = size
        end

        def render(override_size = nil)
            size_to_draw = @data_point_size
            if override_size 
                size_to_draw = override_size 
            end
            half_size = size_to_draw / 2
            Gosu::draw_rect(@x - half_size, @y - half_size,
                            size_to_draw, size_to_draw,
                            graphics_color, z_order) 
        end 

        def widget_z 
            Z_ORDER_PLOT_POINTS
        end

        def to_display 
            "#{@x}, #{@y}"
        end

        def increase_size 
            @data_point_size = @data_point_size + 2
        end 

        def decrease_size 
            if @data_point_size > 2
                @data_point_size = @data_point_size - 2
            end
        end
    end 

    # __Button__
    # Displays a button at the specified x, y location.
    # The button width is based on the label text unless specified
    # using the optional parameter. The code to executeon a button
    # click is specified using the set_action method, however typical
    # using involves the widget or layout form of add_button. For example:
    # add_button("Test Button", 10, 10) do 
    #   puts "User hit the test button"
    # end
    class Button < Widget
        attr_accessor :label
        attr_accessor :is_pressed
        attr_accessor :action_code

        def initialize(x, y, label, args = {}) 
            super(x, y) 
            @label = label
            if args[ARG_THEME]
                @gui_theme = args[ARG_THEME]
            end
            @text_pixel_width = @gui_theme.font.text_width(@label)
            if args[ARG_DESIRED_WIDTH]
                @width = args[ARG_DESIRED_WIDTH] 
            else 
                @width = @text_pixel_width + 10
            end
            @height = 26
            @is_pressed = false
            @is_pressed_update_count = -100
        end

        def render 
            text_x = center_x - (@text_pixel_width / 2)
            @gui_theme.font.draw_text(@label, text_x, @y, z_order, 1, 1, text_color)
        end 

        def widget_z 
            Z_ORDER_TEXT
        end

        def set_action(&block) 
            @action_code = block
        end

        def handle_mouse_down mouse_x, mouse_y
            @is_pressed = true
            if @action_code
                @action_code.call
            end
        end

        def handle_update update_count, mouse_x, mouse_y
            if @is_pressed
                @is_pressed_update_count = update_count
                @is_pressed = false
            end

            if update_count < @is_pressed_update_count + 15
                unset_selected
            elsif contains_click(mouse_x, mouse_y)
                set_selected
            else 
                unset_selected
            end
        end
    end 

    # __DeleteButton__
    # A subclass of button that renders a red X instead of label text
    #
    class DeleteButton < Button
        def initialize(x, y, args = {}) 
            super(x, y, "ignore", {ARG_DESIRED_WIDTH => 50}.merge(args))
            set_dimensions(14, 14)
            add_child(Line.new(@x, @y, right_edge, bottom_edge, COLOR_ERROR_CODE_RED))
            add_child(Line.new(@x, bottom_edge, right_edge, @y, COLOR_ERROR_CODE_RED))
        end

        def render 
            # do nothing, just override the parent so we don't draw a label
        end 
    end 

    # __Document__
    # Displays multiple lines of text content at the specified coordinates
    #
    class Document < Widget
        attr_accessor :lines

        def initialize(x, y, width, height, content, args = {}) 
            super(x, y)
            set_dimensions(width, height)
            @lines = content.split("\n")
            disable_border
            if args[ARG_THEME]
                @gui_theme = args[ARG_THEME]
            end
        end

        def render 
            y = @y + 4
            @lines.each do |line|
                @gui_theme.font.draw_text(line, @x + 5, y, z_order, 1, 1, text_color)
                y = y + 26
            end
        end 

        def widget_z 
            Z_ORDER_TEXT
        end
    end 

    # __InfoBox__
    class InfoBox < Widget 
        def initialize(x, y, width, height, title, content, args = {}) 
            super(x, y) 
            set_dimensions(width, height)
            @base_z = 10
            if args[ARG_THEME]
                @gui_theme = args[ARG_THEME]
            end
            add_text(title, 5, 5)
            add_document(content, 5, 52, width, height - 52)
            ok_button = add_button("OK", (@width / 2) - 50, height - 26) do
                WidgetResult.new(true)
            end
            ok_button.width = 100
        end

        def handle_key_press id, mouse_x, mouse_y
            if id == Gosu::KbEscape
                return WidgetResult.new(true) 
            end
        end 
    end

    # __Dialog__
    class Dialog < Widget
        attr_accessor :textinput

        def initialize(x, y, width, height, title, text_input_default) 
            super(x, y, width, height) 
            @base_z = 10
            @error_message = nil

            add_text(title, 5, 5)
            # Forms automatically have some explanatory content
            add_document(content, 0, 56, width, height)

            # Forms automatically get a text input widget
            @textinput = TextField.new(x + 10, bottom_edge - 80, text_input_default, 600)
            @textinput.base_z = 10
            add_child(@textinput)

            # Forms automatically get OK and Cancel buttons
            ok_button = add_button("OK", (@width / 2) - 100, height - 32) do
                handle_ok
            end
            ok_button.width = 100

            cancel_button = add_button("Cancel", (@width / 2) + 50, height - 32) do
                WidgetResult.new(true)
            end
            cancel_button.width = 100
        end

        def content 
            <<~HEREDOC
            Override the content method to
            put your info here.
            HEREDOC
        end

        def add_error_message(msg) 
            @error_message = ErrorMessage.new(x + 10, bottom_edge - 120, msg)
            @error_message.base_z = @base_z
        end 

        def render 
            if @error_message
                @error_message.draw 
            end 
        end

        def handle_ok
            # Default behavior is to do nothing except tell the caller to 
            # close the dialog
            return WidgetResult.new(true, EVENT_OK) 
        end

        def handle_mouse_click(mouse_x, mouse_y)
            # empty implementation of mouse click outside
            # of standard form elements in this dialog
        end

        def handle_mouse_down mouse_x, mouse_y
            # Mouse click: Select text field based on mouse position.
            WadsConfig.instance.get_window.text_input = [@textinput].find { |tf| tf.under_point?(mouse_x, mouse_y) }
            # Advanced: Move caret to clicked position
            WadsConfig.instance.get_window.text_input.move_caret(mouse_x) unless WadsConfig.instance.get_window.text_input.nil?

            handle_mouse_click(mouse_x, mouse_y)
        end 

        def handle_key_press id, mouse_x, mouse_y
            if id == Gosu::KbEscape
                return WidgetResult.new(true) 
            end
        end
    end 

    # __WdigetResult__
    # A result object returned from handle methods that instructs the parent widget
    # what to do. A close_widget value of true instructs the recipient to close
    # either the overlay window or the entire app, based on the context of the receiver.
    # In the case of a form being submitted, the action may be "OK" and the form_data
    # contains the information supplied by the user.
    # WidgetResult is intentionally generic so it can support a wide variety of use cases.
    #
    class WidgetResult 
        attr_accessor :close_widget
        attr_accessor :action
        attr_accessor :form_data

        def initialize(close_widget = false, action = "none", form_data = nil)
            @close_widget = close_widget 
            @action = action 
            @form_data = form_data
        end
    end

    # __Line__
    # Renders a line from x, y to x2, y2. The theme graphics elements color
    # is used by default, unless specified using the optional parameter.
    #
    class Line < Widget
        attr_accessor :x2
        attr_accessor :y2

        def initialize(x, y, x2, y2, color = nil) 
            super(x, y)
            @override_color = color
            @x2 = x2 
            @y2 = y2
            disable_border
            disable_background
        end

        def render
            Gosu::draw_line x, y, graphics_color, x2, y2, graphics_color, z_order
        end

        def widget_z 
            Z_ORDER_GRAPHIC_ELEMENTS
        end

        def uses_layout
            false 
        end
    end 

    # __AxisLines__
    # A very specific widget used along with a Plot to draw the x and y axis lines.
    # Note that the labels are drawn using separate widgets.
    #
    class AxisLines < Widget
        def initialize(x, y, width, height, color = nil) 
            super(x, y)
            set_dimensions(width, height)
            disable_border
            disable_background
        end

        def render
            add_child(Line.new(@x, @y, @x, bottom_edge, graphics_color))
            add_child(Line.new(@x, bottom_edge, right_edge, bottom_edge, graphics_color))
        end

        def uses_layout
            false 
        end
    end

    # __VerticalAxisLabel__
    # Labels and tic marks for the vertical axis on a plot
    #
    class VerticalAxisLabel < Widget
        attr_accessor :label

        def initialize(x, y, label, color = nil) 
            super(x, y)
            @label = label 
            @override_color = color
            text_pixel_width = @gui_theme.font.text_width(@label)
            add_text(@label, -text_pixel_width - 28, -12)
            disable_border
            disable_background
        end

        def render
            Gosu::draw_line @x - 20, @y, graphics_color,
                            @x, @y, graphics_color, z_order
        end

        def widget_z 
            Z_ORDER_GRAPHIC_ELEMENTS
        end

        def uses_layout
            false 
        end
    end 

    # __HorizontalAxisLabel__
    # Labels and tic marks for the horizontal axis on a plot
    #
    class HorizontalAxisLabel < Widget
        attr_accessor :label

        def initialize(x, y, label, color = nil) 
            super(x, y)
            @label = label 
            @override_color = color
            text_pixel_width = @gui_theme.font.text_width(@label)
            add_text(@label, -(text_pixel_width / 2), 26)
            disable_border
            disable_background
        end

        def render
            Gosu::draw_line @x, @y, graphics_color, @x, @y + 20, graphics_color, z_order
        end

        def widget_z 
            Z_ORDER_TEXT
        end

        def uses_layout
            false 
        end
    end 

    # __Table__
    # Displays a table of information at the given coordinates.
    # The headers are an array of text labels to display at the top of each column.
    # The max_visible_rows specifies how many rows are visible at once.
    # If there are more data rows than the max, the arrow keys can be used to
    # page up or down through the rows in the table.
    #
    class Table < Widget
        attr_accessor :data_rows 
        attr_accessor :row_colors
        attr_accessor :headers
        attr_accessor :max_visible_rows
        attr_accessor :current_row
        attr_accessor :can_delete_rows

        def initialize(x, y, width, height, headers, max_visible_rows = 10, args = {}) 
            super(x, y)
            set_dimensions(width, height)
            if args[ARG_THEME]
                @gui_theme = args[ARG_THEME]
            end
            @headers = headers
            @current_row = 0
            @max_visible_rows = max_visible_rows
            clear_rows
            @can_delete_rows = false
            @delete_buttons = []
            @next_delete_button_y = 38
        end

        def scroll_up 
            if @current_row > 0
                @current_row = @current_row - @max_visible_rows 
            end 
        end 

        def scroll_down
            if @current_row + @max_visible_rows < @data_rows.size
                @current_row = @current_row + @max_visible_rows 
            end 
        end 

        def clear_rows 
            @data_rows = []
            @row_colors = []
        end 

        def add_row(data_row, color = text_color )
            @data_rows << data_row
            @row_colors << color
        end

        def add_table_delete_button 
            if @delete_buttons.size < @max_visible_rows
                new_button = add_delete_button(@width - 18, @next_delete_button_y) do
                    # nothing to do here, handled in parent widget by event
                end
                @delete_buttons << new_button
                @next_delete_button_y = @next_delete_button_y + 30
            end
        end

        def remove_table_delete_button 
            if not @delete_buttons.empty?
                @delete_buttons.pop
                @children.pop
                @next_delete_button_y = @next_delete_button_y - 30
            end
        end

        def handle_update update_count, mouse_x, mouse_y
            # How many visible data rows are there
            if @can_delete_rows
                number_of_visible_rows = @data_rows.size - @current_row
                if number_of_visible_rows > @max_visible_rows
                    number_of_visible_rows = @max_visible_rows
                end
                if number_of_visible_rows > @delete_buttons.size
                    number_to_add = number_of_visible_rows - @delete_buttons.size 
                    number_to_add.times do 
                        add_table_delete_button 
                    end 
                elsif number_of_visible_rows < @delete_buttons.size
                    number_to_remove = @delete_buttons.size - number_of_visible_rows  
                    number_to_remove.times do 
                        remove_table_delete_button 
                    end 
                end
            end
        end

        def number_of_rows 
            @data_rows.size 
        end

        def render
            draw_border
            return unless number_of_rows > 0

            column_widths = []
            number_of_columns = @data_rows[0].size 
            (0..number_of_columns-1).each do |c| 
                max_length = @gui_theme.font.text_width(headers[c])
                (0..number_of_rows-1).each do |r|
                    text_pixel_width = @gui_theme.font.text_width(@data_rows[r][c])
                    if text_pixel_width > max_length 
                        max_length = text_pixel_width
                    end 
                end 
                column_widths[c] = max_length
            end

            # Draw a horizontal line between header and data rows
            x = @x + 10
            if number_of_columns > 1
                (0..number_of_columns-2).each do |c| 
                    x = x + column_widths[c] + 20
                    Gosu::draw_line x, @y, graphics_color, x, @y + @height, graphics_color, z_order
                end 
            end

            # Draw the header row
            y = @y
            Gosu::draw_rect(@x + 1, y, @width - 3, 28, graphics_color, relative_z_order(Z_ORDER_SELECTION_BACKGROUND)) 

            x = @x + 20
            (0..number_of_columns-1).each do |c| 
                @gui_theme.font.draw_text(@headers[c], x, y + 3, z_order, 1, 1, text_color)
                x = x + column_widths[c] + 20
            end
            y = y + 30

            count = 0
            @data_rows.each do |row|
                if count < @current_row
                    # skip
                elsif count < @current_row + @max_visible_rows
                    x = @x + 20
                    (0..number_of_columns-1).each do |c| 
                        @gui_theme.font.draw_text(row[c], x, y + 2, z_order, 1, 1, @row_colors[count])
                        x = x + column_widths[c] + 20
                    end
                    y = y + 30
                end
                count = count + 1
            end
        end

        def determine_row_number(mouse_y)
            relative_y = mouse_y - @y
            row_number = (relative_y / 30).floor - 1
            if row_number < 0 or row_number > data_rows.size - 1
                return nil 
            end 
            row_number
        end

        def widget_z 
            Z_ORDER_TEXT
        end

        def uses_layout
            false 
        end
    end

    # __SingleSelectTable__
    # A table where the user can select one row at a time.
    # The selected row has a background color specified by the selection color of the
    # current theme.
    #
    class SingleSelectTable < Table
        attr_accessor :selected_row

        def initialize(x, y, width, height, headers, max_visible_rows = 10, args = {}) 
            super(x, y, width, height, headers, max_visible_rows, args) 
        end 

        def is_row_selected(mouse_y)
            row_number = determine_row_number(mouse_y)
            if row_number.nil?
                return false
            end
            selected_row = @current_row + row_number
            @selected_row == selected_row
        end 

        def set_selected_row(mouse_y, column_number)
            row_number = determine_row_number(mouse_y)
            if not row_number.nil?
                new_selected_row = @current_row + row_number
                if @selected_row 
                    if @selected_row == new_selected_row
                        return nil  # You can't select the same row already selected
                    end 
                end
                @selected_row = new_selected_row
                @data_rows[@selected_row][column_number]
            end
        end

        def unset_selected_row(mouse_y, column_number) 
            row_number = determine_row_number(mouse_y) 
            if not row_number.nil?
                this_selected_row = @current_row + row_number
                @selected_row = this_selected_row
                return @data_rows[this_selected_row][column_number]
            end 
            nil
        end

        def render 
            super 
            if @selected_row 
                if @selected_row >= @current_row and @selected_row < @current_row + @max_visible_rows
                    y = @y + 30 + ((@selected_row - @current_row) * 30)
                    Gosu::draw_rect(@x + 20, y, @width - 30, 28, @gui_theme.selection_color, relative_z_order(Z_ORDER_SELECTION_BACKGROUND)) 
                end 
            end
        end

        def widget_z 
            Z_ORDER_TEXT
        end

        def handle_mouse_down mouse_x, mouse_y
            if contains_click(mouse_x, mouse_y)
                row_number = determine_row_number(mouse_y)
                if row_number.nil? 
                    return WidgetResult.new(false)
                end
                # First check if its the delete button that got this
                delete_this_row = false
                @delete_buttons.each do |db|
                    if db.contains_click(mouse_x, mouse_y)
                        delete_this_row = true 
                    end 
                end 
                if delete_this_row
                    if not row_number.nil?
                       data_set_row_to_delete = @current_row + row_number
                       data_set_name_to_delete = @data_rows[data_set_row_to_delete][1]
                       @data_rows.delete_at(data_set_row_to_delete)
                       return WidgetResult.new(false, EVENT_TABLE_ROW_DELETE, [data_set_name_to_delete])                       
                    end
                else
                    if is_row_selected(mouse_y)
                        unset_selected_row(mouse_y, 0)
                        return WidgetResult.new(false, EVENT_TABLE_UNSELECT, @data_rows[row_number])
                    else
                        set_selected_row(mouse_y, 0)
                        return WidgetResult.new(false, EVENT_TABLE_SELECT, @data_rows[row_number])
                    end
                end
            end
        end
    end 

    # __MultiSelectTable__
    # A table where the user can select multiple rows at a time.
    # Selected rows have a background color specified by the selection color of the
    # current theme.
    #
    class MultiSelectTable < Table
        attr_accessor :selected_rows

        def initialize(x, y, width, height, headers, max_visible_rows = 10, args = {}) 
            super(x, y, width, height, headers, max_visible_rows, args) 
            @selected_rows = []
        end
    
        def is_row_selected(mouse_y)
            row_number = determine_row_number(mouse_y)
            if row_number.nil?
                return false
            end
            @selected_rows.include?(@current_row + row_number)
        end 

        def set_selected_row(mouse_y, column_number)
            row_number = determine_row_number(mouse_y)
            if not row_number.nil?
                this_selected_row = @current_row + row_number
                @selected_rows << this_selected_row
                return @data_rows[this_selected_row][column_number]
            end
            nil
        end

        def unset_selected_row(mouse_y, column_number) 
            row_number = determine_row_number(mouse_y) 
            if not row_number.nil?
                this_selected_row = @current_row + row_number
                @selected_rows.delete(this_selected_row)
                return @data_rows[this_selected_row][column_number]
            end 
            nil
        end

        def render 
            super 
            y = @y + 30
            row_count = @current_row
            while row_count < @data_rows.size
                if @selected_rows.include? row_count 
                    width_of_selection_background = @width - 30
                    if @can_delete_rows 
                        width_of_selection_background = width_of_selection_background - 20
                    end
                    Gosu::draw_rect(@x + 20, y, width_of_selection_background, 28,
                                    @gui_theme.selection_color,
                                    relative_z_order(Z_ORDER_SELECTION_BACKGROUND)) 
                end 
                y = y + 30
                row_count = row_count + 1
            end
        end

        def widget_z 
            Z_ORDER_TEXT
        end

        def handle_mouse_down mouse_x, mouse_y
            if contains_click(mouse_x, mouse_y)
                row_number = determine_row_number(mouse_y)
                if row_number.nil? 
                    return WidgetResult.new(false)
                end
                # First check if its the delete button that got this
                delete_this_row = false
                @delete_buttons.each do |db|
                    if db.contains_click(mouse_x, mouse_y)
                        delete_this_row = true 
                    end 
                end 
                if delete_this_row
                    if not row_number.nil?
                       data_set_row_to_delete = @current_row + row_number
                       data_set_name_to_delete = @data_rows[data_set_row_to_delete][1]
                       @data_rows.delete_at(data_set_row_to_delete)
                       return WidgetResult.new(false, EVENT_TABLE_ROW_DELETE, [data_set_name_to_delete])                       
                    end
                else
                    if is_row_selected(mouse_y)
                        unset_selected_row(mouse_y, 0)
                        return WidgetResult.new(false, EVENT_TABLE_UNSELECT, @data_rows[row_number])
                    else
                        set_selected_row(mouse_y, 0)
                        return WidgetResult.new(false, EVENT_TABLE_SELECT, @data_rows[row_number])
                    end
                end
            end
        end
    end 

    # __Plot__
    # A two-dimensional graph display which plots a number of PlotPoint objects.
    # Options include grid lines that can be displayed, as well as whether lines
    # should be drawn connecting each point in a data set.
    #
    class Plot < Widget
        attr_accessor :points
        attr_accessor :visible_range
        attr_accessor :display_grid
        attr_accessor :display_lines
        attr_accessor :zoom_level
        attr_accessor :visibility_map

        def initialize(x, y, width, height) 
            super(x, y)
            set_dimensions(width, height)
            @display_grid = false
            @display_lines = true
            @grid_line_color = COLOR_LIGHT_GRAY
            @cursor_line_color = COLOR_DARK_GRAY 
            @zero_line_color = COLOR_HEADER_BRIGHT_BLUE 
            @zoom_level = 1
            @data_point_size = 4
            # Hash of rendered points keyed by data set name, so we can toggle visibility
            @points_by_data_set_name = {}
            @visibility_map = {}
            disable_border
        end

        def toggle_visibility(data_set_name)
            is_visible = @visibility_map[data_set_name]
            if is_visible.nil?
                return
            end
            @visibility_map[data_set_name] = !is_visible
        end
 
        def increase_data_point_size
            @data_point_size = @data_point_size + 2
        end 

        def decrease_data_point_size 
            if @data_point_size > 2
                @data_point_size = @data_point_size - 2
            end
        end

        def zoom_out 
            @zoom_level = @zoom_level + 0.15
            visible_range.scale(@zoom_level)
        end 

        def zoom_in
            if @zoom_level > 0.11
                @zoom_level = @zoom_level - 0.15
            end
            visible_range.scale(@zoom_level)
        end 

        def scroll_up 
            visible_range.scroll_up
        end

        def scroll_down
            visible_range.scroll_down
        end

        def scroll_right
            visible_range.scroll_right
        end

        def scroll_left
            visible_range.scroll_left
        end

        def define_range(range)
            @visible_range = range
            @zoom_level = 1
        end 

        def range_set?
            not @visible_range.nil?
        end 

        def is_on_screen(point) 
            point.data_x >= @visible_range.left_x and point.data_x <= @visible_range.right_x and point.data_y >= @visible_range.bottom_y and point.data_y <= @visible_range.top_y
        end 

        def add_data_point(data_set_name, data_x, data_y, color = COLOR_MAROON) 
            if range_set?
                rendered_points = @points_by_data_set_name[data_set_name]
                if rendered_points.nil?
                    rendered_points = []
                    @points_by_data_set_name[data_set_name] = rendered_points
                end 
                rendered_points << PlotPoint.new(draw_x(data_x), draw_y(data_y),
                                                 data_x, data_y,
                                                 color)
                if @visibility_map[data_set_name].nil?
                    @visibility_map[data_set_name] = true
                end
            else
                error("ERROR: range not set, cannot add data")
            end
        end 

        def add_data_set(data_set_name, rendered_points)
            if range_set?
                @points_by_data_set_name[data_set_name] = rendered_points
                if @visibility_map[data_set_name].nil?
                    @visibility_map[data_set_name] = true
                end
            else
                error("ERROR: range not set, cannot add data")
            end
        end 

        def remove_data_set(data_set_name)
            @points_by_data_set_name.delete(data_set_name)
            @visibility_map.delete(data_set_name)
        end

        def x_val_to_pixel(val)
            x_pct = (@visible_range.right_x - val).to_f / @visible_range.x_range 
            @width - (@width.to_f * x_pct).round
        end 

        def y_val_to_pixel(val)
            y_pct = (@visible_range.top_y - val).to_f / @visible_range.y_range 
            (@height.to_f * y_pct).round
        end

        def draw_x(x)
            x_pixel_to_screen(x_val_to_pixel(x)) 
        end 

        def draw_y(y)
            y_pixel_to_screen(y_val_to_pixel(y)) 
        end 

        def render
            @points_by_data_set_name.keys.each do |key|
                if @visibility_map[key]
                    data_set_points = @points_by_data_set_name[key]
                    data_set_points.each do |point| 
                        if is_on_screen(point)
                            point.render(@data_point_size)
                        end
                    end 
                    if @display_lines 
                        display_lines_for_point_set(data_set_points) 
                    end
                end
                if @display_grid and range_set?
                    display_grid_lines
                end
            end
        end

        def display_lines_for_point_set(points) 
            if points.length > 1
                points.inject(points[0]) do |last, the_next|
                    if last.x < the_next.x
                        Gosu::draw_line last.x, last.y, last.graphics_color,
                                        the_next.x, the_next.y, last.graphics_color, relative_z_order(Z_ORDER_GRAPHIC_ELEMENTS)
                    end
                    the_next
                end
            end
        end

        def display_grid_lines
            grid_widgets = []

            x_lines = @visible_range.grid_line_x_values
            y_lines = @visible_range.grid_line_y_values
            first_x = draw_x(@visible_range.left_x)
            last_x = draw_x(@visible_range.right_x)
            first_y = draw_y(@visible_range.bottom_y)
            last_y = draw_y(@visible_range.top_y)

            x_lines.each do |grid_x|
                dx = draw_x(grid_x)
                color = @grid_line_color
                if grid_x == 0 and grid_x != @visible_range.left_x.to_i
                    color = @zero_line_color 
                end    
                grid_widgets << Line.new(dx, first_y, dx, last_y, color) 
            end

            y_lines.each do |grid_y| 
                dy = draw_y(grid_y)
                color = @grid_line_color
                if grid_y == 0 and grid_y != @visible_range.bottom_y.to_i
                    color = @zero_line_color
                end
                grid_widgets << Line.new(first_x, dy, last_x, dy, color) 
            end 

            grid_widgets.each do |gw| 
                gw.draw 
            end
        end

        def get_x_data_val(mouse_x)
            graph_x = mouse_x - @x
            x_pct = (@width - graph_x).to_f / @width.to_f
            x_val = @visible_range.right_x - (x_pct * @visible_range.x_range)
            x_val
        end 

        def get_y_data_val(mouse_y)
            graph_y = mouse_y - @y
            y_pct = graph_y.to_f / @height.to_f
            y_val = @visible_range.top_y - (y_pct * @visible_range.y_range)
            y_val
        end

        def draw_cursor_lines(mouse_x, mouse_y)
            Gosu::draw_line mouse_x, y_pixel_to_screen(0), @cursor_line_color, mouse_x, y_pixel_to_screen(@height), @cursor_line_color, Z_ORDER_GRAPHIC_ELEMENTS
            Gosu::draw_line x_pixel_to_screen(0), mouse_y, @cursor_line_color, x_pixel_to_screen(@width), mouse_y, @cursor_line_color, Z_ORDER_GRAPHIC_ELEMENTS
            
            # Return the data values at this point, so the plotter can display them
            [get_x_data_val(mouse_x), get_y_data_val(mouse_y)]
        end 
    end 

    # __NodeWidget__
    # A graphical representation of a node in a graph using a button-style, i.e
    # a rectangular border with a text label.
    # The choice to use this display class is dictated by the use_icons attribute
    # of the current theme.
    # Like images, the size of node widgets can be scaled.
    # 
    class NodeWidget < Button
        attr_accessor :data_node

        def initialize(x, y, node, color = nil, initial_scale = 1, is_explorer = false) 
            super(x, y, node.name)
            @orig_width = @width 
            @orig_height = @height
            @data_node = node
            @override_color = color
            set_scale(initial_scale, @is_explorer)
        end

        def is_background 
            @scale <= 1 and @is_explorer
        end

        def set_scale(value, is_explorer = false)
            @scale = value
            @is_explorer = is_explorer
            if value < 1
                value = 1
            end 
            @width = @orig_width * @scale.to_f
            debug("In regular node widget Setting scale of #{@label} to #{@scale}")
        end

        def get_text_widget
            nil 
        end

        def render 
            super 
            draw_background(Z_ORDER_FOCAL_ELEMENTS)
            #draw_shadow(COLOR_GRAY)
        end
    
        def widget_z 
            Z_ORDER_TEXT
        end
    end 

    # __NodeIconWidget__
    # A graphical representation of a node in a graph using circular icons 
    # and adjacent text labels.
    # The choice to use this display class is dictated by the use_icons attribute
    # of the current theme.
    # Like images, the size of node widgets can be scaled.
    # 
    class NodeIconWidget < Widget
        attr_accessor :data_node
        attr_accessor :image
        attr_accessor :scale
        attr_accessor :label
        attr_accessor :is_explorer

        def initialize(x, y, node, color = nil, initial_scale = 1, is_explorer = false) 
            super(x, y) 
            @override_color = color
            @data_node = node
            @label = node.name
            circle_image = WadsConfig.instance.circle(color)
            if circle_image.nil?
                @image = WadsConfig.instance.circle(COLOR_BLUE)
            else 
                @image = circle_image 
            end
            @is_explorer = is_explorer
            set_scale(initial_scale, @is_explorer)
            disable_border
        end

        def name 
            @data_node.name 
        end

        def is_background 
            @scale <= 0.1 and @is_explorer
        end

        def set_scale(value, is_explorer = false)
            @is_explorer = is_explorer
            if value < 0.5
                value = 0.5
            end 
            @scale = value / 10.to_f
            #debug("In node widget Setting scale of #{@label} to #{value} = #{@scale}")
            @width = IMAGE_CIRCLE_SIZE * scale.to_f
            @height = IMAGE_CIRCLE_SIZE * scale.to_f
            # Only in explorer mode do we dull out nodes on the outer edge
            if is_background 
                @image = WadsConfig.instance.circle(COLOR_ALPHA)
            else
                text_pixel_width = @gui_theme.font.text_width(@label)
                clear_children  # the text widget is the only child, so we can remove all
                add_text(@label, (@width / 2) - (text_pixel_width / 2), -20)
            end
        end

        def get_text_widget
            if @children.size > 0
                return @children[0]
            end 
            #raise "No text widget for NodeIconWidget" 
            nil
        end

        def render 
            @image.draw @x, @y, relative_z_order(Z_ORDER_FOCAL_ELEMENTS), @scale, @scale
        end 

        def widget_z 
            Z_ORDER_TEXT
        end
    end 

    # __GraphWidget__
    # Given a single node or a graph data structure, this widget displays
    # a visualization of the graph using one of the available node widget classes.
    # There are different display modes that control what nodes within the graph 
    # are shown. The default display mode, GRAPH_DISPLAY_ALL, shows all nodes
    # as the name implies. GRAPH_DISPLAY_TREE assumes an acyclic graph and renders
    # the graph in a tree-like structure. GRAPH_DISPLAY_EXPLORER has a chosen
    # center focus node with connected nodes circled around it based on the depth
    # or distance from that node. This mode also allows the user to click on
    # different nodes to navigate the graph and change focus nodes.
    #
    class GraphWidget < Widget
        attr_accessor :graph
        attr_accessor :selected_node
        attr_accessor :selected_node_x_offset
        attr_accessor :selected_node_y_offset
        attr_accessor :size_by_connections
        attr_accessor :is_explorer

        def initialize(x, y, width, height, graph, display_mode = GRAPH_DISPLAY_ALL) 
            super(x, y)
            set_dimensions(width, height)
            if graph.is_a? Node 
                @graph = Graph.new(graph)
            else
                @graph = graph 
            end
            @size_by_connections = false
            @is_explorer = false 
            if [GRAPH_DISPLAY_ALL, GRAPH_DISPLAY_TREE, GRAPH_DISPLAY_EXPLORER].include? display_mode 
                debug("Displaying graph in #{display_mode} mode")
            else 
                raise "#{display_mode} is not a valid display mode for Graph Widget"
            end
            if display_mode == GRAPH_DISPLAY_ALL
                set_all_nodes_for_display
            elsif display_mode == GRAPH_DISPLAY_TREE 
                set_tree_display
            else 
                set_explorer_display 
            end
        end 

        def handle_update update_count, mouse_x, mouse_y
            if contains_click(mouse_x, mouse_y) and @selected_node 
                @selected_node.move_recursive_absolute(mouse_x - @selected_node_x_offset,
                                                       mouse_y - @selected_node_y_offset)
            end
        end

        def handle_mouse_down mouse_x, mouse_y
            # check to see if any node was selected
            if @rendered_nodes
                @rendered_nodes.values.each do |rn|
                    if rn.contains_click(mouse_x, mouse_y)
                        @selected_node = rn 
                        @selected_node_x_offset = mouse_x - rn.x 
                        @selected_node_y_offset = mouse_y - rn.y
                        @click_timestamp = Time.now
                    end
                end
            end
            WidgetResult.new(false)
        end

        def handle_mouse_up mouse_x, mouse_y
            if @selected_node 
                if @is_explorer
                    time_between_mouse_up_down = Time.now - @click_timestamp
                    if time_between_mouse_up_down < 0.2
                        # Treat this as a single click and make the selected
                        # node the new center node of the graph
                        set_explorer_display(@selected_node.data_node)
                    end 
                end
                @selected_node = nil 
            end 
        end

        def set_explorer_display(center_node = nil)
            if center_node.nil? 
                # If not specified, pick a center node as the one with the most connections
                center_node = @graph.node_with_most_connections
            end

            @graph.reset_visited
            @visible_data_nodes = {}
            center_node.bfs(4) do |n|
                @visible_data_nodes[n.name] = n
            end

            @size_by_connections = false
            @is_explorer = true

            @rendered_nodes = {}
            populate_rendered_nodes

            prevent_text_overlap 
        end 

        def set_tree_display
            @graph.reset_visited
            @visible_data_nodes = @graph.node_map
            @rendered_nodes = {}

            root_nodes = @graph.root_nodes
            number_of_root_nodes = root_nodes.size 
            width_for_each_root_tree = @width / number_of_root_nodes

            start_x = 0
            y_level = 20
            root_nodes.each do |root|
                set_tree_recursive(root, start_x, start_x + width_for_each_root_tree - 1, y_level)
                start_x = start_x + width_for_each_root_tree
                y_level = y_level + 40
            end

            @rendered_nodes.values.each do |rn|
                rn.base_z = @base_z
            end

            if @size_by_connections
                scale_node_size
            end

            prevent_text_overlap 
        end 

        def scale_node_size 
            range = @graph.get_number_of_connections_range
            # There are six colors. Any number of scale sizes
            # Lets try 4 first as a max size.
            bins = range.bin_max_values(4)  

            # Set the scale for each node
            @visible_data_nodes.values.each do |node|
                num_links = node.number_of_links
                index = 0
                while index < bins.size 
                    if num_links <= bins[index]
                        @rendered_nodes[node.name].set_scale(index + 1, @is_explorer)
                        index = bins.size
                    end 
                    index = index + 1
                end
            end
        end 

        def prevent_text_overlap 
            @rendered_nodes.values.each do |rn|
                text = rn.get_text_widget
                if text
                    if overlaps_with_a_node(text)
                        move_text_for_node(rn)
                    else 
                        move_in_bounds = false
                        # We also check to see if the text is outside the edges of this widget
                        if text.x < @x or text.right_edge > right_edge 
                            move_in_bounds = true 
                        elsif text.y < @y or text.bottom_edge > bottom_edge 
                            move_in_bounds = true
                        end
                        if move_in_bounds 
                            debug("#{text.label} was out of bounds")
                            move_text_for_node(rn)
                        end
                    end
                end
            end
        end

        def move_text_for_node(rendered_node)
            text = rendered_node.get_text_widget
            if text.nil? 
                return 
            end
            radians_between_attempts = DEG_360 / 24
            current_radians = 0.05
            done = false 
            while not done
                # Use radians to spread the other nodes around the center node
                # TODO base the distance off of scale
                text_x = rendered_node.center_x + ((rendered_node.width / 2) * Math.cos(current_radians))
                text_y = rendered_node.center_y - ((rendered_node.height / 2) * Math.sin(current_radians))
                if text_x < @x 
                    text_x = @x + 1
                elsif text_x > right_edge - 20
                    text_x = right_edge - 20
                end 
                if text_y < @y 
                    text_y = @y + 1
                elsif text_y > bottom_edge - 26 
                    text_y = bottom_edge - 26
                end
                text.x = text_x 
                text.y = text_y
                current_radians = current_radians + radians_between_attempts
                if overlaps_with_a_node(text)
                    # check for done
                    if current_radians > DEG_360
                        done = true 
                        error("ERROR: could not find a spot to put the text")
                    end
                else 
                    done = true
                end 
            end
        end 

        def overlaps_with_a_node(text)
            @rendered_nodes.values.each do |rn| 
                if text.label == rn.label 
                    # don't compare to yourself 
                else 
                    if rn.overlaps_with(text) 
                        return true
                    end
                end
            end
            false
        end

        def set_tree_recursive(current_node, start_x, end_x, y_level)
            # Draw the current node, and then recursively divide up
            # and call again for each of the children
            if current_node.visited 
                return 
            end 
            current_node.visited = true

            if @gui_theme.use_icons
                @rendered_nodes[current_node.name] = NodeIconWidget.new(
                    x_pixel_to_screen(start_x + ((end_x - start_x) / 2)),
                    y_pixel_to_screen(y_level),
                    current_node,
                    get_node_color(current_node))
            else
                @rendered_nodes[current_node.name] = NodeWidget.new(
                    x_pixel_to_screen(start_x + ((end_x - start_x) / 2)),
                    y_pixel_to_screen(y_level),
                    current_node,
                    get_node_color(current_node))
            end

            number_of_child_nodes = current_node.outputs.size 
            if number_of_child_nodes == 0
                return 
            end
            width_for_each_child_tree = (end_x - start_x) / number_of_child_nodes
            start_child_x = start_x + 5

            current_node.outputs.each do |child| 
                if child.is_a? Edge 
                    child = child.destination 
                end
                set_tree_recursive(child, start_child_x, start_child_x + width_for_each_child_tree - 1, y_level + 40)
                start_child_x = start_child_x + width_for_each_child_tree
            end
        end

        def set_all_nodes_for_display 
            @visible_data_nodes = @graph.node_map
            @rendered_nodes = {}
            populate_rendered_nodes
            if @size_by_connections
                scale_node_size
            end
            prevent_text_overlap 
        end 

        def get_node_color(node)
            color_tag = node.get_tag(COLOR_TAG)
            if color_tag.nil? 
                return @color 
            end 
            color_tag
        end 

        def set_center_node(center_node, max_depth = -1)
            # Determine the list of nodes to draw
            @graph.reset_visited 
            @visible_data_nodes = @graph.traverse_and_collect_nodes(center_node, max_depth)

            # Convert the data nodes to rendered nodes
            # Start by putting the center node in the center, then draw others around it
            @rendered_nodes = {}
            if @gui_theme.use_icons
                @rendered_nodes[center_node.name] = NodeIconWidget.new(
                    center_x, center_y, center_node, get_node_color(center_node)) 
            else
                @rendered_nodes[center_node.name] = NodeWidget.new(center_x, center_y,
                    center_node, get_node_color(center_node), get_node_color(center_node))
            end

            populate_rendered_nodes(center_node)

            if @size_by_connections
                scale_node_size
            end
            prevent_text_overlap 
        end 

        def populate_rendered_nodes(center_node = nil)
            # Spread out the other nodes around the center node
            # going in a circle at each depth level
            stats = Stats.new("NodesPerDepth")
            @visible_data_nodes.values.each do |n|
                stats.increment(n.depth)
            end
            current_radians = []
            radians_increment = []
            (1..4).each do |n|
                number_of_nodes_at_depth = stats.count(n)
                radians_increment[n] = DEG_360 / number_of_nodes_at_depth.to_f
                current_radians[n] = 0.05
            end

            padding = 100
            size_of_x_band = (@width - padding) / 6
            size_of_y_band = (@height - padding) / 6
            random_x = size_of_x_band / 8
            random_y = size_of_y_band / 8
            half_random_x = random_x / 2
            half_random_y = random_y / 2

            # Precompute the band center points
            # then reference by the scale or depth values below
            band_center_x = padding + (size_of_x_band / 2) 
            band_center_y = padding + (size_of_y_band / 2) 
            # depth 1 [0] - center node, distance should be zero. Should be only one
            # depth 2 [1] - band one
            # depth 3 [2] - band two
            # depth 4 [3] - band three
            bands_x = [0, band_center_x]
            bands_x << band_center_x + size_of_x_band
            bands_x << band_center_x + size_of_x_band + size_of_x_band

            bands_y = [0, band_center_y]
            bands_y << band_center_y + size_of_y_band
            bands_y << band_center_y + size_of_y_band + size_of_y_band

            @visible_data_nodes.each do |node_name, data_node|
                process_this_node = true
                if center_node 
                    if node_name == center_node.name 
                        process_this_node = false 
                    end 
                end
                if process_this_node 
                    scale_to_use = 1
                    if stats.count(1) > 0 and stats.count(2) == 0
                        # if all nodes are depth 1, then size everything
                        # as a small node
                    elsif data_node.depth < 4
                        scale_to_use = 5 - data_node.depth
                    end
                    if @is_explorer 
                        # TODO Layer the nodes around the center
                        # We need a better multiplier based on the height and width
                        # max distance x would be (@width / 2) - padding
                        # divide that into three regions, layer 2, 3, and 4
                        # get the center point for each of these regions, and do a random from there
                        # scale to use determines which of the regions
                        band_index = 4 - scale_to_use
                        distance_from_center_x = bands_x[band_index] + rand(random_x) - half_random_x
                        distance_from_center_y = bands_y[band_index] + rand(random_y) - half_random_y
                    else 
                        distance_from_center_x = 80 + rand(200)
                        distance_from_center_y = 40 + rand(100)
                    end
                    # Use radians to spread the other nodes around the center node
                    radians_to_use = current_radians[data_node.depth]
                    radians_to_use = radians_to_use + (rand(radians_increment[data_node.depth]) / 2)
                    current_radians[data_node.depth] = current_radians[data_node.depth] + radians_increment[data_node.depth]
                    node_x = center_x + (distance_from_center_x * Math.cos(radians_to_use))
                    node_y = center_y - (distance_from_center_y * Math.sin(radians_to_use))
                    if node_x < @x 
                        node_x = @x + 1
                    elsif node_x > right_edge - 20
                        node_x = right_edge - 20
                    end 
                    if node_y < @y 
                        node_y = @y + 1
                    elsif node_y > bottom_edge - 26 
                        node_y = bottom_edge - 26
                    end

                    # Note we can link between data nodes and rendered nodes using the node name
                    # We have a map of each
                    if @gui_theme.use_icons
                        @rendered_nodes[data_node.name] = NodeIconWidget.new(
                                                        node_x,
                                                        node_y,
                                                        data_node,
                                                        get_node_color(data_node),
                                                        scale_to_use,
                                                        @is_explorer) 
                    else
                        @rendered_nodes[data_node.name] = NodeWidget.new(
                                                        node_x,
                                                        node_y,
                                                        data_node,
                                                        get_node_color(data_node),
                                                        scale_to_use,
                                                        @is_explorer)
                    end
                end
            end
            @rendered_nodes.values.each do |rn|
                rn.base_z = @base_z
            end
        end

        def render 
            if @rendered_nodes
                @rendered_nodes.values.each do |vn|
                    vn.draw 
                end 

                # Draw the connections between nodes 
                @visible_data_nodes.values.each do |data_node|
                    data_node.outputs.each do |connected_data_node|
                        if connected_data_node.is_a? Edge 
                            connected_data_node = connected_data_node.destination 
                        end
                        rendered_node = @rendered_nodes[data_node.name]
                        connected_rendered_node = @rendered_nodes[connected_data_node.name]
                        if connected_rendered_node.nil?
                            # Don't draw if it is not currently visible
                        else
                            if @is_explorer and (rendered_node.is_background or connected_rendered_node.is_background)
                                # Use a dull gray color for the line
                                Gosu::draw_line rendered_node.center_x, rendered_node.center_y, COLOR_LIGHT_GRAY,
                                    connected_rendered_node.center_x, connected_rendered_node.center_y, COLOR_LIGHT_GRAY,
                                    relative_z_order(Z_ORDER_GRAPHIC_ELEMENTS)
                            else
                                Gosu::draw_line rendered_node.center_x, rendered_node.center_y, rendered_node.graphics_color,
                                    connected_rendered_node.center_x, connected_rendered_node.center_y, connected_rendered_node.graphics_color,
                                    relative_z_order(Z_ORDER_GRAPHIC_ELEMENTS)
                            end
                        end
                    end
                end 
            end
        end 
    end
end
