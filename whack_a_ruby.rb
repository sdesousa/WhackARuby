# frozen_string_literal: true

require 'gosu'
require_relative 'moving_element'

# WhackARuby Class
class WhackARuby < Gosu::Window
  RUBY_IMAGE = { width: 50, height: 43, img: Gosu::Image.new('images/ruby.png') }.freeze
  ELIXIR_IMAGE = { width: 50, height: 50, img: Gosu::Image.new('images/elixir.png') }.freeze
  HAMMER_IMAGE = { width: 60, height: 60, img: Gosu::Image.new('images/hammer.png') }.freeze

  def initialize(window_width = 800, window_height = 600, velocity = 5, nb_click_icons = 3, nb_unclick_icons= 2)
    @window_size = { width: window_width, height: window_height }
    super(window_width, window_height)
    self.caption = 'Whack the Ruby!'

    @clickable_icons = []
    @unclickable_icons = []
    (1..nb_click_icons).each do |_i|
      velocity_x = [-1, 1].sample * velocity
      velocity_y = [-1, 1].sample * velocity
      @clickable_icons << MovingElement.new(
        RUBY_IMAGE,
        rand(RUBY_IMAGE[:width] + 1...window_width - RUBY_IMAGE[:width]),
        rand(RUBY_IMAGE[:height] + 1...window_height - RUBY_IMAGE[:height]),
        velocity_x,
        velocity_y
      )
    end
    (1..nb_unclick_icons).each do |_i|
      velocity_x = [-1, 1].sample * velocity
      velocity_y = [-1, 1].sample * velocity
      @unclickable_icons << MovingElement.new(
        ELIXIR_IMAGE,
        rand(ELIXIR_IMAGE[:width] + 1...window_width - ELIXIR_IMAGE[:width]),
        rand(ELIXIR_IMAGE[:height] + 1...window_height - ELIXIR_IMAGE[:height]),
        velocity_x,
        velocity_y
      )
    end
    @fonts = {
      score: Gosu::Font.new(30),
      text: Gosu::Font.new(50)
    }
    @hit = 0
    @score = 0
    @playing = true
    @start_time = 0
    @duration = 60
  end

  def draw
    @clickable_icons.each do |icon|
      next unless icon.visible.positive?

      icon.image[:img].draw(
        icon.position_x - icon.image[:width] / 2,
        icon.position_y - icon.image[:height] / 2,
        2
      )
    end
    @unclickable_icons.each do |icon|
      next unless icon.visible.positive?

      icon.image[:img].draw(
        icon.position_x - icon.image[:width] / 2,
        icon.position_y - icon.image[:height] / 2,
        2
      )
    end
    HAMMER_IMAGE[:img].draw(mouse_x - 40, mouse_y - 10, 2)
    color = case @hit
            when 1
              Gosu::Color::GREEN
            when -1
              Gosu::Color::RED
            else
              Gosu::Color::NONE
            end
    draw_quad(
      0, 0, color,
      @window_size[:width], 0, color,
      @window_size[:width], @window_size[:height], color,
      0, @window_size[:height], color
    )
    @hit = 0
    score_display = "Score: #{@score}"
    time_display = "Time: #{@time_left}"
    @fonts[:score].draw_text(score_display, @window_size[:width] - @fonts[:score].text_width(score_display) - 20, 20, 3)
    @fonts[:score].draw_text(time_display, 20, 20, 3)

    return if @playing

    over_display = 'Game over'
    again_display = 'Press the space bar to play again'
    @fonts[:text].draw_text(
      over_display,
      (@window_size[:width] - @fonts[:text].text_width(over_display)) / 2,
      @window_size[:height] / 2 - 30,
      4
    )
    @fonts[:text].draw_text(
      again_display,
      (@window_size[:width] - @fonts[:text].text_width(again_display)) / 2,
      @window_size[:height] / 2 + 30,
      4
    )
    @clickable_icons.each do |icon|
      icon.visible = 20
    end
    @unclickable_icons.each do |icon|
      icon.visible = 20
    end
  end

  def update
    return unless @playing

    @clickable_icons.each do |icon|
      icon.position_x += icon.velocity_x
      icon.position_y += icon.velocity_y
      icon.velocity_x *= -1 if icon.position_x + icon.image[:width] / 2 > @window_size[:width] ||
                               (icon.position_x - icon.image[:width] / 2).negative?
      icon.velocity_y *= -1 if icon.position_y + icon.image[:height] / 2 > @window_size[:height] ||
                               (icon.position_y - icon.image[:height] / 2).negative?
      icon.visible -= 1
      icon.visible = 40 if icon.visible < -10 && rand < 0.05
    end
    @unclickable_icons.each do |icon|
      icon.position_x += icon.velocity_x
      icon.position_y += icon.velocity_y
      icon.velocity_x *= -1 if icon.position_x + icon.image[:width] / 2 > @window_size[:width] ||
        (icon.position_x - icon.image[:width] / 2).negative?
      icon.velocity_y *= -1 if icon.position_y + icon.image[:height] / 2 > @window_size[:height] ||
        (icon.position_y - icon.image[:height] / 2).negative?
      icon.visible -= 1
      icon.visible = 40 if icon.visible < -10 && rand < 0.05
    end
    @time_left = (@duration - ((Gosu.milliseconds - @start_time) / 1000))
    @playing = false if @time_left.negative?
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    if @playing
      if id == Gosu::MsLeft
        touched = false
        @clickable_icons.each do |icon|
          if Gosu.distance(mouse_x, mouse_y, icon.position_x, icon.position_y) < 55 && icon.visible.positive?
            touched = true
          end
        end
        @hit = touched ? 1 : -1
        @score += touched ? 5 : -1
      end
    elsif id == Gosu::KbSpace
      @playing = true
      @clickable_icons.each do |icon|
        icon.visible = -10
      end
      @start_time = Gosu.milliseconds
      @score = 0
    end
  end
end
