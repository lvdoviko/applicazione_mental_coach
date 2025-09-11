# KAIX - Lo-Fi Mental Coach App

[![Flutter Version](https://img.shields.io/badge/Flutter-3.16.0+-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.2.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

> **KAIX** - Una conversazione serena per il benessere mentale. Design lo-fi minimalista che promuove calma e riflessione attraverso interfacce pulite e interazioni fluide.

## 🏆 Overview

KAIX è un'app di mental coaching con un design lo-fi minimalista che promuove calma e riflessione. L'interfaccia pulita e le animazioni fluide creano un ambiente sereno per conversazioni significative con un AI coach intelligente.

### ✨ Funzionalità Principali

- **🎨 Design Lo-Fi**: Estetica minimalista con palette pastello rilassante
- **🤖 AI Coach Intelligente**: Conversazioni empatiche e personalizzate
- **📱 Flutter Nativo**: Performance ottimali su iOS e Android
- **🌙 Modalità Scura**: Adattamento automatico per comfort visivo
- **♿ Accessibilità Completa**: Supporto VoiceOver/TalkBack WCAG 2.1
- **🌍 Localizzazione**: Interfaccia completa in Italiano e Inglese
- **🔒 Privacy-First**: Dati locali cifrati, zero tracking
- **📐 Design Responsivo**: Adattivo per tablet e dispositivi foldable

## 🎨 Design System Lo-Fi

Il design system KAIX abbraccia l'estetica lo-fi con colori pastello morbidi, spazi generosi e animazioni delicate che promuovono una sensazione di calma e benessere.

### 🌈 Palette Colori
```dart
// Colori Lo-Fi Principali
Primary: #7DAEA9      // Teal rilassante
Secondary: #E6D9F2    // Lavanda soft  
Accent: #D4C4E8       // Viola tenue
Background: #FBF9F8   // Carta naturale
Surface: #FFFFFF      // Bianco puro
Text Primary: #0F1724 // Blu-nero profondo
```

### 🔤 Tipografia
- **Font Famiglia**: Inter (Google Fonts)
- **Fallback**: -apple-system, BlinkMacSystemFont, Roboto
- **Dimensioni**: Scala 10px-34px con line-height ottimizzato
- **Pesi**: Da Light (300) a Bold (700)
- **Accessibilità**: Supporto scaling 0.8x - 1.3x

### 🧩 Componenti Lo-Fi
- `LoFiMessageBubble` - Bolle messaggio con stile minimalista
- `LoFiInputComposer` - Campo input con animazioni fluide
- `LoFiQuickSuggestions` - Chip suggerimenti contestuali
- `LoFiEmptyState` - Stati vuoto con illustrazioni minimali
- `LoFiErrorState` - Gestione errori elegante e rassicurante

## 🚀 Installazione

### Prerequisiti

- Flutter SDK 3.16.0+
- Dart SDK 3.2.0+  
- iOS 12.0+ / Android API 21+
- Xcode 14+ (per sviluppo iOS)
- Android Studio con Android SDK

### Setup Progetto

1. **Clone del repository**:
   ```bash
   git clone <repository-url>
   cd applicazione_mental_coach
   ```

2. **Installazione dipendenze**:
   ```bash
   flutter pub get
   ```

3. **Generazione localizzazioni**:
   ```bash
   flutter gen-l10n
   ```

4. **Build e run**:
   ```bash
   # Modalità debug
   flutter run
   
   # Modalità release
   flutter run --release
   
   # Dispositivo specifico
   flutter run -d <device_id>
   ```

### Configurazione Piattaforma

#### Setup iOS
1. Aprire `ios/Runner.xcworkspace` in Xcode
2. Configurare signing e capabilities
3. Aggiornare `Info.plist` per permessi necessari

#### Setup Android
1. Aprire `android/app/src/main/AndroidManifest.xml`  
2. Configurare permessi e target SDK
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   ```

## 🏧 Architettura

### Struttura del Progetto
```
lib/
├── design_system/           # Sistema di design lo-fi completo
│   ├── components/          # Componenti riutilizzabili
│   ├── tokens/              # Design tokens (colori, spacing, etc)
│   ├── theme/               # Tema Material 3 customizzato
│   └── responsive/          # Utilities responsive
├── features/                # Organizzazione per funzionalità
│   ├── chat/                # Chat e messaging
│   ├── onboarding/          # Prima esperienza utente
│   └── settings/            # Configurazioni app
├── shared/                  # Codice condiviso
│   ├── services/            # Servizi business logic
│   ├── models/              # Data models
│   └── utils/               # Utilities generiche
├── l10n/                    # Localizzazione multilingua
└── main.dart                 # Entry point applicazione
```

### Principi Architetturali

1. **Feature-First** - Organizzazione per funzionalità
2. **Single Responsibility** - Un compito per classe
3. **Dependency Injection** - Con Riverpod provider
4. **Immutable State** - Stati immutabili e predicibili
5. **Test-Driven** - Coverage >90% per core logic

### Stack Tecnologico
- **State Management**: Riverpod per DI e state
- **Navigation**: GoRouter type-safe
- **Local Storage**: Hive cifrato
- **HTTP Client**: Dio con interceptors
- **Animazioni**: AnimationController custom

## 🧪 Testing Completo

### Copertura Test
- **Unit Tests**: >95% per business logic
- **Widget Tests**: Tutti i componenti core  
- **Integration Tests**: Flussi utente principali
- **Accessibility Tests**: Compliance WCAG 2.1

### Comandi Test Rapidi
```bash
# Tutti i test
flutter test

# Con coverage
flutter test --coverage

# Test integrazione
flutter test integration_test/

# Golden tests (UI regression)
flutter test --update-goldens
```

## 📦 Build & Deploy

### Build Release
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS  
flutter build ios --release
```

### Performance Ottimizzazioni
- **Widget Stateless** - Preferenza const constructors
- **Build Scope** - Rebuild minimization
- **Lazy Loading** - Liste pigre ottimizzate
- **Memory Management** - Disposal corretto controllers

## 🎨 Design System

### Design Tokens
Il file `design_tokens.json` contiene tutti i tokens sincronizzati con Figma:

```json
{
  "colors": {
    "light": {
      "primary": "#7DAEA9",
      "background": "#FBF9F8"
    }
  },
  "typography": {
    "fontFamily": "Inter",
    "fontSizes": { "md": 16, "lg": 18 }
  }
}
```

### Processo Sync Figma
1. **Designer**: Aggiorna tokens in Figma
2. **Export**: Genera JSON con plugin tokens
3. **Import**: Aggiorna `design_tokens.json`
4. **Code Gen**: Script aggiorna costanti Flutter
5. **Test**: Verifica consistenza visuale

## 🔒 Sicurezza & Privacy

### Data Protection
- **Local Storage** - Dati sensibili mai in cloud
- **Encryption** - Messaggi cifrati localmente AES-256
- **Biometric Auth** - Optional fingerprint/FaceID
- **Session Management** - Token refresh automatico

### Privacy Features
- **No Tracking** - Zero analytics di terze parti
- **Data Minimal** - Raccolta dati minimale
- **User Control** - Export/delete completo dati
- **Transparency** - Privacy policy chiara

## 🧩 Componenti Lo-Fi

### LoFiMessageBubble
Bolle messaggio con stile minimalista e animazioni fluide.

```dart
LoFiMessageBubble(
  message: "Ciao! Come posso aiutarti oggi?",
  type: MessageType.bot,
  timestamp: DateTime.now(),
  isAnimated: true,
)
```

### LoFiInputComposer  
Campo input con registrazione vocale e allegati.

```dart
LoFiInputComposer(
  onSendMessage: (message) => _sendMessage(message),
  onVoiceStart: () => _startVoiceRecording(),
  placeholder: "Scrivi qui...",
)
```

### LoFiQuickSuggestions
Chip suggerimenti contestuali con animazioni smooth.

```dart
LoFiQuickSuggestions(
  suggestions: ["Come stai?", "Parliamo di ansia", "Esercizi mindfulness"],
  onSuggestionTap: (suggestion) => _selectSuggestion(suggestion),
)
```

### LoFiErrorState / LoFiEmptyState
Stati di errore e vuoto con illustrazioni minimali.

```dart
LoFiEmptyState(
  title: "Nessuna conversazione",
  description: "Inizia una nuova chat per cominciare",
  actionText: "Nuova Chat",
  onAction: () => _startNewChat(),
)
```

## 🤝 Contributi

### Come Contribuire
1. **Fork** il repository
2. **Create** feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** changes (`git commit -m 'Add amazing feature'`)
4. **Push** branch (`git push origin feature/amazing-feature`)  
5. **Open** Pull Request

### Coding Standards
- **Dart Style Guide** - Seguire dart style oficial
- **Comments** - Documentazione comprehensive per API pubbliche
- **Tests** - Copertura >90% per nuove feature
- **Accessibility** - Supporto screen reader obbligatorio

## 🌍 Internazionalizzazione

Supporto completo per Italiano e Inglese:

```dart
// Utilizzo
Text(AppLocalizations.of(context)!.welcomeMessage)

// Configurazione
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
)
```

### File di Localizzazione
- `lib/l10n/app_en.arb` - Inglese  
- `lib/l10n/app_it.arb` - Italiano

## ♿ Accessibilità

KAIX include accessibilità completa:

- **Screen Reader** - Label semantici per VoiceOver/TalkBack
- **Contrasto** - Ratio 4.5:1+ per tutti i testi
- **Dimensioni Touch** - Target 44x44pt minimi
- **Navigazione** - Supporto completo da tastiera
- **Annunci Live** - Per messaggi chat in tempo reale

## 📁 Documentazione

- [Design Tokens Mapping](docs/design-to-code-mapping.md) - Mapping completo Figma-Flutter
- [Figma Export Guide](docs/figma-export-guide.md) - Guida export design system
- [Component Library](lib/design_system/components/) - Componenti design system
- [Theme System](lib/design_system/theme/) - Sistema tema customizzato

## 📄 Roadmap

### Fase 2 - Features Avanzate
- [ ] **Sync Cloud** - Backup conversazioni sicuro
- [ ] **Voice Messages** - Messaggi vocali nativi
- [ ] **Smart Notifications** - Promemoria personalizzati
- [ ] **Progress Tracking** - Analisi benessere mentale
- [ ] **Community** - Gruppi supporto anonimi

### Fase 3 - AI Enhancement  
- [ ] **Sentiment Analysis** - Riconoscimento emotivo avanzato
- [ ] **Personalized Coaching** - AI training personalizzato
- [ ] **Crisis Detection** - Intervento automatico emergenze
- [ ] **Wellness Integration** - Sync Apple Health/Google Fit

## 🚀 Comandi Rapidi

```bash
# Setup progetto
git clone <repo> && cd applicazione_mental_coach
flutter pub get && flutter gen-l10n

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

## 👥 Team & Licenza

**Design System Team**
- Design Lead: [Nome]
- Flutter Developer: [Nome]  
- UX Researcher: [Nome]

**Contatti**
- 📧 Email: team@kaixapp.com
- 🐦 Twitter: @kaixapp
- 💬 Discord: [Server Invite]

### 📄 Licenza

Questo progetto è licenziato sotto MIT License - vedi [LICENSE](LICENSE) per dettagli.

---

*"Design che calma, tecnologia che cura"* - **KAIX Team**

**Versione**: 1.0.0  
**Build**: 1 (Phase 2 Complete)  
**Flutter**: 3.16.0+ Required  
**Dart**: 3.2.0+ Required  
**Ultimo Aggiornamento**: Gennaio 2025
