import std/[strformat, sequtils, cookies, math]
import mummy, mummy/routers, webby, dekao, dekao/htmx
import game, mummy_utils, views/[game, round]

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

proc cookie(game: Game): string =
  setCookie("game", game.save(), path = "/", noName = true)

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
      href "./game"
      role "button"
      say "Resume last game"
    form:
      hxPost "./game"
      page.gameForm.render()
      button:
        ttype "submit"
        say "Start game"

router.get("/") do (req: Request):
  let resp = mainContent: req.initIndexPage.render()
  req.respond(200, body = resp)

router.post("/game") do (req: Request):
  var game: Game
  let form = req.body.parseSearch.initGameForm()
  game.players = form.players.mapIt(it.value)
  var headers: HttpHeaders
  headers["Set-Cookie"] = game.cookie()
  headers["Location"] = "/game"
  req.respond(303, headers)

router.get("/game") do (req: Request):
  if "game" notin req.cookies:
    req.redirect("./")
  else:
    var game = req.cookies["game"].load()
    let resp = mainContent:
      form:
        hxPost "./game/rounds"
        initRoundForm(game, req.query).render()
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
                href &"game/rounds?id={i}"
                say &"Round {i + 1}"
              for player in game.players:
                td: say $round.pointsWon(player)
          tr:
            td: say "Sum"
            for player in game.players:
              td: say $game.rounds.mapIt(it.pointsWon(player)).sum
      a ".secondary":
        href "./game"
        role "button"
        say "Start a new game"
    req.respond(200, body = resp)

proc toRound(roundForm: RoundForm): Round =
  result.bidder = roundForm.bidder
  result.partners = roundForm.partners
  result.bidderWon = roundForm.bidderWon
  result.wager = roundForm.wager

router.get("/game/rounds") do (req: Request):
  var game = req.cookies["game"].load()
  var id = req.query["id"].parseInt
  var round = game.rounds[id]
  let resp = mainContent:
    form:
      hxPut &"./rounds?id={id}"
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
      hxDelete &"./rounds?id={id}"
      say "Delete round"
  req.respond(200, body = resp)

router.delete("/game/rounds") do (req: Request):
  var game = req.cookies["game"].load()
  var id = req.query["id"].parseInt
  game.delete(id)
  var headers: HttpHeaders
  headers["Set-Cookie"] = game.cookie()
  headers["Location"] = "/game"
  req.respond(303, headers)

router.put("/game/rounds") do (req: Request):
  var game = req.cookies["game"].load()
  var id = req.query["id"].parseInt
  var round = game.initRoundForm(req.body.parseSearch).toRound()
  game.update(id, round)
  var headers: HttpHeaders
  headers["Set-Cookie"] = game.cookie()
  headers["Location"] = "/game"
  req.respond(303, headers)

router.post("/game/rounds") do (req: Request):
  var game = req.cookies["game"].load()
  let roundForm = game.initRoundForm(req.body.parseSearch)
  game.add(roundForm.toRound())
  var headers: HttpHeaders
  headers["Set-Cookie"] = game.cookie()
  headers["Location"] = "/game"
  req.respond(303, headers)

let server = newServer(router)
echo "Serving on http://localhost:8080"
server.serve(Port(8080))
