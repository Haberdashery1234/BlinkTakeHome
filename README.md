# Blink Chat Take Home

## Overview
A chat application built with SwiftUI and SwiftData.

## Current Features
- Conversation management with SwiftData persistence
- Message handling with cascade delete relationships
- JSON decoding support for conversations and messages

## Future Expansions

### High Priority
- [ ] Add participant list to conversations
  - Create a `Person` or `Participant` model
  - Add relationship between `Conversation` and participants
  - Support for multiple users in group conversations
  
- [ ] Enhanced message features
  - Read receipts
  - Message reactions
  - Message editing and deletion
  - Reply threading

### UI/UX Improvements
- [ ] Search functionality across conversations and messages
- [ ] Message filtering and sorting options
- [ ] Conversation archiving
- [ ] Custom themes and appearance settings

### Performance & Scalability
- [ ] Message pagination for large conversations
- [ ] Image and media attachment support
- [ ] Optimized SwiftData queries for better performance
- [ ] Background message syncing

### Additional Features
- [ ] Push notifications for new messages
- [ ] Typing indicators
- [ ] User presence (online/offline status)
- [ ] Message encryption
- [ ] Export conversation history

## Architecture Notes
- Uses SwiftData for local persistence
- `Conversation` model includes cascade delete for messages
- Decodable extensions for JSON parsing
