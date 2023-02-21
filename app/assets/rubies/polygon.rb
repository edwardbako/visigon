class Polygon

  VISIBLE_COLOR = "#ECFB8E"
  POLYGON_COLOR = "#EE86AB"

  attr_accessor :points, :outline, :fill, :visible

  def initialize(points, fill = true, outline = true, visible = false)
    @points = points.map(&:to_point)
    @outline = outline
    @fill = fill
    @visible = visible
  end

  def lines
    @lines ||= begin
      last = points.last
      points.map do |point|
        line = Line.new(last, point)
        last = point
        line
      end.rotate(1)
    end
  end

  def to_s
    lines.join(" | ")
  end

  def draw(drawer)
    drawer.beginPath()

    if fill
      first = points.first

      drawer.moveTo(first.x.round, first.y.round)
      points[1..-1].each { |point| drawer.lineTo(point.x.round, point.y.round) }
      drawer.lineTo(first.x.round, first.y.round)
      
      drawer[:fillStyle] = visible ? VISIBLE_COLOR : POLYGON_COLOR
      drawer.fill()
    end

    if outline && !visible
      lines.each { |line| line.draw(drawer) }
    end
  end

end