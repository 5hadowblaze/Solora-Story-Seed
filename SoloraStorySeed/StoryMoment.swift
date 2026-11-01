import SwiftUI

enum MomentCategory: String, CaseIterable, Codable, Hashable, Identifiable {
    case making = "Making"
    case learning = "Learning"
    case helping = "Helping"
    case brave = "Being brave"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .making: "sparkles.rectangle.stack"
        case .learning: "lightbulb"
        case .helping: "hands.sparkles"
        case .brave: "sun.max"
        }
    }

    var tint: Color {
        switch self {
        case .making: Color(red: 0.96, green: 0.46, blue: 0.30)
        case .learning: Color(red: 0.47, green: 0.57, blue: 0.84)
        case .helping: Color(red: 0.38, green: 0.72, blue: 0.62)
        case .brave: Color(red: 0.95, green: 0.69, blue: 0.27)
        }
    }
}

struct StoryMoment: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var title: String
    var category: MomentCategory
    var context: String
    var action: String
    var outcome: String
    var learning: String
    var story: String
}

struct DraftPayload: Hashable {
    var title: String
    var date: Date
    var category: MomentCategory
    var context: String
    var action: String
    var outcome: String
    var learning: String
}

enum StoryComposer {
    static func compose(_ draft: DraftPayload) -> String {
        [draft.context, draft.action, draft.outcome, draft.learning]
            .map { sentence($0) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }

    private static func sentence(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        return ".!?".contains(trimmed.last!) ? trimmed : trimmed + "."
    }
}
