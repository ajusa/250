import webby
when defined(release):
  const BASE = "/250"
else:
  const BASE = ""

type Route = object
  base: string
  pattern*: string

proc link*(route: Route, params: openArray[(string, string)] = []): string =
  route.base & route.pattern & "?" & $QueryParams(@params)

proc initRoute*(base: string, pattern: string): Route =
  result.base = base
  result.pattern = pattern

const index* = initRoute(BASE, "/")
const game* = initRoute(BASE, "/game")
const rounds* = initRoute(BASE, "/game/rounds")