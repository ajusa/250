import std/[strformat, sequtils, cookies, math, os]
import mummy, mummy/routers, webby, dekao, dekao/htmx
import game, mummy_utils, paths, views/[game, round]

type GameHandler = proc(request: Request, game: var Game) {.gcsafe.}
type RoundHandler = proc(request: Request, game: var Game, id: int) {.gcsafe.}

const HTML_HEADERS = @[("Content-Type", "text/html;charset=utf-8")]

proc toHandler(wrapped: GameHandler): RequestHandler =
  return proc(req: Request) =
    if "game" notin req.cookies:
      req.redirect(paths.index)
    else:
      var game = req.cookies["game"].load()
      req.wrapped(game)

proc toHandler(wrapped: RoundHandler): RequestHandler =
  return toHandler do (req: Request, game: var Game):
    req.wrapped(game, req.query["id"].parseInt)

template mainContent(inner): string =
  let content = render:
    say "<!DOCTYPE html>"
    html:
      head:
        meta:
          charset "utf-8"
          name "viewport"
          content "width=device-width, initial-scale=1"
        link:
          rel "stylesheet"
          href "https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css"
        script: src "https://unpkg.com/htmx.org@1.9.2/dist/htmx.js"
        title: say "250"
      body:
        hxBoost "true"
        hxPushUrl "true"
        hxTarget "body"
        main ".container":
          h1: say "250 Score Tracker"
          inner
  content

var router: Router

type IndexPage = object
  hasGame: bool
  gameForm: GameForm

proc initIndexPage(req: Request): IndexPage =
  result.hasGame = "game" in req.cookies
  result.gameForm = req.query.initGameForm()

proc render(page: IndexPage) =
  if page.hasGame:
    p: a ".secondary":
      href paths.game
      role "button"
      say "Resume last game"
  form:
    hxPost paths.game
    page.gameForm.render()
    button:
      ttype "submit"
      say "Start game"

proc updateGameAndRedirect(req: Request, game: Game) =
  var headers: HttpHeaders
  headers["Set-Cookie"] = setCookie("game", game.save(), path = "/", noName = true)
  headers["Location"] = paths.game
  req.respond(303, headers)

proc indexHandler(req: Request) =
  let resp = mainContent: req.initIndexPage.render()
  req.respond(200, HTML_HEADERS, resp)

proc createGameHandler(req: Request) =
  var game: Game
  let form = req.body.parseSearch.initGameForm()
  game.players = form.players.mapIt(it.value)
  req.updateGameAndRedirect(game)

proc viewGameHandler(req: Request, game: var Game) =
  let resp = mainContent: GameDetails(game: game, query: req.query).render()
  req.respond(200, HTML_HEADERS, resp)

proc editRoundHandler(req: Request, game: var Game, id: int) =
  let round = game.rounds[id]
  let resp = mainContent:
    h3: say "Edit round"
    form:
      hxPut &"{paths.round}?id={id}"
      var roundForm = RoundForm(game: game,
                                title: &"Round {id + 1}",
                                wager: round.wager,
                                bidder: round.bidder,
                                bidderWon: round.bidderWon,
                                partners: round.partners)
      roundForm.render()
      button:
        ttype: "submit"
        say "Edit round"
    button ".secondary":
      hxDelete &"{paths.round}?id={id}"
      say "Delete round"
  req.respond(200, HTML_HEADERS, resp)

proc deleteRoundHandler(req: Request, game: var Game, id: int) =
  game.delete(id)
  req.updateGameAndRedirect(game)

proc updateRoundHandler(req: Request, game: var Game, id: int) =
  var round = game.initRoundForm(req.body.parseSearch).toRound()
  game.update(id, round)
  req.updateGameAndRedirect(game)

proc createRoundHandler(req: Request, game: var Game) =
  let round = game.initRoundForm(req.body.parseSearch).toRound()
  game.add(round)
  req.updateGameAndRedirect(game)

router.get(paths.index.route, indexHandler)
router.post(paths.game.route, createGameHandler)
router.get(paths.game.route, viewGameHandler.toHandler())
router.get(paths.round.route, editRoundHandler.toHandler())
router.delete(paths.round.route, deleteRoundHandler.toHandler())
router.put(paths.round.route, updateRoundHandler.toHandler())
router.post(paths.round.route, createRoundHandler.toHandler())

let server = newServer(router)
echo &"Serving on http://localhost:8080"
server.serve(Port(8080))
