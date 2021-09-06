# chapter_01/hello_world.rb
require 'ramaze'

class HelloWorld < Ramaze::Controller
  map '/hello_world'

  def index
    'Hello, World1'
  end
end

Ramaze.start