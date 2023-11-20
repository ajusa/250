import dekao, dekao/vue
template mainContent*(inner): untyped = render:
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
