# Offline/Online Features

## Overview

The application now supports offline-first functionality with visual indicators to distinguish between offline and online content.

## Features

### 1. Offline/Online Flags

Both `Note` and `Notebook` models now include:
- `isOffline`: Boolean flag indicating if the item was created offline
- `isDirty`: Boolean flag indicating if the item needs synchronization

### 2. Visual Indicators

#### Notes
- **Offline notes** show an orange cloud-off icon overlay on the note avatar
- **Online notes** show the standard note icon without overlay

#### Notebooks
- **Offline notebooks** show an orange cloud-off icon next to the notebook name
- **Online notebooks** show the standard notebook name without icon

### 3. Helper Methods

#### Creating Offline Content
```dart
// Create offline note
Note offlineNote = NoteServiceApi.createOfflineNote(
  title: "My Offline Note",
  content: "This note was created offline",
  notebookUuid: "notebook-uuid",
);

// Create offline notebook
Notebook offlineNotebook = NotebookServiceApi.createOfflineNotebook(
  name: "My Offline Notebook",
  description: "Created offline",
  color: "#FF5722",
);
```

#### Checking API Availability
```dart
// Check if API is available
bool isOnline = await ApiService().isApiAvailable();
```

#### Platform Detection
```dart
// Check platform type
bool isWeb = AppConfig.isWebPlatform;
bool isDesktop = AppConfig.isDesktopPlatform;
bool isMobile = AppConfig.isMobilePlatform;
bool isOfflineMode = AppConfig.isOfflineMode;
```

### 4. Synchronization

#### Manual Sync
```dart
// Sync offline notes to API
await noteService.syncOfflineNotes(offlineNotesList);
```

#### Automatic Sync
- Offline notes are marked with `isDirty = true`
- When API becomes available, dirty notes can be synced
- After successful sync, `isOffline = false` and `isDirty = false`

### 5. Configuration

#### Environment Variables
```env
# Enable offline mode
OFFLINE_MODE=true

# API configuration
API_HOST=192.109.245.95
API_PORT=8080
```

## Usage Examples

### Creating Content in Offline Mode
1. User creates a note/notebook while offline
2. Content is marked with `isOffline = true` and `isDirty = true`
3. Visual indicators show the offline status
4. When connection is restored, content can be synced

### Visual Feedback
- **Orange cloud-off icon**: Indicates offline content
- **Standard icons**: Indicates online content
- **Sync indicators**: Show when content needs synchronization

## Implementation Details

### Model Changes
```dart
class Note {
  // ... existing fields
  bool isOffline; // New field
  bool isDirty;   // Existing field, now used for sync
}

class Notebook {
  // ... existing fields
  bool isOffline; // New field
  bool isDirty;   // Existing field, now used for sync
}
```

### Service Helpers
- `NoteServiceApi.createOfflineNote()`: Creates notes with offline flag
- `NotebookServiceApi.createOfflineNotebook()`: Creates notebooks with offline flag
- `ApiService.isApiAvailable()`: Checks API connectivity
- `NoteServiceApi.syncOfflineNotes()`: Syncs offline notes to API

### UI Components
- `NotesListView`: Shows offline indicators on notes
- `CreateNoteScreen`: Shows offline indicators on notebooks
- Visual feedback for sync status

## Benefits

1. **Offline-First**: Users can work without internet connection
2. **Visual Clarity**: Clear indication of online/offline status
3. **Sync Awareness**: Users know when content needs synchronization
4. **Platform Flexibility**: Works on web, desktop, and mobile
5. **Data Integrity**: Prevents data loss in offline scenarios

## Future Enhancements

1. **Automatic Sync**: Background synchronization when connection is restored
2. **Conflict Resolution**: Handle conflicts between offline and online versions
3. **Sync Progress**: Show sync progress indicators
4. **Offline Storage**: Implement local database for offline storage
5. **Push Notifications**: Notify users when sync is complete 