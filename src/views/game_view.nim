import ../controllers/[game_controller, round_controller], with, dekao, dekao/htmx, index, ../paths, round_view, sequtils, ../game, strformat, math

proc show*(gameDetails: GameDetails): string = mainContent:
  form:
    hxPost paths.round
    initRoundForm(gameDetails.game, gameDetails.query).render()
    button:
      ttype: "submit"
      say "Add round"
  h4: say "Results"
  table:
    role "grid"
    thead:
      tr:
        th: say "Round"
        for player in gameDetails.game.players:
          th: say player
    tbody:
      for i, round in gameDetails.game.rounds:
        tr:
          td: a:
            href &"{paths.round}?id={i}"
            say &"Round {i + 1}"
          for player in gameDetails.game.players:
            td: say $round.pointsWon(player)
      tr:
        td: say "Sum"
        for player in gameDetails.game.players:
          td: say $gameDetails.game.rounds.mapIt(it.pointsWon(player)).sum
  a ".secondary":
    href paths.index
    role "button"
    say "Start a new game"

proc new*(gameView: GameView): string = with gameView: mainContent:
  if inProgress:
    p: a ".secondary":
      href paths.game
      role "button"
      say "Resume last game"
  form:
    hxPost paths.game
    gameForm.render()
    button:
      ttype "submit"
      say "Start game"


proc render(form: GameForm) =
  tdiv("#gameForm"):
    hxGet paths.index
    hxTrigger "change from:.dynamic"
    hxInclude "this"
    hxTarget "this"
    hxSelect "#gameForm"
    hxSwap "outerHTML"

    label: say "Number of players"
    select(".dynamic"):
      name "num"
      for n in ["5", "7"]:
        option:
          say $n
          if $form.num == n: selected ""
    for player in form.players:
      label: say player.title
      input:
        ttype "text"
        value player.value
        name player.name
        required ""
        placeholder "Player name"
