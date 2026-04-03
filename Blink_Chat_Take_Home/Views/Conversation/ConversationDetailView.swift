//
//  ConversationDetailView.swift
//  Blink_Chat_Take_Home
//
//  Created by Christian Grise on 4/2/26.
//

import SwiftUI
import SwiftData

struct ConversationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ConversationDetailViewModel?
    
    let conversation: Conversation
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel?.sortedMessages ?? []) { message in
                        MessageRowView(message: message)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listRowBackground(Color.clear)
                            .id(message.id)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .onChange(of: viewModel?.sortedMessages.count) { oldValue, newValue in
                    // Scroll to bottom when new message is added
                    if let lastMessage = viewModel?.sortedMessages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    // Scroll to bottom on initial load
                    if let lastMessage = viewModel?.sortedMessages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            Divider()
            
            // Reply section
            if let viewModel = viewModel {
                ReplyView(viewModel: viewModel)
            }
        }
        .navigationTitle(conversation.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = ConversationDetailViewModel(
                    conversation: conversation,
                    modelContext: modelContext
                )
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Conversation.self, Message.self, configurations: config)
    let context = container.mainContext
    
    let conversation = Conversation(id: "1", name: "Test Chat", lastUpdated: Date())
    context.insert(conversation)
    
    let message1 = Message(id: "1", text: "Hello there!", lastUpdated: Date().addingTimeInterval(-3600))
    message1.conversation = conversation
    context.insert(message1)
    
    let message2 = Message(id: "2", text: "How are you doing today?", lastUpdated: Date())
    message2.conversation = conversation
    context.insert(message2)
    
    return NavigationStack {
        ConversationDetailView(conversation: conversation)
    }
    .modelContainer(container)
}
