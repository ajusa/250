import mummy, webby, std/[cookies, strtabs]
export strtabs, webby

proc query*(req: Request): QueryParams =
  req.uri.parseUrl.query

proc cookies*(req: Request): StringTableRef =
  req.headers["Cookie"].parseCookies

proc getOrDefault*(params: QueryParams, key, default: string): string =
  if key in params: params[key] else: default

proc redirect*(req: Request, path: string) =
  var headers: HttpHeaders
  headers["Location"] = path
  req.respond(302, headers)
