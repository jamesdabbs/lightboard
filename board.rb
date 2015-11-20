require "./launchpad"

class Board
  class Error  < StandardError; end
  class Reload < Error; end
  class Reset  < Error; end
  class Exit   < Error; end

  def initialize
    @pad = Launchpad.new
    @pad.programmer_mode!
    reset

    @rows = 8.times.map do |y|
      8.times.map do |x|
        Cell.new x,y
      end
    end

    @side = Cell.new(8,8)

    @log_level = 0
  end

  def pick_cells
    return enum_for(:get_squares) unless block_given?
    loop do
      events = pad.in.gets
      events.each do |data|
        pre, pos, v = data[:data]
        next unless v && v.zero? # Key-up

        log "Got event #{data}", level: 2

        if pre == 176 # Side buttons
          case pos
          when 6
            raise Reload
          when 7
            raise Reset
          when 8
            raise Exit
          when 91
            self.log_level += 1
          when 92
            self.log_level -= 1
          end
        end

        yield cell_at_pos(pos) if pre == 144 # In-pad press events
      end
    end
  end

  def each_cell
    return enum_for(:each_cell) unless block_given?
    rows.each do |row|
      row.each do |cell|
        yield cell
      end
    end
  end

  def side
  end

  def [] x,y
    rows[y][x]
  end

  def draw
    each_cell do |c|
      pad.light number(c), color_for(c)
    end
  end

  def reset color=BLACK
    pad.reset color
  end

  def print msg, color: nil
    pad.scroll msg, color: color
    sleep 1
  end

  def log msg, level: 0
    warn msg if level <= log_level
  end

  def update cell, color=nil
    color ||= color_for(cell)
    pad.light number(cell), color
  end

  def select cell
    pulse cell, GREEN
  end

  def remove cell
    piece = cell.release
    pulse cell, piece.player.color, time: 1
  end

  def error! cell
    pulse cell, YELLOW, time: 1
  end

  def current_player= player
    pulse side, player.color
  end

  private

  attr_reader :pad, :rows, :side, :log_level

  def log_level= new_level
    @log_level = new_level
    warn "Log level is now: #{log_level}"
  end

  def pulse cell, color, time: nil
    pad.pulse number(cell), color
    if time
      Thread.new do
        sleep time
        update cell
      end
    end
  end
  alias_method :flash, :pulse

  def cell_at_pos n
    x = (n % 10) - 1
    y = (n / 10) - 1
    self[x,y]
  end

  def number cell
    (cell.y * 10) + cell.x + 11
  end

  def color_for cell
    return cell if cell.is_a? Fixnum
    if p = cell.piece
      p.king? ? p.player.king_color : p.player.color
    elsif cell.playable?
      REALLY_LIGHT_WHITE
    else
      BLACK
    end
  end
end
