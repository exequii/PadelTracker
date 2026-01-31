import Foundation
import SwiftUI

final class MatchState: ObservableObject {
    struct PointSnapshot {
        let gameScore: GameScore
        let tieBreakPoints: (Int, Int)
        let setScores: [SetScore]
        let matchScore: MatchScore
        let currentSetIndex: Int
        let gameMode: GameMode
        let scorer: Int
    }

    struct AwardResult {
        let progress: MatchProgress
        let winner: Int?
    }

    @Published var config: MatchConfig?
    @Published var currentGameScore: GameScore = GameScore(team1: .love, team2: .love)
    @Published var tieBreakPoints: (Int, Int) = (0, 0)
    @Published var currentSetIndex: Int = 0
    @Published var setScores: [SetScore] = []
    @Published var matchScore: MatchScore = MatchScore(setsTeam1: 0, setsTeam2: 0)
    @Published var gameMode: GameMode = .normal
    private var pointHistory: [PointSnapshot] = []

    func startMatch(config: MatchConfig) {
        self.config = config
        self.currentSetIndex = 0
        self.setScores = [SetScore(gamesTeam1: 0, gamesTeam2: 0)]
        self.matchScore = MatchScore(setsTeam1: 0, setsTeam2: 0)
        self.pointHistory = []
        startNewGame()
    }

    func startNewGame() {
        guard let setScore = currentSetScore else { return }
        if setScore.gamesTeam1 == 6 && setScore.gamesTeam2 == 6 {
            gameMode = .tieBreak
            tieBreakPoints = (0, 0)
        } else {
            gameMode = .normal
            currentGameScore = GameScore(team1: .love, team2: .love)
        }
        pointHistory = []
    }

    func awardPoint(to teamIndex: Int) -> AwardResult {
        switch gameMode {
        case .normal:
            return awardPointNormal(to: teamIndex)
        case .tieBreak:
            return awardPointTieBreak(to: teamIndex)
        }
    }

    private func awardPointNormal(to teamIndex: Int) -> AwardResult {
        guard let config = config else { return AwardResult(progress: .continueGame, winner: nil) }
        storeSnapshot(scorer: teamIndex)
        let result = applyPoint(current: currentGameScore, scoringTeam: teamIndex, deuceRule: config.deuceRule)
        currentGameScore = result.0

        guard result.gameEnded, let winner = result.winner else {
            return AwardResult(progress: .continueGame, winner: nil)
        }

        incrementGame(for: winner)

        if let setWinner = checkSetWinner() {
            recordSetWin(for: setWinner)
            let matchEnded = matchScore.setsTeam1 == 2 || matchScore.setsTeam2 == 2
            if !matchEnded {
                currentSetIndex += 1
                setScores.append(SetScore(gamesTeam1: 0, gamesTeam2: 0))
            }
            return AwardResult(progress: .setEnded(matchEnded: matchEnded), winner: winner)
        }

        return AwardResult(progress: .gameEnded, winner: winner)
    }

    private func awardPointTieBreak(to teamIndex: Int) -> AwardResult {
        storeSnapshot(scorer: teamIndex)
        if teamIndex == 0 {
            tieBreakPoints.0 += 1
        } else {
            tieBreakPoints.1 += 1
        }

        let diff = abs(tieBreakPoints.0 - tieBreakPoints.1)
        let leader = tieBreakPoints.0 > tieBreakPoints.1 ? 0 : 1
        let maxPoints = max(tieBreakPoints.0, tieBreakPoints.1)

        if maxPoints >= 7 && diff >= 2 {
            if leader == 0 {
                setScores[currentSetIndex].gamesTeam1 = 7
                setScores[currentSetIndex].gamesTeam2 = 6
            } else {
                setScores[currentSetIndex].gamesTeam1 = 6
                setScores[currentSetIndex].gamesTeam2 = 7
            }

            recordSetWin(for: leader)
            let matchEnded = matchScore.setsTeam1 == 2 || matchScore.setsTeam2 == 2
            if !matchEnded {
                currentSetIndex += 1
                setScores.append(SetScore(gamesTeam1: 0, gamesTeam2: 0))
            }
            return AwardResult(progress: .setEnded(matchEnded: matchEnded), winner: leader)
        }

        return AwardResult(progress: .continueGame, winner: nil)
    }

    private func incrementGame(for teamIndex: Int) {
        if teamIndex == 0 {
            setScores[currentSetIndex].gamesTeam1 += 1
        } else {
            setScores[currentSetIndex].gamesTeam2 += 1
        }
    }

    private func checkSetWinner() -> Int? {
        let set = setScores[currentSetIndex]
        let diff = abs(set.gamesTeam1 - set.gamesTeam2)

        if set.gamesTeam1 >= 6 || set.gamesTeam2 >= 6 {
            if diff >= 2 {
                return set.gamesTeam1 > set.gamesTeam2 ? 0 : 1
            }
        }

        if set.gamesTeam1 == 7 || set.gamesTeam2 == 7 {
            return set.gamesTeam1 > set.gamesTeam2 ? 0 : 1
        }

        return nil
    }

    private func recordSetWin(for teamIndex: Int) {
        if teamIndex == 0 {
            matchScore.setsTeam1 += 1
        } else {
            matchScore.setsTeam2 += 1
        }
    }

    var currentSetScore: SetScore? {
        guard setScores.indices.contains(currentSetIndex) else { return nil }
        return setScores[currentSetIndex]
    }

    var currentSetNumber: Int {
        return currentSetIndex + 1
    }

    func makeHistoryItem() -> MatchHistoryItem {
        let team1 = config?.teams.first ?? Team(name: "Equipo 1", players: [])
        let team2 = config?.teams.last ?? Team(name: "Equipo 2", players: [])
        let winner = matchScore.setsTeam1 > matchScore.setsTeam2 ? 0 : 1
        return MatchHistoryItem(
            id: UUID(),
            date: Date(),
            team1: team1,
            team2: team2,
            setScores: setScores,
            winner: winner
        )
    }

    func undoLastPoint(expectedTeam: Int? = nil) -> Bool {
        guard let snapshot = pointHistory.last else { return false }
        if let expectedTeam, snapshot.scorer != expectedTeam {
            return false
        }
        pointHistory.removeLast()
        currentGameScore = snapshot.gameScore
        tieBreakPoints = snapshot.tieBreakPoints
        setScores = snapshot.setScores
        matchScore = snapshot.matchScore
        currentSetIndex = snapshot.currentSetIndex
        gameMode = snapshot.gameMode
        return true
    }

    private func storeSnapshot(scorer: Int) {
        let snapshot = PointSnapshot(
            gameScore: currentGameScore,
            tieBreakPoints: tieBreakPoints,
            setScores: setScores,
            matchScore: matchScore,
            currentSetIndex: currentSetIndex,
            gameMode: gameMode,
            scorer: scorer
        )
        pointHistory.append(snapshot)
    }
}
