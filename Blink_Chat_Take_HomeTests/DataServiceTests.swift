//
//  DataServiceTests.swift
//  Blink_Chat_Take_HomeTests
//
//  Created by Christian Grise on 4/2/26.
//

import Testing
import Foundation
import SwiftData
@testable import Blink_Chat_Take_Home

@Suite("DataService Tests")
struct DataServiceTests {
    
    @MainActor
    func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Conversation.self, Message.self,
            configurations: config
        )
        return container
    }
    
    @Test("DataService loads JSON data successfully")
    @MainActor
    func testLoadConversationsFromJSON() async throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let dataService = DataService()
        
        try await dataService.loadConversationsFromJSON(
            filename: "code_test_data",
            modelContext: context
        )
        
        let descriptor = FetchDescriptor<Conversation>()
        let conversations = try context.fetch(descriptor)
        
        #expect(!conversations.isEmpty, "Conversations should be loaded from JSON")
    }
    
    @Test("DataService doesn't reload if data already exists")
    @MainActor
    func testDataServiceSkipsReloadWhenDataExists() async throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let dataService = DataService()
        
        // Add existing conversation
        let existingConv = Conversation(
            id: "existing",
            name: "Existing",
            lastUpdated: Date()
        )
        context.insert(existingConv)
        try context.save()
        
        // Try to load JSON
        try await dataService.loadConversationsFromJSON(
            filename: "code_test_data",
            modelContext: context
        )
        
        let descriptor = FetchDescriptor<Conversation>()
        let conversations = try context.fetch(descriptor)
        
        // Should still only have the one existing conversation
        #expect(conversations.count == 1)
        #expect(conversations.first?.id == "existing")
    }
    
    @Test("DataService throws error for missing file")
    @MainActor
    func testDataServiceThrowsForMissingFile() async throws {
        let container = try createTestContainer()
        let context = container.mainContext
        let dataService = DataService()
        
        await #expect(throws: Error.self) {
            try await dataService.loadConversationsFromJSON(
                filename: "nonexistent_file",
                modelContext: context
            )
        }
    }
}
