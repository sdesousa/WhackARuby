# frozen_string_literal: true

require_relative 'whack_a_ruby'

window_width = 800
window_height = 600
velocity = 5

if ARGV.length > 1
  window_width = ARGV[0].to_i
  window_height = ARGV[1].to_i
  velocity = ARGV[2].to_i unless ARGV[2].nil?
else
  velocity = ARGV[0].to_i unless ARGV.empty?
end

WhackARuby.new(window_width, window_height, velocity).show
