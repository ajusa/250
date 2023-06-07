const BASE = ""
proc path(url: string): string = BASE & url
const index* = path "/"
const game* = path "/game"
const round* = path "/game/rounds"