import std/strformat
import mummy, mummy/routers, webby, nails
import paths
import controllers/[game_controller, round_controller]
import views/[game_view, round_view, index]

var router: Router
router.get(paths.index.route, wire(game_controller, new))
router.post(paths.game.route, wire(game_controller, create))
router.get(paths.game.route, wire(game_controller, show))
router.get(paths.round.route, wire(round_controller, edit))
router.delete(paths.round.route, wire(round_controller, delete))
router.put(paths.round.route, wire(round_controller, update))
router.post(paths.round.route, wire(round_controller, create))

let server = newServer(router)
echo &"Serving on http://localhost:8080"
server.serve(Port(8080))
