import mummy, ../mummy_utils, ../game, strutils, strformat
from game_controller import updateGameAndRedirect

type RoundForm* = object
  game*: Game
  title*: string
  wager*: int
  bidder*: string
  partners*: seq[string]
  bidderWon*: bool

type RoundView* = object
  roundForm*: RoundForm
  id*: int

proc initRoundForm*(game: Game, q: QueryParams): RoundForm =
  result.game = game
  result.title = &"Round {result.game.rounds.len + 1}"
  result.wager = q.getOrDefault("wager", "120").parseInt
  result.bidder = q["bidder"]
  result.bidderWon = "bidderWon" in q
  for i in 0..1:
    result.partners.add(q[&"partner{i}"])

proc initRoundForm*(game: Game, id: int): RoundForm =
  let round = game.rounds[id]
  result.game = game
  result.title = &"Round {id + 1}"
  result.wager = round.wager
  result.bidder = round.bidder
  result.bidderWon = round.bidderWon
  result.partners = round.partners

proc toRound(roundForm: RoundForm): Round =
  result.bidder = roundForm.bidder
  result.partners = roundForm.partners
  result.bidderWon = roundForm.bidderWon
  result.wager = roundForm.wager

proc delete*(req: Request) =
  var game = req.cookies["game"].load()
  game.delete(req.query["id"].parseInt)
  req.updateGameAndRedirect(game)

proc update*(req: Request) =
  var game = req.cookies["game"].load()
  var round = game.initRoundForm(req.body.parseSearch).toRound()
  game.update(req.query["id"].parseInt, round)
  req.updateGameAndRedirect(game)

proc create*(req: Request) =
  var game = req.cookies["game"].load()
  var round = game.initRoundForm(req.body.parseSearch).toRound()
  game.add(round)
  req.updateGameAndRedirect(game)

proc edit*(req: Request): RoundView =
  var game = req.cookies["game"].load()
  let id = req.query["id"].parseInt
  result.roundForm = initRoundForm(game, id)
  result.id = id