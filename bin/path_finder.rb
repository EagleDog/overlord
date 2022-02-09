# path_finder.rb
#
#

path_found = '' 

puts __dir__
puts __FILE__

path_found = __dir__ + __FILE__

puts path_found

#path_found = '' 
path_found = File.join(File.dirname(File.dirname(__FILE__)), 'media', 'ooo')

puts path_found
