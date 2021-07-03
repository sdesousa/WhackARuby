# frozen_string_literal: true

require 'gosu'

# WhackARuby Class
class WhackARuby < Gosu::Window
  def initialize(window_width = 800, window_height = 600, velocity = 5)
    @window_size = { width: window_width, height: window_height }
    super(window_width, window_height)
    self.caption = 'Whack the Ruby!'
    @ruby_image = { width: 50, height: 43, img: Gosu::Image.new('images/ruby.png') }
    @elixir_image = { width: 50, height: 50, img: Gosu::Image.new('images/elixir.png') }
    @hammer_image = { width: 60, height: 60, img: Gosu::Image.new('images/hammer.png') }
    @fonts = {
      score: Gosu::Font.new(30),
      text: Gosu::Font.new(50)
    }
    @positions = {
      ruby_x: rand(@ruby_image[:width] + 1...window_width - @ruby_image[:width]),
      ruby_y: rand(@ruby_image[:height] + 1...window_height - @ruby_image[:height]),
      elixir_x: rand(@elixir_image[:width] + 1...window_width - @elixir_image[:width]),
      elixir_y: rand(@elixir_image[:height] + 1...window_height - @elixir_image[:height])
    }
    @velocities = {
      ruby_x: velocity,
      ruby_y: velocity,
      elixir_x: velocity,
      elixir_y: velocity
    }
    @visible = {
      ruby: 0,
      elixir: 0
    }
    @hit = 0
    @score = 0
    @playing = true
    @start_time = 0
    @duration = 60
  end

  def draw
    if @visible[:ruby].positive?
      @ruby_image[:img].draw(
        @positions[:ruby_x] - @ruby_image[:width] / 2,
        @positions[:ruby_y] - @ruby_image[:height] / 2,
        2
      )
    end
    if @visible[:elixir].positive?
      @elixir_image[:img].draw(
        @positions[:elixir_x] - @elixir_image[:width] / 2,
        @positions[:elixir_y] - @elixir_image[:height] / 2,
        1
      )
    end
    @hammer_image[:img].draw(mouse_x - 40, mouse_y - 10, 2)
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
    @visible[:ruby] = 20
  end

  def update
    return unless @playing

    @positions[:ruby_x] += @velocities[:ruby_x]
    @positions[:ruby_y] += @velocities[:ruby_y]
    @velocities[:ruby_x] *= -1 if @positions[:ruby_x] + @ruby_image[:width] / 2 > @window_size[:width] ||
                                  (@positions[:ruby_x] - @ruby_image[:width] / 2).negative?
    @velocities[:ruby_y] *= -1 if @positions[:ruby_y] + @ruby_image[:height] / 2 > @window_size[:height] ||
                                  (@positions[:ruby_y] - @ruby_image[:height] / 2).negative?
    @positions[:elixir_x] -= @velocities[:elixir_x]
    @positions[:elixir_y] -= @velocities[:elixir_y]
    @velocities[:elixir_x] *= -1 if @positions[:elixir_x] + @elixir_image[:width] / 2 > @window_size[:width] ||
                                    (@positions[:elixir_x] - @elixir_image[:width] / 2).negative?
    @velocities[:elixir_y] *= -1 if @positions[:elixir_y] + @elixir_image[:height] / 2 > @window_size[:height] ||
                                    (@positions[:elixir_y] - @elixir_image[:height] / 2).negative?
    @visible[:ruby] -= 1
    @visible[:ruby] = 40 if @visible[:ruby] < -10 && rand < 0.05
    @visible[:elixir] -= 1
    @visible[:elixir] = 40 if @visible[:elixir] < -10 && rand < 0.05
    @time_left = (@duration - ((Gosu.milliseconds - @start_time) / 1000))
    @playing = false if @time_left.negative?
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    # return unless @playing && id == Gosu::MsLeft

    if @playing
      if id == Gosu::MsLeft
        if Gosu.distance(mouse_x, mouse_y, @positions[:ruby_x], @positions[:ruby_y]) < 55 && @visible[:ruby].positive?
          @hit = 1
          @score += 5
        else
          @hit = -1
          @score -= 1
        end
      end
    elsif id == Gosu::KbSpace
      @playing = true
      @visible[:ruby] = -10
      @start_time = Gosu.milliseconds
      @score = 0
    end
  end
end
