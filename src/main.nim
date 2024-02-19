import mummy, mummy/routers, webby, flatty, supersnappy, dekao, dekao/htmx, jsony
import std/[strformat, strtabs, cookies, base64]

proc parseHook*(s: string, i: var int, v: var int) =
  var str: string
  parseHook(s, i, str)
  v = parseInt(str)

proc parseHook*(s: string, i: var int, v: var bool) =
  var str: string
  parseHook(s, i, str)
  v = true

proc respondHtml*(request: Request, value: string) =
  request.respond(200, @[("Content-Type", "text/html")], value)
proc cookies(request: Request): StringTableRef = request.headers["Cookie"].parseCookies

proc link(url: string): string =
  when defined(release): "/250" & url else: url

type
  Round = object
    bidder*: string
    wager*: int
    partners*: seq[string]
    bidderWon*: bool
  TwoFifty = object
    players*: seq[string]
    rounds*: seq[Round]

proc pointsWon*(round: Round, player: string): int =
  var multiplier = 0
  if round.bidderWon:
    if round.bidder == player: multiplier = 2
    elif player in round.partners: multiplier = 1
  else:
    if round.bidder == player: multiplier = -1
    elif player notin round.partners: multiplier = 1
  return multiplier * round.wager

type TwoFiftyHandler = proc(request: Request, twoFifty: var TwoFifty) {.gcsafe.}
proc toHandler(wrapped: TwoFiftyHandler): RequestHandler =
  return proc(request: Request) =
    var twoFifty = request.cookies["game"].decode.uncompress.fromFlatty(TwoFifty)
    wrapped(request, twoFifty)

proc updateAndRedirect(request: Request, twoFifty: TwoFifty) =
  let cookie = setCookie("game", twoFifty.toFlatty().compress.encode, path = "/", noName = true)
  request.respond(303, @[("Set-Cookie", cookie), ("Location", link "/game")])

template page(inner): untyped = render:
  say "<!DOCTYPE html>"
  html:
    head:
      meta: charset "utf-8"; name "viewport"; content "width=device-width, initial-scale=1"
      link: rel "stylesheet"; href "https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css"
      script: src "https://unpkg.com/htmx.org@1.9.2/dist/htmx.js"
      script: src "https://unpkg.com/htmx.org/dist/ext/json-enc.js"
      title: say "250"
    body:
      hxBoost "true"; hxTarget "body"; hxPushUrl "true"; hxExt "json-enc"
      main ".container":
        h1: say "250 Score Tracker"
        inner

proc form(round: Round, players: seq[string], id: int) =
  article:
    h4: say &"Round {id+1}"
    label: say "Bidder"
    select:
      name "bidder"
      for player in players: option: selected player == round.bidder; say player
    label: say "Points wagered"
    input: ttype "number"; name "wager"; value $round.wager; step "5"; min "120"; max "250"
    for i, partner in round.partners:
      label: say &"Partner {i+1}"
      select:
        name "partners"
        if i >= 1: option: value ""; say "None"
        for player in players:
          option: selected player == partner; say player
    fieldset: label:
      input: ttype "checkbox"; name "bidderWon"; checked round.bidderWon
      say "Did the bidder win?"

proc createRoundHandler(request: Request, twoFifty: var TwoFifty) =
  twoFifty.rounds.add(request.body.fromJson(Round))
  request.updateAndRedirect(twoFifty)

proc updateRoundHandler(request: Request, twoFifty: var TwoFifty) =
  let id = request.pathParams["id"].parseInt
  twoFifty.rounds[id] = request.body.fromJson(Round)
  request.updateAndRedirect(twoFifty)

proc deleteRoundHandler(request: Request, twoFifty: var TwoFifty) =
  twoFifty.rounds.delete(request.pathParams["id"].parseInt)
  request.updateAndRedirect(twoFifty)

proc editRoundHandler*(request: Request, twoFifty: var TwoFifty) =
  let id = request.pathParams["id"].parseInt
  let resp = page:
    p: a ".secondary": href link "/game"; role "button"; say "Go back to game"
    h3: say "Update round"
    form:
      hxPut link &"/game/rounds/{id}"
      twoFifty.rounds[id].form(twoFifty.players, id)
      button: ttype "submit"; say "Save round"
    button ".secondary": hxDelete link &"/game/rounds/{id}"; say "Delete round"
  request.respondHtml(resp)

proc newGameHandler*(request: Request) =
  let playerCount = request.queryParams.getOrDefault("number", "5").parseInt()
  let resp = page:
    if "game" in request.cookies:
      p: a ".secondary": href link("/game"); role "button"; say "Resume last game"
    form:
      hxPost link "/game"
      label: say "Number of players"
      select:
        name "number"; hxSelect "#players"; hxTarget "#players"; hxSwap "outerHTML"; hxGet "."
        option: say "5"
        option: say "7"
      tdiv("#players"):
        for i in 1..playerCount:
          label: say &"Player {i}"
          input: ttype "text"; name "players"; required ""; placeholder "Player name"
      button: ttype "submit"; say "Start game"
  request.respondHtml(resp)

proc createGameHandler(request: Request) =
  request.updateAndRedirect(request.body.fromJson(TwoFifty))

proc showGameHandler(request: Request, twoFifty: var TwoFifty) =
  let resp = page:
    form:
      hxPost link "/game/rounds"
      Round(partners: @["", ""], wager: 120).form(twoFifty.players, twoFifty.rounds.len)
      button: ttype "submit"; say "Add round"
    h4: say "Results"
    table:
      thead: tr:
        th: say "Round"
        for player in twoFifty.players: th: say player
      tbody:
        for i, round in twoFifty.rounds:
          tr:
            td: a: href link &"/game/rounds/{i}"; say &"Round {i+1}"
            for player in twoFifty.players:
              td: say round.pointsWon(player)
      tfoot: tr:
        td: say "Sum"
        for player in twoFifty.players:
          var total = 0
          for round in twoFifty.rounds:
            total += round.pointsWon(player)
          td: say total
    a ".secondary": href link "/"; role "button"; say "Start a new game"
  request.respondHtml(resp)

var router: Router
router.get("/", newGameHandler)
router.post("/game", createGameHandler)
router.get("/game", showGameHandler.toHandler())
router.post("/game/rounds", createRoundHandler.toHandler())
router.get("/game/rounds/@id", editRoundHandler.toHandler())
router.put("/game/rounds/@id", updateRoundHandler.toHandler())
router.delete("/game/rounds/@id", deleteRoundHandler.toHandler())

let server = newServer(router)
echo "Serving on http://localhost:8080"
server.serve(Port(8080))
