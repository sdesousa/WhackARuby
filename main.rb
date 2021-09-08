# frozen_string_literal: true

require_relative 'whack_a_ruby'

window_width = 800
window_height = 600
velocity = 5
nb_click_icons = 3
nb_no_click_icons = 1

if ARGV.length > 1
  window_width = ARGV[0].to_i
  window_height = ARGV[1].to_i
  velocity = ARGV[2].to_i unless ARGV[2].nil?
  nb_click_icons = ARGV[3].to_i unless ARGV[3].nil?
  nb_no_click_icons = ARGV[4].to_i unless ARGV[4].nil?
else
  velocity = ARGV[0].to_i unless ARGV.empty?
end

WhackARuby.new(window_width, window_height, velocity, nb_click_icons, nb_no_click_icons).show
