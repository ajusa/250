import std/strformat
import mummy, dekao, dekao/[htmx, vue], index, nails, ../paths, ../game, round

proc fromRequest*(req: Request, game: var Game) =
  game = req.cookies["game"].load()

proc show*(req: Request, game: Game) =
  var round = Round(wager: 120, partners: @["", ""])
  let resp = mainContent:
    form:
      hxPost paths.round()
      round.form(game.players, game.rounds.len)
      button: ttype "submit"; say "Add round"
    h4: say "Results"
    table:
      role "grid"
      thead: tr:
        th: say "Round"
        for player in game.players: th: say player
      tbody:
        for i, round in game.rounds: tr:
          td: a: href paths.round(i); say &"Round {i + 1}"
          for player in game.players: td: say round.pointsWon(player)
        tr:
          td: say "Sum"
          for player in game.players: td: say game.totalPointsWon(player)
    a ".secondary": href paths.index(); role "button"; say "Start a new game"
  req.respond(resp)

proc gameForm() =
  tdiv:
    vScope "{players: 5}"
    label: say "Number of players"
    select:
      vModel "players"
      name "num"
      option: say "5"
      option: say "7"
    for i in 0..6:
      tdiv:
        if i >= 5:
          vIf "Number(players) == 7"
        label: say &"Player {i + 1}"
        input: ttype "text"; name "players"; required ""; placeholder "Player name"

proc fromRequest*(req: Request, args: var tuple[hasGame: bool]) =
  args.hasGame = "game" in req.cookies

proc new*(req: Request, args: tuple[hasGame: bool]) =
  let resp = mainContent:
    if args.hasGame:
      p: a ".secondary": href paths.game(); role "button"; say "Resume last game"
    form:
      hxPost paths.game()
      gameForm()
      button: ttype "submit"; say "Start game"
  req.respond(resp)

proc create*(req: Request, args: tuple[players: seq[string]]) =
  req.updateGameAndRedirect(Game(players: args.players))
