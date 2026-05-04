import SwiftUI

@main
struct TodoMenuBarApp: App {
    @StateObject private var store = TodoStore()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView()
                .environmentObject(store)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "checklist")
                if store.remainingCount > 0 {
                    Text("\(store.remainingCount)")
                }
            }
        }
        .menuBarExtraStyle(.window)

        Window("할 일 관리", id: "manage") {
            ManageTodosView()
                .environmentObject(store)
        }
        .windowResizability(.contentSize)
    }
}
