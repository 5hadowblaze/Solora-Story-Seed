import Foundation
import SwiftUI

@MainActor
final class StoryStore: ObservableObject {
    @Published private(set) var moments: [StoryMoment] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var backupStatus = "Saved on this device"

    private let fileURL: URL
    #if os(iOS) && canImport(FirebaseCore)
    private var backup: FirebaseBackup?
    #endif

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SoloraStorySeed", isDirectory: true)
            .appendingPathComponent("moments.json")
        load()
        #if os(iOS) && canImport(FirebaseCore)
        backup = FirebaseBackup { [weak self] message in self?.backupStatus = message }
        backup?.start(existing: moments)
        #endif
    }

    @discardableResult
    func add(_ draft: DraftPayload, story: String) -> StoryMoment {
        let moment = StoryMoment(
            id: UUID(), date: draft.date,
            title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
            category: draft.category,
            context: draft.context.trimmingCharacters(in: .whitespacesAndNewlines),
            action: draft.action.trimmingCharacters(in: .whitespacesAndNewlines),
            outcome: draft.outcome.trimmingCharacters(in: .whitespacesAndNewlines),
            learning: draft.learning.trimmingCharacters(in: .whitespacesAndNewlines),
            story: story.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        moments.insert(moment, at: 0)
        persist()
        #if os(iOS) && canImport(FirebaseCore)
        backup?.save(moment)
        #endif
        return moment
    }

    func delete(_ id: UUID) {
        moments.removeAll { $0.id == id }
        persist()
        #if os(iOS) && canImport(FirebaseCore)
        backup?.delete(id)
        #endif
    }

    func clearError() { errorMessage = nil }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            moments = try JSONDecoder().decode([StoryMoment].self, from: Data(contentsOf: fileURL))
                .sorted { $0.date > $1.date }
        } catch {
            errorMessage = "Your saved stories could not be opened. The file was left untouched."
        }
    }

    private func persist() {
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(moments).write(to: fileURL, options: .atomic)
            errorMessage = nil
        } catch {
            errorMessage = "This story is visible now, but could not be saved on this device."
        }
    }
}
