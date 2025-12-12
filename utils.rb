# frozen_string_literal: true

module Utils
  def self.load(day, test: false, strip: false)
    filename = "input/d#{day}#{test ? '_test' : ''}.txt"

    lines = File.readlines(filename)

    lines.reject! { |line| line.start_with?('#') } if strip
    lines.map!(&:strip) if strip
    lines.map { |l| l.chomp("\n") }
  end

  def self.as_grid(lines)
    lines.map { |line| line.chars }
  end
end
