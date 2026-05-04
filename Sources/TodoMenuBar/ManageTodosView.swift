import SwiftUI

struct ManageTodosView: View {
    @EnvironmentObject var store: TodoStore
    @State private var selection: Todo.ID?
    @State private var showingAdd = false
    @State private var editing: Todo?

    var body: some View {
        VStack(spacing: 0) {
            List(selection: $selection) {
                ForEach(store.todos) { todo in
                    HStack(spacing: 10) {
                        Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(todo.isDone ? Color.accentColor : .secondary)
                            .onTapGesture { store.toggle(todo) }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(todo.title)
                                .strikethrough(todo.isDone)
                                .foregroundStyle(todo.isDone ? .secondary : .primary)
                            Text(formatted(todo.createdAt))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 2)
                    .tag(todo.id)
                    .contextMenu {
                        Button(todo.isDone ? "완료 해제" : "완료") { store.toggle(todo) }
                        Button("편집") { editing = todo }
                        Divider()
                        Button("삭제", role: .destructive) { store.remove(todo) }
                    }
                }
                .onMove { store.move(from: $0, to: $1) }
            }
            .listStyle(.inset)

            Divider()

            HStack(spacing: 8) {
                Button { showingAdd = true } label: {
                    Image(systemName: "plus")
                        .frame(width: 20, height: 20)
                }
                .help("추가")

                Button {
                    if let id = selection,
                       let todo = store.todos.first(where: { $0.id == id }) {
                        store.remove(todo)
                        selection = nil
                    }
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 20, height: 20)
                }
                .disabled(selection == nil)
                .help("삭제")

                Button {
                    if let id = selection,
                       let todo = store.todos.first(where: { $0.id == id }) {
                        editing = todo
                    }
                } label: {
                    Image(systemName: "pencil")
                        .frame(width: 20, height: 20)
                }
                .disabled(selection == nil)
                .help("편집")

                Divider()
                    .frame(height: 16)

                Button {
                    store.clearCompleted()
                } label: {
                    Image(systemName: "trash")
                        .frame(width: 20, height: 20)
                }
                .disabled(!store.hasCompleted)
                .help("완료 항목 삭제")

                Spacer()
                Text("드래그로 순서 변경")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .padding(8)
        }
        .navigationTitle("할 일 관리")
        .frame(minWidth: 460, minHeight: 360)
        .sheet(isPresented: $showingAdd) {
            TodoEditor(todo: nil) { title in
                store.add(title: title)
            }
        }
        .sheet(item: $editing) { todo in
            TodoEditor(todo: todo) { title in
                var updated = todo
                updated.title = title
                store.update(updated)
            }
        }
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct TodoEditor: View {
    let todo: Todo?
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(todo == nil ? "할 일 추가" : "할 일 편집")
                .font(.headline)

            Form {
                TextField("내용", text: $title, prompt: Text("예: 우유 사기"))
            }
            .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()
                Button("취소") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(todo == nil ? "추가" : "저장") {
                    onSave(title.trimmingCharacters(in: .whitespacesAndNewlines))
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(18)
        .frame(width: 380)
        .onAppear {
            if let todo {
                title = todo.title
            }
        }
    }
}
