import std/[strutils, strformat, sequtils, cookies]
import mummy, ../mummy_utils, dekao, dekao/htmx, ../paths, ../game
type
  PlayerInfo* = object
    title*: string
    value*: string
    name*: string
  GameForm* = object
    num*: int
    players*: seq[PlayerInfo]
  GameDetails* = object
    game*: Game
    query*: QueryParams
  GameView* = object
    inProgress*: bool
    gameForm*: GameForm

proc initGameForm(q: QueryParams): GameForm =
  result.num = q.getOrDefault("num", "5").parseInt
  for i in 1..result.num:
    var info = PlayerInfo(title: &"Player {i}", name: &"players{i}")
    info.value = q[info.name]
    result.players.add(info)

proc updateGameAndRedirect*(req: Request, game: Game) =
  var headers: HttpHeaders
  headers["Set-Cookie"] = setCookie("game", game.save(), path = "/", noName = true)
  headers["Location"] = paths.game
  req.respond(303, headers)

proc render*(form: GameForm) =
  tdiv("#gameForm"):
    hxGet paths.index
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

proc show*(req: Request): GameDetails =
  if "game" notin req.cookies:
    req.redirect(paths.index)
  else:
    result.game = req.cookies["game"].load()
    result.query = req.query

proc new*(req: Request): GameView =
  result.inProgress = "game" in req.cookies
  result.gameForm = req.query.initGameForm()

proc create*(req: Request) =
  var game: Game
  let gameForm = req.body.parseSearch.initGameForm()
  game.players = gameForm.players.mapIt(it.value)
  req.updateGameAndRedirect(game)
