import std/[sequtils, cookies, strformat]
import mummy, dekao, dekao/htmx, index, webby, nails, ../paths, ../game, round

type GameView* = object
  inProgress*: bool
  game*: Game
  round*: Round
  totalPointsWon*: seq[int]

proc updateGameAndRedirect(req: Request, game: Game) =
  var headers = {"Set-Cookie": setCookie("game", game.save(), path = "/", noName = true),
                 "Location": paths.game}.toSeq.HttpHeaders
  req.respond(303, headers)

proc gameUpdater*(
  controller: proc(req: Request, game: var Game) {.gcsafe.}): RequestHandler =
  proc(req: Request) =
    var game = req.loadGame()
    req.controller(game)
    req.updateGameAndRedirect(game)

proc show*(req: Request): GameView =
  result.game = req.loadGame()
  result.round = Round(wager: 120, partners: @["", ""])
  result.totalPointsWon = result.game.players.mapIt(result.game.totalPointsWon(it))

proc new*(req: Request): GameView =
  result.inProgress = "game" in req.cookies

proc create*(req: Request) =
  var game = Game(players: req.body.parseSearch.toBase.filterIt(it[0] == "players").mapIt(it[1]))
  req.updateGameAndRedirect(game)

proc show*(view: GameView) = mainContent:
  form:
    hxPost paths.round
    view.round.form(view.game.players, view.game.rounds.len)
    button: ttype "submit"; say "Add round"
  h4: say "Results"
  table:
    role "grid"
    thead: tr:
      th: say "Round"
      for player in view.game.players: th: say player
    tbody:
      for i, round in view.game.rounds: tr:
        td: a: href &"{paths.round}?id={i}"; say &"Round {i + 1}"
        for player in view.game.players: td: say round.pointsWon(player)
      tr:
        td: say "Sum"
        for total in view.totalPointsWon: td: say total
  a ".secondary": href paths.index; role "button"; say "Start a new game"

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

proc new*(view: GameView) = mainContent:
  if view.inProgress:
    p: a ".secondary": href paths.game; role "button"; say "Resume last game"
  form:
    hxPost paths.game
    gameForm()
    button: ttype "submit"; say "Start game"
