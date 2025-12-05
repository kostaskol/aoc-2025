# frozen_string_literal: true

require_relative 'base'

module Days
  class D5 < Base
    def part1
      ranges, ingredients = parsed_input.values_at(:ranges, :ingredients)

      collapsed = collapsed_ranges(ranges)

      ingredients.count do |ingredient|
        collapsed.any? { |range| range.include?(ingredient) }
      end
    end

    def part2
      ranges, ingredients = parsed_input.values_at(:ranges, :ingredients)

      collapsed = collapsed_ranges(ranges)

      collapsed.sum { |range| range.end - range.begin + 1 }
    end

    private

    def collapsed_ranges(ranges)
      ranges = ranges.sort_by(&:begin)

      collapsed = []
      current_range = ranges.shift

      while current_range
        next_range = ranges.first

        if next_range && current_range.end >= next_range.begin - 1
          current_range = (current_range.begin..[current_range.end, next_range.end].max)
          ranges.shift
        else
          collapsed << current_range
          current_range = ranges.shift
        end
      end

      collapsed
    end

    def parsed_input
      mode = :ranges

      @lines.each_with_object({}) do |line, acc|
        if line.empty?
          mode = :ingredients
          next
        end

        val =
          case mode
          when :ranges
            lims = line.split('-')
            (lims[0].to_i..lims[1].to_i)
          when :ingredients
            line.to_i
          end

        acc[mode] ||= []
        acc[mode] << val
      end
    end
  end
end