import unittest, game
let SAMPLE_ROUND = Round(bidder: "me", wager: 150, partners: @["notme", "you"], bidderWon: true)

suite "round when bidder wins":
  test "checks points":
    check SAMPLE_ROUND.pointsWon("me") == 300
    check SAMPLE_ROUND.pointsWon("notme") == 150
    check SAMPLE_ROUND.pointsWon("other player") == 0

suite "round when bidder loses":
  var bidderLostRound = SAMPLE_ROUND
  bidderLostRound.bidderWon = false
  test "checks points":
    check bidderLostRound.pointsWon("me") == -150
    check bidderLostRound.pointsWon("notme") == 0
    check bidderLostRound.pointsWon("other player") == 150

suite "other":
  test "ensures unknown players for a round are ignored":
    let round = Round(bidder: "me", wager: 120, partners: @["not me", ""], bidderWon: true)
    check Game(rounds: @[round]).totalPointsWon("me") == 240
