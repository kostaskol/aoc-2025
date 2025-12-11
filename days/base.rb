module Days
  # Inherit this class and override the part1 and part2 methods,
  # each of which solves one part of the problem.
  # The basic state provided by this class is the @lines array,
  # which is the input of the day's problem
  class Base
    def initialize(lines, test_mode)
      @lines = lines
      @test_mode = test_mode
    end

    def self.solve(part, lines, test_mode: false)
      case part.to_i
      when 1
        new(lines, test_mode).part1
      when 2
        new(lines, test_mode).part2
      else
        raise "Unknown part #{part}"
      end
    end

    def part1
      raise NotImplementedError
    end

    def part2
      raise NotImplementedError
    end
  end
end
