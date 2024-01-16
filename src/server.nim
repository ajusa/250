import mummy, mummy/routers, route, dekao
import handler/[game, round]
# handlers/[game, round]
# import nails


var router: Router
router.get(route.index.pattern, newGameHandler)
router.post(route.game.pattern, createGameHandler)
router.get(route.game.pattern, showGameHandler)
router.post(route.rounds.pattern, createRoundHandler)
router.get(route.rounds.pattern, editRoundHandler)
router.put(route.rounds.pattern, updateRoundHandler)
router.delete(route.rounds.pattern, deleteRoundHandler)

# router.post(paths.game().route, fillArgs(game.create))
# router.get(paths.game().route, fillArgs(game.show))
# router.get(paths.round().route, fillArgs(round.edit))
# router.delete(paths.round().route, fillArgs(round.delete))
# router.put(paths.round().route, fillArgs(round.update))
# router.post(paths.round().route, fillArgs(round.create))

let server = newServer(router)
echo "Serving on http://localhost:8080"
server.serve(Port(8080))
