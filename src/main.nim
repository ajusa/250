import flatty, supersnappy
import std/[strutils, base64]
import ../../rody/src/rody

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

proc hasGame(): bool = request.cookies("game").len > 0

proc updateAndRedirect(twoFifty: TwoFifty) =
  rody.setCookie("game", twoFifty.toFlatty().compress.encode)
  redirect("/game")

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

include "index.html"

let handler = route:
  at "/":
    get: resp render(newGame())
  at "/create-game":
    post:
      if "X-Up-Validate" in request.headers:
        resp render(newGame())
      else:
        updateAndRedirect(params().toTwoFifty)
  at "/game":
    var twoFifty = request.cookies("game").decode.uncompress.fromFlatty(TwoFifty)
    get:
      resp render(showGame(twoFifty))
    at "/rounds":
      post:
        twoFifty.rounds.add(params().toRound)
        updateAndRedirect(twoFifty)
      at(int):
        let id = it
        get:
          if id >= 0 and id < twoFifty.rounds.len:
            resp render(editRound(id, twoFifty))
          else:
            redirect "/game"
        at "/update": post:
          twoFifty.rounds[id] = params().toRound
          updateAndRedirect(twoFifty)
        at "/delete": post:
          twoFifty.rounds.delete(id)
          updateAndRedirect(twoFifty)

when isMainModule:
  let server = newServer(handler)
  echo "Serving on http://localhost:8080"
  server.serve(Port(8080))
