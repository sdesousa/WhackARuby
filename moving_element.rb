# frozen_string_literal: true

# MovingElement class
class MovingElement
  attr_accessor :image, :position_x, :position_y, :velocity_x, :velocity_y, :visible

  def initialize(image, x, y, velocity_x, velocity_y)
    @image = image
    @position_x = x
    @position_y = y
    @velocity_x = velocity_x
    @velocity_y = velocity_y
    @visible = 0
  end
end
