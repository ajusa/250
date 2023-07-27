import std/[sequtils, strformat]
import mummy, dekao, dekao/htmx, index, webby, nails, ../paths, ../game, round

proc needsGame*(
  controller: proc(req: Request, game: var Game) {.gcsafe.}): RequestHandler =
  proc(req: Request) =
    var game = req.loadGame()
    req.controller(game)

proc show*(req: Request, game: var Game) =
  var round = Round(wager: 120, partners: @["", ""])
  let resp = mainContent:
    form:
      hxPost paths.round
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
          td: a: href &"{paths.round}?id={i}"; say &"Round {i + 1}"
          for player in game.players: td: say round.pointsWon(player)
        tr:
          td: say "Sum"
          for player in game.players: td: say game.totalPointsWon(player)
    a ".secondary": href paths.index; role "button"; say "Start a new game"
  req.respond(resp)

proc gameForm() =
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
      input: ttype "text"; name "players"; required ""; placeholder "Player name"

proc new*(req: Request) =
  let resp = mainContent:
    if "game" in req.cookies:
      p: a ".secondary": href paths.game; role "button"; say "Resume last game"
    form:
      hxPost paths.game
      gameForm()
      button: ttype "submit"; say "Start game"
  req.respond(resp)

proc create*(req: Request) =
  var game = Game(players: req.body.parseSearch.toBase.filterIt(it[0] == "players").mapIt(it[1]))
  req.updateGameAndRedirect(game)
