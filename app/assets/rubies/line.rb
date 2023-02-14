class Line
  # include Comparable

  LINE_COLOR = "#854200"
  LINE_WIDTH = 1

  attr_accessor :start, :stop
  
  def initialize(start, stop)
    @start = start.to_point
    @stop = stop.to_point
  end

  def length
    start.distance_to stop
  end

  def points
    [start, stop]
  end

  def intersects?(other)
    d1 = start.direction_to other
    d2 = stop.direction_to other
    d3 = direction_of other.start
    d4 = direction_of other.stop

    (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
    ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) ||
    (d1 == 0 && start.is_on_line?(other)) ||
    (d2 == 0 && stop.is_on_line?(other)) ||
    (d3 == 0 && other.start.is_on_line?(self)) ||
    (d4 == 0 && other.stop.is_on_line?(self))
  end

  def intersection_of(other)
    a = start
    b = stop
    c = other.start
    d = other.stop

    denominator=(d.y-c.y)*(a.x-b.x)-(d.x-c.x)*(a.y-b.y)
    inter = intersects?(other)

    if denominator == 0
      if ((a.x*b.y-b.x*a.y)*(d.x-c.x) - (c.x*d.y-d.x*c.y)*(b.x.-a.x) == 0 &&
          (a.x*b.y-b.x*a.y)*(d.y-c.y) - (c.x*d.y-d.x*c.y)*(b.y.-a.y) == 0)
        {point: nil, value: inter ? :same_in : :same_out}
      else
        {point: nil, value: :parallel}
      end
    else
      numerator_a = (d.x-b.x)*(d.y-c.y)-(d.x-c.x)*(d.y-b.y)
      numerator_b = (a.x-b.x)*(d.y-b.y)-(d.x-b.x)*(d.y-b.y)
      u_a = numerator_a/denominator.to_f
      u_b = numerator_b/denominator.to_f
      point = Point.new(a.x*u_a + b.x*(1-u_a), a.y*u_a + b.y*(1-u_a))
      if (0..1).include?(u_a) && (0..1).include?(u_b)
        {
          point: point,
          value: if inter && point != start && point != stop
                  :intersects_in
                else
                  :intersects_out
                end 
        }
      else
        {point: point, value: :none}
      end
    end
  end

  def intersections(others)
    result = points
    others.each do |line|
      intersection = intersection_of(line)
      result << intersection[:point] if intersection[:value] == :intersects_in 
    end
    result.sort_by {|point| [point.x, point.y]}
  end

  def split_by_lines(others)
    inter_points = intersections(others)
    first = inter_points.first
    if inter_points.size > 2
      inter_points[1..-1].map do |point|
        line = Line.new(first, point)
        first = point
        line
      end
    else
      [self]
    end
  end

  def ==(other)
    (self.start == other.start && self.stop == other.stop) ||
    (self.start == other.stop && self.stop == other.start)
  end

  def <=>(other)
    self.length <=> other.length
  end

  def direction_of(point)
    point.direction_to self
  end

  def dx
    stop.x - start.x
  end

  def dy
    stop.y - start.y
  end

  def to_s
    "#{start} - #{stop}"
  end

  def draw(drawer)
    drawer.beginPath()
    
    drawer.moveTo(start.x, start.y)
    drawer.lineTo(stop.x, stop.y)

    drawer[:strokeStyle] = LINE_COLOR
    drawer[:lineWidth] = LINE_WIDTH
    drawer.stroke()
  end
end
