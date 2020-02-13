import Foundation
import FirebaseFirestore

struct EventService {
    static func getEvents(complection: @escaping (([Event]) -> Void)) {
        Firestore.firestore().collection("event").getDocuments { (snapshot, error) in
            if let error = error {
                AlertUtils.show(title: "error in EventService", message: error.localizedDescription)
            } else {
                var result: [Event] = []
                if let snapshot = snapshot {
                    for document in snapshot.documents {
                        result.append(Event.init(map: document.data()))
                    }
                }
                complection(result)
            }
        }
    }
}
