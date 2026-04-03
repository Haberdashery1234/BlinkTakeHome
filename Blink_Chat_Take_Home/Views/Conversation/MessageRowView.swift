//
//  MessageRowView.swift
//  Blink_Chat_Take_Home
//
//  Created by Christian Grise on 4/3/26.
//

import SwiftUI

struct MessageRowView: View {
    let message: Message
    
    // Messages use ID for "sender" simulation
    private var isFromUser: Bool {
        // Simple logic: even IDs are from user, odd IDs are from others
        if let idNumber = Int(message.id) {
            return idNumber % 2 == 0
        }
        return message.id.hashValue % 2 == 0
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isFromUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isFromUser ? Color.blue : Color(.systemGray5))
                    .foregroundStyle(isFromUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                Text(message.lastUpdated, format: .dateTime.hour().minute())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if !isFromUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack(spacing: 12) {
        MessageRowView(
            message: Message(
                id: "1",
                text: "Hey! How are you doing?",
                lastUpdated: Date().addingTimeInterval(-3600)
            )
        )
        
        MessageRowView(
            message: Message(
                id: "2",
                text: "I'm doing great, thanks for asking! Just working on this project.",
                lastUpdated: Date().addingTimeInterval(-3500)
            )
        )
        
        MessageRowView(
            message: Message(
                id: "3",
                text: "That's awesome!",
                lastUpdated: Date()
            )
        )
    }
    .padding()
}


