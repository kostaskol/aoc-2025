# frozen_string_literal: true

require_relative 'base'

begin
  require 'z3'
rescue LoadError
  # Z3 gem not available; part 2 will not work
end

module Days
  class D10 < Base
    def part1
      parsed_input.sum do |entry|
        lights = entry[:lights]
        switches = entry[:switches]

        n = lights.length
        m = switches.length

        # Build the coefficient matrix
        # We need A^T where A[switch][light] tells which lights each switch affects
        # A^T[light][switch] tells which switches affect each light
        a_t = Array.new(n) { Array.new(m, 0) }
        switches.each_with_index do |switch, i|
          switch.each do |light_idx|
            a_t[light_idx][i] = 1
          end
        end

        # Solve the system A^T * x = b over GF(2)
        solution = solve_gf2(a_t, lights)

        # If there's no solution, return 0 for this entry
        next 0 unless solution

        solution.count(1)
      end
    end

    # Part 2 utilizes Z3 theorem prover to find minimal switch presses
    # in a reasonable time. Must be run with `ruby -rz3 main.rb -p2`
    def part2
      parsed_input.sum do |entry|
        joltage = entry[:joltage]
        switches = entry[:switches]

        n = joltage.length
        m = switches.length

        # Build the coefficient matrix
        # We need A^T where A[switch][joltage] tells which joltage each switch affects
        # A^T[joltage][switch] tells which switches affect each joltage
        a_t = Array.new(n) { Array.new(m, 0) }
        switches.each_with_index do |switch, i|
          switch.each do |joltage_idx|
            a_t[joltage_idx][i] = 1
          end
        end

        # Solve the system A^T * x = b over GF(2)
        solution = solve_with_z3(a_t, joltage)
        # If there's no solution, return 0 for this entry
        next 0 unless solution

        solution.sum
      end
    end

    private

    # Part 1 solution using Gaussian elimination over GF(2)
    def solve_gf2(a, b)
      a = Marshal.load(Marshal.dump(a))
      rhs = b.dup

      n_rows = a.length
      n_cols = a[0].length
      row = 0

      # Keep track of pivot columns
      pivot_cols = []

      # Forward elimination
      (0...n_cols).each do |col|
        # Find pivot: a row with a 1 in this column, starting from `row`
        pivot = (row...n_rows).find { |r| a[r][col] == 1 }
        next unless pivot

        # Record this as a pivot column
        pivot_cols << col

        # Swap pivot row into place
        a[row], a[pivot] = a[pivot], a[row]
        rhs[row], rhs[pivot] = rhs[pivot], rhs[row]

        # Eliminate all OTHER rows (not just below)
        (0...n_rows).each do |r|
          next if r == row
          if a[r][col] == 1
            a[r].map!.with_index { |v, i| v ^ a[row][i] }
            rhs[r] ^= rhs[row]
          end
        end

        row += 1
        break if row >= n_rows
      end

      # Check inconsistencies
      (row...n_rows).each do |r|
        return nil if a[r].all?(&:zero?) && rhs[r] == 1
      end

      # Find free variables (non-pivot columns)
      free_cols = (0...n_cols).to_a - pivot_cols

      # If no free variables, return the unique solution
      if free_cols.empty?
        x = [0] * n_cols
        pivot_cols.each_with_index do |col, i|
          x[col] = rhs[i]
        end
        return x
      end

      # Generate all possible solutions by trying all combinations of free variables
      min_solution = nil
      min_count = Float::INFINITY

      (0...(1 << free_cols.length)).each do |mask|
        x = [0] * n_cols
        
        # Set free variables based on mask
        free_cols.each_with_index do |col, i|
          x[col] = (mask >> i) & 1
        end
        
        # Calculate pivot variables based on free variables
        pivot_cols.each_with_index do |col, i|
          # Start with the RHS value
          val = rhs[i]
          # XOR with contributions from free variables
          free_cols.each do |free_col|
            val ^= (a[i][free_col] & x[free_col])
          end
          x[col] = val
        end
        
        # Count number of switches pressed
        count = x.sum
        if count < min_count
          min_count = count
          min_solution = x
        end
      end

      min_solution
    end

    # Solve using Z3 theorem prover
    def solve_with_z3(a_t, b)
      return nil unless defined?(Z3)

      n_equations = a_t.length
      n_vars = a_t[0].length
      
      solver = Z3::Solver.new
      
      # Create integer variables for each switch (x[0], x[1], ...)
      # Note: variable names must be strings
      vars = (0...n_vars).map { |i| Z3::Int(i.to_s) }
      
      # Add constraints: each variable must be non-negative
      vars.each do |v|
        solver.assert(v >= 0)
      end
      
      # Add equation constraints: A^T * x = b
      (0...n_equations).each do |eq|
        # Build the sum: a_t[eq][0]*x[0] + a_t[eq][1]*x[1] + ...
        sum_terms = []
        (0...n_vars).each do |idx|
          coeff = a_t[eq][idx]
          if coeff != 0
            sum_terms << (vars[idx] * coeff)
          end
        end
        
        # Create the sum expression
        sum = sum_terms.empty? ? Z3::Int(0) : sum_terms.reduce(:+)
        
        # Assert that sum equals b[eq]
        solver.assert(sum == b[eq])
      end
      
      # Try to find solution with increasing cost bounds
      # Start from 0 and incrementally increase
      (0..b.sum).each do |max_cost|
        # Create a new scope for this iteration
        solver.push
        
        # Add constraint: sum of all variables <= max_cost
        total = vars.reduce(:+)
        solver.assert(total <= max_cost)
        
        if solver.satisfiable?
          model = solver.model
          solution = vars.map { |v| model[v].to_i }
          solver.pop
          return solution
        end
        
        solver.pop
      end
      
      nil
    end

    def parsed_input
      @lines.map do |line|
        parts = line.split(' ')

        parts.each_with_object({ lights: nil, switches: [], joltage: nil }) do |part, acc|
          case part[0]
          when '['
            acc[:lights] = part[1..-2].chars.map { |c| c == '#' ? 1 : 0 }
          when '('
            acc[:switches] << part[1..-2].split(',').map(&:to_i)
          when '{'
            acc[:joltage] = part[1..-2].split(',').map(&:to_i)
          end
        end
      end
    end
  end
end