import SwiftUI

private enum Palette {
    static let paper = Color(red: 0.985, green: 0.967, blue: 0.935)
    static let ink = Color(red: 0.20, green: 0.21, blue: 0.23)
    static let muted = Color(red: 0.46, green: 0.43, blue: 0.41)
    static let coral = Color(red: 0.95, green: 0.38, blue: 0.29)
}

private enum Route: Hashable {
    case capture
    case draft(DraftPayload)
    case detail(UUID)
}

struct ContentView: View {
    @ObservedObject var store: StoryStore
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    hero
                    Button {
                        path.append(.capture)
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Save a moment")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.headline)
                        .padding(19)
                        .foregroundStyle(.white)
                        .background(Palette.ink, in: RoundedRectangle(cornerRadius: 18))
                    }
                    .accessibilityIdentifier("saveMomentButton")

                    lore
                }
                .frame(maxWidth: 640)
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
            }
            .background(Palette.paper.ignoresSafeArea())
            .hideNavigationBarOnPhone()
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .capture:
                    CaptureView { path.append(.draft($0)) }
                case .draft(let draft):
                    DraftView(draft: draft) { story in
                        let saved = store.add(draft, story: story)
                        path = [.detail(saved.id)]
                    }
                case .detail(let id):
                    MomentDetailView(moment: store.moments.first { $0.id == id }) {
                        store.delete(id)
                        path = []
                    }
                }
            }
            .alert("Save issue", isPresented: Binding(
                get: { store.errorMessage != nil },
                set: { if !$0 { store.clearError() } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
        .tint(Palette.coral)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SOLORA")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(Palette.coral)
                Text("Story Seed")
                    .font(.system(size: 31, weight: .semibold, design: .serif))
                    .foregroundStyle(Palette.ink)
            }
            Spacer()
            Image(systemName: "circle.hexagongrid.fill")
                .font(.title2)
                .foregroundStyle(Palette.coral)
                .padding(12)
                .background(.white.opacity(0.8), in: Circle())
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Spacer()
                StoryOrb(category: .brave, size: 130)
                Spacer()
            }
            Text("Your life becomes your lore.")
                .font(.system(size: 33, weight: .medium, design: .serif))
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Keep a small moment. Find the story in it when it matters.")
                .font(.system(size: 16))
                .foregroundStyle(Palette.muted)
            Text(store.backupStatus)
                .font(.caption)
                .foregroundStyle(Palette.muted)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [.white, Color(red: 1, green: 0.91, blue: 0.82)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 28)
        )
    }

    private var lore: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Your lore")
                    .font(.system(size: 25, weight: .medium, design: .serif))
                    .foregroundStyle(Palette.ink)
                Spacer()
                Text("\(store.moments.count) \(store.moments.count == 1 ? "moment" : "moments")")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }
            if store.moments.isEmpty {
                Text("Your first story starts with something you did today, however small.")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 20))
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(store.moments) { moment in
                        Button {
                            path.append(.detail(moment.id))
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                StoryOrb(category: moment.category, size: 85)
                                    .frame(maxWidth: .infinity)
                                Text(moment.title)
                                    .font(.system(size: 17, weight: .semibold, design: .serif))
                                    .foregroundStyle(Palette.ink)
                                    .lineLimit(2)
                                Text(moment.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(Palette.muted)
                            }
                            .padding(15)
                            .frame(maxWidth: .infinity, minHeight: 175, alignment: .topLeading)
                            .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 22))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("loreMoment_\(moment.id.uuidString)")
                    }
                }
            }
        }
    }
}

private struct StoryOrb: View {
    let category: MomentCategory
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [.white, category.tint.opacity(0.88), category.tint], center: .init(x: 0.32, y: 0.25), startRadius: 3, endRadius: size * 0.68))
            Circle()
                .strokeBorder(.white.opacity(0.8), lineWidth: 2)
            Circle()
                .fill(.white.opacity(0.42))
                .frame(width: size * 0.25, height: size * 0.12)
                .blur(radius: size * 0.035)
                .offset(x: -size * 0.22, y: -size * 0.25)
            Image(systemName: category.symbol)
                .font(.system(size: size * 0.31, weight: .light))
                .foregroundStyle(.white)
                .shadow(color: category.tint.opacity(0.7), radius: 8, y: 3)
        }
        .frame(width: size, height: size)
        .shadow(color: category.tint.opacity(0.3), radius: 15, y: 9)
        .accessibilityLabel("\(category.rawValue) memory orb")
    }
}

private struct CaptureView: View {
    let onContinue: (DraftPayload) -> Void
    @State private var title = ""
    @State private var date = Date()
    @State private var category: MomentCategory = .making
    @State private var context = ""
    @State private var action = ""
    @State private var outcome = ""
    @State private var learning = ""

