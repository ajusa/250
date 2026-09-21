import mummy, webby, flatty, supersnappy
import std/[strutils, strtabs, base64, cookies]

type
  Round* = object
    bidder*: string
    wager*: int
    partners*: seq[string]
    bidderWon*: bool
  TwoFifty* = object
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

proc totalPointsWon*(twoFifty: TwoFifty, player: string): int =
  for round in twoFifty.rounds: result += round.pointsWon(player)

proc selected(e: bool): string =
  if e: "selected" else: ""
proc checked(e: bool): string =
  if e: "checked" else: ""

proc toTwoFifty(params: QueryParams): TwoFifty =
  for (k, v) in params:
    if k == "players": result.players.add(v)

proc toRound(params: QueryParams): Round =
  for (k, v) in params:
    case k
    of "bidder": result.bidder = v
    of "wager":
      try: result.wager = v.parseInt
      except ValueError: discard
    of "partners": result.partners.add(v)
    of "bidderWon": result.bidderWon = true

const htmlHeaders: HttpHeaders = @[("Content-Type", "text/html; charset=utf-8")]

proc gameHeaders(game: TwoFifty): HttpHeaders =
  result = htmlHeaders
  result["Location"] = "/?action=game"
  result["Set-Cookie"] = "game=" & game.toFlatty.compress.encode & "; Path=/"

include "index.html"

proc route(request: Request): (int, HttpHeaders, string) {.gcsafe.} =
  var params = request.body.parseSearch
  params &= request.queryParams
  let isPost = request.httpMethod == "POST"
  let action = params["action"]
  let count = try: params["number"].parseInt except: 5
  let resume = request.headers["Cookie"].len > 0

  if request.path != "/": return (404, htmlHeaders, "Not found")

  if not isPost and action == "":
    return (200, htmlHeaders, render(newGame(count, resume)))

  if isPost and action == "create":
    if "X-Up-Validate" in request.headers:
      return (200, htmlHeaders, render(newGame(count, resume)))
    return (302, gameHeaders(params.toTwoFifty), "")

  var game = request.headers["Cookie"].parseCookies["game"].decode.uncompress.fromFlatty(TwoFifty)
  let id = try: params["id"].parseInt except: -1

  if not isPost and action == "game":
    return (200, htmlHeaders, render(showGame(game)))

  if isPost and action == "add":
    game.rounds.add(params.toRound)
    return (302, gameHeaders(game), "")

  if not isPost and action == "edit":
    return (200, htmlHeaders, render(editRound(id, game)))

  if isPost and action == "update":
    game.rounds[id] = params.toRound
    return (302, gameHeaders(game), "")

  if isPost and action == "delete":
    game.rounds.delete(id)
    return (302, gameHeaders(game), "")

  return (404, htmlHeaders, "Not found")

proc handle(request: Request) {.gcsafe.} =
  let (code, headers, body) = route(request)
  request.respond(code, headers, body)

when isMainModule:
  echo "Serving on http://localhost:8080"
  newServer(handle).serve(Port(8080))
