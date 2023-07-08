import with, dekao, dekao/htmx, sequtils, strformat, math
import ../controllers/[game_controller, round_controller], round_view, ../game, index, ../paths

proc show*(gameView: GameView): string = with gameView: mainContent:
  form:
    hxPost paths.round
    gameView.roundView.renderForm()
    button:
      ttype: "submit"
      say "Add round"
  h4: say "Results"
  table:
    role "grid"
    thead:
      tr:
        th: say "Round"
        for player in game.players:
          th: say player
    tbody:
      for i, round in game.rounds:
        tr:
          td: a:
            href &"{paths.round}?id={i}"
            say &"Round {i + 1}"
          for player in game.players:
            td: say $round.pointsWon(player)
      tr:
        td: say "Sum"
        for player in game.players:
          td: say $game.rounds.mapIt(it.pointsWon(player)).sum
  a ".secondary":
    href paths.index
    role "button"
    say "Start a new game"

proc renderGameForm() =
  label: say "Number of players"
  select:
    name "num"
    option: say "5"
    option: say "7"
  for i in 0..6:
    tdiv:
      if i >= 5:
        hs """on load or change from first <[name=num]/> 
              shownWhen(me, value of first <[name=num]/> is 7)"""
      label: say &"Player {i + 1}"
      input:
        ttype "text"
        name &"players"
        required ""
        placeholder "Player name"

proc new*(gameView: GameView): string = with gameView: mainContent:
  if inProgress:
    p: a ".secondary":
      href paths.game
      role "button"
      say "Resume last game"
  form:
    hxPost paths.game
    renderGameForm()
    button:
      ttype "submit"
      say "Start game"
