class Drawer
  include Profiler
  include JsPrimitives

  BACKGROUND_COLOR = "#CCCCCC"

  attr_accessor :width, :height, :observer, :elements, :changed, :visibility

  def initialize(**args)
    elements = args.delete(:elements) || defaults[:elements]

    defaults.merge!(args)
    defaults.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    @elements = [Polygon.new([
      [-1,-0],
      [width+1, -1],
      [width+1, height+1],
      [-1, height+1]
    ], false)] + elements

    @changed = true
    Logger.log self, "Initialized and wisigon is #{window[:visigon]}"
  end

  def defaults
    {
      width: 500,
      height: 500,
      observer: [214, 154].to_point,
      elements: []
    }
  end

  def update
    if changed
      clear
      visibility.update
      draw
      self.changed = false
    end
  end
  
  def clear
  end
  
  def draw
    # elements.compact.each{ |element| element.draw(ctx) }
    draw_visibility
    draw_polygons
    draw_segments
    # draw_points
    draw_observer
  end

  [:polygons, :segments, :points, :lines, :observer, :visibility].each do |el|
    define_method "draw_#{el}" do
      # puts "Ok. Drawed... thought..."
    end
  end

  def visibility
    @visibility ||= VisibilityPolygon.new(observer, segments)
  end

  def polygons
    @polygons ||= elements.select {|element| element.is_a? Polygon}
  end

  def lines
    @lines ||= elements.map do |element|
      case 
      when element.is_a?(Line)
        element
      when element.is_a?(Polygon)
        element.lines
      else
      end
    end.flatten.compact
  end
  
  def points
    @points ||= (segments.map(&:points).flatten + visibility.points)
      .uniq {|point| point.to_a}
  end

  def segments
    @segments ||= begin
      s = []
      lines.each do |line|
        s += line.split_by_lines(lines)
      end
      s
    end
  end 
  
end