//
//  ConversationsViewModel.swift
//  Blink_Chat_Take_Home
//
//  Created by Christian Grise on 4/2/26.
//

import Foundation
import SwiftData

/// ViewModel for managing the conversations list
@Observable
@MainActor
final class ConversationsViewModel {
    private let modelContext: ModelContext
    private let dataService = DataService()
    
    var isLoading = false
    var errorMessage: String?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Load conversations from JSON file on first launch
    func loadInitialData() async {
        print("ConversationsViewModel: Starting data load...")
        isLoading = true
        errorMessage = nil
        
        do {
            try await dataService.loadConversationsFromJSON(modelContext: modelContext)
            print("ConversationsViewModel: Data load completed successfully")
        } catch {
            let errorMsg = "Failed to load data: \(error.localizedDescription)"
            errorMessage = errorMsg
            print("[ERROR] ConversationsViewModel: \(errorMsg)")
            print("[ERROR] Error details: \(error)")
        }
        
        isLoading = false
        print("ConversationsViewModel: isLoading = false")
    }
}
