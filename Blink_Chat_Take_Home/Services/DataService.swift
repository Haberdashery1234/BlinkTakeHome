//
//  DataService.swift
//  Blink_Chat_Take_Home
//
//  Created by Christian Grise on 4/2/26.
//

import Foundation
import SwiftData

/// Service responsible for loading and parsing JSON data into SwiftData models
@MainActor
final class DataService {
    
    /// Loads conversations from JSON file and imports them into SwiftData
    /// - Parameters:
    ///   - filename: Name of the JSON file (without extension)
    ///   - modelContext: SwiftData model context for persistence
    /// - Throws: Errors related to file loading or JSON parsing
    func loadConversationsFromJSON(filename: String = "code_test_data", modelContext: ModelContext) async throws {
        // Check if data already exists
        let descriptor = FetchDescriptor<Conversation>()
        let existingConversations = try modelContext.fetch(descriptor)
        
        // Only load if database is empty (offline-first approach)
        guard existingConversations.isEmpty else {
            print("Data already loaded (\(existingConversations.count) conversations), skipping JSON import")
            return
        }
        
        print("Loading conversations from JSON...")
        
        // Load JSON file from bundle
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("[ERROR] JSON file not found: \(filename).json")
            throw DataServiceError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        print("JSON file loaded, size: \(data.count) bytes")
        
        let decoder = JSONDecoder()
        
        // Custom date decoding strategy
        let dateFormatter = ISO8601DateFormatter()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            
            // Fallback for non-ISO dates
            let fallbackFormatter = DateFormatter()
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = fallbackFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        
        let decodableConversations = try decoder.decode([Conversation.DecodableConversation].self, from: data)
        print("Decoded \(decodableConversations.count) conversations")
        
        // Convert to SwiftData models
        for decodableConv in decodableConversations {
            let conversation = Conversation(
                id: decodableConv.id,
                name: decodableConv.name,
                lastUpdated: try Self.parseDate(decodableConv.last_updated)
            )
            
            modelContext.insert(conversation)
            
            // Add messages to conversation
            for decodableMsg in decodableConv.messages {
                let message = Message(
                    id: decodableMsg.id,
                    text: decodableMsg.text,
                    lastUpdated: try Self.parseDate(decodableMsg.last_updated)
                )
                message.conversation = conversation
                modelContext.insert(message)
            }
            
            print("  Added conversation: \(conversation.name) with \(decodableConv.messages.count) messages")
        }
        
        try modelContext.save()
        print("Successfully loaded and saved \(decodableConversations.count) conversations to SwiftData")
    }
    
    private static func parseDate(_ dateString: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = fallbackFormatter.date(from: dateString) {
            return date
        }
        
        throw DataServiceError.invalidDateFormat
    }
}

enum DataServiceError: LocalizedError {
    case fileNotFound
    case invalidDateFormat
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "JSON file not found in bundle"
        case .invalidDateFormat:
            return "Invalid date format in JSON"
        }
    }
}
