import jester, nimja, os, jsony, tables, sequtils, strutils, options, math

proc parseHook*(s: string, i: var int, v: var int) =
  try:
    var str: string
    parseHook(s, i, str)
    v = str.parseInt()
  except:
    jsony.parseHook(s, i, v)

type
  Players = array[5, string]
  Round = object
    bidder: string
    points: int
    partner1: string
    partner2: string
    bidderWon: Option[string] # if it exists, the bidder won
  Game = object
    players: Players
    rounds: seq[Round]

proc partner(p: string, r: Round): bool = p == r.partner1 or p == r.partner2
proc pointsWon(player: string, round: Round): int =
  if round.bidder == player:
    return (if round.bidderWon.isSome: round.points * 2 else: round.points * -1)
  elif player.partner(round):
    return (if round.bidderWon.isSome: round.points else: 0)
  return (if round.bidderWon.isSome: 0 else: round.points)

const templates = getScriptDir() / "templates"
proc html(content: string): string = tmplf(templates / "index.twig")

routes:
  get "/":
    resp html tmplf(templates / "player_form.twig")
  post "/game":
    var game = request.body.fromJson(Game)
    setCookie("game", game.toJson(), path="/")
    redirect "./game"
  post "/game/rounds":
    var game = request.cookies["game"].fromJson(Game)
    game.rounds.add(request.body.fromJson(Round))
    setCookie("game", game.toJson(), path="/")
    redirect "../game"
  get "/game":
    let game = request.cookies["game"].fromJson(Game)
    resp html tmplf(templates / "rounds.twig")