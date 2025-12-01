# frozen_string_literal: true

require 'optparse'
require 'date'

require_relative 'utils'

Dir.glob(File.expand_path('days/*.rb', __dir__)).sort.each do |file|
  require_relative file
end

opts = {
  part: 1,
  day: Date.today.day,
  test: false
}

OptionParser.new do |opt|
  opt.on('--part PART', '-p PART') { |o| opts[:part] = o.to_i }
  opt.on('--day DAY', '-d DAY') { |o| opts[:day] = o.to_i }
  opt.on('--test', '-t') { opts[:test] = true }
end.parse!

raise 'Day not released yet!' if Date.new(Date.today.year, Date.today.month, opts[:day]) > Date.today
raise 'Part must be 1 or 2' if opts[:part] != 1 && opts[:part] != 2

day_class = Object.const_get("Days::D#{opts[:day]}")

puts day_class.solve(opts[:part], Utils.load(opts[:day], test: opts[:test]))
