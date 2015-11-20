# Light Board

Games and utilities for playing them on [one of these](http://launchpad-pro.com/)

![Launchpad Pro](http://uk.novationmusic.com/sites/default/files/styles/cta_scale_1280/public/3-LPP_0_0.png)

## Checkers

Right now, this is the only game implemented. To run it:

    ruby play.rb

The side light shows the current player. Press a piece to select it, a sequence of moves to make, and then commit them by re-tapping the last step (or press the piece again to cancel).

The `pan`, `sends` and `stop clip` buttons reload code, reset the board, and exit, respectively.

Future work:

* Add tests and refactor the game logic
* Require players to make a jump if one is available
* Promote kings mid-sequence, if a turnaround jump becomes available
* Use the left and right buttons to undo / redo
