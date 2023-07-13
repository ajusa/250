import mummy, nails, ../game, strutils, sequtils, ../views/round_view
from game_controller import updateGameAndRedirect, loadGame

proc initRound(q: QueryParams): Round =
  result.bidder = q["bidder"]
  result.partners = q.toBase.filterIt(it[0] == "partners").mapIt(it[1])
  result.bidderWon = "bidderWon" in q
  result.wager = q["wager"].parseInt

proc getId(req: Request): int = req.query["id"].parseInt

template mutateGame(req: Request, body: untyped): untyped =
  var game {.inject.} = req.loadGame()
  body
  req.updateGameAndRedirect(game)

proc delete*(req: Request) = req.mutateGame:
  game.delete(req.getId())

proc update*(req: Request) = req.mutateGame:
  var round = initRound(req.body.parseSearch)
  game.update(req.getId(), round)

proc create*(req: Request) = req.mutateGame:
  var round = initRound(req.body.parseSearch)
  game.add(round)

proc edit*(req: Request): RoundView =
  var game = req.loadGame()
  RoundView(id: req.getId(), round: game.rounds[req.getId()], players: game.players)
