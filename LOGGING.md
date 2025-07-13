# Logging System - Notematic Flutter App

## Overview
The Notematic Flutter app uses the `logger` package to provide comprehensive debugging and monitoring capabilities across the application.

## Log Levels

### Available Log Levels
- **ERROR**: Critical errors that prevent normal operation
- **WARN**: Warning conditions that might indicate problems
- **INFO**: General information about application flow
- **DEBUG**: Detailed debugging information
- **VERBOSE**: Very detailed debugging information
- **WTF**: What a Terrible Failure (for unexpected errors)

## Configuration

### Logger Initialization
The logger is initialized in `main.dart`:

```dart
Future<void> main() async {
  // Initialize logger
  final logger = LoggerService();
  logger.init();
  logger.info('Starting Notematic Flutter app');
  
  runApp(const MyApp());
}
```

### Logger Configuration
The logger is configured with:
- Method count: 2 (shows 2 levels of call stack)
- Error method count: 8 (shows 8 levels for errors)
- Line length: 120 characters
- Colors: enabled
- Emojis: enabled
- Timestamp: enabled

## What Gets Logged

### Authentication
- Login attempts (username)
- Registration attempts (username, email)
- Token operations (save, retrieve, clear)
- Authentication failures

### API Operations
- HTTP requests (URL, method)
- HTTP responses (status code, body)
- Network errors
- API errors with details

### Application Flow
- App startup
- Screen navigation
- Form validation
- User interactions

### Error Handling
- Exception details
- Stack traces for errors
- Network timeouts
- Storage errors

## Usage Examples

### Basic Logging
```dart
final logger = LoggerService();

logger.info('User logged in successfully');
logger.debug('Processing API response');
logger.warning('Network timeout occurred');
logger.error('Failed to save data', error, stackTrace);
```

### In Services
```dart
class ApiService {
  Future<void> makeRequest() async {
    final logger = LoggerService();
    logger.info('Making API request');
    
    try {
      // API call
      logger.info('Request successful');
    } catch (e) {
      logger.error('Request failed: $e');
      rethrow;
    }
  }
}
```

### In UI Components
```dart
class LoginScreen extends StatefulWidget {
  Future<void> _submitForm() async {
    final logger = LoggerService();
    
    if (!_formKey.currentState!.validate()) {
      logger.warning('Form validation failed');
      return;
    }
    
    logger.info('Starting login process');
    // ... login logic
  }
}
```

## Debugging Tips

### Development
1. Use `logger.debug()` for detailed flow information
2. Use `logger.info()` for important state changes
3. Use `logger.warning()` for potential issues
4. Use `logger.error()` for actual errors

### Production
1. Filter logs by level (ERROR, WARN, INFO only)
2. Remove sensitive information from logs
3. Use structured logging for better analysis

### Common Debugging Scenarios

#### API Issues
```dart
logger.debug('API request: $url');
logger.info('API response: ${response.statusCode}');
logger.error('API error: $error');
```

#### Authentication Issues
```dart
logger.info('Login attempt: $username');
logger.debug('Token saved successfully');
logger.warning('Token expired');
logger.error('Authentication failed: $error');
```

#### UI Issues
```dart
logger.debug('Form validation: $fieldName = $value');
logger.info('Navigation: $from -> $to');
logger.warning('Invalid user input: $input');
```

## Log Output Format

Logs are formatted with:
- Timestamp
- Log level (with emoji)
- Message
- Error details (if applicable)
- Stack trace (for errors)

Example:
```
💡 2024-01-15 10:30:45.123 [INFO] Starting Notematic Flutter app
🔍 2024-01-15 10:30:45.124 [DEBUG] Making API request to: http://127.0.0.1:8080/login
✅ 2024-01-15 10:30:45.125 [INFO] User logged in successfully: testuser
⚠️  2024-01-15 10:30:45.126 [WARNING] Form validation failed
❌ 2024-01-15 10:30:45.127 [ERROR] Network error: Connection timeout
```

## Integration with Development Tools

### Flutter DevTools
- View logs in the console
- Filter by log level
- Search through log messages

### IDE Integration
- Most IDEs show logs in the debug console
- Use log level filtering for cleaner output
- Set breakpoints based on log messages

## Best Practices

1. **Don't log sensitive data**: Never log passwords, tokens, or personal information
2. **Use appropriate levels**: Choose the right log level for each message
3. **Include context**: Add relevant information to help with debugging
4. **Handle errors gracefully**: Always catch and log exceptions
5. **Performance**: Avoid expensive operations in debug logs
6. **Consistency**: Use consistent log message formats across the app 