class Player
  attr_reader :color, :king_color, :king_row

  def initialize color, king_color, king_row
    @color = color
    @king_color = king_color
    @taken = []
    @king_row = king_row
  end

  def take piece
    @taken.push piece
  end
end
