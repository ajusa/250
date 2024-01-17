import strformat, common, mummy, webby, ../twofifty, ../route

proc options(players: seq[string], value = "") =
  for player in players:
    option:
      if value == player: selected ""
      value player
      say player

proc form*(round: Round, players: seq[string], id: int) =
  article:
    h4: say &"Round {id + 1}"
    label: say "Bidder"
    select: name "bidder"; players.options(round.bidder)
    label: say "Points wagered"
    input:
      ttype "number"
      name "wager"
      value $round.wager
      step "5"
      min "120"
      max "250"
    for i, partner in round.partners:
      label: say &"Partner {i + 1}"
      select:
        name "partners"
        if i != 0: option: value ""; say "None"
        players.options(value = partner)
    fieldset:
      label:
        input:
          ttype "checkbox"
          name "bidderWon"
          if round.bidderWon: checked ""
          say "Did the bidder win?"

proc initRound(params: QueryParams): Round =
  result.bidder = params["bidder"]
  result.wager = params["wager"].parseInt
  result.bidderWon = "bidderWon" in params
  for (k, v) in params:
    if k == "partners": result.partners.add(v)

proc createRoundHandler*(request: Request) =
  var twoFifty = request.twoFifty()
  twoFifty.rounds.add(request.params.initRound())
  request.updateAndRedirect(twoFifty)

proc updateRoundHandler*(request: Request) =
  var twoFifty = request.twoFifty()
  let id = parseInt(request.params["id"])
  twoFifty.rounds[id] = request.params.initRound()
  request.updateAndRedirect(twoFifty)

proc deleteRoundHandler*(request: Request) =
  var twoFifty = request.twoFifty()
  twoFifty.rounds.delete(request.params["id"].parseInt)
  request.updateAndRedirect(twoFifty)

proc editRoundHandler*(request: Request) =
  var twoFifty = request.twoFifty()
  let id = parseInt(request.params["id"])
  let resp = page:
    p: a ".secondary": href route.game.link; role "button"; say "Go back to game"
    h3: say "Update round"
    form:
      hxPut route.rounds.link({"id": $id})
      twoFifty.rounds[id].form(twoFifty.players, id)
      button: ttype "submit"; say "Save round"
    button ".secondary": hxDelete route.rounds.link({"id": $id}); say "Delete round"
  request.respondHtml(resp)