require "./launchpad"

class Board
  attr_reader :pad

  def initialize
    @pad = Launchpad.new
    reset

    @rows = 8.times.map do |y|
      8.times.map do |x|
        Cell.new self,x,y
      end
    end
  end

  def each_cell
    return enum_for(:each_cell) unless block_given?
    @rows.each do |row|
      row.each do |cell|
        yield cell
      end
    end
  end

  def side
    @_side ||= Cell.new(self,8,-1)
  end

  def [] x,y
    @rows[y][x]
  end

  def key n
    x = (n % 10) - 1
    y = 8 - (n / 10)
    self[x,y]
  end

  def draw
    @rows.each { |row| row.each { |cell| cell.draw } }
  end
  def reset color=BLACK
    @pad.reset color
  end
end
