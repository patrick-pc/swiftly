//
//  MainViewModel.swift
//  Swiftly
//
//  Created by Patrick on 10/25/24.
//

import Foundation
import SwiftUI
import RevenueCat
import Combine
import Firebase
import FirebaseAuth
import FirebaseFirestore

class MainViewModel: NSObject, ObservableObject {
    @Published var currentPage: Page = .onboarding
    @Published var isPro = false
    @Published var showHalfOff = false
    @Published var errorMessage: String?

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

    @Published var logs: [Log] = []

    var filteredLogs: [Log] {
        logs.filter { log in
            Calendar.current.isDate(
                log.createdAt.dateValue(),
                inSameDayAs: selectedDate
            )
        }
    }

    private var listenerRegistration: ListenerRegistration?
    private let firebaseService = FirebaseService.shared

    override init() {
        super.init()

        fetchLogs()
    }

    deinit {
        listenerRegistration?.remove()
    }

    // Fetch Logs with Real-time Updates and Offline Support
    func fetchLogs() {
        let query = Firestore.firestore().collection("logs")
            .order(by: "createdAt", descending: true)

        // Enable offline data persistence
        let settings = Firestore.firestore().settings
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings

        listenerRegistration = query.addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching logs: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No logs found.")
                return
            }

            // Map documents to Log model
            self?.logs = documents.compactMap { document in
                try? document.data(as: Log.self)
            }
        }
    }

    // Add Item
    func addItem(title: String, description: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let collectionRef = Firestore.firestore().collection("logs")
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
        let documentRef = Firestore.firestore().collection("logs").document(item.id)
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
        let documentRef = Firestore.firestore().collection("logs").document(item.id)
        Task {
            do {
                try await documentRef.delete()
            } catch {
                print("Error deleting item: \(error.localizedDescription)")
            }
        }
    }

    func refreshCustomerInfo() {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.checkSubscriptionStatus(customerInfo: customerInfo)
                }
            }
        }
    }

    func checkSubscriptionStatus(customerInfo: CustomerInfo?) {
        isPro = customerInfo?.entitlements["Pro"]?.isActive == true
    }

    // Add Log
    func addLog(
        type: String,
        note: String,
        data: LogData
    ) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let collectionRef = Firestore.firestore().collection("logs")
        let documentRef = collectionRef.document()
        let logId = documentRef.documentID

        let newLog = Log(
            id: logId,
            userId: userId,
            type: type,
            createdAt: Timestamp(date: Date()),
            note: note,
            data: data
        )

        Task {
            do {
                try await documentRef.setData(from: newLog)
            } catch {
                print("Error adding log: \(error.localizedDescription)")
            }
        }
    }

    func updateLog(
        id: String,
        type: String,
        note: String,
        data: LogData
    ) {
        let documentRef = Firestore.firestore().collection("logs").document(id)
        
        // Only update the fields we want to change
        let updateData: [String: Any] = [
            "note": note,
            "data": try? Firestore.Encoder().encode(data)
        ]
        
        Task {
            do {
                try await documentRef.updateData(updateData)
            } catch {
                print("Error updating log: \(error.localizedDescription)")
            }
        }
    }
}

extension MainViewModel: PurchasesDelegate {
    func purchases(_: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        DispatchQueue.main.async {
            self.checkSubscriptionStatus(customerInfo: customerInfo)
        }
    }
}
