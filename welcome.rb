# welcome.rb
# welcome screen

class WelcomeScreen < InfoBox
    def initialize(title, content_id)
        content_file_name = 
            File.join(File.dirname(File.dirname(__FILE__)), 
            'overlord', 
            'msgs', 
            "messages_#{content_id}.txt")
        if not File.exist?(content_file_name)
            raise "The content file #{content_file_name} does not exist"
        end
        content = File.readlines(content_file_name).join("")
        super(300, 80, 600, 450, 
              title, content, 
              { ARG_THEME => OverTheme.new})
    end

    def handle_key_press id, mouse_x, mouse_y
        if id == Gosu::KbEscape or id == Gosu::KbEnter or 
           id == Gosu::KbSpace
            return WidgetResult.new(true)
        end
    end
end


    # __LoseScreen__
class LoseScreen < Widget 
    def initialize(x, y, width, height, title, content, args = {}) 
        super(x, y) 
        set_dimensions(width, height)
        @base_z = 10
        if args[ARG_THEME]
            @gui_theme = args[ARG_THEME]
        end
        add_text(title, 25, 40)
        add_document(content, 25, 70, width, height - 52)
        ok_button = add_button("OK", (@width / 2) - 50, height - 120) do
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




def create_overlay_widget
    InfoBox.new(100, 60, 600, 400,
                "Overlord Castle", 
                overlay_content, 
                { ARG_THEME => OverTheme.new})
end

def overlay_content
    <<~HEREDOC
    Try to win.
    HEREDOC
end

def create_you_lose_widget
    InfoBox.new(300, 80, 600, 400, 
                "        You lost", 
                you_lose_content, 
                { ARG_THEME => OverTheme.new})
end

def you_lose_content
    <<~HEREDOC
    Try not to lose.
    HEREDOC
end

def create_you_win_widget
    InfoBox.new(300, 80, 600, 400, 
                "         Goal Reached", 
                you_win_content, 
                { ARG_THEME => OverTheme.new})
end

def you_win_content
    <<~HEREDOC

        You have saved the castle.

        You have saved the world.
    HEREDOC
end


