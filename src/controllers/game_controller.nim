import std/[sequtils, cookies]
import mummy, webby, nails, ../paths, ../game, ../views/round_view
type GameView* = object
    inProgress*: bool
    game*: Game
    roundView*: RoundView
    totalPointsWon*: seq[int]

proc initGame(q: QueryParams): Game =
  result.players = q.toBase.filterIt(it[0] == "players").mapIt(it[1])

proc updateGameAndRedirect*(req: Request, game: Game) =
  var headers = {"Set-Cookie": setCookie("game", game.save(), path = "/", noName = true),
                 "Location": paths.game}.toSeq.HttpHeaders
  req.respond(303, headers)

proc loadGame*(req: Request): Game = req.cookies["game"].load()

proc show*(req: Request): GameView =
  if "game" notin req.cookies:
    req.redirect(paths.index)
  else:
    let game = req.loadGame()
    result.game = game
    result.roundView = RoundView(id: game.rounds.len,
                                 players: game.players, 
                                 round: Round(wager: 120))
    result.totalPointsWon = game.players.mapIt(game.totalPointsWon(it))

proc new*(req: Request): GameView =
  result.inProgress = "game" in req.cookies

proc create*(req: Request) =
  req.updateGameAndRedirect(req.body.parseSearch.initGame)
