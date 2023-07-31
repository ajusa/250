import mummy, mummy/routers, paths, handlers/[game, round]
import nails

var router: Router
router.get(paths.index().route, fillArgs(game.new))
router.post(paths.game().route, fillArgs(game.create))
router.get(paths.game().route, fillArgs(game.show))
router.get(paths.round().route, fillArgs(round.edit))
router.delete(paths.round().route, fillArgs(round.delete))
router.put(paths.round().route, fillArgs(round.update))
router.post(paths.round().route, fillArgs(round.create))

let server = newServer(router)
echo "Serving on http://localhost:8080"
server.serve(Port(8080))
