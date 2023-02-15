class Polygon

  VISIBLE_COLOR = "#FFE7B7"
  POLYGON_COLOR = "#FFBC84"

  attr_accessor :points, :outline, :fill, :visible

  def initialize(points, fill = true, outline = true, visible = false)
    @points = points.map(&:to_point)
    @outline = outline
    @fill = fill
    @visible = visible
  end

  def lines
    @ponts ||= begin
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

      drawer.moveTo(first.x, first.y)
      points[1..-1].each { |point| drawer.lineTo(point.x, point.y) }
      drawer.lineTo(first.x, first.y)
      
      drawer[:fillStyle] = visible ? VISIBLE_COLOR : POLYGON_COLOR
      drawer.fill()
    end

    if outline && !visible
      lines.each { |line| line.draw(drawer) }
    end
  end

end