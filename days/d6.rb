# frozen_string_literal: true

require_relative 'base'
require 'pry'

module Days
  class D6 < Base
    def part1
      grid = as_grid(@lines)

      grid[0].size.times.sum do |col|
        op = grid[-1][col]

        result = op == '+' ? 0 : 1

        grid[..-2].size.times do |row|
          val = grid[row][col].to_i

          case op
          when '+'
            result += val
          when '*'
            result *= val
          else
            raise 'boom'
          end
        end

        result
      end
    end

    def part2
      overall = 0
      closed_group = true
      op = nil
      result = 0

      @lines[0].size.times do |col|
        curr_num = []

        if closed_group
          overall += result

          # We're in the next number group
          # Find the next operator
          op = @lines[-1][col]
          raise "Unexpected #{op}" unless ['+', '*'].include?(op)

          result = op == '+' ? 0 : 1
        end

        @lines[..-2].size.times do |row|
          val = @lines[row][col]

          next if val == ' '

          curr_num << @lines[row][col]
        end

        closed_group = curr_num.empty?

        next if closed_group

        case op
        when '+'
          result += curr_num.join.to_i
        when '*'
          result *= curr_num.join.to_i
        else
          raise 'boom'
        end
      end

      # The last time, we won't find a closed group so
      # we must add the result manually
      overall + result
    end

    private

    def as_grid(lines)
      grid =
        lines[..-2].map do |line|
          line.strip.split(' ').map(&:to_i)
        end
      grid << lines[-1].strip.split(' ')
    end
  end
end