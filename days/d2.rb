# frozen_string_literal: true

require_relative 'base'

module Days
  # Splitting the initial range into multiple same-digit-number
  # ranges (so 11..1005 becomes [11..99, 100..999, 1000..1005])
  # results in a few more iterations but keeps each iteration
  # very straightforward as we don't have to account for numbers
  # of different length.
  # We also never expand upon the initial ranges. Instead we build the
  # numbers we're interested in (depending on the part) and check
  # (in O(1)) if that number belongs to the range
  class D2 < Base
    def part1
      solve(:sum_invalids_p1)
    end

    def part2
      solve(:sum_invalids_p2)
    end

    private

    def solve(method)
      ranges = @lines[0].split(',').map do |range|
        lims = range.split('-').map(&:to_i)
        explode(Range.new(lims[0], lims[1]))
      end.flatten

      ranges.sum do |range|
        send(method, range)
      end
    end

    # Similar to `sum_invalids_p1` but:
    # * we have to account for odd-digit numbers too
    # * we can't just check the ranges created by the half-numbers.
    #   we have to create number ranges beginning from the first digit
    #   of the initial range all the way up to the range between the
    #   half-numbers of the limits of the initial range
    #   e.g.
    #   123123-321321 -> 1..3, 12..32, 123..321
    #   with each of these numbers, we build the N-digit number we need
    #   and check:
    #   1. if it's included in the original range
    #   2. if it's not a number we've built before. Not sure if this can
    #      occur with the given input but theoretically it's possible.
    def sum_invalids_p2(range)
      seen = Set.new

      # We need to go up to the half-digits of the range of the numbers
      # e.g. for 123123, 1231 (4-digits) can never repeat
      (num_digits(range.begin) / 2).times.sum do |i|
        begin_digits = range.begin.to_s[0..i].to_i
        end_digits = range.end.to_s[0..i].to_i

        (begin_digits..end_digits).sum do |el|
          built_el = build_num(num_digits(range.begin) / num_digits(el), el)

          if range.include?(built_el) && !seen.include?(built_el)
            seen << built_el
            built_el
          else
            0
          end
        end
      end
    end

    # For each range, we build a smaller range made up of the
    # half-numbers of each of the range's limits, iterate that
    # and build numbers of appropriate lengths off of that
    # e.g.
    # for 123321-321123 we'll iterate over
    # 123..321 and for each, we'll "duplicate" the number and check
    # if it's within the initial range (123123, 124124, 125125, ...)
    def sum_invalids_p1(range)
      # Since we need the numbers to repeat exactly twice, odd-digit
      # numbers cannot be invalid.
      return 0 if odd_num_digits?(range.begin)

      new_range = half_num(range.begin)..half_num(range.end)

      new_range.sum do |el|
        double_el = build_num(2, el)
        range.include?(double_el) ? double_el : 0
      end
    end

    def build_num(n, num)
      n.times.map { num }.join.to_i
    end

    def half_num(num)
      num.to_s[0...(num_digits(num) / 2)].to_i
    end

    def num_digits(num)
      num.to_s.length
    end

    def odd_num_digits?(num)
      num_digits(num) % 2 == 1
    end

    # Split the given range into multiple ranges, each with
    # the same number of digits
    # e.g.
    # 8..1005 -> [8..9, 100..999, 1000..1005]
    def explode(range)
      min_digits = num_digits(range.begin)
      max_digits = num_digits(range.end)

      (min_digits..max_digits).map do |digits|
        low = 10**(digits - 1)
        high = 10**digits - 1

        from = [range.begin, low].max
        to = [range.end, high].min

        from..to
      end
    end
  end
end
