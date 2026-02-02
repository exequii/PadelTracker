import SwiftUI

struct GameView: View {
    @ObservedObject var matchState: MatchState
    let onGameEnded: () -> Void
    let onSetEnded: () -> Void
    let onMatchEnded: () -> Void
    let onExitToHistory: () -> Void
    @State private var isMinusMode = false
    @State private var showGameEndConfirm = false
    @State private var pendingProgress: MatchProgress?
    @State private var pendingWinner: Int?
    @State private var showExitConfirm = false

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                statusBox()
                modeBox()
            }

            HStack(spacing: 6) {
                scoreButton(teamIndex: 0)
                scoreButton(teamIndex: 1)
            }
        }
        .padding(6)
        .navigationTitle("Game")
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
        .alert("¿Game terminado?", isPresented: $showGameEndConfirm) {
            Button("Confirmar") {
                handleGameEndConfirm()
            }
            Button("Cancelar", role: .cancel) {
                if let winner = pendingWinner {
                    _ = matchState.undoLastPoint(expectedTeam: winner)
                } else {
                    _ = matchState.undoLastPoint()
                }
                resetPending()
            }
        } message: {
            let winnerName = pendingWinnerName()
            Text("Ganó \(winnerName). ¿Confirmas?")
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

    private func statusBox() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.25))
            VStack(spacing: 4) {
                Text("Set \(matchState.currentSetNumber)")
                    .font(.caption)
                if let setScore = matchState.currentSetScore {
                    Text("Games \(setScore.gamesTeam1)-\(setScore.gamesTeam2)")
                        .font(.caption2)
                }
            }
            .foregroundStyle(.white)
            .padding(6)
        }
    }

    private func modeBox() -> some View {
        Button(action: {
            isMinusMode.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isMinusMode ? Color.red.opacity(0.85) : Color.green.opacity(0.85))
                Text(isMinusMode ? "Resta −" : "Suma +")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }

    private func scoreButton(teamIndex: Int) -> some View {
        Button(action: {
            if isMinusMode {
                _ = matchState.undoLastPoint(expectedTeam: teamIndex)
                return
            }

            let result = matchState.awardPoint(to: teamIndex)
            switch result.progress {
            case .continueGame:
                break
            case .gameEnded, .setEnded:
                pendingProgress = result.progress
                pendingWinner = result.winner
                showGameEndConfirm = true
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(teamIndex == 0 ? Color.blue.opacity(0.85) : Color.orange.opacity(0.85))

                VStack(spacing: 6) {
                    Text(teamName(for: teamIndex))
                        .font(.caption)
                        .multilineTextAlignment(.center)
                    Text(scoreText(for: teamIndex))
                        .font(.title2)
                        .bold()
                }
                .foregroundStyle(.white)
                .padding(8)
            }
        }
        .buttonStyle(.plain)
    }

    private func teamName(for index: Int) -> String {
        matchState.config?.teams[index].name ?? "Equipo \(index + 1)"
    }

    private func scoreText(for index: Int) -> String {
        switch matchState.gameMode {
        case .normal:
            let display = displayScore(score: matchState.currentGameScore)
            return index == 0 ? display.0 : display.1
        case .tieBreak:
            let points = index == 0 ? matchState.tieBreakPoints.0 : matchState.tieBreakPoints.1
            return "TB \(points)"
        }
    }

    private func pendingWinnerName() -> String {
        guard let winner = pendingWinner else { return "el equipo" }
        return teamName(for: winner)
    }

    private func handleGameEndConfirm() {
        guard let progress = pendingProgress else { return }
        switch progress {
        case .continueGame:
            break
        case .gameEnded:
            onGameEnded()
        case .setEnded(let matchEnded):
            if matchEnded {
                onMatchEnded()
            } else {
                onSetEnded()
            }
        }
        resetPending()
    }

    private func resetPending() {
        pendingProgress = nil
        pendingWinner = nil
    }
}
