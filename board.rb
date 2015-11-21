require_relative "./launchpad"
require_relative "./cell"

module Board
  class Error    < StandardError; end
  class Reload   < Error; end
  class Reset    < Error; end
  class Exit     < Error; end
  class Previous < Error; end
  class Next     < Error; end

  module WithPad
    def pick_cells
      return enum_for(:pick_cells) unless block_given?
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
            when 93
              raise Previous
            when 94
              raise Next
            end
          end

          if pre == 144 # In-pad press event
            c = cell_at_pos pos
            log c, level: 1
            yield c
          end
        end
      end
    end

    private

    def pad
      @_pad ||= launch_pad
    end

    def launch_pad
      p = Launchpad.new
      p.programmer_mode!
      p.reset
      p
    end

    def side
      @_side ||= Cell.new(8,8)
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
  end

  class Base
    def initialize
      @log_level = 0
      @rows = 8.times.map do |y|
        8.times.map do |x|
          Cell.new x,y
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

    def [] x,y
      rows[y][x]
    end

    def log msg, level: 0
      warn msg if level <= log_level
    end

    private

    attr_reader :rows, :log_level

    def log_level= new_level
      @log_level = new_level
      warn "Log level is now: #{log_level}"
    end
  end
end
