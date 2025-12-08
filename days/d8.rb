# frozen_string_literal: true

require_relative 'base'

N = 1000

module Days
  class D8 < Base
    def part1
      points = @lines.map { |line| line.split(',').map(&:to_i) }

      # All circuits start containing only themselves
      circuits = points.to_h { |p| [p, Set.new([p])] }
      distances = distance_all(points)

      distances.sort_by { |d, _| d }.take(N).each do |_dist, (p1, p2)|
        circuit2 = circuits[p2]
        merged = circuits[p1].merge(circuit2)
        circuit2.each { |p| circuits[p] = merged }
      end

      circuits.values.uniq.map(&:size).max(3).reduce(&:*)
    end

    def part2
      points = @lines.map { |line| line.split(',').map(&:to_i) }
      circuits = points.to_h { |p| [p, Set.new([p])] }
      distances = distance_all(points).sort_by  { |d, _| d }

      last_pair = []

      while true
        break if circuits.values.uniq.size == 1

        distances.each do |_dist, (p1, p2)|
          circuit2 = circuits[p2]
          next if circuits[p1] == circuit2

          merged = circuits[p1].merge(circuit2)
          circuit2.each { |p| circuits[p] = merged }
          last_pair = [p1, p2]
        end
      end

      last_pair[0][0] * last_pair[1][0]
    end

    private

    def distance_all(points)
      points.combination(2).to_h { |p1, p2| [distance(p1, p2), [p1, p2]] }
    end

    def distance(p1, p2)
      Math.sqrt((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2 + (p1[2] - p2[2])**2)
    end
  end
end