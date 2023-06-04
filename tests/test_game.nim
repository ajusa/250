import unittest, game
let SAMPLE_ROUND = Round(bidder: "me", wager: 150, partners: @["notme", "you"], bidderWon: true)

suite "round when bidder wins":
  test "checks winner":
    check SAMPLE_ROUND.won("me")
    check SAMPLE_ROUND.won("notme")
    check not SAMPLE_ROUND.won("other player")

  test "checks points":
    check SAMPLE_ROUND.pointsWon("me") == 300
    check SAMPLE_ROUND.pointsWon("notme") == 150
    check SAMPLE_ROUND.pointsWon("other player") == 0

suite "round when bidder loses":
  var bidderLostRound = SAMPLE_ROUND
  bidderLostRound.bidderWon = false
  test "checks winner":
    check(not bidderLostRound.won("me"))
    check(not bidderLostRound.won("notme"))
    check(bidderLostRound.won("other player"))

  test "checks points":
    check bidderLostRound.pointsWon("me") == -150
    check bidderLostRound.pointsWon("notme") == 0
    check bidderLostRound.pointsWon("other player") == 150
