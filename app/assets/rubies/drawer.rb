require 'js'

class Drawer

  BACKGROUND_COLOR = "#AAAAAA"

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
      [-1, height+10]
    ], false)] + elements

    @changed = true

    canvas.addEventListener("mousemove") do |event|
      observer.x =
        event[:clientX].to_i - canvas[:offsetLeft].to_i + window[:scrollX].to_i
      observer.y =
        event[:clientY].to_i - canvas[:offsetTop].to_i + window[:scrollY].to_i
      self.changed = true
      # puts "X: #{observer.x}, Y: #{observer.y}"
      update
    end

  end

  def defaults
    {
      width: 500,
      height: 500,
      observer: [200,209].to_point,
      elements: []
    }
  end

  def update
    # puts "UPE"
    if changed
      ctx.clearRect(0, 0, width, height)
      ctx.beginPath()
      ctx.rect(0, 0, width, height)
      ctx[:fillStyle] = BACKGROUND_COLOR
      ctx.fill()
      
      draw
      self.changed = false
    end
    # animation_frame.call(lambda { update() })
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
      if el == :observer || el == :visibility
        send(el).draw(ctx)
      else
        self.send(el).compact.each { |element| element.draw(ctx) }
      end
    end
  end

  def visibility
    @visib = VisibilityPolygon.new(observer, segments)
    # puts @visib.points
    @visib
  end

  def polygons
    elements.select {|element| element.is_a? Polygon}
  end

  def lines
    elements.map do |element|
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
    (segments.map(&:points).flatten + visibility.points)
      .uniq {|point| point.to_a}
  end

  def segments
    segments = []
    lines.each do |line|
      segments += line.split_by_lines(lines)
    end
    segments
  end 
  
  private
  
  def window
    @window ||= JS.global[:window]
  end

  def document
    @document ||= JS.global[:document]
  end
  
  def canvas
    @canvas ||= document.getElementById('canvas')
  end
  
  def ctx
    @ctx = canvas.getContext("2d")
  end
  
end