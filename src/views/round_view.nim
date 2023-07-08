import with, dekao, dekao/htmx, strformat, ../game, ../paths, index

type RoundView* = object
  id*: int
  round*: Round
  players*: seq[string]

proc options(players: seq[string], value = "") =
  for player in players:
    option:
      value player
      say player
      if value == player: selected ""

proc renderForm*(roundView: RoundView) = with roundView:
  article:
    h4: say &"Round {id + 1}"
    label: say "Bidder"
    select:
      name "bidder"
      players.options(round.bidder)
    label: say "Points wagered"
    input:
      ttype "number"
      name "wager"
      value $round.wager
      step "5"
      min "120"
      max "250"
    for i in 1..2:
      label: say &"Partner {i + 1}"
      select:
        name &"partners"
        players.options()
    fieldset:
      label:
        input:
          ttype "checkbox"
          name "bidderWon"
          if round.bidderWon: checked ""
        say "Did the bidder win?"

proc edit*(roundView: RoundView): string = with roundView: mainContent:
  h3: say "Edit round"
  form:
    hxPut &"{paths.round}?id={id}"
    roundView.renderForm()
    button:
      ttype: "submit"
      say "Edit round"
  button ".secondary":
    hxDelete &"{paths.round}?id={id}"
    say "Delete round"