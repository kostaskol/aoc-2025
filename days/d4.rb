# frozen_string_literal: true

require_relative 'base'
require_relative '../utils'

module Days
  # Part 2 is just part 1, but more times (until the grid is stable)
  class D4 < Base
    def part1
      grid = Utils.as_grid(@lines)

      accessible_rolls = 0

      grid.length.times do |row|
        grid.first.length.times do |col|
          val = grid[row][col]
          next if val != '@'

          ns = neighbours(row, col, grid).map { |nrow, ncol| grid[nrow][ncol] }
          accessible_rolls += 1 if ns.count { |n| n == '@' } < 4
        end
      end

      accessible_rolls
    end

    def part2
      grid = Utils.as_grid(@lines)

      overall_accessible_rolls = 0

      loop do
        accessible_rolls = 0

        grid.length.times do |row|
          grid.first.length.times do |col|
            val = grid[row][col]
            next if val != '@'

            ns = neighbours(row, col, grid).map { |nrow, ncol| grid[nrow][ncol] }

            if ns.count { |n| n == '@' } < 4
              grid[row][col] = '.'
              overall_accessible_rolls += 1
              accessible_rolls += 1
            end
          end
        end

        break if accessible_rolls == 0
      end

      overall_accessible_rolls
    end

    private
    
    def neighbours(row, col, grid)
      deltas = [-1, 0, 1]
      deltas.product(deltas).reject { |drow, dcol| drow.zero? && dcol.zero? }.map do |drow, dcol|
        [row + drow, col + dcol]
      end.select do |nrow, ncol|
        nrow.between?(0, grid.size - 1) && ncol.between?(0, grid.first.size - 1)
      end
    end
  end
end