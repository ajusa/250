import dekao, dekao/vue, dekao/htmx, mummy, webby, strtabs, cookies, ../twofifty, ../route
export dekao, vue, htmx

proc respondHtml*(request: Request, content: string) =
  request.respond(200, @[("Content-Type", "text/html")], content)

proc url*(request: Request): Url =
  request.uri.parseUrl

proc params*(request: Request): QueryParams =
  request.body.parseSearch

proc cookies*(request: Request): StringTableRef =
  request.headers["Cookie"].parseCookies

proc cookie(twoFifty: TwoFifty): string =
  setCookie("game", string(twoFifty.save()), path = "/", noName = true)

proc updateAndRedirect*(request: Request, twoFifty: TwoFifty) =
  request.respond(303, @[("Set-Cookie", twoFifty.cookie), ("Location", route.game.link)])

proc twoFifty*(request: Request): TwoFifty =
  request.cookies["game"].TwoFiftySave.initTwoFifty()

template page*(inner): untyped = render:
  say "<!DOCTYPE html>"
  html:
    head:
      meta: charset "utf-8"; name "viewport"; content "width=device-width, initial-scale=1"
      link: rel "stylesheet"; href "https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css"
      script: src "https://unpkg.com/htmx.org@1.9.2/dist/htmx.js"
      script: src "https://unpkg.com/petite-vue"; tDefer(); init()
      title: say "250"
    body:
      hxBoost "true"
      hxTarget "body"
      hxPushUrl "true"
      main ".container":
        h1: say "250 Score Tracker"
        inner
