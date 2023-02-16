require 'js'

class CanvasDrawer < Drawer

  def initialize
    super

    canvas.addEventListener("mousemove") do |event|
      observer.x =
        event[:clientX].to_i - canvas[:offsetLeft].to_i + window[:scrollX].to_i
      observer.y =
        event[:clientY].to_i - canvas[:offsetTop].to_i + window[:scrollY].to_i
      self.changed = true
    #   # puts "X: #{observer.x}, Y: #{observer.y}"
    #   update
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
    window.requestAnimationFrame(lambda { |timestamp| update })
  end

  def clear
    ctx.clearRect(0, 0, width, height)
    ctx.beginPath()
    ctx.rect(0, 0, width, height)
    ctx[:fillStyle] = BACKGROUND_COLOR
    ctx.fill()
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