template mainContent*(inner): string =
  let content = render:
    say "<!DOCTYPE html>"
    html:
      head:
        meta:
          charset "utf-8"
          name "viewport"
          content "width=device-width, initial-scale=1"
        link:
          rel "stylesheet"
          href "https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css"
        script: src "https://unpkg.com/htmx.org@1.9.2/dist/htmx.js"
        script: src "https://unpkg.com/hyperscript.org@0.9.9"
        title: say "250"
        script: 
          ttype "text/hyperscript"
          say """
          def shownWhen(el, check)
            if check then show el then remove [@disabled] from <input/> in el
            else hide el then add [@disabled] to <input/> in el
            end
          end
          """
      body:
        hxBoost "true"
        hxPushUrl "true"
        hxTarget "body"
        main ".container":
          h1: say "250 Score Tracker"
          inner
  content
