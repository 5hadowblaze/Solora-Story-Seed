# Solora Story Seed

**Your life becomes your lore.** A small, private SwiftUI app for keeping a moment and turning it into a career story you can revisit or share.

Built on **1 November 2026** at the DevDay Exchange Community Hackathon in London.

## One complete journey

1. Tap **Save a moment** and describe the situation, your contribution, the result, and what you learned.
2. Review an editable story assembled only from your own words.
3. Save it as a visual orb in **Your lore**.
4. Open it later and share its text through the system share sheet.

The result field is optional. The app does not invent an outcome when none was entered. Stories are stored on the device first. On iOS, an optional Firebase backup signs in anonymously and writes to a user-scoped Firestore path when configured and available.

## Run it

You need Xcode 27.2, the iOS simulator runtime or a connected iPhone, and [XcodeGen](https://github.com/yonaskolb/XcodeGen). The app targets iOS 17 or later. For the fastest offline setup:

```sh
xcodegen -s project.local.yml
open SoloraStorySeedLocal.xcodeproj
```

Choose the **SoloraStorySeed** scheme and run it. This version stores moments only on the device. The project also has a **SoloraStorySeedMac** scheme for trying the same journey on macOS while an iOS runtime is unavailable.

### Optional Firebase backup

The Firebase Apple SDK is resolved by Swift Package Manager for the iOS target when using `project.yml`. To enable backup in your own Firebase project:

1. Register an iOS app with bundle ID `com.amirdzakwan.solora.storyseed` (or change the bundle ID in `project.yml` first).
2. Enable **Anonymous** sign-in in Firebase Authentication.
3. Create a Cloud Firestore database and apply owner-scoped rules for `users/{userId}/wins/{momentId}`. A standalone example is in [`firebase/firestore.rules`](firebase/firestore.rules). If your project already has rules, merge the nested match instead of replacing them.
4. Place the downloaded `GoogleService-Info.plist` in `SoloraStorySeed/`, run `xcodegen -s project.yml`, and open `SoloraStorySeed.xcodeproj`.

The plist is ignored by Git. Do not put service-account credentials or OpenAI API keys in the app. Firebase backup is best-effort; the on-device copy remains the source of truth for this demo.

## Checks

```sh
xcodebuild -project SoloraStorySeedLocal.xcodeproj -scheme SoloraStorySeed \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project SoloraStorySeedLocal.xcodeproj -scheme SoloraStorySeedMac \
  -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO test
```

The demo uses fictional workshop content. Do not put real career notes or personal images in a public screen recording.

## What was made today and what was credited

This repository was empty at the 11:00 build start. Today's work includes the SwiftUI capture, review, Lore and share journey; local JSON persistence; optional Firebase backup; tests; and demo material. The broader Solora idea and tagline existed before the event in a separate, private Solora repository. No code, template, screenshot, photo, or visual asset from that repository was copied into this entry. The visual orbs are drawn with SwiftUI and use Apple SF Symbols. Firebase Apple SDK and XcodeGen are third-party tools used under their own licences.

**Concrete Codex example:** Codex built the first SwiftUI journey, compiled both targets, caught macOS-only failures from iOS navigation modifiers, fixed them with conditional modifiers, and exercised capture → review → saved detail using fictional input. See [`docs/codex-build-example.md`](docs/codex-build-example.md).

## Privacy

This app has no analytics or public profiles. The story text stays in app storage unless the user explicitly shares it, or configures Firebase backup. Anonymous Firebase sign-in is tied to the app install, so cloud content is not recoverable after reinstall in this hackathon version. Deleting a story removes its local copy and requests deletion of its Firebase copy when connected.
