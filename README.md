# Platia - Pilates Club Mobile Application

A comprehensive Flutter application for managing Pilates and Yoga clubs, featuring class booking, membership management, and multi-language support.

## Features

### Member Features

- User registration and authentication
- Class schedule viewing with calendar
- Class booking and cancellation
- Membership package management
- Payment history tracking
- Attendance history
- Push notifications for class reminders
- Multi-language support (Turkish/English)
- Dark/Light theme support

### Admin Features

- User management (CRUD operations)
- Class and schedule management
- Instructor management
- Studio management
- Financial reporting
- Announcement system
- Real-time dashboard

## Technology Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging)
- **Navigation**: GoRouter
- **Localization**: Flutter Intl
- **Local Storage**: SharedPreferences
- **Notifications**: Firebase Cloud Messaging + Local Notifications

## Project Structure

```
platia/
├── lib/
│   ├── config/         # App configuration
│   ├── core/           # Core utilities and extensions
│   ├── data/           # Data layer (models, repositories, services)
│   ├── domain/         # Business logic (providers)
│   ├── l10n/           # Localization files
│   └── presentation/   # UI layer (screens, widgets)
├── assets/             # Images, fonts, icons
└── test/              # Test files
```

## Setup Instructions

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/platia.git
   cd platia
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   - Create a new Firebase project
   - Add Android and iOS apps to Firebase
   - Download and add configuration files:
     - `google-services.json` to `android/app/`
     - `GoogleService-Info.plist` to `ios/Runner/`
   - Enable Authentication, Firestore, and Cloud Messaging

4. **Run the app**
   ```bash
   flutter run
   ```

## Multi-language Support

The app supports Turkish and English languages. To add a new language:

1. Add the locale to `supportedLocales` in `app.dart`
2. Create new localization files in `lib/l10n/`
3. Update the ARB files with translations

## Architecture

The app follows a clean architecture pattern with clear separation of concerns:

- **Presentation Layer**: UI components and screens
- **Domain Layer**: Business logic and state management
- **Data Layer**: Data models, repositories, and external services

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
