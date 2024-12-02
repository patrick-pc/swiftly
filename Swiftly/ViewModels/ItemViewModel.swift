// ItemViewModel.swift

import Combine
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

class ItemViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var selectedDate: Date = .init()

    var filteredItems: [Item] {
        items.filter { item in
            Calendar.current.isDate(
                item.createdAt.dateValue(),

                inSameDayAs: selectedDate
            )
        }
    }

    private var listenerRegistration: ListenerRegistration?
    private let firebaseService = FirebaseService.shared

    init() {
        fetchItems()
    }

    deinit {
        listenerRegistration?.remove()
    }

    // Fetch Items with Real-time Updates and Offline Support
    func fetchItems() {
        let query = Firestore.firestore().collection("items")
            .order(by: "createdAt", descending: true)

        // Enable offline data persistence
        let settings = Firestore.firestore().settings
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings

        listenerRegistration = query.addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching items: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No items found.")
                return
            }

            // Map documents to Item model
            self?.items = documents.compactMap { document in
                try? document.data(as: Item.self)
            }
        }
    }

    // Add Item
    func addItem(title: String, description: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let collectionRef = Firestore.firestore().collection("items")
        let documentRef = collectionRef.document() // Create a new document reference
        let itemId = documentRef.documentID // Get the document ID

        let newItem = Item(
            id: itemId, // Set the item's id to the document ID
            userId: userId,
            title: title,
            description: description,
            createdAt: Timestamp(date: Date())
        )

        Task {
            do {
                try await documentRef.setData(from: newItem)
            } catch {
                print("Error adding item: \(error.localizedDescription)")
            }
        }
    }

    // Update Item
    func updateItem(_ item: Item) {
        let documentRef = Firestore.firestore().collection("items").document(item.id)
        Task {
            do {
                try await documentRef.setData(from: item, merge: true)
            } catch {
                print("Error updating item: \(error.localizedDescription)")
            }
        }
    }

    // Delete Item
    func deleteItem(_ item: Item) {
        let documentRef = Firestore.firestore().collection("items").document(item.id)
        Task {
            do {
                try await documentRef.delete()
            } catch {
                print("Error deleting item: \(error.localizedDescription)")
            }
        }
    }
}
