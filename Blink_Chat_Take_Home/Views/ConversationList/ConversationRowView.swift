//
//  Untitled.swift
//  Blink_Chat_Take_Home
//
//  Created by Christian Grise on 4/3/26.
//

import SwiftUI

struct ConversationRowView: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            // Bubble icon
            Image(systemName: "person.fill")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            // Conversation details
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.name)
                    .font(.headline)
                
                HStack {
                    Text(conversation.lastUpdated, style: .date)
                    Text("•")
                    Text(conversation.lastUpdated, style: .time)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        ConversationRowView(
            conversation: Conversation(
                id: "1",
                name: "Project Discussion",
                lastUpdated: Date()
            )
        )
        
        ConversationRowView(
            conversation: Conversation(
                id: "2",
                name: "Team Meeting",
                lastUpdated: Date().addingTimeInterval(-3600)
            )
        )
        
        ConversationRowView(
            conversation: Conversation(
                id: "3",
                name: "Design Review",
                lastUpdated: Date().addingTimeInterval(-86400)
            )
        )
    }
}

