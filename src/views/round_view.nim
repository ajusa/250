import webby, dekao, dekao/htmx, ../mummy_utils, strformat, ../game, mummy, ../controllers/round_controller, ../paths, index, with

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

proc edit*(roundView: RoundView): string = with roundView: mainContent:
  h3: say "Edit round"
  form:
    hxPut &"{paths.round}?id={id}"
    roundForm.render()
    button:
      ttype: "submit"
      say "Edit round"
  button ".secondary":
    hxDelete &"{paths.round}?id={id}"
    say "Delete round"