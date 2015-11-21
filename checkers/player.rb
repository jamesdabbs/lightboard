class Player
  # FIXME: just have a single color and change RGB
  attr_reader :name, :color, :king_color, :home_row

  def initialize name:, color:, king_color:, home_row:
    @name, @color, @king_color, @home_row = name, color, king_color, home_row
    @taken = []
  end

  def to_s
    "<Player(#@name)>"
  end

  def king_row
    (7 - home_row).abs
  end
end
