import Foundation
import SwiftUI

final class HistoryStore: ObservableObject {
    @Published private(set) var items: [MatchHistoryItem] = []

    private let storageKey = "padelTrackerHistory"

    init() {
        load()
    }

    func add(item: MatchHistoryItem) {
        items.insert(item, at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items.remove(at: index)
            save()
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([MatchHistoryItem].self, from: data) {
            items = decoded
        }
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
