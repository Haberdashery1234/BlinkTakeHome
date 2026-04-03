//
//  IntegrationTests.swift
//  Blink_Chat_Take_HomeTests
//
//  Created by Christian Grise on 4/2/26.
//

import Testing
import Foundation
import SwiftData
@testable import Blink_Chat_Take_Home

@Suite("Integration Tests")
struct IntegrationTests {
    
    @MainActor
    func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Conversation.self, Message.self,
            configurations: config
        )
        return container
    }
    
    @Test("Complete flow: Create conversation, add messages, sort correctly")
    @MainActor
    func testCompleteConversationFlow() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        
        // Create conversation
        let conversation = Conversation(
            id: "test-1",
            name: "Integration Test Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        // Add messages
        let message1 = Message(
            id: "1",
            text: "First message",
            lastUpdated: Date().addingTimeInterval(-200)
        )
        let message2 = Message(
            id: "2",
            text: "Second message",
            lastUpdated: Date().addingTimeInterval(-100)
        )
        
        message1.conversation = conversation
        message2.conversation = conversation
        context.insert(message1)
        context.insert(message2)
        
        // Create view model and send new message
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        viewModel.newMessageText = "Third message"
        viewModel.sendMessage()
        
        // Verify results
        let sortedMessages = viewModel.sortedMessages
        
        #expect(sortedMessages.count == 3)
        #expect(sortedMessages[0].text == "First message")
        #expect(sortedMessages[1].text == "Second message")
        #expect(sortedMessages[2].text == "Third message")
        #expect(viewModel.newMessageText.isEmpty)
    }
    
    @Test("Multiple conversations remain independent")
    @MainActor
    func testMultipleConversationsIndependence() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        
        let conv1 = Conversation(id: "1", name: "Chat 1", lastUpdated: Date())
        let conv2 = Conversation(id: "2", name: "Chat 2", lastUpdated: Date())
        
        context.insert(conv1)
        context.insert(conv2)
        
        let msg1 = Message(id: "1", text: "Message for conv1", lastUpdated: Date())
        let msg2 = Message(id: "2", text: "Message for conv2", lastUpdated: Date())
        
        msg1.conversation = conv1
        msg2.conversation = conv2
        
        context.insert(msg1)
        context.insert(msg2)
        
        #expect(conv1.messages.count == 1)
        #expect(conv2.messages.count == 1)
        #expect(conv1.messages.first?.text == "Message for conv1")
        #expect(conv2.messages.first?.text == "Message for conv2")
    }
    
    // MARK: - Negative Integration Tests
    
    @Test("Empty conversation list can be handled")
    @MainActor
    func testEmptyConversationList() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        
        let descriptor = FetchDescriptor<Conversation>()
        let conversations = try context.fetch(descriptor)
        
        #expect(conversations.isEmpty)
    }
    
    @Test("Conversation with no messages can use ViewModel")
    @MainActor
    func testViewModelWithEmptyConversation() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        
        let conversation = Conversation(
            id: "test-1",
            name: "Empty Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        #expect(viewModel.sortedMessages.isEmpty)
        #expect(viewModel.newMessageText.isEmpty)
    }
    
    @Test("Large number of conversations can be created")
    @MainActor
    func testManyConversations() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        
        for i in 1...100 {
            let conv = Conversation(
                id: "conv-\(i)",
                name: "Chat \(i)",
                lastUpdated: Date().addingTimeInterval(Double(i))
            )
            context.insert(conv)
        }
        
        let descriptor = FetchDescriptor<Conversation>()
        let conversations = try context.fetch(descriptor)
        
        #expect(conversations.count == 100)
    }
    
    @Test("Large number of messages in single conversation")
    @MainActor
    func testConversationWithManyMessages() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        
        let conversation = Conversation(
            id: "test-1",
            name: "Busy Chat",
            lastUpdated: Date()
        )
        context.insert(conversation)
        
        for i in 1...500 {
            let message = Message(
                id: "msg-\(i)",
                text: "Message \(i)",
                lastUpdated: Date().addingTimeInterval(Double(i))
            )
            message.conversation = conversation
            context.insert(message)
        }
        
        #expect(conversation.messages.count == 500)
        
        let viewModel = ConversationDetailViewModel(
            conversation: conversation,
            modelContext: context
        )
        
        let sortedMessages = viewModel.sortedMessages
        #expect(sortedMessages.count == 500)
        #expect(sortedMessages.first?.text == "Message 1")
        #expect(sortedMessages.last?.text == "Message 500")
    }
    
    @Test("Moving message between conversations")
    @MainActor
    func testMovingMessageBetweenConversations() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        
        let conv1 = Conversation(id: "1", name: "Chat 1", lastUpdated: Date())
        let conv2 = Conversation(id: "2", name: "Chat 2", lastUpdated: Date())
        
        context.insert(conv1)
        context.insert(conv2)
        
        let message = Message(id: "msg-1", text: "Movable message", lastUpdated: Date())
        message.conversation = conv1
        context.insert(message)
        
        #expect(conv1.messages.count == 1)
        #expect(conv2.messages.isEmpty)
        
        // Move message to conv2
        message.conversation = conv2
        
        #expect(conv1.messages.isEmpty)
        #expect(conv2.messages.count == 1)
        #expect(conv2.messages.first?.text == "Movable message")
    }
    
    @Test("ViewModel handles messages added externally")
    @MainActor
    func testViewModelWithExternallyAddedMessages() throws {
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
        
        // Add message directly to conversation (not through viewModel)
        let externalMessage = Message(
            id: "external-1",
            text: "External message",
            lastUpdated: Date()
        )
        externalMessage.conversation = conversation
        context.insert(externalMessage)
        
        // ViewModel should see the new message
        #expect(viewModel.sortedMessages.count == 1)
        #expect(viewModel.sortedMessages.first?.text == "External message")
    }
    
    @Test("Conversation with identical message IDs in different conversations")
    @MainActor
    func testDuplicateMessageIDsAcrossConversations() throws {
        let container = try createTestContainer()
        let context = container.mainContext
        
        let conv1 = Conversation(id: "conv-1", name: "Chat 1", lastUpdated: Date())
        let conv2 = Conversation(id: "conv-2", name: "Chat 2", lastUpdated: Date())
        
        context.insert(conv1)
        context.insert(conv2)
        
        // Different messages with same ID in different conversations
        let msg1 = Message(id: "1", text: "Message in conv1", lastUpdated: Date())
        let msg2 = Message(id: "1", text: "Message in conv2", lastUpdated: Date())
        
        msg1.conversation = conv1
        msg2.conversation = conv2
        
        context.insert(msg1)
        context.insert(msg2)
        
        #expect(conv1.messages.count == 1)
        #expect(conv2.messages.count == 1)
        #expect(conv1.messages.first?.text == "Message in conv1")
        #expect(conv2.messages.first?.text == "Message in conv2")
    }
}
