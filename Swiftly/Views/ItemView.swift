import SwiftUI

struct ItemView: View {
    @StateObject private var itemVM = ItemViewModel()

    @State private var showUpsertItemSheet = false
    @State private var itemTitle = ""
    @State private var itemDescription = ""
    @State private var selectedItem: Item?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calendar View
                CalendarView(selectedDate: $itemVM.selectedDate)
                    .padding(.bottom)

                // Items List
                VStack {
                    if itemVM.filteredItems.isEmpty {
                        Text("No items for this date")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 24) {
                                ForEach(itemVM.filteredItems) { item in
                                    SharedComponents.card {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(formattedDate(item.createdAt.dateValue()))
                                                .font(.caption)
                                                .foregroundColor(.primary.opacity(0.8))
                                            Text(item.title)
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                            Text(item.description)
                                                .font(.subheadline)
                                                .padding(.top)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedItem = item
                                        itemTitle = item.title
                                        itemDescription = item.description
                                        showUpsertItemSheet = true
                                    }
                                }
                                .onDelete(perform: deleteItems)
                            }
                            .padding(.top)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            // .navigationBarTitleDisplayMode(.inline)
            // .toolbar {
            //     ToolbarItem(placement: .principal) {
            //         Text("Biome")
            //             .font(.title3)
            //             .fontWeight(.semibold)
            //             .fontDesign(.rounded)
            //     }
            //     ToolbarItem(placement: .navigationBarTrailing) {
            //         Button(action: {
            //             selectedItem = nil
            //             itemTitle = ""
            //             itemDescription = ""
            //             showUpsertItemSheet = true
            //         }) {
            //             Image(systemName: "plus")
            //                 .fontWeight(.semibold)
            //         }
            //     }
            // }
        }
        .sheet(isPresented: $showUpsertItemSheet) {
            upsertItemSheet
        }
    }

    // Upsert Item Sheet
    private var upsertItemSheet: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $itemTitle)
                TextField("Description", text: $itemDescription)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showUpsertItemSheet = false
                        clearItemFields()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(selectedItem == nil ? "Add Item" : "Edit Item")
                        .font(.headline)
                        .fontDesign(.rounded)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(selectedItem == nil ? "Save" : "Update") {
                        if let item = selectedItem {
                            var updatedItem = item
                            updatedItem.title = itemTitle
                            updatedItem.description = itemDescription
                            itemVM.updateItem(updatedItem)
                        } else {
                            itemVM.addItem(title: itemTitle, description: itemDescription)
                        }
                        showUpsertItemSheet = false
                        clearItemFields()
                    }
                    .disabled(itemTitle.isEmpty)
                }
            }
        }
    }

    // Delete Items
    private func deleteItems(at offsets: IndexSet) {
        offsets.map { itemVM.items[$0] }.forEach { item in
            itemVM.deleteItem(item)
        }
    }

    // Helper Methods
    private func clearItemFields() {
        itemTitle = ""
        itemDescription = ""
        selectedItem = nil
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ItemView()
}
