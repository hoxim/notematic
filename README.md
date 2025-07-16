# Notematic

A Flutter application for note-taking with Rust backend.

## Development Setup

### Environment Configuration

1. Copy the example environment file:
   ```bash
   cp env.example .env
   ```

2. Configure your `.env` file:
   ```bash
   # Set environment to development
   ENVIRONMENT=development
   
   # API configuration
   API_HOST=192.109.245.95
   API_PORT=8080
   
   # Development tokens for auto-login (optional)
   # Get these tokens by logging in normally and copying them from the logs
   DEV_ACCESS_TOKEN=your_development_access_token_here
   DEV_REFRESH_TOKEN=your_development_refresh_token_here
   ```

### Development Tokens

To enable automatic login in development mode:

1. Log in normally to the application
2. Copy the access and refresh tokens from the console logs
3. Add them to your `.env` file as `DEV_ACCESS_TOKEN` and `DEV_REFRESH_TOKEN`

This will enable automatic login in development mode across all platforms (desktop, mobile, web).

### Running the Application

```bash
# Run on desktop
flutter run -d linux

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android
```

## Production

In production mode, the application uses normal token storage and authentication flow.
