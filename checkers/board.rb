require_relative "../board"

class Checkers::Board < Board::Base
  include Board::WithPad

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


class Checkers::TermBoard < Board::Base
  def current_player= player
    @current_player = player
  end

  def draw
    system "clear"
    str = rows.map do |row|
      row.map do |cell|
        if p = cell.piece
          p.player.name[-1]
        elsif cell.playable?
          "X"
        else
          " "
        end
      end.join ""
    end.reverse.join "\n"

    puts str
  end

  def reset
  end

  def select cell
  end

  def error! cell
  end

  def pick_cells
    return enum_for(:pick_cells) unless block_given?
    loop do
      print "#{@current_player.name} > "
      case cmd = gets.chomp
      when "reload"
        raise Board::Reload
      when "reset"
        raise Board::Reset
      when "exit", "quit", "q"
        raise Board::Exit
      end

      x,y = cmd.strip.split(",").map &:to_i

      yield self[x,y]
    end

  end
end
