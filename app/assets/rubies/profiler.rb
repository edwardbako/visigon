module Profiler
  def profile(&block)
    start = Time.now.to_f
    yield if block_given?
    stop = Time.now.to_f
    puts "DONE IN #{(stop-start)* 1000} ms"
  end
end