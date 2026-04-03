//
//  Message.swift
//  Blink_Chat_Take_Home
//
//  Created by Christian Grise on 4/2/26.
//

import Foundation
import SwiftData

@Model
final class Message {
    @Attribute(.unique) var id: String
    var text: String
    var lastUpdated: Date
    
    var conversation: Conversation?
    
    init(id: String, text: String, lastUpdated: Date) {
        self.id = id
        self.text = text
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Decodable Support
extension Message {
    struct DecodableMessage: Decodable {
        let id: String
        let text: String
        let last_updated: String
    }
}
