class VisibilityPolygon < Polygon
  include Profiler

  attr_accessor :observer, :segments, :ray, :start, :stop, :prev

  def initialize(observer, segments)
    @observer = observer
    @segments = segments
    @ray = observer.line_to([1000, observer.y])
    @start = Point.new(observer.x, observer.y)
    @stop = Point.new(observer.x, observer.y)
    @prev = [stop, Line.new(start, stop)]
    super(construction_points, true, false, true)
  end

  def construction_points
    result = []

    b = base_points
    ray.stop.x = 1000
    ray.stop.y = observer.y
    start.clone b.first[0]
    stop.clone b.last[0]
    prev[0] = stop
    prev[1].start = start
    prev[1].stop = stop
    
    b.each do |base|
      ray.stop.clone base[0]
      int = ray.intersections(segments)
      
      if int.empty?
        same = false
        if result.size == 0
          same = true if (base[1].same_in_with?(prev[1]) || base[1].active_to?(observer))
        elsif prev[1].start.is_on_line?(base[1]) ||
          prev[1].stop.is_on_line?(base[1])
          same = true
        end

        same ? ray.prolong!(:forward) : ray.prolong!(:backward)
        
        prolonged_points = ray.intersections(segments)
        
        unless prolonged_points.empty?
          if prolonged_points.first.distance_to(base[0]) <= 2
            result << base[0] if result.empty? || result.last != base[0]
          else
            additions = [base[0], prolonged_points.first]
            result += same ? additions : additions.reverse
          end
        end

        prev[0].clone result.last if result.size > 0
        prev[1].start.clone result.last if result.size > 0
        prev[1].stop.clone result[-2] if result.size > 1
      end
    end
    result
  end

  def update
    @points = construction_points
  end
  
  def base_points
    result = []
    segments.each do |segment|
      segment.points.each do |point|
        result << [point, segment]
      end
    end
    result
    .sort_by {|base| base[0].angle_to(observer)}
  end

end