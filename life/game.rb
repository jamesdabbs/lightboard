class Life::Game
  def initialize board: Life::Board
    @board_klass = board
    @boards      = {}
    @generation  = 0

    @boards[@generation] = @board_klass.new
  end

  def load_template grid
    grid.each_with_index do |line, row|
      line.split("").each_with_index do |val, col|
        p = Life::Piece.new
        p.revive! if val == "X"
        board[col, 7 - row].place p
      end
    end
  end

  def play
    loop do
      board.draw
      begin
        sleep 0.6
        next_board!
        #board.pick_cells do |cell|
        #  # No-op for now, just waiting to raise Next / Previous
        #end
      rescue Board::Next
        next_board!
      rescue Board::Previous
        prev_board!
      end
    end
  end

  private

  attr_reader :boards, :board_klass, :generation

  def board
    boards[generation]
  end

  def next_board!
    @generation += 1
    return if boards[generation]

    boards[generation] = evolve boards[generation - 1]
  end

  def evolve old
    newb = board_klass.new
    newb.each_cell do |c|

      p = Life::Piece.new
      c.place p

      was_alive = old[c.x, c.y].piece.alive?
      neighbors = old.live_neighbors(c)

      if neighbors == 3 || (was_alive && neighbors == 2)
        p.revive!
      else
        p.die!
      end
    end
    newb
  end

  def prev_board!
    @generation -= 1 if @generation > 0
  end
end
