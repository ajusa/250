import std/[sequtils, cookies]
import mummy, ../mummy_utils, ../paths, ../game
type
  GameView* = object
    inProgress*: bool
    game*: Game

proc initGame(q: QueryParams): Game =
  result.players = q.toBase.filterIt(it[0] == "players").mapIt(it[1])

proc updateGameAndRedirect*(req: Request, game: Game) =
  var headers: HttpHeaders
  headers["Set-Cookie"] = setCookie("game", game.save(), path = "/", noName = true)
  headers["Location"] = paths.game
  req.respond(303, headers)

proc loadGame*(req: Request): Game = req.cookies["game"].load()

proc show*(req: Request): GameView =
  if "game" notin req.cookies:
    req.redirect(paths.index)
  else:
    result.game = req.loadGame()

proc new*(req: Request): GameView =
  result.inProgress = "game" in req.cookies

proc create*(req: Request) =
  req.updateGameAndRedirect(req.body.parseSearch.initGame)
