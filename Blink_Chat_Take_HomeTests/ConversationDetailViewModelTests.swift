//
//  ConversationDetailViewModelTests.swift
//  Blink_Chat_Take_HomeTests
//
//  Created by Christian Grise on 4/2/26.
//

import Testing
import Foundation
import SwiftData
@testable import Blink_Chat_Take_Home

@Suite("ConversationDetailViewModel Tests")
struct ConversationDetailViewModelTests {
    
    @MainActor
    func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Conversation.self, Message.self,
            configurations: config
        )
        return container
    }
    
    @Test("ViewModel initializes with correct conversation")
    @MainActor
    func testViewModelInitialization() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        #expect(viewModel.conversation.id == "test-1")
        #expect(viewModel.newMessageText.isEmpty)
    }
    
    @Test("Sending message creates new message and clears text field")
    @MainActor
    func testSendMessage() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        viewModel.newMessageText = "Test message"
        viewModel.sendMessage()
        
        #expect(viewModel.newMessageText.isEmpty)
        #expect(conversation.messages.count == 1)
        #expect(conversation.messages.first?.text == "Test message")
    }
    
    @Test("Empty message is not sent")
    @MainActor
    func testEmptyMessageNotSent() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        viewModel.newMessageText = "   "
        viewModel.sendMessage()
        
        #expect(conversation.messages.isEmpty)
    }
    
    @Test("Whitespace-only message is not sent")
    @MainActor
    func testWhitespaceMessageNotSent() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        viewModel.newMessageText = "\n\t  \n"
        viewModel.sendMessage()
        
        #expect(conversation.messages.isEmpty)
    }
    
    @Test("Messages are sorted by date (oldest first)")
    @MainActor
    func testMessagesSorting() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        // Add messages in random order
        let message3 = Message(
            id: "3",
            text: "Third",
            lastUpdated: Date().addingTimeInterval(300)
        )
        let message1 = Message(
            id: "1",
            text: "First",
            lastUpdated: Date().addingTimeInterval(100)
        )
        let message2 = Message(
            id: "2",
            text: "Second",
            lastUpdated: Date().addingTimeInterval(200)
        )
        
        message3.conversation = conversation
        message1.conversation = conversation
        message2.conversation = conversation
        
        context.insert(message3)
        context.insert(message1)
        context.insert(message2)
        
        let sortedMessages = viewModel.sortedMessages
        
        #expect(sortedMessages.count == 3)
        #expect(sortedMessages[0].text == "First")
        #expect(sortedMessages[1].text == "Second")
        #expect(sortedMessages[2].text == "Third")
    }
    
    @Test("Sending message updates conversation lastUpdated")
    @MainActor
    func testSendMessageUpdatesConversationDate() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let oldDate = Date().addingTimeInterval(-3600)
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: oldDate
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        viewModel.newMessageText = "New message"
        viewModel.sendMessage()
        
        #expect(conversation.lastUpdated > oldDate)
    }
    
    // MARK: - Negative Tests
    
    @Test("Sending multiple empty messages does not create any messages")
    @MainActor
    func testMultipleEmptyMessagesSentDoNothing() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        // Try sending multiple empty messages
        viewModel.newMessageText = ""
        viewModel.sendMessage()
        #expect(conversation.messages.isEmpty)
        
        viewModel.newMessageText = "   "
        viewModel.sendMessage()
        #expect(conversation.messages.isEmpty)
        
        viewModel.newMessageText = "\t\n"
        viewModel.sendMessage()
        #expect(conversation.messages.isEmpty)
        
        // Text field retains the last invalid input (not cleared)
        #expect(viewModel.newMessageText == "\t\n")
    }
    
    @Test("Message text with only special characters is sent")
    @MainActor
    func testMessageWithOnlySpecialCharacters() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        viewModel.newMessageText = "!@#$%^&*()"
        viewModel.sendMessage()
        
        #expect(conversation.messages.count == 1)
        #expect(conversation.messages.first?.text == "!@#$%^&*()")
    }
    
    @Test("Very long message text is handled correctly")
    @MainActor
    func testVeryLongMessage() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        let longText = String(repeating: "A", count: 10000)
        viewModel.newMessageText = longText
        viewModel.sendMessage()
        
        #expect(conversation.messages.count == 1)
        #expect(conversation.messages.first?.text == longText)
        #expect(viewModel.newMessageText.isEmpty)
    }
    
    @Test("Message with newlines and tabs is preserved")
    @MainActor
    func testMessageWithMixedWhitespace() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        viewModel.newMessageText = "Line 1\nLine 2\tTabbed"
        viewModel.sendMessage()
        
        #expect(conversation.messages.count == 1)
        #expect(conversation.messages.first?.text == "Line 1\nLine 2\tTabbed")
    }
    
    @Test("Sending messages rapidly creates all messages")
    @MainActor
    func testRapidMessageSending() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        for i in 1...10 {
            viewModel.newMessageText = "Message \(i)"
            viewModel.sendMessage()
        }
        
        #expect(conversation.messages.count == 10)
        #expect(viewModel.newMessageText.isEmpty)
    }
    
    @Test("Empty conversation has empty sorted messages")
    @MainActor
    func testSortedMessagesWhenEmpty() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        let sortedMessages = viewModel.sortedMessages
        
        #expect(sortedMessages.isEmpty)
    }
    
    @Test("Messages with identical timestamps are handled")
    @MainActor
    func testMessagesWithSameTimestamp() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        let sameDate = Date()
        let message1 = Message(id: "1", text: "First", lastUpdated: sameDate)
        let message2 = Message(id: "2", text: "Second", lastUpdated: sameDate)
        let message3 = Message(id: "3", text: "Third", lastUpdated: sameDate)
        
        message1.conversation = conversation
        message2.conversation = conversation
        message3.conversation = conversation
        
        context.insert(message1)
        context.insert(message2)
        context.insert(message3)
        
        let sortedMessages = viewModel.sortedMessages
        
        // All messages should be present, order may vary due to same timestamp
        #expect(sortedMessages.count == 3)
        #expect(sortedMessages.contains(where: { $0.text == "First" }))
        #expect(sortedMessages.contains(where: { $0.text == "Second" }))
        #expect(sortedMessages.contains(where: { $0.text == "Third" }))
    }
    
    @Test("Message with emoji and unicode characters")
    @MainActor
    func testMessageWithUnicodeCharacters() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        viewModel.newMessageText = "Hello 👋 世界 🌍 مرحبا"
        viewModel.sendMessage()
        
        #expect(conversation.messages.count == 1)
        #expect(conversation.messages.first?.text == "Hello 👋 世界 🌍 مرحبا")
    }
    
    @Test("Conversation with single message sorts correctly")
    @MainActor
    func testSortingWithSingleMessage() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let conversation = Conversation(
            id: "test-1",
            name: "Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        viewModel.newMessageText = "Only message"
        viewModel.sendMessage()
        
        let sortedMessages = viewModel.sortedMessages
        
        #expect(sortedMessages.count == 1)
        #expect(sortedMessages[0].text == "Only message")
    }
}
