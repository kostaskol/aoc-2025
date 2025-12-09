# frozen_string_literal: true

require_relative 'base'
require 'pry'

module Days
  class D9 < Base
    def part1
      points = points_list
      max_area = 0

      points.combination(2) do |point1, point2|
        next if point1[0] == point2[0] || point1[1] == point2[1]

        area = rectangle_area(point1, point2)
        max_area = area if area > max_area
      end

      max_area
    end

    # The basic idea is to generate all rectangles defined by pairs of points,
    # reject those that are not fully enclosed within the polygon
    # and find the maximum area among the remaining ones.
    # We use a caching mechanism to avoid redundant checks for specific points.
    # For each rectangle whose corners are all inside the shape, we need to check
    # if any edge of the shape intersects with the interior of the rectangle,
    # at which point the rectangle is considered not enclosed.
    # e.g.
    # ┌─────┐ <- shape
    # │     │
    # │ ┌──┐│
    # │ +──++
    # │ │  ││
    # │ └──┘│
    # │     │
    # └─────┘
    def part2
      shape = points_list
      shape << shape[0] # Close the shape

      recs_in_shape = shape.combination(2).each_with_object([]) do |(point1, point2), acc|
        next if point1[0] == point2[0] || point1[1] == point2[1]

        acc << [point1, point2] if rectangle_enclosed?(point1, point2, shape)
      end

      recs_in_shape.map { |(p1, p2)| rectangle_area(p1, p2) }.max
    end

    private

    def points_list
      @lines.map { |line| line.split(',').map(&:to_i) }
    end

    def rectangle_area(point1, point2)
      ((point1[0] - point2[0]).abs + 1) * ((point1[1] - point2[1]).abs + 1)
    end

    def rectangle_enclosed?(point1, point2, shape)
      @cache ||= {}

      # Generate the other two corners
      point3 = [point1[0], point2[1]]
      point4 = [point2[0], point1[1]]

      # Check if the other two corners are inside or on the shape
      @cache[point3] ||= inside?(point3, shape)
      @cache[point4] ||= inside?(point4, shape)
      
      # Fail fast if either vertice is outside the general shape
      # The first 2 vertices are necessarily on the shape
      return false unless @cache[point3] && @cache[point4]

      x1, y1 = point1
      x2, y2 = point2
      
      rect_min_x, rect_max_x = [x1, x2].minmax
      rect_min_y, rect_max_y = [y1, y2].minmax
      
      # For each edge of the shape, check if it intersects with the interior of our rectangle
      (shape.size - 1).times do |i|
        sx1, sy1 = shape[i]
        sx2, sy2 = shape[i + 1]
        
        # Skip if this edge connects to any of our rectangle corners
        next if [sx1, sy1] == point1 || [sx1, sy1] == point2 || [sx1, sy1] == point3 || [sx1, sy1] == point4
        next if [sx2, sy2] == point1 || [sx2, sy2] == point2 || [sx2, sy2] == point3 || [sx2, sy2] == point4
        
        # Get bounds of the shape edge (treating it as a line segment/thin rectangle)
        edge_min_x, edge_max_x = [sx1, sx2].minmax
        edge_min_y, edge_max_y = [sy1, sy2].minmax
        
        # Check if this edge's bounding box intersects with the interior of our rectangle
        # (We want strict interior, so we check if the intersection is more than just touching at boundary)
        if rectangles_intersect_interior?(
          rect_min_x, rect_max_x, rect_min_y, rect_max_y,
          edge_min_x, edge_max_x, edge_min_y, edge_max_y
        )
          return false
        end
      end

      true
    end
    
    def rectangles_intersect_interior?(r1_min_x, r1_max_x, r1_min_y, r1_max_y,
                                       r2_min_x, r2_max_x, r2_min_y, r2_max_y)
      # Check if rectangle 2 intersects with the INTERIOR of rectangle 1
      # (not just touching at the boundary)
      
      # First check if they overlap at all
      return false if r1_max_x < r2_min_x || r2_max_x < r1_min_x
      return false if r1_max_y < r2_min_y || r2_max_y < r1_min_y
      
      # Now check if the overlap is in the interior (not just at boundary)
      # The intersection must have some overlap in both x and y that's not just the boundary
      
      # Calculate overlap region
      overlap_min_x = [r1_min_x, r2_min_x].max
      overlap_max_x = [r1_max_x, r2_max_x].min
      overlap_min_y = [r1_min_y, r2_min_y].max
      overlap_max_y = [r1_max_y, r2_max_y].min
      
      # Check if any part of the overlap is strictly inside r1 (not on its boundary)
      interior_x = (overlap_min_x > r1_min_x && overlap_min_x < r1_max_x) ||
                   (overlap_max_x > r1_min_x && overlap_max_x < r1_max_x) ||
                   (overlap_min_x <= r1_min_x && overlap_max_x >= r1_max_x)
      
      interior_y = (overlap_min_y > r1_min_y && overlap_min_y < r1_max_y) ||
                   (overlap_max_y > r1_min_y && overlap_max_y < r1_max_y) ||
                   (overlap_min_y <= r1_min_y && overlap_max_y >= r1_max_y)
      
      interior_x && interior_y
    end

    def inside?(point, shape, include_bounds: true)
      px, py = point

      inside = false
      (shape.size - 1).times do |i|
        x1, y1 = shape[i]
        x2, y2 = shape[i + 1]

        # Check if point is on the edge
        return true if include_bounds && point_on_bounds?(px, py, x1, y1, x2, y2)

        # Ray casting algorithm: cast a ray from point to infinity (to the right)
        # For grid cells, we check from the cell itself (not its center)
        # Count how many times it crosses the polygon edges
        # If odd number of crossings, point is inside; if even, it's outside
        
        # Check if the edge crosses the horizontal ray extending right from the point
        if (y1 > py) != (y2 > py)
          # Calculate the x-coordinate where the edge crosses the ray at y = py
          # Since we're on a discrete grid, we use the exact grid coordinates
          x_intersection = x1 + (py - y1) * (x2 - x1) / (y2 - y1).to_f
          
          # If the intersection is strictly to the right of the point, we have a crossing
          # Using < instead of <= to handle edge cases consistently
          inside = !inside if px < x_intersection
        end
      end

      inside
    end

    def point_on_bounds?(px, py, x1, y1, x2, y2)
      return false if (px - x1) * (y2 - y1) != (py - y1) * (x2 - x1)

      [x1, x2].min <= px && px <= [x1, x2].max &&
      [y1, y2].min <= py && py <= [y1, y2].max
    end
  end
end