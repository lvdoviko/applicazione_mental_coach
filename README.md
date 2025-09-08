# AI Wellbeing Coach - Flutter Mobile App

[![Flutter Version](https://img.shields.io/badge/Flutter-3.16.0+-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.2.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Private-red.svg)](https://opensource.org/licenses/MIT)

> **AI Wellbeing Coach** - Your personal AI mental wellness companion for athletes and sports teams. Built with Flutter for iOS and Android.

## 🏆 Overview

AI Wellbeing Coach is a mobile-first application designed to provide mental wellness support specifically for athletes and sports teams. The app features an empathetic AI coach, health data integration, and seamless escalation to human coaches when needed.

### ✨ Key Features

- **🤖 AI Chat Coach**: Empathetic, sports-focused AI conversations
- **📱 Mobile-First**: Optimized for iOS and Android
- **🏥 Health Integration**: Apple HealthKit & Google Health Connect support
- **👤 Avatar Customization**: Personalized avatar with multiple styles
- **📊 Analytics Dashboard**: Wellness metrics and progress tracking
- **🆘 Human Escalation**: Seamless transition to human coaches
- **🔒 Privacy-First**: GDPR compliant with end-to-end encryption
- **🌍 Multilingual**: English and Italian support

## 🎨 Design System

### Color Palette
```dart
// Primary Brand Colors
Deep Teal: #0F5860
Soft Blue: #2B9ED9  
Lime: #A7D129
Orange: #FF9A42
Background: #F6F8FA
Text: #0B1A1F
```

### Typography
- **Font**: Inter
- **Body**: 16sp
- **Headings**: 28sp semibold
- **Accessible**: Supports font scaling 0.8x - 1.3x

### Components
- `ChatBubble` - Message display with status indicators
- `MessageComposer` - Voice-to-text input with animations
- `QuickReplyChips` - Context-aware quick responses
- `AvatarCustomizer` - Interactive avatar personalization
- `StatCard` - Wellness metrics with sparklines
- `EscalationModal` - Human coach request dialog

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.16.0 or higher
- Dart SDK 3.2.0 or higher
- iOS 12.0+ / Android API level 21+
- Xcode 14+ (for iOS development)
- Android Studio with Android SDK (for Android development)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-org/applicazione_mental_coach.git
   cd applicazione_mental_coach
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate localization files**:
   ```bash
   flutter gen-l10n
   ```

4. **Run code generation**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**:
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   
   # Specific device
   flutter run -d <device_id>
   ```

### Platform-Specific Setup

#### iOS Setup
1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing & capabilities
3. Add HealthKit entitlement:
   ```xml
   <key>com.apple.developer.healthkit</key>
   <true/>
   ```
4. Update `Info.plist` with health data usage descriptions

#### Android Setup
1. Update `android/app/src/main/AndroidManifest.xml`
2. Add Health Connect permissions:
   ```xml
   <uses-permission android:name="android.permission.health.READ_STEPS" />
   <uses-permission android:name="android.permission.health.READ_HEART_RATE" />
   ```

## 🛠 Development

### Project Structure
```
lib/
├── core/
│   ├── config/           # App configuration
│   ├── routing/          # Navigation & routing
│   ├── theme/            # Theme definitions
│   └── utils/            # Utility functions
├── design_system/
│   ├── components/       # Reusable UI components
│   └── tokens/           # Design tokens (colors, typography, spacing)
├── features/
│   ├── auth/             # Authentication
│   ├── chat/             # AI chat functionality
│   ├── dashboard/        # Analytics & metrics
│   ├── avatar/           # Avatar customization
│   ├── onboarding/       # First-time user experience
│   └── settings/         # App settings & privacy
├── shared/
│   ├── models/           # Data models
│   ├── services/         # Business logic services
│   ├── widgets/          # Shared widgets
│   └── providers/        # State management
└── main.dart             # App entry point
```

### Architecture Patterns

- **State Management**: Riverpod for dependency injection and state
- **Navigation**: GoRouter for type-safe routing
- **Local Storage**: Hive for encrypted local data
- **API Client**: Dio with interceptors for HTTP requests
- **Real-time Chat**: WebSocket with Socket.io client

## 🧪 Testing

### Quick Test Commands
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Golden tests (UI regression)
flutter test --update-goldens
```

## 📦 Building

### Release Builds
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🔌 API Integration

The app connects to a microservices backend with:
- **Chat Service**: Real-time AI conversations
- **Health Service**: Wearable data integration  
- **Analytics Service**: Wellness metrics
- **Escalation Service**: Human coach handoff

API documentation: [api_specification.yaml](api_specification.yaml)

## 🔒 Security & Privacy

- **GDPR Compliant**: Data export, deletion, consent management
- **Encryption**: AES-256 for sensitive data
- **Privacy-First**: Analytics opt-in, notification obfuscation
- **Secure Auth**: JWT tokens, biometric support (planned)

## 📊 Component Showcase

### ChatBubble Component
```dart
ChatBubble(
  message: "I understand that training can feel overwhelming sometimes.",
  type: ChatBubbleType.ai,
  timestamp: DateTime.now(),
  status: ChatBubbleStatus.delivered,
  isAnimated: true,
)
```

### MessageComposer Component  
```dart
MessageComposer(
  onSendMessage: (message) => sendToAI(message),
  hintText: 'Share what\'s on your mind...',
  supportsSpeech: true,
  onVoiceStart: () => startRecording(),
  onVoiceStop: () => stopRecording(),
)
```

### AvatarCustomizer Component
```dart
AvatarCustomizer(
  onConfigChanged: (config) => saveAvatarConfig(config),
  initialConfig: AvatarConfig(
    style: AvatarStyle.modern,
    expression: AvatarExpression.determined,
    primaryColor: AppColors.deepTeal,
    secondaryColor: AppColors.softBlue,
  ),
  showPreview: true,
)
```

### StatCard Component
```dart
StatCard(
  title: 'Mood Score',
  value: '8.2/10',
  subtitle: 'Above average',
  icon: Icons.mood,
  trend: StatTrend.up,
  trendValue: '+0.5',
  variant: StatCardVariant.success,
  sparklineData: [7.5, 7.8, 8.0, 7.9, 8.2, 8.1, 8.2],
)
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make changes following our coding standards
4. Add tests for new functionality
5. Commit changes (`git commit -m 'Add amazing feature'`)
6. Push to branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 Documentation

- [Backend Architecture](backend_architecture.md) - Complete backend system design
- [API Specification](api_specification.yaml) - OpenAPI 3.0 specification
- [Component Library](lib/design_system/components/) - Design system components
- [Theme System](lib/core/theme/) - App theming and styling

## 🚀 Quick Start Commands

```bash
# Setup project
git clone <repo> && cd applicazione_mental_coach
flutter pub get && dart run build_runner build

# Run app  
flutter run

# Run tests
flutter test && flutter test integration_test/

# Build release
flutter build apk --release  # Android
flutter build ios --release  # iOS

# Code quality
flutter analyze && dart format .
```

---

**Built with ❤️ for the mental wellness of athletes worldwide**
