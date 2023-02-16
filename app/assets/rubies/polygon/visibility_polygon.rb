class VisibilityPolygon < Polygon
  include Profiler

  attr_accessor :observer, :segments

  def initialize(observer, segments)
    @observer = observer
    @segments = segments
    super(construction_points, true, false, true)
  end

  def construction_points
    result = []
    first = base_points.first
    ray = observer.line_to([1000, observer.y])
    prev = base_points.last
    base_points.each do |base|
      # puts "=============== POINT: #{base[0]}, ANGLE: #{base[0].angle_to(observer)}============"
      
      ray.stop.clone base[0]
      int = ray.intersections(segments)
      
      # puts "R#{ray}, Ss: #{segments.count} #{int}"
      
      if int.empty?
        prev_segment = Line.new(base[0], prev[0])
        # puts "!!!-- Point of same segment: #{base[1].intersection_of(prev_segment)}. PREV: #{prev_segment}"
        same = base[1].same_in_with?(prev_segment)
        same ? ray.prolong!(1) : ray.prolong!(-1)
        
        prolonged_points = ray.intersections(segments)
        # puts "----- Prolonged points"
        # puts " #{prolonged_points}"
        # puts " #{prolonged_points.first.distance_to(base[0])}"
        first = base if result.empty?
        news = if prolonged_points.first.distance_to(base[0]) < 2
                [base[0]]
              else
                [base[0], prolonged_points.first]
              end
              
              if same
                result += news
                prev = [result.last]
        else
          result += news.rotate
          prev = base
        end
      end

      # puts
      # puts "RES: #{result}"
      # puts
      
      result
    end
    # puts "#{prev}"
    prev_segment = Line.new(first[0], result.last)
    ray.stop.clone first[0]
    
    if first[1].same_in_with? prev_segment
      ray.prolong!(1)
      prolonged_points = ray.intersections(segments)
      # puts "----- Prolonged points"
      # puts " #{prolonged_points}"
      # puts " #{prolonged_points.first.distance_to(first[0])}"
      
      if prolonged_points.first.distance_to(first[0]) > 2
        result.insert 1, prolonged_points.first
      end
    end
    result.uniq {|point| point.to_a}
  end

  def update
    @points = construction_points
  end
  
  def base_points
    result = []
    segments.compact.each do |segment|
      segment.points.each do |point|
        result << [point, segment]
      end
    end
    result.uniq {|point| point.to_a}
    .sort_by {|base| base[0].angle_to(observer)}
  end

end