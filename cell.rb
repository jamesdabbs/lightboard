class Cell
  attr_reader :x,:y, :piece
  attr_accessor :color

  def initialize board, x,y
    @board,@x,@y = board,x,y
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

  def draw color=nil
    c = color || self.color
    @board.pad.light cell_number, c
  end
  def pulse color, time: nil
    @board.pad.pulse cell_number, color
    if time
      Thread.new do
        sleep time
        draw
      end
    end
  end
  alias_method :flash, :pulse

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

  def error!
    pulse 13, time: 1
  end

  def color
    if occupied?
      piece.color
    else
      background_color
    end
  end

  def background_color
    if (x + y) % 2 == 0
      REALLY_LIGHT_WHITE
    else
      BLACK
    end
  end

  def cell_number
    (8 - y) * 10 + (x + 1)
  end
end
