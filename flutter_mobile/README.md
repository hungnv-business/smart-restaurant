# SmartRestaurant Mobile App

Vietnamese Restaurant Management System - Flutter Mobile Application

## Overview

This Flutter mobile app provides Vietnamese restaurant workflows including order management, table reservations, and takeaway processing. Designed for restaurant staff and customers with Vietnamese localization support.

## Features

- **Gọi món (Orders)**: Real-time order management for restaurant staff
- **Đặt bàn (Reservations)**: Table booking system for customers  
- **Mang về (Takeaway)**: Takeaway order processing
- **Vietnamese Localization**: Full Vietnamese language support
- **ABP Integration**: Connects to ABP Framework backend APIs

## Quick Start

### Prerequisites
- Flutter SDK 3.35.1+
- Dart 3.0+
- Android Studio / Xcode for platform development
- Connected device or emulator

### Installation

1. **Get Flutter dependencies**
   ```bash
   cd flutter_mobile
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run
   ```

3. **Or from root directory**
   ```bash
   npm run dev:mobile
   ```

## Development Commands

### From flutter_mobile directory:
```bash
# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Run tests
flutter test

# Build for Android
flutter build apk

# Build for iOS (macOS only)
flutter build ios
```

### From root directory:
```bash
# Start mobile development
npm run dev:mobile

# Run mobile tests
npm run test:mobile

# Build mobile app
npm run build:mobile
```

## Project Structure

```
flutter_mobile/
├── lib/
│   ├── features/               # Feature modules
│   │   ├── orders/            # Order management
│   │   ├── reservations/      # Table reservations  
│   │   └── takeaway/          # Takeaway orders
│   ├── shared/                # Shared components
│   │   ├── constants/         # Vietnamese constants
│   │   ├── models/            # Data models
│   │   ├── services/          # API services
│   │   ├── utils/             # Vietnamese utilities
│   │   └── widgets/           # Reusable widgets
│   └── main.dart              # App entry point
├── test/                      # Tests
├── android/                   # Android configuration
├── ios/                       # iOS configuration
└── pubspec.yaml              # Dependencies
```

## Vietnamese Features

- **Language**: Vietnamese-first with English fallback
- **Currency**: Vietnamese Dong (₫) formatting
- **Input**: Vietnamese text input support
- **Workflows**: Restaurant-specific Vietnamese workflows
- **Date/Time**: Vietnamese locale formatting

## API Integration

Connects to SmartRestaurant ABP Framework backend:
- Authentication via ABP Identity
- RESTful API consumption
- Real-time updates via SignalR
- Vietnamese data handling

## Testing

```bash
# Unit tests
flutter test test/unit/

# Widget tests  
flutter test test/widgets/

# Integration tests
flutter test integration_test/
```

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### iOS (macOS only)
```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

1. **Flutter not found**
   ```bash
   flutter doctor
   ```

2. **Dependencies issue**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **No connected devices**
   ```bash
   flutter devices
   flutter emulators
   ```

### Vietnamese Text Issues
- Ensure proper font support in `pubspec.yaml`
- Check locale configuration in `main.dart`
- Verify API returns proper UTF-8 encoding

## Contributing

1. Follow Flutter/Dart conventions
2. Add tests for new features
3. Ensure Vietnamese localization
4. Test on both Android and iOS

## Documentation

- [Flutter Documentation](https://docs.flutter.dev/)
- [Project Architecture](../docs/architecture/source-tree.md)
- [Development Guide](../CLAUDE.md)

---

Built for Vietnamese restaurants with Flutter 3.35.1