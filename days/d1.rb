# frozen_string_literal: true

require_relative 'base'

module Days
  class D1 < Base
    def part1
      current = 50

      @lines.count do |line|
        op = line[0] == 'L' ? :- : :+
        num = line[1..].to_i

        current = circular_op(op, current, num)

        current == 0
      end
    end

    def part2
      current = 50

      @lines.sum do |line|
        op = line[0] == 'L' ? :- : :+
        num = line[1..].to_i
        c = current
        current, zero_passes = circular_op_p2(op, current, num)

        zero_passes
      end
    end

    private

    def circular_op_p2(op, a, b)
      zero_passes =
        if op == :-
          ((100 - a) % 100 + b) / 100
        else
          (a + b) / 100
        end

      c = (op == :+ ? (a + b) : (a - b)) % 100

      [c, zero_passes]
    end

    def circular_op(op, a, b)
      b %= 100

      c =
        case op
        when :+
          a + b
        when :-
          a - b
        end

      if c >= 100
        c - 100
      elsif c < 0
        c + 100
      else
        c
      end
    end
  end
end
