require "./board"
require "./cell"
require "./piece"
require "./player"

BLACK = 0
WHITE = 3
RED   = 5
BLUE  = 45
REALLY_LIGHT_WHITE = 71


class Game
  Done = Class.new StandardError

  attr_reader :board

  def initialize
    @board = Board.new
    @players = [
      Player.new(36, 69, 0),
      Player.new(4, RED, 7)
    ]
    @current = 0

    self.load [
      "2 2 2 2 ",
      " 2 2 2 2",
      "2 2 2 2 ",
      "        ",
      "        ",
      " 1 1 1 1",
      "1 1 1 1 ",
      " 1 1 1 1"
    ]
  end

  def load grid
    @board.each_cell { |c| c.release }
    grid.each_with_index do |line, row|
      line.split("").each_with_index do |val, col|
        next if val == " "
        @board[col, row].place Piece.new @players[val.to_i - 1]
      end
    end
  end

  def log msg
    warn msg
  end

  def play
    at_exit { board.reset }
    loop do
      draw
      moves = get_move_sequence
      apply_all moves
    end
  rescue Done
    log "Exiting"
  end

  def valid? sequence
    if sequence.any? { |c| !c.playable? }
      log "You can only play playable squares"
      return false
    end

    start, *rest = sequence

    if start.piece.nil? || start.piece.player != current_player
      log "You must start with one of your pieces"
      return false
    end

    return true if rest.empty?


    if rest.any? { |c| c.occupied? }
      log "You cannot move through occupied spaces"
      return false
    end

    piece = start.piece
    moves = sequence.each_cons 2

    if !piece.king? && moves.any? { |f,t| backwards? f,t }
      log "Non-king pieces can't move backwards"
      return false
    end

    if moves.all? { |f,t| can_jump? f,t }
      return true
    end

    if sequence.length > 2
      log "Can't move multiple times without jumping"
      return false
    end

    stop = rest.first
    unless start.adjacent_to? stop
      log "You must move to an adjacent square"
      return false
    end

    return true
  end

  def promote_kings
    @board.each_cell do |c|
      next unless c.piece
      c.piece.king! if c.y == c.piece.player.king_row
    end
  end

  def apply_all moves
    return unless moves.length > 1
    moves.each_cons(2) { |f,t| move f,t }
    if winner? current_player
      @board.each_cell { |c| c.draw current_player.color if c.playable? }
      sleep 1
      @board.pad.scroll "Player #{@current + 1} wins!", color: current_player.color
      sleep 1
      raise Done
    else
      promote_kings
      toggle_current_player
    end
  end

  def winner? player
    @board.each_cell.all? { |c| c.empty? || c.piece.player == player }
  end

  def move from, to
    if over = jump_between(from, to)
      raise unless over.piece && over.piece.player != current_player
      taken = over.release
      over.flash taken.player.color, time: 1
      current_player.take taken
    end
    to.place from.release
  end

  def current_player
    @players[@current]
  end

  def toggle_current_player
    @current = 1 - @current
  end

  def draw
    board.draw
    board.side.pulse current_player.color
  end

  def jump_between from, to
    dx = from.x - to.x
    dy = from.y - to.y
    return unless dx.abs == 2 && dy.abs == 2
    board[to.x + dx/2, to.y + dy/2]
  end

  def can_jump? from, to
    return nil if to.adjacent_to? from
    if to.occupied?
      log "You cannot jump to an occupied square!"
      return false
    end
    intermediate = jump_between from, to
    if intermediate.nil?
      log "You can't jump to there"
      return false
    end
    if intermediate.empty?
      log "You cannot jump an empty square"
      return false
    end
    if intermediate.piece.player == current_player
      log "You cannot jump your own piece"
      return false
    end
    return true
  end

  def backwards? f,t
    dy = t.y - f.y
    if current_player == @players.first
      dy > 0
    else
      dy < 0
    end
  end

  def get_move_sequence
    moves = []
    loop do
      events = board.pad.in.gets
      events.each do |data|
        pre, key, v = data[:data]

        raise Done if pre == 176 && key == 8
        next unless pre == 144 && v == 0

        cell = board.key(key)
        return [] if cell == moves.first
        return moves if cell == moves.last

        moves.push cell
        if valid? moves
          cell.pulse 21
        else
          moves.pop
          cell.error!
        end
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  require "pry"
  g = Game.new
  #g.load [
  #  "        ",
  #  "   2    ",
  #  "        ",
  #  "   2    ",
  #  "        ",
  #  "     2  ",
  #  "      1 ",
  #  "        "
  #]
  #g.board[1,1].piece.king!
  #g.board[1,7].piece.king!
  #g.board.draw
  g.play
end
