require "json"

class Game
  def initialize template=nil
    @board = Board.new
    @players = [
      Player.new(name: "Player 1", color: LIGHT_BLUE, king_color: BLUE, home_row: 0),
      Player.new(name: "Player 2", color: LIGHT_RED,  king_color: RED,  home_row: 7)
    ]
    @current = 0

    template ||= [
      " 2 2 2 2",
      "2 2 2 2",
      " 2 2 2 2",
      "        ",
      "        ",
      "1 1 1 1 ",
      " 1 1 1 1",
      "1 1 1 1 "
    ]

    load_template template
    at_exit { Thread.new { board.reset } }
  end

  def load_template grid
    board.each_cell { |c| c.release }
    grid.each_with_index do |line, row|
      line.split("").each_with_index do |val, col|
        next if val == " "
        board[col, 7 - row].place Piece.new players[val.to_i - 1]
      end
    end
  end

  def load json
    json = JSON.parse json
    board.each_cell { |c| c.release }
    @current = json["current"]
    json["pieces"].each do |data|
      p = Piece.new players[data.fetch "player"]
      p.king! if data.fetch("king")
      board[ data.fetch("x"), data.fetch("y") ].place p
    end
  end

  def dump
    pieces = []
    board.each_cell do |c|
      if p = c.piece
        pieces.push(
          player: players.index(p.player),
          king:   p.king?,
          x:      c.x,
          y:      c.y
        )
      end
    end

    {
      current: current,
      pieces:  pieces
    }.to_json
  end

  def play
    loop do
      draw
      moves = get_move_sequence
      next if moves.empty?

      make_moves moves

      if winner? current_player
        display_winner current_player
        break
      else
        promote_kings
        toggle_current_player
      end
    end
  end

  private

  attr_reader :players, :current, :board

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

    # TODO: are you _required_ to take a piece if you can?

    return true
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

  def current_player
    players[current]
  end

  def toggle_current_player
    @current = 1 - current
  end

  def log msg
    board.log msg
  end

  def draw
    board.current_player = current_player
    board.draw
  end

  def promote_kings
    # TODO: can you promote mid-move and then turn around?
    board.each_cell do |c|
      next unless c.piece
      c.piece.king! if c.y == c.piece.player.king_row
    end
  end

  def make_moves moves
    return unless moves.length > 1
    moves.each_cons(2) { |f,t| move f,t }
  end

  def winner? player
    board.each_cell.all? { |c| c.empty? || c.piece.player == player }
  end

  def display_winner player
    board.each_cell { |c| board.update c, player.color if c.playable? }
    sleep 1
    board.print "#{player.name} wins!", color: player.color
    sleep 10
  end

  def move from, to
    if over = jump_between(from, to)
      raise unless over.piece && over.piece.player != current_player
      board.remove over
    end
    to.place from.release
  end

  def jump_between from, to
    dx = from.x - to.x
    dy = from.y - to.y
    return unless dx.abs == 2 && dy.abs == 2
    board[to.x + dx/2, to.y + dy/2]
  end

  def backwards? from,to
    (from.y <=> to.y) == (to.y <=> current_player.home_row)
  end

  def get_move_sequence
    moves = []
    board.pick_cells do |cell|
      return [] if cell == moves.first
      return moves if cell == moves.last

      board.log "Picked #{cell}", level: 1

      moves.push cell
      if valid? moves
        board.select cell
      else
        board.error! cell
        moves.pop
      end
    end
  end
end
