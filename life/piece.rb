class Life::Piece
  def initialize
    @alive = false
  end

  def alive?
    @alive
  end
  def revive!
    @alive = true
  end
  def die!
    @alive = false
  end
end
