import Foundation

enum GameMode {
    case normal
    case tieBreak
}

enum MatchProgress {
    case continueGame
    case gameEnded
    case setEnded(matchEnded: Bool)
}

func applyPoint(current: GameScore, scoringTeam: Int, deuceRule: DeuceRule) -> (GameScore, gameEnded: Bool, winner: Int?) {
    var score = current
    let opponentIndex = scoringTeam == 0 ? 1 : 0

    let scoringValue = scoringTeam == 0 ? score.team1 : score.team2
    let opponentValue = opponentIndex == 0 ? score.team1 : score.team2

    // Golden point: 40-40 next point wins.
    if deuceRule == .goldenPoint && scoringValue == .forty && opponentValue == .forty {
        return (score, true, scoringTeam)
    }

    // Advantage rule: if opponent has advantage and scorer wins, back to deuce.
    if deuceRule == .advantage {
        if opponentValue == .advantage {
            if scoringTeam == 0 {
                score.team1 = .forty
                score.team2 = .forty
            } else {
                score.team1 = .forty
                score.team2 = .forty
            }
            return (score, false, nil)
        }
    }

    // If scorer is at 40 and opponent < 40, winning point ends game.
    if scoringValue == .forty && opponentValue.rawValue < PointValue.forty.rawValue {
        return (score, true, scoringTeam)
    }

    // If scorer already has advantage and wins again, game ends.
    if scoringValue == .advantage {
        return (score, true, scoringTeam)
    }

    // Normal increment.
    let nextValue: PointValue
    switch scoringValue {
    case .love: nextValue = .fifteen
    case .fifteen: nextValue = .thirty
    case .thirty: nextValue = .forty
    case .forty: nextValue = (deuceRule == .advantage && opponentValue == .forty) ? .advantage : .forty
    case .advantage: nextValue = .advantage
    }

    if scoringTeam == 0 {
        score.team1 = nextValue
    } else {
        score.team2 = nextValue
    }

    return (score, false, nil)
}

func displayScore(score: GameScore) -> (String, String) {
    return (score.team1.displayValue, score.team2.displayValue)
}
