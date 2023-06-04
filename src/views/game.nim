import webby, dekao, dekao/htmx, ../mummy_utils, strformat

type
  PlayerInfo* = object
    title*: string
    value*: string
    name*: string
  GameForm* = object
    num*: int
    players*: seq[PlayerInfo]

proc initGameForm*(q: QueryParams): GameForm =
  result.num = q.getOrDefault("num", "5").parseInt
  for i in 1..result.num:
    var info = PlayerInfo(title: &"Player {i}", name: &"players{i}")
    info.value = q[info.name]
    result.players.add(info)

proc render*(form: GameForm) =
  tdiv("#gameForm"):
    hxGet "./"
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
