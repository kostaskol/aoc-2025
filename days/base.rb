module Days
  # Inherit this class and override the part1 and part2 methods,
  # each of which solves one part of the problem.
  # The basic state provided by this class is the @lines array,
  # which is the input of the day's problem
  class Base
    def initialize(lines)
      @lines = lines
    end

    def self.solve(part, lines)
      case part.to_i
      when 1
        new(lines).part1
      when 2
        new(lines).part2
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
