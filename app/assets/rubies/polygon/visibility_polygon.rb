class VisibilityPolygon < Polygon
  include Profiler

  attr_accessor :observer, :segments, :ray, :start, :stop, :prev, :bouded

  def initialize(observer, segments)
    @observer = observer
    @segments = segments
    super(construction_points, true, false, true)
  end

  def update
    @points = construction_points
  end

  private

  def construction_points
    compute.map(&:to_point)
  end

  def sort_points(position, segments)
    points = Array.new(segments.length * 2)
    (0..(segments.length - 1)).each do |i|
      2.times do |j|
        a = angle(segments[i][j], position)
        points[2 * i + j] = [i, j, a]
      end
    end
    points.sort { |a, b| a[2] <=> b[2] }
  end
  
  def compute
    position = observer.to_a
    segmens = segments.map(&:to_a)
    bounded = []
    min_x = position[0]
    min_y = position[1]
    max_x = position[0]
    max_y = position[1]
    (0...segmens.length).each do |i|
      2.times do |j|
        min_x = [min_x, segmens[i][j][0]].min
        min_y = [min_y, segmens[i][j][1]].min
        max_x = [max_x, segmens[i][j][0]].max
        max_y = [max_y, segmens[i][j][1]].max
      end
      bounded.push([[segmens[i][0][0], segmens[i][0][1]], [segmens[i][1][0], segmens[i][1][1]]])
    end
    min_x -= 1
    min_y -= 1
    max_x += 1
    max_y += 1
    bounded.push([[min_x, min_y], [max_x, min_y]])
    bounded.push([[max_x, min_y], [max_x, max_y]])
    bounded.push([[max_x, max_y], [min_x, max_y]])
    bounded.push([[min_x, max_y], [min_x, min_y]])
    polygon = []
    sorted = sort_points(position, bounded)
    map = Array.new(bounded.length, -1)
    heap = []
    start = [position[0] + 1, position[1]]
    (0...bounded.length).each do |i|
      a1 = angle(bounded[i][0], position)
      a2 = angle(bounded[i][1], position)
      active = false
      active = true if a1 > -180 && a1 <= 0 && a2 <= 180 && a2 >= 0 && a2 - a1 > 180
      active = true if a2 > -180 && a2 <= 0 && a1 <= 180 && a1 >= 0 && a1 - a2 > 180
      insert(i, heap, position, bounded, start, map) if active
    end
    i = 0
    while i < sorted.length
      extend = false
      shorten = false
      orig = i
      vertex = bounded[sorted[i][0]][sorted[i][1]]
      old_segment = heap[0]
      while i < sorted.length && sorted[i][2] < sorted[orig][2] + epsilon
        if map[sorted[i][0]] != -1
          if sorted[i][0] == old_segment
            extend = true
            vertex = bounded[sorted[i][0]][sorted[i][1]]
          end
          remove(map[sorted[i][0]], heap, position, bounded, vertex, map)
        else
          insert(sorted[i][0], heap, position, bounded, vertex, map)
          shorten = true if heap[0] != old_segment
        end
        i += 1
      end
      if extend
        polygon.push(vertex)
        cur = intersect_lines(bounded[heap[0]][0], bounded[heap[0]][1], position, vertex)
        polygon.push(cur) unless equal(cur, vertex)
      elsif shorten
        polygon.push(intersect_lines(bounded[old_segment][0], bounded[old_segment][1], position, vertex))
        polygon.push(intersect_lines(bounded[heap[0]][0], bounded[heap[0]][1], position, vertex))
      end
    end
    polygon
  end

  def insert(index, heap, position, segments, destination, map)
    intersect = intersect_lines(segments[index][0], segments[index][1], position, destination)
    return if intersect.empty?

    cur = heap.length
    heap.push(index)
    map[index] = cur
    while cur.positive?
      parent = parent(cur)
      break unless less_than(heap[cur], heap[parent], position, segments, destination)

      map[heap[parent]] = cur
      map[heap[cur]] = parent
      temp = heap[cur]
      heap[cur] = heap[parent]
      heap[parent] = temp
      cur = parent
    end
  end

  def less_than(index1, index2, position, segments, destination)
    inter1 = intersect_lines(segments[index1][0], segments[index1][1], position, destination)
    inter2 = intersect_lines(segments[index2][0], segments[index2][1], position, destination)
    return false if inter1.empty? || inter2.empty?

    unless equal(inter1, inter2)
      d1 = distance(inter1, position)
      d2 = distance(inter2, position)
      return d1 < d2
    end
    end1 = 0
    end1 = 1 if equal(inter1, segments[index1][0])
    end2 = 0
    end2 = 1 if equal(inter2, segments[index2][0])
    a1 = angle2(segments[index1][end1], inter1, position)
    a2 = angle2(segments[index2][end2], inter2, position)
    if a1 < 180
      return true if a2 > 180

      return a2 < a1
    end
    a1 < a2
  end

  def intersect_lines(a1, a2, b1, b2)
    dbx = b2[0] - b1[0]
    dby = b2[1] - b1[1]
    dax = a2[0] - a1[0]
    day = a2[1] - a1[1]

    u_b = dby * dax - dbx * day
    if u_b != 0
      ua = (dbx * (a1[1] - b1[1]) - dby * (a1[0] - b1[0])) / u_b.to_f
      return [a1[0] - ua * -dax, a1[1] - ua * -day]
    end
    []
  end

  def epsilon
    0.0000001
  end

  def equal(a, b)
    return true if (a[0] - b[0]).abs < epsilon && (a[1] - b[1]).abs < epsilon

    false
  end

  def remove(index, heap, position, segments, destination, map)
    map[heap[index]] = -1
    if index == heap.length - 1
      heap.pop
      return
    end
    heap[index] = heap.pop
    map[heap[index]] = index
    cur = index
    parent = parent(cur)
    if cur != 0 && less_than(heap[cur], heap[parent], position, segments, destination)
      while cur.positive?
        parent = parent(cur)
        break unless less_than(heap[cur], heap[parent], position, segments, destination)

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
        if left < heap.length && less_than(heap[left], heap[cur], position, segments,
                                          destination) && (right == heap.length || less_than(heap[left], heap[right],
                                                                                              position, segments, destination))
          map[heap[left]] = cur
          map[heap[cur]] = left
          temp = heap[left]
          heap[left] = heap[cur]
          heap[cur] = temp
          cur = left
        elsif right < heap.length && less_than(heap[right], heap[cur], position, segments, destination)
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

  def angle2(a, b, c)
    a1 = angle(a, b)
    a2 = angle(b, c)
    a3 = a1 - a2
    if a3.negative?
      a3 += 360
    elsif a3 > 360
      a3 -= 360
    end
    a3
  end

  def angle(a, b)
    Math.atan2(b[1] - a[1], b[0] - a[0]) * 180 / Math::PI
  end

  def distance(a, b)
    dx = a[0] - b[0]
    dy = a[1] - b[1]
    dx * dx + dy * dy
  end


end