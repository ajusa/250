import std/[strformat, cookies]
import mummy, nails, ../game, dekao, dekao/htmx, index, webby, ../paths

proc updateGameAndRedirect*(req: Request, game: Game) =
  let cookie = setCookie("game", game.save(), path = "/", noName = true)
  req.respond(303, @[("Set-Cookie", cookie), ("Location", $paths.game())])

proc delete*(req: Request, args: var tuple[game: Game, id: int]) =
  args.game.delete(args.id)
  req.updateGameAndRedirect(args.game)

proc update*(req: Request, args: var tuple[game: Game, id: int, round: Round]) =
  args.game.update(args.id, args.round)
  req.updateGameAndRedirect(args.game)

proc create*(req: Request, args: var tuple[game: Game, round: Round]) =
  args.game.add(args.round)
  req.updateGameAndRedirect(args.game)

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
    label: say "Partner 1"
    select: 
      name &"partners"
      players.options(round.partners[0])
    label: say "Partner 2"
    select: 
      name &"partners"
      option:
        value: ""
        say "None"
      players.options(round.partners[1])
    fieldset:
      label:
        input:
          ttype "checkbox"
          name "bidderWon"
          if round.bidderWon: checked ""
          say "Did the bidder win?"

proc edit*(req: Request, args: tuple[game: Game, id: int]) =
  let resp = mainContent:
    p: a ".secondary": href paths.game(); role "button"; say "Go back to game"
    h3: say "Update round"
    form:
      hxPut paths.round(args.id)
      args.game.rounds[args.id].form(args.game.players, args.id)
      button: ttype "submit"; say "Save round"
    button ".secondary": hxDelete paths.round(args.id); say "Delete round"
  req.respond(resp)
