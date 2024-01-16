import flatty, std/base64, supersnappy
type
  Round* = object
    bidder*: string
    wager*: int
    partners*: seq[string]
    bidderWon*: bool
  TwoFifty* = object
    players*: seq[string]
    rounds*: seq[Round]
  TwoFiftySave* = distinct string


proc initTwoFifty*(players: seq[string] = @[], rounds: seq[Round] = @[]): TwoFifty =
  result.players = players
  result.rounds = rounds

proc initTwoFifty*(save: TwoFiftySave): TwoFifty =
  string(save).decode.uncompress.fromFlatty(TwoFifty)

proc initRound*(bidder = "", wager = 120, partners: seq[string] = @[], bidderWon = false): Round =
  result.bidder = bidder
  result.wager = wager
  result.partners = partners
  result.bidderWon = bidderWon

proc pointsWon*(round: Round, player: string): int =
  var multiplier = 0
  if round.bidderWon:
    if round.bidder == player: multiplier = 2
    elif player in round.partners: multiplier = 1
  else:
    if round.bidder == player: multiplier = -1
    elif player notin round.partners: multiplier = 1
  return multiplier * round.wager

proc save*(twoFifty: TwoFifty): TwoFiftySave =
  TwoFiftySave(twoFifty.toFlatty().compress.encode)
