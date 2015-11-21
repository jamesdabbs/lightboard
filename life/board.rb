require_relative "../board"

class Life::Board < Board::Base
  include Board::WithPad

  def draw
    each_cell do |c|
      pad.light number(c), color_for(c)
    end
  end

  def live_neighbors cell
    neighbors(cell).count { |c| c.piece.alive? }
  end

  private

  def neighbors cell
    (-1 .. 1).map do |dx|
      (-1 .. 1).map do |dy|
        next if dx == 0 && dy == 0
        next unless (0 .. 7).cover?(cell.x + dx)
        next unless (0 .. 7).cover?(cell.y + dy)
        self[cell.x + dx, cell.y + dy]
      end
    end.flatten.compact
  end

  def color_for c
    c.piece.alive? ? BLUE : BLACK
  end
end
