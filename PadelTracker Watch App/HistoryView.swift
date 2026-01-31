import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyStore: HistoryStore
    let onNewMatch: () -> Void
    @State private var pendingDelete: MatchHistoryItem?
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(spacing: 8) {
            if historyStore.items.isEmpty {
                Text("Sin partidos")
                    .font(.headline)
                    .padding(.top, 6)
            } else {
                List {
                    ForEach(historyStore.items) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(item.team1.name) vs \(item.team2.name)")
                                .font(.headline)
                            Text(setScoreLine(for: item.setScores))
                                .font(.caption2)
                            Text(item.winner == 0 ? "Ganador: \(item.team1.name)" : "Ganador: \(item.team2.name)")
                                .font(.caption2)
                        }
                    }
                    .onDelete { offsets in
                        if let index = offsets.first {
                            pendingDelete = historyStore.items[index]
                            showDeleteConfirm = true
                        }
                    }
                }
            }

            Button("Nueva partida") {
                onNewMatch()
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .padding(.horizontal, 6)
        .navigationTitle("Historial")
        .alert("Eliminar partido", isPresented: $showDeleteConfirm, presenting: pendingDelete) { item in
            Button("Eliminar", role: .destructive) {
                historyStore.delete(id: item.id)
            }
            Button("Cancelar", role: .cancel) {}
        } message: { _ in
            Text("¿Seguro que quieres eliminar este partido?")
        }
    }

    private func setScoreLine(for sets: [SetScore]) -> String {
        return sets.map { "\($0.gamesTeam1)-\($0.gamesTeam2)" }.joined(separator: ", ")
    }
}
