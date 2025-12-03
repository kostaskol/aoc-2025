# frozen_string_literal: true

require_relative 'base'

module Days
  class D3 < Base
    def part1
      @lines.sum do |line|
        max_joltage = 0

        joltages = line.split('')
        joltages.each_with_index do |joltage, index|
          joltages[index + 1..].each do |second_joltage|
            if (j = "#{joltage}#{second_joltage}".to_i) > max_joltage
              max_joltage = j
            end
          end
        end

        max_joltage
      end
    end

    # Part 2 logic taken from/inspired by
    # https://www.reddit.com/r/adventofcode/comments/1pcxkif/2025_day_3_mega_tutorial/
    def part2
      @lines.sum do |line|
        find_max(line, 12, {})
      end
    end

    private

    def find_max(num, digits, cache = {})
      cache_key = [num, digits]
      return cache[cache_key] if cache.key?(cache_key)

      if digits == 0
        return cache[cache_key] = 0
      end

      if num.length == digits
        return cache[cache_key] = num.to_i
      end

      case_1 = (num[0].to_i * 10 ** (digits - 1)) + find_max(num[1..], digits - 1, cache)

      case_2 = find_max(num[1..], digits, cache)

      cache[cache_key] = [case_1, case_2].max
    end
  end
end
