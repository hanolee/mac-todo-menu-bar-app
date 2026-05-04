import SwiftUI
import AppKit

struct MenuContentView: View {
    @EnvironmentObject var store: TodoStore
    @Environment(\.openWindow) private var openWindow
    @State private var newTitle: String = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Divider()

            quickAdd

            Divider()

            if store.todos.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "checklist")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("할 일이 없습니다")
                        .foregroundStyle(.secondary)
                    Text("위에서 추가하세요")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(store.todos) { todo in
                            TodoRow(todo: todo)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 360)
            }

            Divider()

            footer
        }
        .frame(width: 320)
    }

    private var header: some View {
        HStack {
            Image(systemName: "checklist")
            Text("할 일")
                .font(.headline)
            Spacer()
            Text("\(store.remainingCount) / \(store.todos.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var quickAdd: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus.circle")
                .foregroundStyle(.secondary)
            TextField("새 할 일 추가", text: $newTitle)
                .textFieldStyle(.plain)
                .focused($inputFocused)
                .onSubmit(submit)
            if !newTitle.isEmpty {
                Button(action: submit) {
                    Image(systemName: "return")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func submit() {
        store.add(title: newTitle)
        newTitle = ""
        inputFocused = true
    }

    private var footer: some View {
        VStack(spacing: 0) {
            if store.hasCompleted {
                MenuButton(systemImage: "trash", title: "완료 항목 삭제") {
                    store.clearCompleted()
                }
            }
            MenuButton(systemImage: "slider.horizontal.3", title: "할 일 관리...") {
                openWindow(id: "manage")
                NSApp.activate(ignoringOtherApps: true)
            }
            MenuButton(systemImage: "power", title: "종료", shortcut: "Q") {
                NSApp.terminate(nil)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct TodoRow: View {
    let todo: Todo
    @EnvironmentObject var store: TodoStore
    @State private var hovering = false
    @State private var isEditing = false
    @State private var draft: String = ""
    @FocusState private var editFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Button(action: { store.toggle(todo) }) {
                Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.isDone ? Color.accentColor : .secondary)
                    .font(.body)
            }
            .buttonStyle(.plain)

            if isEditing {
                TextField("", text: $draft)
                    .textFieldStyle(.plain)
                    .focused($editFocused)
                    .onSubmit(commitEdit)
                    .onExitCommand(perform: cancelEdit)
                    .onChange(of: editFocused) { focused in
                        if !focused { commitEdit() }
                    }
            } else {
                Text(todo.title)
                    .strikethrough(todo.isDone)
                    .foregroundStyle(todo.isDone ? .secondary : .primary)
                    .lineLimit(2)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: beginEdit)
            }

            Spacer(minLength: 0)

            if hovering && !isEditing {
                Button(action: { store.remove(todo) }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("삭제")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(hovering ? Color.accentColor.opacity(0.12) : .clear)
                .padding(.horizontal, 4)
        )
        .onHover { hovering = $0 }
    }

    private func beginEdit() {
        draft = todo.title
        isEditing = true
        DispatchQueue.main.async { editFocused = true }
    }

    private func commitEdit() {
        guard isEditing else { return }
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        isEditing = false
        guard !trimmed.isEmpty, trimmed != todo.title else { return }
        var updated = todo
        updated.title = trimmed
        store.update(updated)
    }

    private func cancelEdit() {
        isEditing = false
        draft = todo.title
    }
}

private struct MenuButton: View {
    let systemImage: String
    let title: String
    var shortcut: String? = nil
    let action: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .frame(width: 16)
                    .foregroundStyle(.secondary)
                Text(title)
                Spacer()
                if let shortcut {
                    Text("⌘\(shortcut)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(hovering ? Color.accentColor.opacity(0.18) : .clear)
                    .padding(.horizontal, 4)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}
