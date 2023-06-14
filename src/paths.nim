import strutils, sugar
when defined(release):
  const BASE = "/250"
else:
  const BASE = ""

proc path*(url: string): string = BASE & url
proc route*(url: string): string = dup url: removePrefix(BASE)

const index* = path "/"
const game* = path "/game"
const round* = path "/game/rounds"