import strformat, strtabs, mummy, common, round, ../route, ../twofifty

proc gameForm() =
  tdiv:
    vScope "{players: 5}"
    label: say "Number of players"
    select:
      vModel "players"
      name "num"
      option: say "5"
      option: say "7"
    for i in 1..7:
      tdiv:
        if i == 6 or i == 7: vIf "Number(players) == 7"
        label: say &"Player {i}"
        input: ttype "text"; name "players"; required ""; placeholder "Player name"

proc newGameHandler*(request: Request) =
  let resp = page:
    if "game" in request.cookies:
      p: a ".secondary": href route.game.link; role "button"; say "Resume last game"
    form:
      hxPost route.game.link
      gameForm()
      button: ttype "submit"; say "Start game"
  request.respondHtml(resp)

proc createGameHandler*(request: Request) =
  var players: seq[string]
  for (k, v) in request.params:
    if k == "players": players.add(v)
  request.updateAndRedirect(initTwoFifty(players))

proc showGameHandler*(request: Request) =
  let twoFifty = request.twoFifty()
  let resp = page:
    form:
      hxPost route.rounds.link
      initRound(partners = @["", ""]).form(twoFifty.players, twoFifty.rounds.len)
      button: ttype "submit"; say "Add round"
    h4: say "Results"
    table:
      role "grid"
      thead: tr:
        th: say "Round"
        for player in twoFifty.players: th: say player
      tbody:
        for i, round in twoFifty.rounds: 
          tr:
            td: 
              a: href route.rounds.link({"id": $i}); say &"Round {i + 1}"
            for player in twoFifty.players: 
              td: say round.pointsWon(player)
        tr:
          td: say "Sum"
          for player in twoFifty.players: 
            var total = 0
            for round in twoFifty.rounds:
              total += round.pointsWon(player)
            td: say total
    a ".secondary": href route.index.link; role "button"; say "Start a new game"
  request.respondHtml(resp)
