# frozen_string_literal: true

require_relative 'base'
require_relative '../utils'

module Days
  class D7 < Base
    def part1
      grid = Utils.as_grid(@lines)
      solve_p1(grid, 0, grid[0].index('S'), Set.new, {})

      # or
      # solve_p1_alt(grid)
    end

    def part2
      grid = Utils.as_grid(@lines)
      solve_p2(grid, 0, grid[0].index('S'), {})
    end

    private

    # Recursive part 1 solution with memoization
    def solve_p1(grid, row, col, visited, cache)
      return cache[[row, col]] = 0 if visited.include?([row, col])
      return cache[[row, col]] if cache.key?([row, col])
      return cache[[row, col]] = 0 if row == grid.length

      visited << [row, col]

      val =
        if grid[row][col] == '^'
          1 + solve_p1(grid, row, col - 1, visited, cache) + solve_p1(grid, row, col + 1, visited, cache)
        else
          solve_p1(grid, row + 1, col, visited, cache)
        end

      return cache[[row, col]] = val
    end

    # Iterative alternative part 1 solution
    def solve_p1_alt(grid)
     splits = 0
     starts = Set.new([[0, grid[0].index('S')]])
     visited = Set.new

     while true
       start = starts.first
       break if start.nil?

       starts.delete(start)
       row, col = start

       ((row + 1)..(grid.length - 1)).each do |r|
         break if visited.include?([r, col])

         visited << [r, col]

         if grid[r][col] == '^'
           splits += 1
           starts << [r, col - 1] if col != 0
           starts << [r, col + 1] if col != grid[0].length - 1
           break
         end
       end

       # We've moved all the way down without splitting
       # No need to do anything
     end

     splits
    end

    # Recursive part 2 solution with memoization
    def solve_p2(grid, row, col, cache)
      return cache[[row, col]] if cache.key?([row, col])
      return cache[[row, col]] = 1 if row == grid.length

      val =
        if grid[row][col] == '^'
          solve_p2(grid, row, col - 1, cache) + solve_p2(grid, row, col + 1, cache)
        else
          solve_p2(grid, row + 1, col, cache)
        end

      return cache[[row, col]] = val
    end
  end
end