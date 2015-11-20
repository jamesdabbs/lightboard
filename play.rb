require "pry"
require "./launchpad"

#g.board[1,1].piece.king!
#g.board[1,7].piece.king!
#g.board.draw

endgame = [
  "        ",
  "  2     ",
  "        ",
  "  2     ",
  "        ",
  "    2   ",
  "     1  ",
  "        "
]

start = endgame
dump  = nil

loop do
  %w( board cell game piece player ).each do |f|
    load "./#{f}.rb"
  end

  begin
    g = Game.new start
    g.load dump if dump
    g.play
  rescue Board::Exit
    puts "Exiting!"
    break
  rescue Board::Reset
    puts "Restting"
    dump = nil
    next
  rescue Board::Reload
    puts "Reloading"
    dump = g.dump
    next
  end
end
