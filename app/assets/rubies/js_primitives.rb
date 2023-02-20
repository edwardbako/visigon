require 'js'

module JsPrimitives
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