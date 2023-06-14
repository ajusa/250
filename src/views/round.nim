import webby, dekao, dekao/htmx, ../mummy_utils, strformat, ../game, mummy

type RoundForm* = object
  game*: Game
  title*: string
  wager*: int
  bidder*: string
  partners*: seq[string]
  bidderWon*: bool

proc initRoundForm*(game: Game, q: QueryParams): RoundForm =
  result.game = game
  result.title = &"Round {result.game.rounds.len + 1}"
  result.wager = q.getOrDefault("wager", "120").parseInt
  result.bidder = q["bidder"]
  result.bidderWon = "bidderWon" in q
  for i in 1..2:
    result.partners.add(q[&"partner{i}"])

proc toRound*(roundForm: RoundForm): Round =
  result.bidder = roundForm.bidder
  result.partners = roundForm.partners
  result.bidderWon = roundForm.bidderWon
  result.wager = roundForm.wager

proc playerOptions(game: Game, value = "") =
  for player in game.players:
    option:
      value player
      say player
      if value == player: selected ""

proc render*(roundForm: RoundForm) =
  article:
    h4: say roundForm.title
    label: say "Bidder"
    select:
      name "bidder"
      roundForm.game.playerOptions(roundForm.bidder)
    label: say "Points wagered"
    input:
      ttype "number"
      name "wager"
      value $roundForm.wager
      step "5"
      min "120"
      max "250"
    for i, partner in roundForm.partners:
      label: say &"Partner {i + 1}"
      select:
        name &"partner{i}"
        roundForm.game.playerOptions(partner)
    fieldset:
      label:
        input:
          ttype "checkbox"
          name "bidderWon"
          if roundForm.bidderWon: checked ""
        say "Did the bidder win?"
