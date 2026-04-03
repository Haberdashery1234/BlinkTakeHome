//
//  MessageModelTests.swift
//  Blink_Chat_Take_HomeTests
//
//  Created by Christian Grise on 4/2/26.
//

import Testing
import Foundation
@testable import Blink_Chat_Take_Home

@Suite("Message Model Tests")
struct MessageModelTests {
    
    @Test("Message can be created with required properties")
    func testMessageCreation() {
        let date = Date()
        let message = Message(
            id: "msg-1",
            text: "Hello, World!",
            lastUpdated: date
        )
        
        #expect(message.id == "msg-1")
        #expect(message.text == "Hello, World!")
        #expect(message.lastUpdated == date)
        #expect(message.conversation == nil)
    }
    
    @Test("Message can be associated with a conversation")
    func testMessageConversationRelationship() {
        let conversation = Conversation(
            id: "conv-1",
            name: "Test",
            lastUpdated: Date()
        )
        
        let message = Message(
            id: "msg-1",
            text: "Test message",
            lastUpdated: Date()
        )
        
        message.conversation = conversation
        
        #expect(message.conversation?.id == "conv-1")
    }
    
    // MARK: - Negative Tests
    
    @Test("Message can be created with empty text")
    func testMessageWithEmptyText() {
        let message = Message(
            id: "msg-1",
            text: "",
            lastUpdated: Date()
        )
        
        #expect(message.text.isEmpty)
        #expect(message.id == "msg-1")
    }
    
    @Test("Message can contain only whitespace")
    func testMessageWithWhitespaceText() {
        let message = Message(
            id: "msg-1",
            text: "   \n\t   ",
            lastUpdated: Date()
        )
        
        #expect(message.text == "   \n\t   ")
    }
    
    @Test("Message can have very long text")
    func testMessageWithVeryLongText() {
        let longText = String(repeating: "A", count: 50000)
        let message = Message(
            id: "msg-1",
            text: longText,
            lastUpdated: Date()
        )
        
        #expect(message.text.count == 50000)
    }
    
    @Test("Message can have special characters")
    func testMessageWithSpecialCharacters() {
        let message = Message(
            id: "msg-1",
            text: "!@#$%^&*()_+-=[]{}|;':\",./<>?",
            lastUpdated: Date()
        )
        
        #expect(message.text == "!@#$%^&*()_+-=[]{}|;':\",./<>?")
    }
    
    @Test("Message can have emoji and unicode")
    func testMessageWithUnicode() {
        let message = Message(
            id: "msg-1",
            text: "Hello 👋 世界 🌍",
            lastUpdated: Date()
        )
        
        #expect(message.text == "Hello 👋 世界 🌍")
    }
    
    @Test("Message can be reassigned to different conversation")
    func testMessageReassignedToNewConversation() {
        let conv1 = Conversation(id: "conv-1", name: "Chat 1", lastUpdated: Date())
        let conv2 = Conversation(id: "conv-2", name: "Chat 2", lastUpdated: Date())
        
        let message = Message(id: "msg-1", text: "Test", lastUpdated: Date())
        
        message.conversation = conv1
        #expect(message.conversation?.id == "conv-1")
        #expect(conv1.messages.count == 1)
        
        message.conversation = conv2
        #expect(message.conversation?.id == "conv-2")
        #expect(conv2.messages.count == 1)
        #expect(conv1.messages.isEmpty)
    }
    
    @Test("Message conversation can be set to nil")
    func testMessageConversationCanBeNil() {
        let conversation = Conversation(id: "conv-1", name: "Test", lastUpdated: Date())
        let message = Message(id: "msg-1", text: "Test", lastUpdated: Date())
        
        message.conversation = conversation
        #expect(message.conversation != nil)
        
        message.conversation = nil
        #expect(message.conversation == nil)
    }
    
    @Test("Message with newlines and formatting")
    func testMessageWithNewlinesAndFormatting() {
        let message = Message(
            id: "msg-1",
            text: "Line 1\nLine 2\nLine 3\tTabbed",
            lastUpdated: Date()
        )
        
        #expect(message.text == "Line 1\nLine 2\nLine 3\tTabbed")
        #expect(message.text.contains("\n"))
        #expect(message.text.contains("\t"))
    }
}
