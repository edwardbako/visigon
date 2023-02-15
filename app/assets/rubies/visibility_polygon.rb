class VisibilityPolygon < Polygon

  attr_accessor :observer, :segments

  def initialize(observer, segments)
    @observer = observer
    @segments = segments
    super(construction_points, true, false, true)
  end

  def lines
  end

  def construction_points
    result = []
    first = base_points.first
    ray = Line.new(observer, [1000, observer.y])
    prev = base_points.last
    base_points.each do |base|
      # puts "=============== POINT: #{base[:point]}, ANGLE: #{base[:point].angle_to(observer)}============"
      
      ray.stop.clone base[:point]
      int = ray.intersections(segments)
      
      # puts "R#{ray}, Ss: #{segments.count} #{int}"
      
      if int.empty?
        prev_segment = Line.new(base[:point], prev[:point])
        # puts "!!!-- Point of same segment: #{base[:segment].intersection_of(prev_segment)}. PREV: #{prev_segment}"
        same = base[:segment].same_in_with?(prev_segment)
        same ? ray.prolong!(1) : ray.prolong!(-1)

        prolonged_points = ray.intersections(segments)
        # puts "----- Prolonged points"
        # puts " #{prolonged_points}"
        # puts " #{prolonged_points.first.distance_to(base[:point])}"
        first = base if result.empty?
        news = if prolonged_points.first.distance_to(base[:point]) < 2
                [base[:point]]
              else
                [base[:point], prolonged_points.first]
              end

        if same
          result += news
          prev = {point: result.last}
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
    prev_segment = Line.new(first[:point], result.last)
    ray.stop.clone first[:point]
    
    if first[:segment].same_in_with? prev_segment
      ray.prolong!(1)
      prolonged_points = ray.intersections(segments)
      # puts "----- Prolonged points"
      # puts " #{prolonged_points}"
      # puts " #{prolonged_points.first.distance_to(first[:point])}"

      if prolonged_points.first.distance_to(first[:point]) > 2
        result.insert 1, prolonged_points.first
      end
    end
    result.uniq {|point| point.to_a}
  end

  def base_points
    result = []
    segments.compact.each do |segment|
      segment.points.each do |point|
        result << {point: point, segment: segment}
      end
    end
    result
        .sort_by {|base| base[:point].angle_to(observer)}
  end

end