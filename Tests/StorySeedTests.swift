import XCTest
@testable import SoloraStorySeedMac

@MainActor
final class StorySeedTests: XCTestCase {
    func testComposeUsesOnlyEnteredDetails() {
        let draft = DraftPayload(
            title: "A workshop fix", date: Date(timeIntervalSince1970: 0), category: .making,
            context: "Our workshop demo stopped loading",
            action: "I found a missing configuration file",
            outcome: "The team presented a working demo",
            learning: "I should test setup on a fresh machine"
        )
        let story = StoryComposer.compose(draft)
        XCTAssertTrue(story.contains("missing configuration file"))
        XCTAssertTrue(story.contains("working demo"))
        XCTAssertFalse(story.contains("increased revenue"))
        XCTAssertEqual(story.components(separatedBy: "\n\n").count, 4)
    }

    func testSavedMomentSurvivesRelaunchAndCanBeDeleted() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("moments.json")
        defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }

        let draft = DraftPayload(
            title: "  A small win  ", date: Date(timeIntervalSince1970: 0), category: .helping,
            context: "A friend needed help", action: "I explained the first step",
            outcome: "We made progress", learning: "Simple explanations matter"
        )
        let first = StoryStore(fileURL: fileURL)
        let saved = first.add(draft, story: StoryComposer.compose(draft))
        XCTAssertNil(first.errorMessage)

        let reopened = StoryStore(fileURL: fileURL)
        XCTAssertEqual(reopened.moments.count, 1)
        XCTAssertEqual(reopened.moments.first?.title, "A small win")
        XCTAssertEqual(reopened.moments.first?.id, saved.id)
        reopened.delete(saved.id)
        XCTAssertTrue(StoryStore(fileURL: fileURL).moments.isEmpty)
    }
}
