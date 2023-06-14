import webby, dekao, dekao/htmx, ../mummy_utils, strformat, round, ../paths, ../game, sequtils, math

type
  PlayerInfo* = object
    title*: string
    value*: string
    name*: string
  GameForm* = object
    num*: int
    players*: seq[PlayerInfo]

type GameDetails* = object
  game*: Game
  query*: QueryParams

proc render*(gameDetails: GameDetails) =
  form:
    hxPost paths.round
    initRoundForm(gameDetails.game, gameDetails.query).render()
    button:
      ttype: "submit"
      say "Add round"
  h4: say "Results"
  table:
    role "grid"
    thead:
      tr:
        th: say "Round"
        for player in gameDetails.game.players:
          th: say player
    tbody:
      for i, round in gameDetails.game.rounds:
        tr:
          td: a:
            href &"{paths.round}?id={i}"
            say &"Round {i + 1}"
          for player in gameDetails.game.players:
            td: say $round.pointsWon(player)
      tr:
        td: say "Sum"
        for player in gameDetails.game.players:
          td: say $gameDetails.game.rounds.mapIt(it.pointsWon(player)).sum
  a ".secondary":
    href paths.game
    role "button"
    say "Start a new game"


proc initGameForm*(q: QueryParams): GameForm =
  result.num = q.getOrDefault("num", "5").parseInt
  for i in 1..result.num:
    var info = PlayerInfo(title: &"Player {i}", name: &"players{i}")
    info.value = q[info.name]
    result.players.add(info)

proc render*(form: GameForm) =
  tdiv("#gameForm"):
    hxGet paths.game
    hxTrigger "change from:.dynamic"
    hxInclude "this"
    hxTarget "this"
    hxSelect "#gameForm"
    hxSwap "outerHTML"

    label: say "Number of players"
    select(".dynamic"):
      name "num"
      for n in ["5", "7"]:
        option:
          say $n
          if $form.num == n: selected ""
    for player in form.players:
      label: say player.title
      input:
        ttype "text"
        value player.value
        name player.name
        required ""
        placeholder "Player name"
