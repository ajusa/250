import flatty, std/base64, supersnappy
type
  Round* = object
    bidder*: string
    wager*: int
    partners*: seq[string]
    bidderWon*: bool
  Game* = object
    players*: seq[string]
    rounds*: seq[Round]

proc won*(round: Round, player: string): bool =
  let tiedToBidder = player == round.bidder or player in round.partners
  if round.bidderWon: tiedToBidder else: not tiedToBidder

proc pointsWon*(round: Round, player: string): int =
  if round.bidder == player: 
    (if round.won(player): 2 else: -1) * round.wager
  elif round.won(player): round.wager
  else: 0

proc add*(game: var Game, round: Round) = 
  game.rounds.add(round)

proc update*(game: var Game, i: int, round: Round) = 
  game.rounds[i] = round

proc delete*(game: var Game, i: int) = 
  game.rounds.delete(i)

proc save*(game: Game): string = game.toFlatty().compress.encode
proc load*(save: string): Game = save.decode.uncompress.fromFlatty(Game)