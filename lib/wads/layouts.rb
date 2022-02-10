#
# All wads classes are contained within the wads module.
#
module Wads

    # The base class for all wads layouts. It has helper methods to add
    # different types of widgets to the layout.
    class WadsLayout 
        attr_accessor :border_coords
        attr_accessor :parent_widget
        attr_accessor :args

        def initialize(x, y, width, height, parent_widget, args = {})
            @border_coords = Coordinates.new(x, y, width, height)
            @parent_widget = parent_widget
            @args = args
        end

        def get_coordinates(element_type, args = {})
            raise "You must use a subclass of WadsLayout"
        end

        def add_widget(widget, args = {})
            # The widget already has an x, y position, so we need to move it
            # based on the layout
            coordinates = get_coordinates(ELEMENT_GENERIC, args)
            widget.move_recursive_absolute(coordinates.x, coordinates.y)
            widget.base_z = @parent_widget.base_z
            @parent_widget.add_child(widget)
            widget
        end

        def add_text(message, args = {})
            default_dimensions = WadsConfig.instance.default_dimensions(ELEMENT_TEXT)
            if args[ARG_USE_LARGE_FONT]
                text_width = WadsConfig.instance.current_theme.pixel_width_for_large_font(message)
            else
                text_width = WadsConfig.instance.current_theme.pixel_width_for_string(message)
            end
            coordinates = get_coordinates(ELEMENT_TEXT,
                { ARG_DESIRED_WIDTH => text_width,
                  ARG_DESIRED_HEIGHT => default_dimensions[1]}.merge(args))
            new_text = Text.new(coordinates.x, coordinates.y, message,
                { ARG_THEME => @parent_widget.gui_theme}.merge(args))
            new_text.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_text)
            new_text
        end 

        def add_text_input(width, default_text = '', args = {})
            coordinates = get_coordinates(ELEMENT_TEXT_INPUT,
                { ARG_DESIRED_WIDTH => width}.merge(args))
            new_text_input = TextField.new(coordinates.x, coordinates.y, default_text, width)
            new_text_input.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_text_input)
            @parent_widget.text_input_fields << new_text_input
            new_text_input
        end 

        def add_image(filename, args = {})
            img = Gosu::Image.new(filename)
            coordinates = get_coordinates(ELEMENT_IMAGE,
                { ARG_DESIRED_WIDTH => img.width,
                  ARG_DESIRED_HEIGHT => img.height}.merge(args))
            new_image = ImageWidget.new(coordinates.x, coordinates.y, img,
                                        {ARG_THEME => @parent_widget.gui_theme}.merge(args))
            new_image.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_image)
            new_image
        end

        def add_button(label, args = {}, &block)
            text_width = WadsConfig.instance.current_theme.pixel_width_for_string(label) + 20
            coordinates = get_coordinates(ELEMENT_BUTTON,
                { ARG_DESIRED_WIDTH => text_width}.merge(args))
            new_button = Button.new(coordinates.x, coordinates.y, label, 
                                    { ARG_DESIRED_WIDTH => coordinates.width,
                                      ARG_THEME => @parent_widget.gui_theme}.merge(args))
            new_button.set_action(&block)
            new_button.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_button)
            new_button
        end

        def add_plot(args = {})
            coordinates = get_coordinates(ELEMENT_PLOT, args)
            new_plot = Plot.new(coordinates.x, coordinates.y,
                                coordinates.width, coordinates.height) 
            new_plot.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_plot)
            new_plot
        end

        def add_document(content, args = {})
            number_of_content_lines = content.lines.count
            height = (number_of_content_lines * 26) + 4
            coordinates = get_coordinates(ELEMENT_DOCUMENT,
                { ARG_DESIRED_HEIGHT => height}.merge(args))
            new_doc = Document.new(coordinates.x, coordinates.y,
                                   coordinates.width, coordinates.height,
                                   content,
                                   {ARG_THEME => @parent_widget.gui_theme}.merge(args))
            new_doc.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_doc)
            new_doc
        end

        def add_graph_display(graph, display_mode = GRAPH_DISPLAY_ALL, args = {})
            coordinates = get_coordinates(ELEMENT_GRAPH, args)
            new_graph = GraphWidget.new(coordinates.x, coordinates.y,
                                        coordinates.width, coordinates.height,
                                        graph, display_mode) 
            new_graph.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_graph)
            new_graph
        end

        def add_single_select_table(column_headers, visible_rows, args = {})
            calculated_height = 30 + (visible_rows * 30)
            coordinates = get_coordinates(ELEMENT_TABLE,
                { ARG_DESIRED_HEIGHT => calculated_height}.merge(args))
            new_table = SingleSelectTable.new(coordinates.x, coordinates.y,
                                              coordinates.width, coordinates.height,
                                              column_headers, visible_rows,
                                              {ARG_THEME => @parent_widget.gui_theme}.merge(args))
            new_table.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_table)
            new_table
        end 

        def add_multi_select_table(column_headers, visible_rows, args = {})
            calculated_height = 30 + (visible_rows * 30)
            coordinates = get_coordinates(ELEMENT_TABLE,
                { ARG_DESIRED_HEIGHT => calculated_height}.merge(args))
            new_table = MultiSelectTable.new(coordinates.x, coordinates.y,
                                             coordinates.width, coordinates.height,
                                             column_headers, visible_rows,
                                             {ARG_THEME => @parent_widget.gui_theme}.merge(args))
            new_table.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_table)
            new_table
        end 

        def add_table(column_headers, visible_rows, args = {})
            calculated_height = 30 + (visible_rows * 30)
            coordinates = get_coordinates(ELEMENT_TABLE,
                { ARG_DESIRED_HEIGHT => calculated_height}.merge(args))
            new_table = Table.new(coordinates.x, coordinates.y,
                                coordinates.width, coordinates.height,
                                column_headers, visible_rows,
                                {ARG_THEME => @parent_widget.gui_theme}.merge(args))
            new_table.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_table)
            new_table
        end 

        def add_horizontal_panel(args = {})
            internal_add_panel(ELEMENT_HORIZONTAL_PANEL, args)
        end 

        def add_vertical_panel(args = {})
            internal_add_panel(ELEMENT_VERTICAL_PANEL, args)
        end 

        def add_max_panel(args = {})
            internal_add_panel(ELEMENT_MAX_PANEL, args)
        end 

        def internal_add_panel(orientation, args)
            coordinates = get_coordinates(orientation, args)
            new_panel = Panel.new(coordinates.x, coordinates.y,
                                  coordinates.width, coordinates.height)
            new_panel_layout = args[ARG_LAYOUT]
            if new_panel_layout.nil?
                new_panel_layout = LAYOUT_VERTICAL_COLUMN
            end
            new_panel.set_layout(new_panel_layout, args)

            new_panel_theme = args[ARG_THEME]
            new_panel.gui_theme = new_panel_theme unless new_panel_theme.nil?

            new_panel.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_panel)
            #new_panel.disable_border
            new_panel
        end
    end 

    class VerticalColumnLayout < WadsLayout
        attr_accessor :single_column_container

        def initialize(x, y, width, height, parent_widget, args = {})
            super
            @single_column_container = GuiContainer.new(x, y, width, height, FILL_VERTICAL_STACK)
        end

        # This is the standard interface for layouts
        def get_coordinates(element_type, args = {})
            @single_column_container.get_coordinates(element_type, args)
        end
    end 

    # SectionLayout is an intermediate class in the layout class hierarchy
    # that is used to divide the visible screen into different sections.
    # The commonly used sections include SECTION_TOP or SECTION_NORTH,
    # SECTION_MIDDLE or SECTION_CENTER, SECTION_BOTTOM or SECTION_SOUTH,
    # SECTION_LEFT or SECTION_WEST, SECTION_RIGHT or SECTION_EAST.
    class SectionLayout < WadsLayout
        attr_accessor :container_map

        def initialize(x, y, width, height, parent_widget, args = {})
            super
            @container_map = {}
        end

        #
        # Get the coordinates for the given element type. A generic map of parameters
        # is accepted, however the  ARG_SECTION is required so the layout can determine
        # which section or container is used.
        #
        def get_coordinates(element_type, args = {})
            section = args[ARG_SECTION]
            if section.nil?
                raise "Layout addition requires the arg '#{ARG_SECTION}' with value #{@container_map.keys.join(', ')}"
            end
            container = @container_map[section]
            if container.nil? 
                raise "Invalid section #{section}. Value values are #{@container_map.keys.join(', ')}"
            end
            container.get_coordinates(element_type, args)
        end
    end 

    # The layout sections are as follows:
    #
    #   +-------------------------------------------------+
    #   +                  SECTION_NORTH                  +
    #   +-------------------------------------------------+
    #   +                                                 +
    #   +                  SECTION_CENTER                 +
    #   +                                                 +
    #   +-------------------------------------------------+
    class HeaderContentLayout < SectionLayout
        def initialize(x, y, width, height, parent_widget, args = {})
            super
            # Divide the height into 100, 100, and the middle gets everything else
            # Right now we are using 100 pixels rather than a percentage for the borders
            header_section_height = 100
            if args[ARG_DESIRED_HEIGHT]
                header_section_height = args[ARG_DESIRED_HEIGHT]
            end
            middle_section_y_start = y + header_section_height
            height_middle_section = height - header_section_height
            @container_map[SECTION_NORTH] = GuiContainer.new(x, y, width, header_section_height)
            @container_map[SECTION_CENTER] = GuiContainer.new(x, middle_section_y_start, width, height_middle_section, FILL_VERTICAL_STACK)
        end
    end 

    # The layout sections are as follows:
    #
    #   +-------------------------------------------------+
    #   +                                                 +
    #   +                  SECTION_CENTER                 +
    #   +                                                 +
    #   +-------------------------------------------------+
    #   +                  SECTION_SOUTH                  +
    #   +-------------------------------------------------+
    class ContentFooterLayout < SectionLayout
        def initialize(x, y, width, height, parent_widget, args = {})
            super
            # Divide the height into 100, 100, and the middle gets everything else
            # Right now we are using 100 pixels rather than a percentage for the borders
            bottom_section_height = 100
            if args[ARG_DESIRED_HEIGHT]
                bottom_section_height = args[ARG_DESIRED_HEIGHT]
            end
            bottom_section_y_start = y + height - bottom_section_height
            middle_section_height = height - bottom_section_height
            @container_map[SECTION_CENTER] = GuiContainer.new(x, y, width, middle_section_height, FILL_VERTICAL_STACK)
            @container_map[SECTION_SOUTH] = GuiContainer.new(x, bottom_section_y_start,
                                                            width, bottom_section_height)
        end
    end 

    # The layout sections are as follows:
    #
    #   +-------------------------------------------------+
    #   +                        |                        +
    #   +     SECTION_WEST       |      SECTION_EAST      +
    #   +                        |                        +
    #   +-------------------------------------------------+
    #
    class EastWestLayout < SectionLayout
        def initialize(x, y, width, height, parent_widget, args = {})
            super
            west_section_width = width / 2
            if args[ARG_PANEL_WIDTH]
                west_section_width = args[ARG_PANEL_WIDTH]
            end
            east_section_width = width - west_section_width
            @container_map[SECTION_WEST] = GuiContainer.new(x, y,
                                                           west_section_width, height,
                                                           FILL_FULL_SIZE)
            @container_map[SECTION_EAST] = GuiContainer.new(x + west_section_width, y,
                                                           east_section_width, height,
                                                           FILL_FULL_SIZE)
        end
    end 

    # The layout sections are as follows:
    #
    #   +-------------------------------------------------+
    #   +                  SECTION_NORTH                  +
    #   +-------------------------------------------------+
    #   +                                                 +
    #   +                  SECTION_CENTER                 +
    #   +                                                 +
    #   +-------------------------------------------------+
    #   +                  SECTION_SOUTH                  +
    #   +-------------------------------------------------+
    class TopMiddleBottomLayout < SectionLayout
        def initialize(x, y, width, height, parent_widget, args = {})
            super
            # Divide the height into 100, 100, and the middle gets everything else
            # Right now we are using 100 pixels rather than a percentage for the borders
            middle_section_y_start = y + 100
            bottom_section_y_start = y + height - 100
            height_middle_section = height - 200
            @container_map[SECTION_NORTH] = GuiContainer.new(x, y, width, 100)
            @container_map[SECTION_CENTER] = GuiContainer.new(x, middle_section_y_start,
                                                             width, height_middle_section, FILL_VERTICAL_STACK)
            @container_map[SECTION_SOUTH] = GuiContainer.new(x, bottom_section_y_start, width, 100)
        end
    end 

    # The layout sections are as follows:
    #
    #   +-------------------------------------------------+
    #   +                  SECTION_NORTH                  +
    #   +-------------------------------------------------+
    #   +              |                   |              +
    #   + SECTION_WEST |   SECTION_CENTER  | SECTION_EAST +
    #   +              |                   |              +
    #   +-------------------------------------------------+
    #   +                  SECTION_SOUTH                  +
    #   +-------------------------------------------------+
    class BorderLayout < SectionLayout
        def initialize(x, y, width, height, parent_widget, args = {})
            super
            # Divide the height into 100, 100, and the middle gets everything else
            # Right now we are using 100 pixels rather than a percentage for the borders
            middle_section_y_start = y + 100
            bottom_section_y_start = y + height - 100

            height_middle_section = bottom_section_y_start - middle_section_y_start

            middle_section_x_start = x + 100
            right_section_x_start = x + width - 100
            width_middle_section = right_section_x_start - middle_section_x_start

            @container_map[SECTION_NORTH] = GuiContainer.new(x, y, width, 100)
            @container_map[SECTION_WEST] = GuiContainer.new(
                x, middle_section_y_start, 100, height_middle_section, FILL_VERTICAL_STACK)
            @container_map[SECTION_CENTER] = GuiContainer.new(
                                   middle_section_x_start,
                                   middle_section_y_start,
                                   width_middle_section,
                                   height_middle_section,
                                   FILL_VERTICAL_STACK)
            @container_map[SECTION_EAST] = GuiContainer.new(
                                   right_section_x_start,
                                   middle_section_y_start,
                                   100,
                                   height_middle_section,
                                   FILL_VERTICAL_STACK)
            @container_map[SECTION_SOUTH] = GuiContainer.new(x, bottom_section_y_start, width, 100)
        end
    end 
end
