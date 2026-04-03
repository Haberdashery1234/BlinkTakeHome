//
//  ReplyView.swift
//  Blink_Chat_Take_Home
//
//  Created by Christian Grise on 4/3/26.
//

import SwiftUI
import SwiftData

struct ReplyView: View {
    @Bindable var viewModel: ConversationDetailViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $viewModel.newMessageText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)
                .focused($isTextFieldFocused)
                .onSubmit {
                    sendMessage()
                }
            
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(canSend ? .blue : .gray)
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }
    
    private var canSend: Bool {
        !viewModel.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func sendMessage() {
        viewModel.sendMessage()
        isTextFieldFocused = true
    }
}
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Conversation.self, Message.self, configurations: config)
    let context = container.mainContext
    
    let conversation = Conversation(id: "1", name: "Preview Chat", lastUpdated: Date())
    context.insert(conversation)
    
    let viewModel = ConversationDetailViewModel(
        conversation: conversation,
        modelContext: context
    )
    
    return ReplyView(viewModel: viewModel)
        .modelContainer(container)
}

