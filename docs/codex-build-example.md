# How Codex helped on build day

At 11:00 the new repository was empty. Codex turned the single journey into a SwiftUI app with a local story store and visual Lore orbs. The first generic iPhone simulator build passed. A Mac fallback build then found that `.toolbar(.hidden, for: .navigationBar)` and `.navigationBarTitleDisplayMode(.inline)` are unavailable on macOS. Codex replaced these with platform-conditional view modifiers, rebuilt successfully, and used a fictional workshop moment to check capture → review → saved detail in the running Mac app.

That is a concrete build-and-repair loop, not an AI feature claimed inside the product. The product itself arranges only text entered by the user; it does not call an OpenAI model or fabricate a career outcome.
