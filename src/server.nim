import mummy, mummy/routers, route, dekao
import handler/[game, round]


var router: Router
router.get(route.index.pattern, newGameHandler)
router.post(route.game.pattern, createGameHandler)
router.get(route.game.pattern, showGameHandler)
router.post(route.rounds.pattern, createRoundHandler)
router.get(route.rounds.pattern, editRoundHandler)
router.put(route.rounds.pattern, updateRoundHandler)
router.delete(route.rounds.pattern, deleteRoundHandler)

let server = newServer(router)
echo "Serving on http://localhost:8080"
server.serve(Port(8080))
