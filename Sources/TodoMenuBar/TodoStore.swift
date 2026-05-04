import Foundation

@MainActor
final class TodoStore: ObservableObject {
    @Published private(set) var todos: [Todo] = []

    private let fileURL: URL

    init() {
        let fm = FileManager.default
        let base = (try? fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? fm.homeDirectoryForCurrentUser
        let dir = base.appendingPathComponent("TodoMenuBar", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("todos.json")
        load()
    }

    var remainingCount: Int {
        todos.filter { !$0.isDone }.count
    }

    var hasCompleted: Bool {
        todos.contains { $0.isDone }
    }

    private func load() {
        guard
            let data = try? Data(contentsOf: fileURL),
            let decoded = try? JSONDecoder().decode([Todo].self, from: data)
        else { return }
        todos = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(todos) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func add(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        todos.append(Todo(title: trimmed))
        save()
    }

    func update(_ todo: Todo) {
        guard let idx = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[idx] = todo
        save()
    }

    func toggle(_ todo: Todo) {
        guard let idx = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[idx].isDone.toggle()
        save()
    }

    func remove(_ todo: Todo) {
        todos.removeAll { $0.id == todo.id }
        save()
    }

    func remove(at offsets: IndexSet) {
        todos.remove(atOffsets: offsets)
        save()
    }

    func move(from source: IndexSet, to destination: Int) {
        todos.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func clearCompleted() {
        todos.removeAll { $0.isDone }
        save()
    }
}
