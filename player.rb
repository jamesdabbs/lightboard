class Player
  attr_reader :name, :color, :king_color, :home_row

  def initialize name:, color:, king_color:, home_row:
    @name, @color, @king_color, @home_row = name, color, king_color, home_row
    @taken = []
  end

  def king_row
    (7 - home_row).abs
  end
end
