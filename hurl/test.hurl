GET http://localhost:8080
HTTP 200

[Asserts]
xpath "string(//head/title)" == "250"
xpath "string(//label[1])" contains "Number of players"
xpath "//input" count == 5

GET http://localhost:8080
[QueryStringParams]
num: 7
HTTP 200

[Asserts]
xpath "//input" count == 7

POST http://localhost:8080/game
[Options]
location: true 
variable: bidders=//label[contains(text(), 'Bidder')]/following-sibling::select[1]/option

[FormParams]
num: 5
player1: me
player2: you
player3: them
player4: who
player5: eh

HTTP 200

[Captures]
bidderOptions: xpath "string({{bidders}})"

[Asserts]
xpath "{{bidders}}" count == 5
xpath "string({{bidders}}[1])" == "me"
xpath "string({{bidders}}[2])" == "you"
xpath "string({{bidders}}[3])" == "them"
xpath "string({{bidders}}[4])" == "who"
xpath "string({{bidders}}[5])" == "eh"

xpath "//label[contains(text(), 'Points')]" exists
xpath "//label[contains(text(), 'Partner 1')]/following-sibling::select[1]/option" count == 5
xpath "//label[contains(text(), 'Partner 2')]/following-sibling::select[1]/option" count == 5
xpath "//label[contains(text(), 'Partner 3')]/following-sibling::select[1]/option" count == 5
xpath "//label[contains(text(), 'Did the bidder win?')]" exists

