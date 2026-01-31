import SwiftUI

struct MatchConfigView: View {
    @State private var team1Name = "Nosotros"
    @State private var team2Name = "Ellos"
    @State private var team1Player1 = "Jugador 1"
    @State private var team1Player2 = "Jugador 2"
    @State private var team2Player1 = "Jugador 3"
    @State private var team2Player2 = "Jugador 4"
    @State private var deuceRule: DeuceRule = .advantage

    let onStart: (MatchConfig) -> Void

    var body: some View {
        Form {
            Section {
                TextField("Nombre del equipo", text: $team1Name)
                TextField("Jugador 1", text: $team1Player1)
                TextField("Jugador 2", text: $team1Player2)
            } header: {
                coloredHeader(title: "Equipo 1", color: Color.blue.opacity(0.85))
            }

            Section {
                TextField("Nombre del equipo", text: $team2Name)
                TextField("Jugador 1", text: $team2Player1)
                TextField("Jugador 2", text: $team2Player2)
            } header: {
                coloredHeader(title: "Equipo 2", color: Color.orange.opacity(0.85))
            }

            Section("Regla de 40-40") {
                Picker("Regla", selection: $deuceRule) {
                    ForEach(DeuceRule.allCases, id: \.self) { rule in
                        Text(rule.displayName)
                            .tag(rule)
                    }
                }
                .pickerStyle(.navigationLink)
            }
            .headerProminence(.increased)

            Button("Iniciar partida") {
                onStart(buildConfig())
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(!isValid)
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Nueva partida")
    }

    private var isValid: Bool {
        !team1Name.isEmpty && !team2Name.isEmpty &&
        !team1Player1.isEmpty && !team1Player2.isEmpty &&
        !team2Player1.isEmpty && !team2Player2.isEmpty
    }

    private func buildConfig() -> MatchConfig {
        let team1 = Team(name: team1Name, players: [Player(name: team1Player1), Player(name: team1Player2)])
        let team2 = Team(name: team2Name, players: [Player(name: team2Player1), Player(name: team2Player2)])
        return MatchConfig(teams: [team1, team2], deuceRule: deuceRule)
    }

    private func coloredHeader(title: String, color: Color) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
            )
    }
}
