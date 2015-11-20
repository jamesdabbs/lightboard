require "pry"
require "unimidi"

class Launchpad
  attr_reader :in, :out

  def initialize input: nil, output: nil
    @in  = input  || UniMIDI::Input[1]
    @out = output || UniMIDI::Output[1]
  end

  def configure in_=nil, out=nil
    @in  = in_ || UniMIDI::Input.gets
    @out = out || UniMIDI::Output.gets
  end

  def col col=0, color=0
    colors = [color] * 10
    sysex 12, col, *colors
  end

  def row row=0, color=0
    colors = [color] * 10
    sysex 13, row, *colors
  end

  def reset color=0
    sysex 14, color
  end

  def light cell, color=0
    sysex 10, cell, color
  end

  def set_rgb cell, r, g, b
    sysex 11, cell, r, g, b
  end

  def blink cell, color=0
    sysex 35, cell, color
  end

  def pulse cell, color=0
    sysex 40, cell, color
  end

  def scroll text, color: 1, loop: 0, speed: 4
    sysex 20, color, loop, speed, *text.split("").map(&:ord)
  end

  def sysex *bytes
    out.puts 240, 0, 32, 41, 2, 16, *bytes, 247
  end
end
