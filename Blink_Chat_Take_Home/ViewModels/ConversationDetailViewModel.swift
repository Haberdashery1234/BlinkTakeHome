//
//  ConversationDetailViewModel.swift
//  Blink_Chat_Take_Home
//
//  Created by Christian Grise on 4/2/26.
//

import Foundation
import SwiftData

/// ViewModel for managing a single conversation's messages
@Observable
@MainActor
final class ConversationDetailViewModel {
    private let modelContext: ModelContext
    let conversation: Conversation
    
    var newMessageText = ""
    
    init(conversation: Conversation, modelContext: ModelContext) {
        self.conversation = conversation
        self.modelContext = modelContext
    }
    
    /// Send a new message to the conversation
    func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let message = Message(
            id: UUID().uuidString,
            text: newMessageText,
            lastUpdated: Date()
        )
        
        message.conversation = conversation
        modelContext.insert(message)
        
        // Update conversation's last_updated time
        conversation.lastUpdated = Date()
        
        // Save context
        do {
            try modelContext.save()
            newMessageText = "" // Clear the text field
        } catch {
            print("Failed to save message: \(error)")
        }
    }
    
    /// Get sorted messages (oldest first)
    var sortedMessages: [Message] {
        conversation.messages.sorted { $0.lastUpdated < $1.lastUpdated }
    }
}
