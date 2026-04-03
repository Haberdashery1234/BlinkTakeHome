//
//  ConversationsListView.swift
//  Blink_Chat_Take_Home
//
//  Created by Christian Grise on 4/2/26.
//

import SwiftUI
import SwiftData

struct ConversationsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Conversation.lastUpdated, order: .reverse) private var conversations: [Conversation]
    @State private var isLoadingData = false
    @State private var loadError: String?
    @State private var hasAttemptedLoad = false
    
    var body: some View {
        ZStack {
            // Main content
            if conversations.isEmpty && !isLoadingData {
                ContentUnavailableView(
                    "No Conversations",
                    systemImage: "bubble.left.and.bubble.right",
                    description: Text("Your conversations will appear here")
                )
            } else {
                conversationsList
            }
            
            // Loading overlay (only shows when actually loading)
            if isLoadingData {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Loading conversations...")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .padding(32)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .navigationTitle("Conversations")
        .task {
            // Load data only once
            guard !hasAttemptedLoad else { return }
            hasAttemptedLoad = true
            await loadDataIfNeeded()
        }
        .alert("Error Loading Data", isPresented: .constant(loadError != nil)) {
            Button("Retry") {
                hasAttemptedLoad = false
                Task {
                    await loadDataIfNeeded()
                }
            }
            Button("OK", role: .cancel) {
                loadError = nil
            }
        } message: {
            if let error = loadError {
                Text(error)
            }
        }
    }
    
    private var conversationsList: some View {
        List {
            ForEach(conversations) { conversation in
                NavigationLink {
                    ConversationDetailView(conversation: conversation)
                } label: {
                    ConversationRowView(conversation: conversation)
                }
            }
        }
    }
    
    private func loadDataIfNeeded() async {
        print("ConversationsListView: Checking if data needs to be loaded...")
        
        // Check if data already exists
        let descriptor = FetchDescriptor<Conversation>()
        if let count = try? modelContext.fetchCount(descriptor), count > 0 {
            print("Data already exists (\(count) conversations), skipping load")
            return
        }
        
        print("No data found, loading from JSON...")
        isLoadingData = true
        loadError = nil
        
        do {
            let dataService = DataService()
            try await dataService.loadConversationsFromJSON(modelContext: modelContext)
            print("Data loaded successfully")
        } catch {
            let errorMsg = "Failed to load data: \(error.localizedDescription)"
            loadError = errorMsg
            print("[ERROR] Error loading data: \(error)")
        }
        
        isLoadingData = false
        print("Loading complete, isLoadingData = false")
    }
}

#Preview {
    NavigationStack {
        ConversationsListView()
    }
    .modelContainer(for: [Conversation.self, Message.self], inMemory: true)
}
