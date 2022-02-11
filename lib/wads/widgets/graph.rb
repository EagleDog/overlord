# graph.rb
#   GraphWidget
#

module Wads

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
