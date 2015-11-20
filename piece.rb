class Piece
  attr_reader :player

  def initialize player
    @player = player
    @king = false
  end

  def king?
    @king
  end
  def king!
    @king = true
  end

  def color
    king? ? player.king_color : player.color
  end
end
