//
//  ConversationModelTests.swift
//  Blink_Chat_Take_HomeTests
//
//  Created by Christian Grise on 4/2/26.
//

import Testing
import Foundation
@testable import Blink_Chat_Take_Home

@Suite("Conversation Model Tests")
struct ConversationModelTests {
    
    @Test("Conversation can be created with required properties")
    func testConversationCreation() {
        let date = Date()
        let conversation = Conversation(
            id: "test-1",
            name: "Test Conversation",
            lastUpdated: date
        )
        
        #expect(conversation.id == "test-1")
        #expect(conversation.name == "Test Conversation")
        #expect(conversation.lastUpdated == date)
        #expect(conversation.messages.isEmpty)
    }
    
    @Test("Conversation can have messages added")
    func testConversationWithMessages() {
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        
        let message1 = Message(id: "msg-1", text: "Hello", lastUpdated: Date())
        let message2 = Message(id: "msg-2", text: "World", lastUpdated: Date())
        
        message1.conversation = conversation
        message2.conversation = conversation
        
        #expect(conversation.messages.count == 2)
        #expect(conversation.messages.contains(where: { $0.id == "msg-1" }))
        #expect(conversation.messages.contains(where: { $0.id == "msg-2" }))
    }
    
    // MARK: - Negative Tests
    
    @Test("Conversation can be created with empty name")
    func testConversationWithEmptyName() {
        let conversation = Conversation(
            id: "test-1",
            name: "",
            lastUpdated: Date()
        )
        
        #expect(conversation.name.isEmpty)
        #expect(conversation.id == "test-1")
    }
    
    @Test("Conversation can be created with very long name")
    func testConversationWithLongName() {
        let longName = String(repeating: "A", count: 1000)
        let conversation = Conversation(
            id: "test-1",
            name: longName,
            lastUpdated: Date()
        )
        
        #expect(conversation.name == longName)
        #expect(conversation.name.count == 1000)
    }
    
    @Test("Conversation can have special characters in name")
    func testConversationWithSpecialCharactersInName() {
        let conversation = Conversation(
            id: "test-1",
            name: "Test!@#$%^&*()_+-=[]{}|;':\",./<>?",
            lastUpdated: Date()
        )
        
        #expect(conversation.name == "Test!@#$%^&*()_+-=[]{}|;':\",./<>?")
    }
    
    @Test("Conversation can have emoji in name")
    func testConversationWithEmojiInName() {
        let conversation = Conversation(
            id: "test-1",
            name: "Team Chat 💬 🚀",
            lastUpdated: Date()
        )
        
        #expect(conversation.name == "Team Chat 💬 🚀")
    }
    
    @Test("Conversation with future date")
    func testConversationWithFutureDate() {
        let futureDate = Date().addingTimeInterval(86400 * 365) // 1 year in future
        let conversation = Conversation(
            id: "test-1",
            name: "Future Chat",
            lastUpdated: futureDate
        )
        
        #expect(conversation.lastUpdated == futureDate)
        #expect(conversation.lastUpdated > Date())
    }
    
    @Test("Conversation with very old date")
    func testConversationWithVeryOldDate() {
        let oldDate = Date(timeIntervalSince1970: 0) // January 1, 1970
        let conversation = Conversation(
            id: "test-1",
            name: "Old Chat",
            lastUpdated: oldDate
        )
        
        #expect(conversation.lastUpdated == oldDate)
    }
    
    @Test("Multiple messages can be removed from conversation")
    func testRemovingMessagesFromConversation() {
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        
        let message1 = Message(id: "msg-1", text: "Hello", lastUpdated: Date())
        let message2 = Message(id: "msg-2", text: "World", lastUpdated: Date())
        
        message1.conversation = conversation
        message2.conversation = conversation
        
        #expect(conversation.messages.count == 2)
        
        // Remove message
        message1.conversation = nil
        
        #expect(conversation.messages.count == 1)
        #expect(conversation.messages.contains(where: { $0.id == "msg-2" }))
    }
}
