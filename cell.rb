class Cell
  attr_reader :x,:y, :piece

  def initialize x,y
    @x,@y = x,y
  end

  def to_s
    "<Cell(#@x,#@y)>"
  end

  def inspect
    to_s
  end

  def adjacent_to? other
    (x - other.x).abs <= 1 && (y - other.y).abs <= 1
  end

  def release
    p = @piece
    @piece = nil
    p
  end

  def place piece
    raise if occupied?
    @piece = piece
  end

  def playable?
    (x + y) % 2 == 0
  end

  def empty?
    piece.nil?
  end

  def occupied?
    !empty?
  end
end
