# Offline/Online Sync System

## Overview

Aplikacja teraz obsługuje pełny system offline-first z synchronizacją dwukierunkową między lokalną bazą a API.

## Architektura

### 1. Modele lokalne
- **`NoteLocal`** - lokalny model notatki z flagami sync
- **`NotebookLocal`** - lokalny model notebooka z flagami sync

### 2. Serwisy
- **`SimpleLocalStorageService`** - zarządzanie lokalnymi danymi (w pamięci)
- **`SyncService`** - synchronizacja między lokalną bazą a API
- **`ApiService`** - komunikacja z API

### 3. Flagi synchronizacji
- **`isOffline`** - czy element został utworzony offline
- **`isDirty`** - czy element wymaga synchronizacji
- **`localVersion`** - lokalna wersja do rozwiązywania konfliktów
- **`serverVersion`** - wersja serwera z CouchDB

## Jak to działa

### Tryb Online (API dostępne)
1. **Tworzenie notatek/notebooków** - bezpośrednio do API
2. **Pobieranie danych** - z API + lokalne cache
3. **Synchronizacja** - automatyczna w tle

### Tryb Offline (API niedostępne)
1. **Tworzenie notatek/notebooków** - lokalnie z flagą `isOffline = true`
2. **Pobieranie danych** - z lokalnej bazy
3. **Synchronizacja** - gdy API stanie się dostępne

### Synchronizacja
1. **Offline → Online** - wysyłanie `isDirty = true` elementów
2. **Online → Offline** - pobieranie najnowszych danych z API
3. **Konflikty** - rozwiązywanie na podstawie wersji

## Użycie

### Tworzenie notatki
```dart
final syncService = SyncService();

// Automatycznie wykrywa tryb online/offline
await syncService.createNote(
  title: "My Note",
  content: "Note content",
  notebookUuid: "notebook-uuid",
);
```

### Tworzenie notebooka
```dart
await syncService.createNotebook(
  name: "My Notebook",
  description: "Description",
  color: "#FF5722",
);
```

### Synchronizacja
```dart
// Pełna synchronizacja (dwukierunkowa)
await syncService.fullSync();

// Tylko do API
await syncService.syncToApi();

// Tylko z API
await syncService.syncFromApi();
```

### Sprawdzanie statusu
```dart
final status = await syncService.getSyncStatus();
print('Online: ${status['isOnline']}');
print('Dirty notes: ${status['dirtyNotes']}');
print('Dirty notebooks: ${status['dirtyNotebooks']}');
```

## Wizualne wskaźniki

### Notatki
- **Pomarańczowa chmurka** - notatka offline
- **Brak wskaźnika** - notatka online

### Notebooki
- **Pomarańczowa chmurka** - notebook offline
- **Brak wskaźnika** - notebook online

## Konfiguracja

### Environment Variables
```env
# API configuration
API_HOST=192.109.245.95
API_PORT=8080

# Offline mode (optional)
OFFLINE_MODE=true
```

### Sync Toggle
- **Włączony** - tryb online z synchronizacją
- **Wyłączony** - tryb offline bez synchronizacji

## Przepływ danych

### 1. Tworzenie w trybie online
```
User → SyncService → API → LocalStorage
```

### 2. Tworzenie w trybie offline
```
User → SyncService → LocalStorage (isOffline=true, isDirty=true)
```

### 3. Synchronizacja offline → online
```
LocalStorage (isDirty=true) → SyncService → API → LocalStorage (isOffline=false)
```

### 4. Synchronizacja online → offline
```
API → SyncService → LocalStorage (isOffline=false)
```

## Obsługa błędów

### Błąd API podczas tworzenia online
1. Automatyczny fallback do trybu offline
2. Element zostaje utworzony lokalnie z `isOffline = true`
3. Synchronizacja przy następnej próbie

### Błąd synchronizacji
1. Element pozostaje z `isDirty = true`
2. Ponowna próba przy następnej synchronizacji
3. Logowanie błędów dla debugowania

## Korzyści

1. **Offline-first** - praca bez internetu
2. **Automatyczna synchronizacja** - gdy połączenie wróci
3. **Wizualne wskaźniki** - jasne rozróżnienie online/offline
4. **Obsługa konfliktów** - wersjonowanie z CouchDB
5. **Elastyczność** - przełączanie między trybami

## Przyszłe ulepszenia

1. **ObjectBox** - prawdziwa lokalna baza danych
2. **Automatyczna synchronizacja** - w tle
3. **Konflikt resolution** - UI do rozwiązywania konfliktów
4. **Push notifications** - powiadomienia o synchronizacji
5. **Sync progress** - wskaźniki postępu synchronizacji 