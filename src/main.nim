import mummy, mummy/routers, paths, handlers/[game, round]

var router: Router
router.get(paths.index.route, game.new)
router.post(paths.game.route, game.create)
router.get(paths.game.route, game.show.needsGame)
router.get(paths.round.route, round.edit)
router.delete(paths.round.route, needsGame(round.delete))
router.put(paths.round.route, round.upsert.needsGame)
router.post(paths.round.route, round.upsert.needsGame)

let server = newServer(router)
echo "Serving on http://localhost:8080"
server.serve(Port(8080))
