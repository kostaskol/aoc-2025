# frozen_string_literal: true

require_relative 'base'

START_NODE_P1 = 'you'.freeze
START_NODE_P2 = 'svr'.freeze
END_NODE = 'out'.freeze

module Days
  class D11 < Base
    def part1
      graph = as_graph[0]

      dfs(START_NODE_P1, graph, {})
    end

    def part2
      graph = @test_mode ? as_graph[1] : as_graph[0]

      restricted_dfs(START_NODE_P2, graph, false, false, {})
    end

    private

    def restricted_dfs(node, graph, visited_fft, visited_dac, cache)
      # Update visited flags
      visited_fft = true if node == 'fft'
      visited_dac = true if node == 'dac'

      # Cache key: (node, visited_fft, visited_dac)
      cache_key = [node, visited_fft, visited_dac]
      return cache[cache_key] if cache.key?(cache_key)

      # Base case: reached end node
      if node == END_NODE
        # Valid only if we've visited both required nodes on the way
        return cache[cache_key] = (visited_fft && visited_dac) ? 1 : 0
      end


      cache[cache_key] =
        graph[node].to_a.sum do |neighbor|
          restricted_dfs(neighbor, graph, visited_fft, visited_dac, cache)
        end
    end

    def dfs(node, graph, cache = {})
      return cache[node] if cache.key?(node)
      return cache[node] = 1 if node == END_NODE

      cache[node] = graph[node].to_a.sum { |neighbor| dfs(neighbor, graph, cache) }
    end

    # Unfortunately, part 1 example input is different from part 2 example input
    # If we're in test mode, we split the input into two parts separated by an empty line
    # (we have to manually update d11_test.txt)
    # The actual input does not contain an empty line, so we just parse it as a single graph
    def as_graph
      part = 0

      @lines.each_with_object([{}, {}]) do |line, acc|
        if line.empty?
          part = 1
          next
        end

        parts = line.split(':').map(&:strip)

        acc[part][parts[0]] = parts[1].split(' ').map(&:strip)
      end
    end
  end
end