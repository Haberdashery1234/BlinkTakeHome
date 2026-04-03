//
//  Conversation.swift
//  Blink_Chat_Take_Home
//
//  Created by Christian Grise on 4/2/26.
//

import Foundation
import SwiftData

@Model
final class Conversation {
    @Attribute(.unique) var id: String
    var name: String
    var lastUpdated: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Message.conversation)
    var messages: [Message] = []
    
    init(id: String, name: String, lastUpdated: Date) {
        self.id = id
        self.name = name
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Decodable Support
extension Conversation {
    struct DecodableConversation: Decodable {
        let id: String
        let name: String
        let last_updated: String
        let messages: [Message.DecodableMessage]
    }
}
