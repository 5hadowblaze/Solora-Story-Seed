#if os(iOS) && canImport(FirebaseCore)
import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

@MainActor
final class FirebaseBackup {
    private var userID: String?
    private var pending: [StoryMoment] = []
    private let status: (String) -> Void

    init(status: @escaping (String) -> Void) {
        self.status = status
    }

    func start(existing: [StoryMoment]) {
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            status("Saved on this device")
            return
        }
        if FirebaseApp.app() == nil { FirebaseApp.configure() }
        pending = existing
        if let user = Auth.auth().currentUser {
            connect(user.uid)
        } else {
            status("Saved on device · connecting backup")
            Auth.auth().signInAnonymously { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }
                    if let id = result?.user.uid {
                        self.connect(id)
                    } else {
                        self.status("Saved on device · backup unavailable")
                        if let error { NSLog("Firebase sign-in failed: %@", error.localizedDescription) }
                    }
                }
            }
        }
    }

    func save(_ moment: StoryMoment) {
        guard let userID else {
            pending.append(moment)
            return
        }
        let document = Firestore.firestore()
            .collection("users").document(userID)
            .collection("wins").document(moment.id.uuidString)
        document.getDocument { [weak self] snapshot, readError in
            guard readError == nil else {
                Task { @MainActor in self?.status("Saved on device · backup unavailable") }
                return
            }
            let done: (Error?) -> Void = { error in
                Task { @MainActor in
                    self?.status(error == nil ? "Saved on device and Firebase" : "Saved on device · backup unavailable")
                }
            }
            if snapshot?.exists == true {
                document.updateData([
                    "title": moment.title,
                    "caption": moment.story,
                    "updatedAt": FieldValue.serverTimestamp()
                ], completion: done)
            } else {
                document.setData([
                    "id": moment.id.uuidString,
                    "title": moment.title,
                    "caption": moment.story,
                    "occurredAt": Timestamp(date: moment.date),
                    "createdAt": FieldValue.serverTimestamp(),
                    "updatedAt": FieldValue.serverTimestamp(),
                    "world": "memoryShelves",
                    "schemaVersion": 1,
                    "photoPaths": []
                ], completion: done)
            }
        }
    }

    func delete(_ id: UUID) {
        pending.removeAll { $0.id == id }
        guard let userID else { return }
        Firestore.firestore()
            .collection("users").document(userID)
            .collection("wins").document(id.uuidString)
            .delete()
    }

    private func connect(_ id: String) {
        userID = id
        status("Saved on device · Firebase connected")
        let queued = pending
        pending.removeAll()
        queued.forEach(save)
    }
}
#endif
