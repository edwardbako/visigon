class Point
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end
end

class Line
  attr_accessor :a, :b

  def initialize(a, b)
    @a = a
    @b = b
  end
  
  def length
    Math.sqrt(x_diff ** 2 + y_diff ** 2)
  end

  def x_diff
    b.x - a.x
  end

  def y_diff
    b.y - a.y
  end
end

a = Point.new(0,0)
b = Point.new(4,5)
l = Line.new(a, b)
puts "In assets LIne length: #{l.length}"