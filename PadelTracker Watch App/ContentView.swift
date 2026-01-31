//
//  ContentView.swift
//  PadelTracker Watch App
//
//  Created by teamdev on 31/01/2026.
//

import SwiftUI

enum Route: Hashable {
    case config
    case game
    case setSummary
    case matchSummary
}

struct ContentView: View {
    @StateObject private var historyStore = HistoryStore()
    @StateObject private var matchState = MatchState()
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            HistoryView(
                historyStore: historyStore,
                onNewMatch: { path = [.config] }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .config:
                    MatchConfigView { config in
                        matchState.startMatch(config: config)
                        path = [.game]
                    }
                case .game:
                    GameView(
                        matchState: matchState,
                        onGameEnded: { path = [.setSummary] },
                        onSetEnded: { path = [.matchSummary] },
                        onMatchEnded: {
                            historyStore.add(item: matchState.makeHistoryItem())
                            path = [.matchSummary]
                        }
                    )
                case .setSummary:
                    SetSummaryView(
                        matchState: matchState,
                        onStartGame: {
                            matchState.startNewGame()
                            path = [.game]
                        }
                    )
                case .matchSummary:
                    MatchSummaryView(
                        matchState: matchState,
                        onStartNextSet: {
                            matchState.startNewGame()
                            path = [.game]
                        },
                        onFinishMatch: {
                            path = []
                        }
                    )
                }
            }
        }
        .environmentObject(historyStore)
        .background(
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.12, blue: 0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
