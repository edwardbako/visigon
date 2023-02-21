class VisibilityPolygon < Polygon
  include Profiler

  attr_accessor :observer, :segments
  attr_reader :map, :heap, :ray

  def initialize(observer, segments)
    @observer = observer
    @segments = segments
    bound_segments!
    super(construction_points, true, false, true)
  end

  def update
    @points = construction_points
  end

  def segments=(segments)
    @segments = segments
    bound_segments!
  end

  private

  def construction_points
    compute.map(&:to_point)
  end

  def sorted_points
    result = []
    segments.each_with_index do |segment, i|
      segment.points.each do |point|
        a = point.angle_to observer
        result << [i, point, a]
      end
    end
    result.sort { |a, b| a[2] <=> b[2] }
  end

  def bound_segments!
    result = []
    min_x = observer.x
    min_y = observer.y
    max_x = observer.x
    max_y = observer.y
    
    segments.each do |segment|
      min_x = [min_x, segment.start.x, segment.stop.x].min
      min_y = [min_y, segment.start.y, segment.stop.y].min
      max_x = [max_x, segment.start.x, segment.stop.x].max
      max_y = [max_y, segment.start.y, segment.stop.y].max
    end

    min_x -= 1
    min_y -= 1
    max_x += 1
    max_y += 1
    
    segments.push Line.new([min_x, min_y], [max_x, min_y]),
                  Line.new([max_x, min_y], [max_x, max_y]),
                  Line.new([max_x, max_y], [min_x, max_y]),
                  Line.new([min_x, max_y], [min_x, min_y])
  end

  def compute

    polygon = []
    @map = Array.new(segments.length, -1)
    @heap = []
    start = [observer.x + 1, observer.y]
    @ray = Line.new(observer, start)
    sorted = sorted_points
    
    segments.each_with_index do |segment, i|
      insert(i) if segment.active_to?(observer)
    end
    
    i = 0
    while i < sorted.length
      extend = false
      shorten = false
      orig = i

      ray.stop = sorted[i][1]
      old_segment = heap[0]
      
      while i < sorted.length && sorted[i][2] < sorted[orig][2] + epsilon
        if map[sorted[i][0]] != -1
          if sorted[i][0] == old_segment
            extend = true
            ray.stop = sorted[i][1]
          end
          remove(map[sorted[i][0]])
        else
          insert(sorted[i][0])
          shorten = true if heap[0] != old_segment
        end
        i += 1
      end
      

      if extend
        polygon.push ray.stop
        cur = ray.intersect_lines(segments[heap[0]])
        polygon.push cur unless cur == ray.stop
      elsif shorten
        polygon.push ray.intersect_lines(segments[old_segment])
        polygon.push ray.intersect_lines(segments[heap[0]])
      end
    end
    polygon
  end

  def insert(index)
    intersect = ray.intersect_lines(segments[index])
    return if intersect.nil?

    cur = heap.length
    heap.push(index)
    map[index] = cur
    while cur.positive?
      parent = parent(cur)
      break unless less_than(heap[cur], heap[parent])

      map[heap[parent]] = cur
      map[heap[cur]] = parent
      temp = heap[cur]
      heap[cur] = heap[parent]
      heap[parent] = temp
      cur = parent
    end
  end

  def less_than(index1, index2)
    inter1 = ray.intersect_lines(segments[index1])
    inter2 = ray.intersect_lines(segments[index2])
    return false if inter1.nil? || inter2.nil?

    unless inter1 == inter2
      d1 = inter1.distance_to observer
      d2 = inter2.distance_to observer
      return d1 < d2
    end

    a = segments[index1].not_same_to(inter1)
    b = segments[index2].not_same_to(inter2)
    a1 = a.angle2_to(inter1, observer)
    a2 = b.angle2_to(inter2, observer)
    
    if a1 < 180
      return true if a2 > 180

      return a2 < a1
    end
    a1 < a2
  end

  def epsilon
    0.0000001
  end

  def remove(index)
    map[heap[index]] = -1
    if index == heap.length - 1
      heap.pop
      return
    end
    heap[index] = heap.pop
    map[heap[index]] = index
    cur = index
    parent = parent(cur)
    if cur != 0 && less_than(heap[cur], heap[parent])
      while cur.positive? && !less_than(heap[cur], heap[parent])
        parent = parent(cur)

        map[heap[parent]] = cur
        map[heap[cur]] = parent
        temp = heap[cur]
        heap[cur] = heap[parent]
        heap[parent] = temp
        cur = parent
      end
    else
      loop do
        left = child(cur)
        right = left + 1
        if left < heap.length && less_than(heap[left], heap[cur]) && (right == heap.length || less_than(heap[left], heap[right]))
          map[heap[left]] = cur
          map[heap[cur]] = left
          temp = heap[left]
          heap[left] = heap[cur]
          heap[cur] = temp
          cur = left
        elsif right < heap.length && less_than(heap[right], heap[cur])
          map[heap[right]] = cur
          map[heap[cur]] = right
          temp = heap[right]
          heap[right] = heap[cur]
          heap[cur] = temp
          cur = right
        else
          break
        end
      end
    end
  end

  def parent(index)
    ((index - 1) / 2.to_f).floor
  end

  def child(index)
    2 * index + 1
  end
end