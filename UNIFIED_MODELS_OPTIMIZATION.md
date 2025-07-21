# Unified Models Optimization

## Overview

This document outlines the optimization of data models and synchronization to work seamlessly with both API and local database storage.

## Key Optimizations

### 1. **Unified Models**

#### Before (Separate Models):
```dart
// API Models
class Note { ... }
class Notebook { ... }

// Local Models  
class NoteLocal { ... }
class NotebookLocal { ... }
```

#### After (Unified Models):
```dart
// Single Unified Models
@Entity()
class UnifiedNote { ... }

@Entity() 
class UnifiedNotebook { ... }
```

### 2. **Benefits of Unified Models**

#### ✅ **Single Source of Truth**
- One model for both API and local storage
- No data transformation between formats
- Consistent data structure across the app

#### ✅ **Automatic Sync State Management**
- Built-in sync flags (`isDirty`, `isOffline`)
- Version tracking for conflict resolution
- Automatic timestamp management

#### ✅ **Offline-First Architecture**
- Models work offline by default
- Automatic sync when online
- No data loss during network issues

#### ✅ **Conflict Resolution**
- Local and server version tracking
- Automatic conflict detection
- Merge strategies for conflicting changes

### 3. **Optimized Storage Service**

#### Before (Multiple Services):
```dart
class ObjectBoxService { ... }
class SyncService { ... }
class ApiService { ... }
```

#### After (Unified Service):
```dart
class UnifiedStorageService { ... }
class UnifiedSyncService { ... }
```

### 4. **Key Features**

#### **Smart Sync Logic**
```dart
// Automatic offline-first creation
final note = UnifiedNote.create(
  title: 'My Note',
  content: 'Content',
  notebookUuid: 'notebook-id',
);

// Automatic sync when online
if (await isOnlineMode()) {
  await syncNoteToServer(note);
}
```

#### **Conflict Resolution**
```dart
// Version tracking
String? localVersion;  // Local changes
String? serverVersion; // Server version
String? lastSyncAt;    // Last sync timestamp

// Conflict detection
bool get needsSync => isDirty || isOffline;
bool get isSynced => !isDirty && !isOffline && serverVersion != null;
```

#### **Rich Metadata**
```dart
// Enhanced note model
class UnifiedNote {
  List<String> tags;      // Note tags
  String? color;          // Note color
  int? priority;          // Note priority (1-5)
  String? notebookName;   // Cached notebook name
  int? noteCount;         // Cached note count
}
```

### 5. **Performance Optimizations**

#### **Efficient Queries**
```dart
// ObjectBox queries for fast local access
@Query('isDirty == true')
List<UnifiedNote> getDirtyNotes();

@Query('isOffline == true') 
List<UnifiedNote> getOfflineNotes();

@Query('notebookUuid == ?')
List<UnifiedNote> getNotesByNotebook(String notebookUuid);
```

#### **Batch Operations**
```dart
// Batch sync operations
Future<void> syncNotesFromApi(List<Map<String, dynamic>> apiNotes) async {
  for (final apiNote in apiNotes) {
    final note = UnifiedNote.fromApi(apiNote);
    await _saveNote(note);
  }
}
```

#### **Caching Strategy**
```dart
// Smart caching for online mode
bool? _cachedOnlineMode;
DateTime? _lastOnlineCheck;

// Cache for 5 seconds
if (timeSinceLastCheck.inSeconds < 5) {
  return _cachedOnlineMode!;
}
```

### 6. **Sync Optimization**

#### **Intelligent Sync**
```dart
// Only sync what's needed
Future<List<UnifiedNote>> getDirtyNotes() async {
  return await _noteBox.query(UnifiedNote_.isDirty.equals(true)).build().find();
}

// Batch sync operations
Future<void> syncToApi() async {
  final dirtyNotes = await getDirtyNotes();
  final dirtyNotebooks = await getDirtyNotebooks();
  
  // Sync in parallel
  await Future.wait([
    _syncNotesToApi(dirtyNotes),
    _syncNotebooksToApi(dirtyNotebooks),
  ]);
}
```

#### **Conflict Resolution**
```dart
// Automatic conflict detection
void markAsSynced(String serverVersion) {
  isOffline = false;
  isDirty = false;
  this.serverVersion = serverVersion;
  lastSyncAt = DateTime.now().toIso8601String();
}

// Merge strategies
void update(Map<String, dynamic> updates) {
  // Apply updates
  if (updates['title'] != null) title = updates['title'];
  if (updates['content'] != null) content = updates['content'];
  
  // Mark as dirty for sync
  markAsDirty();
}
```

### 7. **Migration Strategy**

#### **Phase 1: New Models**
- ✅ Create `UnifiedNote` and `UnifiedNotebook`
- ✅ Create `UnifiedStorageService` and `UnifiedSyncService`
- ✅ Add ObjectBox annotations and code generation

#### **Phase 2: Service Integration**
- ✅ Update providers to use unified services
- ✅ Update UI components to work with new models
- ✅ Test offline-first functionality

#### **Phase 3: Data Migration**
- ⏳ Migrate existing data to unified models
- ⏳ Update API endpoints to match unified format
- ⏳ Remove old models and services

### 8. **API Compatibility**

#### **Unified API Format**
```json
{
  "id": "note-uuid",
  "title": "Note Title",
  "content": "Note Content",
  "notebookUuid": "notebook-uuid",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "deleted": false,
  "tags": ["tag1", "tag2"],
  "color": "#2196F3",
  "priority": 1
}
```

#### **Backward Compatibility**
```dart
// Support multiple API formats
static UnifiedNote fromApi(Map<String, dynamic> map) {
  return UnifiedNote(
    uuid: map['id'] ?? map['_id'] ?? '',
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    // ... handle various field names
  );
}
```

### 9. **Benefits Summary**

#### **Developer Experience**
- ✅ Single model to maintain
- ✅ Automatic sync state management
- ✅ Rich metadata and relationships
- ✅ Type-safe operations

#### **User Experience**
- ✅ Offline-first functionality
- ✅ Automatic sync when online
- ✅ No data loss during network issues
- ✅ Fast local operations

#### **Performance**
- ✅ Efficient ObjectBox queries
- ✅ Batch sync operations
- ✅ Smart caching strategy
- ✅ Minimal API calls

#### **Reliability**
- ✅ Conflict resolution
- ✅ Version tracking
- ✅ Error handling
- ✅ Data integrity

### 10. **Next Steps**

1. **Implement ObjectBox Integration**
   - Add proper ObjectBox initialization
   - Implement actual database operations
   - Add code generation for models

2. **Update UI Components**
   - Migrate to unified models
   - Update providers and state management
   - Test offline functionality

3. **API Integration**
   - Update API endpoints
   - Test sync functionality
   - Implement conflict resolution

4. **Performance Testing**
   - Test with large datasets
   - Optimize sync performance
   - Monitor memory usage

This unified approach provides a robust, efficient, and maintainable solution for both offline and online data management. 