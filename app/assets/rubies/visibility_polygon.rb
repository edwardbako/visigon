class VisibilityPolygon
  class << self
    def compute(position, segments)
      bounded = []
        minX = position[0]
        minY = position[1]
        maxX = position[0]
        maxY = position[1]
        segments.each do |segment|
          minX = [minX, segment[0][0], segment[1][0]].min
          minY = [minY, segment[0][1], segment[1][1]].min
          maxX = [maxX, segment[0][0], segment[1][0]].max
          maxY = [maxY, segment[0][1], segment[1][1]].max
          bounded << segment
        end
        bounded << [[minX, minY], [maxX, minY]]
        bounded << [[maxX, minY], [maxX, maxY]]
        bounded << [[maxX, maxY], [minX, maxY]]
        bounded << [[minX, maxY], [minX, minY]]
        polygon = []
        sorted = sortPoints(position, bounded)
        map = Array.new(bounded.length, -1)
        heap = []
        start = [position[0] + 1, position[1]]
        bounded.each_with_index do |segment, i|
          a1 = angle(segment[0], position)
          a2 = angle(segment[1], position)
          active = false
          if a1 > -180 && a1 <= 0 && a2 <= 180 && a2 >= 0 && a2 - a1 > 180
            active = true
          end
          if a2 > -180 && a2 <= 0 && a1 <= 180 && a1 >= 0 && a1 - a2 > 180
            active = true
          end
          if active
            insert(i, heap, position, bounded, start, map)
          end
        end
        sorted.each_with_index do |s, i|
          extend = false
          shorten = false
          orig = i
          vertex = bounded[s[0]][s[1]]
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
              if heap[0] != old_segment
                shorten = true
              end
            end
            i += 1
          end
          if extend
            polygon << vertex
            cur = intersectLines(bounded[heap[0]][0], bounded[heap[0]][1], position, vertex)
            if cur != vertex
              polygon << cur
            end
          elsif shorten
            polygon << intersectLines(bounded[old_segment][0], bounded[old_segment][1], position, vertex)
            polygon << intersectLines(bounded[heap[0]][0], bounded[heap[0]][1], position, vertex)
          end
        end
      polygon
    end

    def computeViewport(position, segments, viewportMinCorner, viewportMaxCorner)
      brokenSegments = []
      viewport = [[viewportMinCorner[0],viewportMinCorner[1]],[viewportMaxCorner[0],viewportMinCorner[1]],[viewportMaxCorner[0],viewportMaxCorner[1]],[viewportMinCorner[0],viewportMaxCorner[1]]]
      for i in 0..segments.length-1
          if segments[i][0][0] < viewportMinCorner[0] && segments[i][1][0] < viewportMinCorner[0]
              next
          end
          if segments[i][0][1] < viewportMinCorner[1] && segments[i][1][1] < viewportMinCorner[1]
              next
          end
          if segments[i][0][0] > viewportMaxCorner[0] && segments[i][1][0] > viewportMaxCorner[0]
              next
          end
          if segments[i][0][1] > viewportMaxCorner[1] && segments[i][1][1] > viewportMaxCorner[1]
              next
          end
          intersections = []
          for j in 0..viewport.length-1
              k = j + 1
              if k == viewport.length
                  k = 0
              end
              if doLineSegmentsIntersect(segments[i][0][0], segments[i][0][1], segments[i][1][0], segments[i][1][1], viewport[j][0], viewport[j][1], viewport[k][0], viewport[k][1])
                  intersect = intersectLines(segments[i][0], segments[i][1], viewport[j], viewport[k])
                  if intersect.length != 2
                      next
                  end
                  if equal(intersect, segments[i][0]) || equal(intersect, segments[i][1])
                      next
                  end
                  intersections.push(intersect)
              end
          end
          start = [segments[i][0][0], segments[i][0][1]]
          while intersections.length > 0
              endIndex = 0
              endDis = distance(start, intersections[0])
              for j in 1..intersections.length-1
                  dis = distance(start, intersections[j])
                  if dis < endDis
                      endDis = dis
                      endIndex = j
                  end
              end
              brokenSegments.push([[start[0], start[1]], [intersections[endIndex][0], intersections[endIndex][1]]])
              start[0] = intersections[endIndex][0]
              start[1] = intersections[endIndex][1]
              intersections.delete_at(endIndex)
          end
          brokenSegments.push([start, [segments[i][1][0], segments[i][1][1]]])
      end

      viewportSegments = []
      for i in 0..brokenSegments.length-1
          if inViewport(brokenSegments[i][0], viewportMinCorner, viewportMaxCorner) && inViewport(brokenSegments[i][1], viewportMinCorner, viewportMaxCorner)
              viewportSegments.push([[brokenSegments[i][0][0], brokenSegments[i][0][1]], [brokenSegments[i][1][0], brokenSegments[i][1][1]]])
          end
      end
      eps = epsilon() * 10
      viewportSegments.push([[viewportMinCorner[0]-eps,viewportMinCorner[1]-eps],[viewportMaxCorner[0]+eps,viewportMinCorner[1]-eps]])
      viewportSegments.push([[viewportMaxCorner[0]+eps,viewportMinCorner[1]-eps],[viewportMaxCorner[0]+eps,viewportMaxCorner[1]+eps]])
      viewportSegments.push([[viewportMaxCorner[0]+eps,viewportMaxCorner[1]+eps],[viewportMinCorner[0]-eps,viewportMaxCorner[1]+eps]])
      viewportSegments.push([[viewportMinCorner[0]-eps,viewportMaxCorner[1]+eps],[viewportMinCorner[0]-eps,viewportMinCorner[1]-eps]])
      return compute(position, viewportSegments)
    end

    def inViewport(position, viewportMinCorner, viewportMaxCorner)
      return false if (position[0] < viewportMinCorner[0] - epsilon())
      return false if (position[1] < viewportMinCorner[1] - epsilon())
      return false if (position[0] > viewportMaxCorner[0] + epsilon())
      return false if (position[1] > viewportMaxCorner[1] + epsilon())
      true
    end

    def inPolygon(position, polygon)
      val = polygon[0][0]
      for i in 0..polygon.length-1
          val = [polygon[i][0], val].min
          val = [polygon[i][1], val].min
      end
      edge = [val-1, val-1]
      parity = 0
      for i in 0..polygon.length-1
          j = i + 1
          if j == polygon.length
              j = 0
          end
          if doLineSegmentsIntersect(edge[0], edge[1], position[0], position[1], polygon[i][0], polygon[i][1], polygon[j][0], polygon[j][1])
              intersect = intersectLines(edge, position, polygon[i], polygon[j])
              if equal(position, intersect)
                  return true
              end
              if equal(intersect, polygon[i])
                  if angle2(position, edge, polygon[j]) < 180
                      parity += 1
                  end
              elsif equal(intersect, polygon[j])
                  if angle2(position, edge, polygon[i]) < 180
                      parity += 1
                  end
              else
                  parity += 1
              end
          end
      end
      return (parity%2)!=0
    end

    def convertToSegments(polygons)
      segments = []
      for i in 0..polygons.length-1
          for j in 0..polygons[i].length-1
              k = j+1
              if k == polygons[i].length
                  k = 0
              end
              segments.push([[polygons[i][j][0], polygons[i][j][1]], [polygons[i][k][0], polygons[i][k][1]]])
          end
      end
      return segments
    end

    def breakIntersections(segments)
      output = []
      for i in 0...segments.length
          intersections = []
          for j in 0...segments.length
              if i == j
                  next
              end
              if doLineSegmentsIntersect(segments[i][0][0], segments[i][0][1], segments[i][1][0], segments[i][1][1], segments[j][0][0], segments[j][0][1], segments[j][1][0], segments[j][1][1])
                  intersect = intersectLines(segments[i][0], segments[i][1], segments[j][0], segments[j][1])
                  if intersect.length != 2
                      next
                  end
                  if equal(intersect, segments[i][0]) || equal(intersect, segments[i][1])
                      next
                  end
                  intersections.push(intersect)
              end
          end
          start = [segments[i][0][0], segments[i][0][1]]
          while intersections.length > 0
              endIndex = 0
              endDis = distance(start, intersections[0])
              for j in 1...intersections.length
                  dis = distance(start, intersections[j])
                  if dis < endDis
                      endDis = dis
                      endIndex = j
                  end
              end
              output.push([[start[0], start[1]], [intersections[endIndex][0], intersections[endIndex][1]]])
              start[0] = intersections[endIndex][0]
              start[1] = intersections[endIndex][1]
              intersections.delete_at(endIndex)
          end
          output.push([start, [segments[i][1][0], segments[i][1][1]]])
      end
      return output
    end

    def epsilon
      return 0.0000001
    end

    def equal(a, b)
      if (a[0] - b[0]).abs < epsilon && (a[1] - b[1]).abs < epsilon
          return true
      end
      return false
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
      if cur != 0 && lessThan(heap[cur], heap[parent], position, segments, destination)
          while cur > 0
              parent = parent(cur)
              if !lessThan(heap[cur], heap[parent], position, segments, destination)
                  break
              end
              map[heap[parent]] = cur
              map[heap[cur]] = parent
              temp = heap[cur]
              heap[cur] = heap[parent]
              heap[parent] = temp
              cur = parent
          end
      else
          while true
              left = child(cur)
              right = left + 1
              if left < heap.length && lessThan(heap[left], heap[cur], position, segments, destination) &&
                      (right == heap.length || lessThan(heap[left], heap[right], position, segments, destination))
                  map[heap[left]] = cur
                  map[heap[cur]] = left
                  temp = heap[left]
                  heap[left] = heap[cur]
                  heap[cur] = temp
                  cur = left
              elsif right < heap.length && lessThan(heap[right], heap[cur], position, segments, destination)
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

    def insert(index, heap, position, segments, destination, map)
      intersect = intersectLines(segments[index][0], segments[index][1], position, destination)
      if intersect.length == 0
          return
      end
      cur = heap.length
      heap.push(index)
      map[index] = cur
      while cur > 0
          parent = parent(cur)
          if !lessThan(heap[cur], heap[parent], position, segments, destination)
              break
          end
          map[heap[parent]] = cur
          map[heap[cur]] = parent
          temp = heap[cur]
          heap[cur] = heap[parent]
          heap[parent] = temp
          cur = parent
      end
    end

    def lessThan(index1, index2, position, segments, destination)
      inter1 = intersectLines(segments[index1][0], segments[index1][1], position, destination)
      inter2 = intersectLines(segments[index2][0], segments[index2][1], position, destination)
      if !equal(inter1, inter2)
          d1 = distance(inter1, position)
          d2 = distance(inter2, position)
          return d1 < d2
      end
      end1 = 0
      if equal(inter1, segments[index1][0])
          end1 = 1
      end
      end2 = 0
      if equal(inter2, segments[index2][0])
          end2 = 1
      end
      a1 = angle2(segments[index1][end1], inter1, position)
      a2 = angle2(segments[index2][end2], inter2, position)
      if a1 < 180
          if a2 > 180
              return true
          end
          return a2 < a1
      end
      return a1 < a2
    end

    def parent(index)
      return (index-1)/2
    end

    def child(index)
      return 2*index+1
    end

    def angle2(a, b, c)
      a1 = angle(a,b)
      a2 = angle(b,c)
      a3 = a1 - a2
      if a3 < 0
          a3 += 360
      end
      if a3 > 360
          a3 -= 360
      end
      return a3
    end

    def sortPoints(position, segments)
      points = Array.new(segments.length * 2)
      for i in 0...segments.length
          for j in 0...2
              a = angle(segments[i][j], position)
              points[2*i+j] = [i, j, a]
          end
      end
      points.sort! {|a,b| a[2]-b[2]}
      return points
    end

    def angle(a, b)
      return Math.atan2(b[1]-a[1], b[0]-a[0]) * 180 / Math::PI
    end

    def intersectLines(a1, a2, b1, b2)
      dbx = b2[0] - b1[0]
      dby = b2[1] - b1[1]
      dax = a2[0] - a1[0]
      day = a2[1] - a1[1]
      
      u_b  = dby * dax - dbx * day
      if u_b != 0
          ua = (dbx * (a1[1] - b1[1]) - dby * (a1[0] - b1[0])) / u_b
          return [a1[0] - ua * -dax, a1[1] - ua * -day]
      end
      return []
    end

    def distance(a, b)
      dx = a[0]-b[0]
      dy = a[1]-b[1]
      return dx*dx + dy*dy
    end

    def isOnSegment(xi, yi, xj, yj, xk, yk)
      return (xi <= xk || xj <= xk) && (xk <= xi || xk <= xj) &&
            (yi <= yk || yj <= yk) && (yk <= yi || yk <= yj)
    end

    def computeDirection(xi, yi, xj, yj, xk, yk)
      a = (xk - xi) * (yj - yi)
      b = (xj - xi) * (yk - yi)
      return a < b ? -1 : a > b ? 1 : 0
    end

    def doLineSegmentsIntersect(x1, y1, x2, y2, x3, y3, x4, y4)
      d1 = computeDirection(x3, y3, x4, y4, x1, y1)
      d2 = computeDirection(x3, y3, x4, y4, x2, y2)
      d3 = computeDirection(x1, y1, x2, y2, x3, y3)
      d4 = computeDirection(x1, y1, x2, y2, x4, y4)
      return (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
              ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) ||
            (d1 == 0 && isOnSegment(x3, y3, x4, y4, x1, y1)) ||
            (d2 == 0 && isOnSegment(x3, y3, x4, y4, x2, y2)) ||
            (d3 == 0 && isOnSegment(x1, y1, x2, y2, x3, y3)) ||
            (d4 == 0 && isOnSegment(x1, y1, x2, y2, x4, y4))
    end
  end
end