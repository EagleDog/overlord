# pathfinder.rb
#
#
class Pathfinder
  attr_reader :mediapath
  def setup
    puts __dir__
    puts __FILE__

    path_found = '' 
    path_found = File.join(File.dirname(File.dirname(__FILE__)), 'media', '----')
    puts path_found
    @pathway = File.join(File.dirname(File.dirname(__FILE__)), 'overlord/media/')
    puts @pathway
    @mediapath = File.join(File.dirname(File.dirname(__FILE__)), 'overlord/media/')
    puts @mediapath


  end
end

#@pathfinder = Pathfinder.new
#@pathfinder.setup