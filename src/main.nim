import mummy, mummy/routers, nails/dekao_utils, paths, handlers/[game, round]

var router: Router
router.get(paths.index.route, game.new.renderWith(new))
router.post(paths.game.route, game.create)
router.get(paths.game.route, game.show.renderWith(show))
router.get(paths.round.route, round.edit.renderWith(edit))
router.delete(paths.round.route, round.delete.gameUpdater)
router.put(paths.round.route, round.upsert.gameUpdater)
router.post(paths.round.route, round.upsert.gameUpdater)

let server = newServer(router)
echo "Serving on http://localhost:8080"
server.serve(Port(8080))
