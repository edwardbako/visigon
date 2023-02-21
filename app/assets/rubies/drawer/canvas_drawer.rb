class CanvasDrawer < Drawer
  include JsPrimitives

  def initialize
    super

    window.cancelAnimationFrame(window[:visigon])
    window[:canvas_hammer].on("pan tap") do |event|
      # puts event[:srcEvent][:clientX]
      observer.x =
        event[:srcEvent][:clientX].to_f - canvas[:offsetLeft].to_f + window[:scrollX].to_f
      observer.y =
        event[:srcEvent][:clientY].to_f - canvas[:offsetTop].to_f + window[:scrollY].to_f
      self.changed = true
    end
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

  def update
    super
    window[:visigon] = window.requestAnimationFrame(lambda { |timestamp| update })
  end

  def clear
    ctx.clearRect(0, 0, width, height)
    ctx.beginPath()
    ctx.rect(0, 0, width, height)
    ctx[:fillStyle] = BACKGROUND_COLOR
    ctx.fill()
  end


end