    private var canContinue: Bool {
        !title.trimmed.isEmpty && !context.trimmed.isEmpty && !action.trimmed.isEmpty && !learning.trimmed.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("What happened?")
                    .font(.system(size: 32, weight: .medium, design: .serif))
                    .foregroundStyle(Palette.ink)
                Text("A tiny win, a tricky choice, or a conversation worth keeping.")
                    .foregroundStyle(Palette.muted)
                field("Give it a name", placeholder: "e.g. Helped a teammate unblock", text: $title, id: "momentTitle")
                DatePicker("When", selection: $date, displayedComponents: .date)
                    .padding(16)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16))
                VStack(alignment: .leading, spacing: 10) {
                    Text("It felt like...").font(.headline)
                    Picker("Category", selection: $category) {
                        ForEach(MomentCategory.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(16)
                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                field("The situation", placeholder: "Where were you, and what was happening?", text: $context, id: "momentContext", multiline: true)
                field("What you did", placeholder: "Describe your contribution in your own words.", text: $action, id: "momentAction", multiline: true)
                field("What changed?", placeholder: "A result or small shift, if there was one.", text: $outcome, id: "momentOutcome", multiline: true)
                field("What you learned", placeholder: "What would you remember or do again?", text: $learning, id: "momentLearning", multiline: true)
                Button("Shape my story") {
                    onContinue(DraftPayload(title: title, date: date, category: category, context: context, action: action, outcome: outcome, learning: learning))
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canContinue)
                .accessibilityIdentifier("shapeStoryButton")
            }
            .frame(maxWidth: 640)
            .padding(22)
            .frame(maxWidth: .infinity)
        }
        .background(Palette.paper.ignoresSafeArea())
        .navigationTitle("Capture")
        .inlineNavigationTitleOnPhone()
    }

    @ViewBuilder
    private func field(_ label: String, placeholder: String, text: Binding<String>, id: String, multiline: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(label).font(.headline).foregroundStyle(Palette.ink)
            if multiline {
                TextField(placeholder, text: text, axis: .vertical)
                    .lineLimit(3...6)
                    .accessibilityIdentifier(id)
            } else {
                TextField(placeholder, text: text)
                    .accessibilityIdentifier(id)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct DraftView: View {
    let draft: DraftPayload
    let onSave: (String) -> Void
    @State private var story = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Keep it in your words.")
                    .font(.system(size: 32, weight: .medium, design: .serif))
                    .foregroundStyle(Palette.ink)
                Text("This draft only arranges what you wrote. Edit anything before saving.")
                    .foregroundStyle(Palette.muted)
                TextEditor(text: $story)
                    .frame(minHeight: 260)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
                    .accessibilityIdentifier("storyEditor")
                Button("Save to my lore") { onSave(story) }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(story.trimmed.isEmpty)
                    .accessibilityIdentifier("saveStoryButton")
            }
            .frame(maxWidth: 640)
            .padding(22)
            .frame(maxWidth: .infinity)
        }
        .background(Palette.paper.ignoresSafeArea())
        .navigationTitle("Review")
        .inlineNavigationTitleOnPhone()
        .onAppear { if story.isEmpty { story = StoryComposer.compose(draft) } }
    }
}

private struct MomentDetailView: View {
    let moment: StoryMoment?
    let onDelete: () -> Void
    @State private var showingDelete = false

    var body: some View {
        ScrollView {
            if let moment {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        Spacer()
                        StoryOrb(category: moment.category, size: 125)
                        Spacer()
                    }
                    Text(moment.title)
                        .font(.system(size: 33, weight: .medium, design: .serif))
                        .foregroundStyle(Palette.ink)
                    Text("\(moment.category.rawValue) · \(moment.date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                    Text(moment.story)
                        .font(.body)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(.white, in: RoundedRectangle(cornerRadius: 20))
                        .accessibilityIdentifier("savedStory")
                    ShareLink(item: "\(moment.title)\n\n\(moment.story)") {
                        Label("Share story text", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    Button("Delete this moment", role: .destructive) { showingDelete = true }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }
                .frame(maxWidth: 640)
                .padding(22)
                .frame(maxWidth: .infinity)
            }
        }
        .background(Palette.paper.ignoresSafeArea())
        .navigationTitle("Lore")
        .inlineNavigationTitleOnPhone()
        .confirmationDialog("Delete this moment?", isPresented: $showingDelete) {
            Button("Delete moment", role: .destructive, action: onDelete)
        } message: {
            Text("This removes it from this device.")
        }
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(18)
            .background(Palette.ink.opacity(configuration.isPressed ? 0.75 : 1), in: RoundedRectangle(cornerRadius: 17))
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

private extension View {
    @ViewBuilder
    func hideNavigationBarOnPhone() -> some View {
        #if os(iOS)
        toolbar(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }

    @ViewBuilder
    func inlineNavigationTitleOnPhone() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}
