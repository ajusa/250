import std/[sequtils, strformat]
import mummy, nails, ../game, dekao, dekao/htmx, index, webby, ../paths

type RoundView* = object
  id*: int
  round*: Round
  players*: seq[string]

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

proc edit*(req: Request): RoundView =
  let game = req.loadGame()
  RoundView(id: req.getId(), round: game.rounds[req.getId()], players: game.players)

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

proc edit*(view: RoundView) = mainContent:
  h3: say "Edit round"
  form:
    hxPut &"{paths.round}?id={view.id}"
    view.round.form(view.players, view.id)
    button: ttype "submit"; say "Edit round"
  button ".secondary": hxDelete &"{paths.round}?id={view.id}"; say "Delete round"
