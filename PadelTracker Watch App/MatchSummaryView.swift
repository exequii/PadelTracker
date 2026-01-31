import SwiftUI

struct MatchSummaryView: View {
    @ObservedObject var matchState: MatchState
    let onStartNextSet: () -> Void
    let onFinishMatch: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text("Sets")
                .font(.headline)

            Text("\(teamName(0)): \(matchState.matchScore.setsTeam1)")
                .font(.caption2)
            Text("\(teamName(1)): \(matchState.matchScore.setsTeam2)")
                .font(.caption2)

            if isMatchOver {
                Text("Ganador: \(winnerName)")
                    .font(.title3)
                    .padding(.top, 4)
                Button("Volver al historial") {
                    onFinishMatch()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            } else {
                Button(startSetTitle) {
                    onStartNextSet()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding(8)
        .navigationTitle("Resumen")
    }

    private var isMatchOver: Bool {
        matchState.matchScore.setsTeam1 == 2 || matchState.matchScore.setsTeam2 == 2
    }

    private var winnerName: String {
        matchState.matchScore.setsTeam1 > matchState.matchScore.setsTeam2 ? teamName(0) : teamName(1)
    }

    private var startSetTitle: String {
        let nextSet = matchState.currentSetNumber
        return "INICIAR \(nextSet)º SET"
    }

    private func teamName(_ index: Int) -> String {
        matchState.config?.teams[index].name ?? "Equipo \(index + 1)"
    }
}
