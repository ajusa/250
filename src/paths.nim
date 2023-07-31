import strutils, webby
when defined(release):
  const BASE = "/250"
else:
  const BASE = ""

proc path*(url: string): Url = parseUrl(BASE & url)
proc route*(url: Url): string =
  result = url.path
  result.removePrefix(BASE)
converter toString*(url: Url): string = $url

proc index*(): Url = path("/")
proc game*(): Url = path("/game")
proc round*(): Url = path("/game/rounds")
proc round*(id: int): Url =
  result = round()
  result.query["id"] = $id