class Point
  include Comparable

  POINT_COLOR = "#DF004F"
  POINT_SIZE = 5
  
  attr_accessor :x, :y
  
  def initialize(x, y)
    @x = x
    @y = y
  end

  def distance_to(other)
    Math.sqrt(dx_to(other) ** 2 + dy_to(other) ** 2)
  end

  def dx_to(other)
    other.to_point.x - x
  end

  def dy_to(other)
    other.to_point.y - y
  end

  def to_point
    self
  end

  def line_to(other)
    Line.new(self, other)
  end

  def direction_to(line)
    a = line.start
    b = line.stop

    k = (x - a.x) * (b.y - a.y)
    m = (b.x - a.x) * (y - a.y)

    return k < m ? -1 : k > m ? 1 : 0
  end

  def is_on_line?(line)
    a = line.start
    b = line.stop

    (a.x <= x || b.x <= x) && (x <= a.x || x <= b.x) &&
    (a.y <= y || b.y <= y) && (y <= a.y || y <= b.y)
  end

  def to_s
    "(#{x.round(2)},#{y.round(2)})"
  end

  def to_a
    [x, y]
  end

  def draw(drawer)
    drawer.beginPath()
    drawer.arc(x.round, y.round, POINT_SIZE, 0, JS.eval("return 2 * Math.PI"), true)
    drawer[:fillStyle] = POINT_COLOR
    drawer.fill()
    drawer[:strokeStyle] = Line::LINE_COLOR
    drawer.stroke()
  end

  def ==(other)
    (self.x - other.x).abs < epsilon && (self.y - other.y).abs < epsilon
  end

  def epsilon
    0.0000001
  end

  def clone(other)
    self.x = other.x
    self.y = other.y
  end

  alias :eql? :==

  def <=>(other)
    self.distance_to(Point.zero) <=> other.distance_to(Point.zero)
  end

  def x_axis
    @x_axis ||= Line.new(self, [x+1, y])
  end

  def y_axis
    @y_axis ||= Line.new(self, [x, y+1])
  end

  def angle_to(other)
    Math.atan2(other.y-y, other.x-x) * 180 / Math::PI
  end

  def angle2_to(b, c)
    a1 = angle_to b
    a2 = b.angle_to c
    a3 = a1 - a2
    if a3.negative?
      a3 += 360
    elsif a3 > 360
      a3 -= 360
    end
    a3
  end


  def self.zero
    @zero ||= new(0,0)
  end

  Array.class_eval do
    class NotPointError < StandardError; end

    def to_point
      raise NotPointError, "Provide array of size like [x, y]" if size != 2
      Point.new(self[0], self[1])
    end
  end

end