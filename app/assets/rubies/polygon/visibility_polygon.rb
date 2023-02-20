class VisibilityPolygon < Polygon
  include Profiler

  attr_accessor :observer, :segments, :ray, :first, :start, :stop, :prev

  def initialize(observer, segments)
    @observer = observer
    @segments = segments
    @ray = observer.line_to([1000, observer.y])
    @first = [nil,nil]
    @start = Point.new(observer.x, observer.y)
    @stop = Point.new(observer.x, observer.y)
    @prev = [stop, Line.new(start, stop)]
    super(construction_points, true, false, true)
  end

  def construction_points
    # Logger.info self, "\n\n\n%%%%%%%%%%%%%%%%%%%%%%%% Visibility Construction start %%%%%%%%%%%%%%%%%%%%%%%%\n\n"

    result = []

    first = base_points.first
    ray.stop.x = 1000
    ray.stop.y = observer.y
    start.clone first[0]
    stop.clone base_points.last[0]
    prev[0] = stop
    prev[1].start = start
    prev[1].stop = stop
    
    base_points.each do |base|
      # next if !result.empty? && result.last == base[0]
      # Logger.log self, "======================================================="
      # Logger.log self, "=========== BASE POINT: #{base[0]}, LINE: #{base[1]}"
      # Logger.log self, "=========== PREV POINT: #{prev[0]}, SEGMENT: #{prev[1]}"
      # Logger.log self, "=========== ANGLE: #{base[0].angle_to(observer)}"
      # Logger.log self, "======================================================="
      
      ray.stop.clone base[0]
      int = ray.intersections(segments)
      
      # Logger.info self, "R---<#{ray}>--, ANGLE: #{ray.stop.angle_to(observer)}, Intersections: #{int}"
      if int.empty?
        # Logger.info self, "````````` NO intersections in between"

        same = false
        if result.size == 0
          same = true if (base[1].same_in_with?(prev[1]) || base[1].active_to?(observer))
        elsif prev[1].start.is_on_line?(base[1]) ||
          prev[1].stop.is_on_line?(base[1])
          same = true
        end

        same ? ray.prolong!(:forward) : ray.prolong!(:backward)
        
        # Logger.info self, "!!!-- Point of same segment: #{base[1].intersection_of(prev[1])}.\n SEGMENT:#{base[1]},\n PREV: #{prev[1]}, SAME?: #{same}"
        
        # Logger.info self, "R--PRO<#{ray}>--, ANGLE: #{ray.stop.angle_to(observer)}"
        
        prolonged_points = ray.intersections(segments)
        
        # Logger.info self, "----- Prolonged points"
        # Logger.info self, " #{prolonged_points}"
        # Logger.info self, " First distance to base: #{prolonged_points.first.distance_to(base[0])}"

        unless prolonged_points.empty?
          if prolonged_points.first.distance_to(base[0]) <= 2
            result << base[0] # if result.empty? || result.last != base[0]
          else
            additions = [base[0], prolonged_points.first]
            result += same ? additions : additions.reverse
          end
        end

        # Logger.info self, ">>>> BEFORE \nBASE:#{base}\nPREV:#{prev}"
        
        prev[0].clone result.last if result.size > 0
        prev[1].start.clone result.last if result.size > 0
        prev[1].stop.clone result[-2] if result.size > 1
       
        # Logger.info self, "<<<< AFTER \nBASE:#{base}\nPREV:#{prev}"

      else
        # Logger.info self, "----------------------------------------NEXT-->>>"
      end

      # Logger.info self, "\n\nRES: #{result}\n\n"
      
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