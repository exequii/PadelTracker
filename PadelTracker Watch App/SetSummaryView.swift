import SwiftUI

struct SetSummaryView: View {
    @ObservedObject var matchState: MatchState
    let onStartGame: () -> Void
    let onExitToHistory: () -> Void
    @State private var showExitConfirm = false

    var body: some View {
        VStack(spacing: 8) {
            Text("Set \(matchState.currentSetNumber)")
                .font(.headline)

            if let setScore = matchState.currentSetScore {
                HStack(spacing: 8) {
                    scoreBox(
                        color: Color.blue.opacity(0.85),
                        teamName: teamName(for: 0),
                        games: setScore.gamesTeam1
                    )
                    scoreBox(
                        color: Color.orange.opacity(0.85),
                        teamName: teamName(for: 1),
                        games: setScore.gamesTeam2
                    )
                }
            }

            Button("INICIAR GAME") {
                onStartGame()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding(8)
        .navigationTitle("Resumen")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    showExitConfirm = true
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .alert("Volver al historial", isPresented: $showExitConfirm) {
            Button("Volver", role: .destructive) {
                onExitToHistory()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Perderás el partido en curso. ¿Continuar?")
        }
    }

    private func scoreBox(color: Color, teamName: String, games: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
            VStack(spacing: 4) {
                Text(teamName)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                Text("\(games)")
                    .font(.title2)
                    .bold()
            }
            .foregroundStyle(.white)
            .padding(6)
        }
        .frame(maxWidth: .infinity, minHeight: 64)
    }

    private func teamName(for index: Int) -> String {
        matchState.config?.teams[index].name ?? "Equipo \(index + 1)"
    }
}
