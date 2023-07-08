import mummy, ../mummy_utils, ../game, strutils, sequtils, ../views/round_view
from game_controller import updateGameAndRedirect, loadGame

proc initRound(q: QueryParams): Round =
  result.bidder = q["bidder"]
  result.partners = q.toBase.filterIt(it[0] == "partners").mapIt(it[1])
  result.bidderWon = "bidderWon" in q
  result.wager = q["wager"].parseInt

proc getId(req: Request): int = req.query["id"].parseInt

proc delete*(req: Request) =
  var game = req.loadGame()
  game.delete(req.getId())
  req.updateGameAndRedirect(game)

proc update*(req: Request) =
  var game = req.loadGame()
  var round = initRound(req.body.parseSearch)
  game.update(req.getId(), round)
  req.updateGameAndRedirect(game)

proc create*(req: Request) =
  var game = req.loadGame()
  var round = initRound(req.body.parseSearch)
  game.add(round)
  req.updateGameAndRedirect(game)

proc edit*(req: Request): RoundView =
  var game = req.loadGame()
  RoundView(id: req.getId(), round: game.rounds[req.getId()], players: game.players)