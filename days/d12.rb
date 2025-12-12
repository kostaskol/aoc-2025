# frozen_string_literal: true

require_relative 'base'

module Days
  class D12 < Base
    # This solution is very much based on the specific input and wouldn't work
    # with any input.
    # Normally, this would be a packing problem, but the inputs are very small
    # compared to the available grids. As such, we compute the area of each shape
    # (only the '#') and check if the total area of required shapes would fit into the
    # grid.
    # NOTE: This logic **does not** apply to the test input (in which we actually need
    #       to solve the packing problem).
    def part1
      raise 'Does not work for test input' if @test_mode

      shapes, grids = parsed_input.values_at(:shapes, :grids)
      
      shape_areas = shapes.map do |shape|
        shape.sum { |row| row.count { |cell| cell == '#' } }
      end

      grids.count do |grid_info|
        dims = grid_info[:dims]
        amounts = grid_info[:amounts]

        total_area = dims[0] * dims[1]
        required_area = amounts.each_with_index.sum { |a, i| a * shape_areas[i] }

        required_area <= total_area
      end
    end

    def part2
      raise 'D12 has no part 2'
    end

    private

    def parsed_input
      @lines.each_with_object({ shapes: [], grids: [] }) do |line, acc|
        next if line.empty?

        if line.match?(/^\d:/)
          acc[:shapes] << []
          next
        end

        if line.include?('#') || line.include?('.')
          acc[:shapes][-1] << line.chars
          next
        end

        if line.match?(/^\d+x\d+:/)
          dims, amounts = line.split(':')
          acc[:grids] << {
            dims: dims.split('x').map(&:to_i),
            amounts: amounts.split(' ').map(&:to_i)
          }
        end
      end
    end
  end
end