import Foundation

struct Player: Codable, Hashable {
    let name: String
}

struct Team: Codable, Hashable {
    let name: String
    let players: [Player]
}

enum DeuceRule: String, Codable, CaseIterable {
    case advantage
    case goldenPoint

    var displayName: String {
        switch self {
        case .advantage: return "Ventaja"
        case .goldenPoint: return "Punto de oro"
        }
    }
}

struct MatchConfig: Codable, Hashable {
    let teams: [Team]
    let deuceRule: DeuceRule
}

enum PointValue: Int, Codable {
    case love = 0
    case fifteen = 15
    case thirty = 30
    case forty = 40
    case advantage = 50

    var displayValue: String {
        switch self {
        case .love: return "0"
        case .fifteen: return "15"
        case .thirty: return "30"
        case .forty: return "40"
        case .advantage: return "AD"
        }
    }
}

struct GameScore: Codable, Hashable {
    var team1: PointValue
    var team2: PointValue
}

struct SetScore: Codable, Hashable {
    var gamesTeam1: Int
    var gamesTeam2: Int
}

struct MatchScore: Codable, Hashable {
    var setsTeam1: Int
    var setsTeam2: Int
}

struct MatchHistoryItem: Codable, Hashable, Identifiable {
    let id: UUID
    let date: Date
    let team1: Team
    let team2: Team
    let setScores: [SetScore]
    let winner: Int
}
