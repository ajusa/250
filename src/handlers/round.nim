import std/[sequtils, strformat, cookies]
import mummy, nails, ../game, dekao, dekao/htmx, index, webby, ../paths

proc updateGameAndRedirect*(req: Request, game: Game) =
  let cookie = setCookie("game", game.save(), path = "/", noName = true)
  req.respond(303, @[("Set-Cookie", cookie), ("Location", paths.game)])

proc loadGame*(req: Request): Game = req.cookies["game"].load()

proc getId(req: Request): int = req.query["id"].parseInt

proc delete*(req: Request, game: var Game) =
  game.delete(req.getId())

proc upsert*(req: Request, game: var Game) =
  let q = req.body.parseSearch
  var round = Round(bidder: q["bidder"],
                    partners: q.toBase.filterIt(it[0] == "partners").mapIt(it[1]),
                    bidderWon: "bidderWon" in q,
                    wager: q["wager"].parseInt)
  if "id" in req.query: game.update(req.getId(), round)
  else: game.add(round)
  req.updateGameAndRedirect(game)

proc options(players: seq[string], value = "") =
  for player in players:
    option: (value player; say player; if value == player: selected "")

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
    for i in 0..1:
      label: say &"Partner {i + 1}"
      select: name &"partners"; players.options(round.partners[i])
    fieldset:
      label:
        input:
          ttype "checkbox"
          name "bidderWon"
          if round.bidderWon: checked ""
          say "Did the bidder win?"

proc edit*(req: Request) =
  let game = req.loadGame()
  var id = req.getId()
  let resp = mainContent:
    h3: say "Edit round"
    form:
      hxPut &"{paths.round}?id={id}"
      game.rounds[id].form(game.players, id)
      button: ttype "submit"; say "Edit round"
  button ".secondary": hxDelete &"{paths.round}?id={id}"; say "Delete round"
  req.respond(resp)
