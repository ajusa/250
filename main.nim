import jester, nimja, os, jsony, tables, sequtils, strutils, options

proc parseHook*(s: string, i: var int, v: var int) =
  try:
    var str: string
    parseHook(s, i, str)
    echo str
    v = str.parseInt()
  except:
    jsony.parseHook(s, i, v)

const templates = getScriptDir() / "templates"

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

proc pointsWon(round: Round, player: string): int =
  if player == round.bidder: 
    if round.bidderWon.isSome:
      result = round.points * 2
    else:
      result = -1 * round.points
  elif player == round.partner1 or player == round.partner2:
    if round.bidderWon.isSome:
      result = round.points

proc html(content: string): string =
  tmplf(templates / "index.twig")

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
    var results = initTable[string, seq[int]]()
    for player in game.players:
      results[player] = @[]
      var sum = 0
      for round in game.rounds:
        sum += round.pointsWon(player)
        results[player].add(sum)
    resp html tmplf(templates / "rounds.twig")
