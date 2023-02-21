class Line
  # include Comparable

  class WrongDirctionError < StandardError; end

  LINE_COLOR = "#849A00"
  LINE_WIDTH = 2

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

  def active_to?(observer)
    a1 = start.angle_to(observer)
		a2 = stop.angle_to(observer)
		active = false
		active = true if ((0..180).include?(a1) && (180..360).include?(a2) && a2 - a1 > 180)
		active = true if ((0..180).include?(a2) && (180..360).include?(a1) && a1 - a2 > 180)
    active
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

    # puts "### denominator: #{denominator} for #{self} :: #{other}"
    if denominator == 0
      if ((a.x*b.y-b.x*a.y)*(d.x-c.x) - (c.x*d.y-d.x*c.y)*(b.x.-a.x) == 0 &&
          (a.x*b.y-b.x*a.y)*(d.y-c.y) - (c.x*d.y-d.x*c.y)*(b.y.-a.y) == 0)
        [nil, inter ? :same_in : :same_out]
      else
        [nil, :parallel]
      end
    else
      numerator_a = (d.x-b.x)*(d.y-c.y)-(d.x-c.x)*(d.y-b.y)
      numerator_b = (a.x-b.x)*(d.y-b.y)-(d.x-b.x)*(d.y-b.y)
      u_a = numerator_a/denominator.to_f
      u_b = numerator_b/denominator.to_f

      if inter || (0..1).include?(u_a) && (0..1).include?(u_b)
        point = Point.new((a.x*u_a + b.x*(1-u_a)).round, (a.y*u_a + b.y*(1-u_a)).round)
        [
          point,
          if inter && (point != start) && (point != stop)
            :intersects_in
          else
            :intersects_out
          end 
        ]
      else
        [nil, :none]
      end
    end
  end

  def intersections(others)
    result = []
    # puts "----- Intersections on #{self}"
    others.each do |line|
      if intersects?(line)
        intersection = intersection_of(line)
        # puts "#{line} #{" "*(26-line.to_s.size)} :: #{intersection}"
        result << intersection[0] if intersection[1] == :intersects_in 
      end
    end
    # puts "intersections points: #{result}"
    result.sort_by {|point| point.distance_to(start)}
  end

  def outer_intersections(others)
    result = []
    others.each do |line|
      intersection = intersection_of(line)
      result << intersection[0] if intersection[1] == :intersects_out
    end
    # puts "#{self} #{result}"
    result.sort_by {|point| point.distance_to(start)}
  end

  def sections(others)
    (intersections(others) + points).sort_by {|point| point.distance_to(start)}
  end

  def split_by_lines(others)
    inter_points = sections(others)
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

  def same_in_with?(other)
    intersection_of(other)[1] == :same_in
  end

  def ==(other)
    (self.start == other.start && self.stop == other.stop) ||
    (self.start == other.stop && self.stop == other.start)
  end

  def <=>(other)
    self.length <=> other.length
  end

  def prolong!(direction)
    base = 0.01
    epsilon = case direction
              when :forward
                base
              when :backward
                -base
              else
                raise WrongDirctionError, "Direction should either be :forward or :backward"
              end

    angle = stop.angle_to(start) + epsilon
    # puts "ANGLE: #{angle}"
    stop.x = (start.x + Math.cos(angle * Math::PI / 180) * 1000)
    stop.y = (start.y + Math.sin(angle * Math::PI / 180) * 1000)
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

  def to_a
    points.map(&:to_a)
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
