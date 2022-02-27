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
        super(300, 80, 600, 450, title, content, 
              { ARG_THEME => OverTheme.new})
    end

    def handle_key_press id, mouse_x, mouse_y
        if id == Gosu::KbEscape or id == Gosu::KbEnter or 
           id == Gosu::KbSpace
            return WidgetResult.new(true)
        end
    end
end 