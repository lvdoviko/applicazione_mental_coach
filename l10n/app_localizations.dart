import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'KAIX'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Personal AI Coach'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Supporting your mental wellness journey with empathy and understanding'**
  String get onboardingSubtitle;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data'**
  String get consentTitle;

  /// No description provided for @consentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We prioritize your privacy and data security'**
  String get consentSubtitle;

  /// No description provided for @consent.
  ///
  /// In en, this message translates to:
  /// **'I consent to data processing'**
  String get consent;

  /// No description provided for @healthDataPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow health data access'**
  String get healthDataPermission;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notificationPermission;

  /// No description provided for @chatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Share what\'s on your mind...'**
  String get chatPlaceholder;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @voiceToText.
  ///
  /// In en, this message translates to:
  /// **'Voice to Text'**
  String get voiceToText;

  /// No description provided for @quickReplies.
  ///
  /// In en, this message translates to:
  /// **'Quick Replies'**
  String get quickReplies;

  /// No description provided for @escalateToHuman.
  ///
  /// In en, this message translates to:
  /// **'Talk to a Human Coach'**
  String get escalateToHuman;

  /// No description provided for @customizeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Customize Avatar'**
  String get customizeAvatar;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start voice recording'**
  String get startRecording;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stopRecording;

  /// No description provided for @aiCoachTyping.
  ///
  /// In en, this message translates to:
  /// **'AI Coach is typing...'**
  String get aiCoachTyping;

  /// No description provided for @messageDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get messageDelivered;

  /// No description provided for @messageRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get messageRead;

  /// No description provided for @messageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send'**
  String get messageFailed;

  /// No description provided for @attachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get attachFile;

  /// No description provided for @addAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add attachment'**
  String get addAttachment;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// No description provided for @noConversationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with your AI coach to begin your wellness journey.'**
  String get noConversationsMessage;

  /// No description provided for @newConversation.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get newConversation;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchConversations;

  /// No description provided for @conversationPreview.
  ///
  /// In en, this message translates to:
  /// **'Conversation preview'**
  String get conversationPreview;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme throughout the app'**
  String get darkModeDescription;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

  /// No description provided for @themeColorDescription.
  ///
  /// In en, this message translates to:
  /// **'Customize accent colors'**
  String get themeColorDescription;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// No description provided for @textSizeDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust font size and accessibility'**
  String get textSizeDescription;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Sounds'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Get notified about new messages'**
  String get pushNotificationsDescription;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @soundEffectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Play sounds for interactions'**
  String get soundEffectsDescription;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Feel vibrations for interactions'**
  String get hapticFeedbackDescription;

  /// No description provided for @privacyAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyAndSecurity;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDescription.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get privacyPolicyDescription;

  /// No description provided for @dataEncryption.
  ///
  /// In en, this message translates to:
  /// **'Data Encryption'**
  String get dataEncryption;

  /// No description provided for @dataEncryptionDescription.
  ///
  /// In en, this message translates to:
  /// **'View security details'**
  String get dataEncryptionDescription;

  /// No description provided for @anonymousAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Analytics'**
  String get anonymousAnalytics;

  /// No description provided for @anonymousAnalyticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Help improve the app (optional)'**
  String get anonymousAnalyticsDescription;

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your Data'**
  String get yourData;

  /// No description provided for @dataExport.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get dataExport;

  /// No description provided for @dataExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Download your conversation history'**
  String get dataExportDescription;

  /// No description provided for @syncSettings.
  ///
  /// In en, this message translates to:
  /// **'Sync Settings'**
  String get syncSettings;

  /// No description provided for @syncSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Backup and sync across devices'**
  String get syncSettingsDescription;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get deleteAccountDescription;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all data. This action cannot be undone.'**
  String get deleteAccountWarning;

  /// No description provided for @supportAndFeedback.
  ///
  /// In en, this message translates to:
  /// **'Support & Feedback'**
  String get supportAndFeedback;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @helpCenterDescription.
  ///
  /// In en, this message translates to:
  /// **'Find answers and tutorials'**
  String get helpCenterDescription;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @sendFeedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Report issues or suggest features'**
  String get sendFeedbackDescription;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Version info and legal'**
  String get aboutDescription;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @criticalError.
  ///
  /// In en, this message translates to:
  /// **'Critical Error'**
  String get criticalError;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionError;

  /// No description provided for @connectionErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server. Please check your internet connection and try again.'**
  String get connectionErrorMessage;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverError;

  /// No description provided for @serverErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our end. Our team has been notified and is working on a fix.'**
  String get serverErrorMessage;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid Input'**
  String get invalidInput;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @permissionRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This feature requires additional permissions to function properly.'**
  String get permissionRequiredMessage;

  /// No description provided for @underMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Under Maintenance'**
  String get underMaintenance;

  /// No description provided for @underMaintenanceMessage.
  ///
  /// In en, this message translates to:
  /// **'The app is temporarily unavailable for scheduled maintenance. Please try again shortly.'**
  String get underMaintenanceMessage;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @fixInput.
  ///
  /// In en, this message translates to:
  /// **'Fix Input'**
  String get fixInput;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipForNow;

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'Check Again'**
  String get checkAgain;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noSearchResults;

  /// No description provided for @noSearchResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms or browse all conversations.'**
  String get noSearchResultsMessage;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get allCaughtUp;

  /// No description provided for @allCaughtUpMessage.
  ///
  /// In en, this message translates to:
  /// **'You have no new notifications. Check back later for updates.'**
  String get allCaughtUpMessage;

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get connectionLost;

  /// No description provided for @connectionLostMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get connectionLostMessage;

  /// No description provided for @nothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get nothingHere;

  /// No description provided for @nothingHereMessage.
  ///
  /// In en, this message translates to:
  /// **'This section will populate with content as you use the app.'**
  String get nothingHereMessage;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @sendMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Sends your message to the AI coach'**
  String get sendMessageHint;

  /// No description provided for @voiceRecordingHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to start recording a voice message'**
  String get voiceRecordingHint;

  /// No description provided for @stopRecordingHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to stop voice recording and send message'**
  String get stopRecordingHint;

  /// No description provided for @attachmentHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to add files, images, or other attachments to your message'**
  String get attachmentHint;

  /// No description provided for @messageInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Message input'**
  String get messageInputLabel;

  /// No description provided for @messageInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type your message to the AI coach'**
  String get messageInputHint;

  /// No description provided for @retryMessage.
  ///
  /// In en, this message translates to:
  /// **'Double tap to retry sending message'**
  String get retryMessage;

  /// No description provided for @aiCoachMessage.
  ///
  /// In en, this message translates to:
  /// **'AI Coach response'**
  String get aiCoachMessage;

  /// No description provided for @userMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get userMessage;

  /// No description provided for @systemMessage.
  ///
  /// In en, this message translates to:
  /// **'System message'**
  String get systemMessage;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howAreYouFeeling;

  /// No description provided for @needSupport.
  ///
  /// In en, this message translates to:
  /// **'I need some support'**
  String get needSupport;

  /// No description provided for @stressedAnxious.
  ///
  /// In en, this message translates to:
  /// **'I\'m feeling stressed and anxious'**
  String get stressedAnxious;

  /// No description provided for @celebrateSuccess.
  ///
  /// In en, this message translates to:
  /// **'I want to celebrate a success'**
  String get celebrateSuccess;

  /// No description provided for @copingStrategies.
  ///
  /// In en, this message translates to:
  /// **'Can you suggest coping strategies?'**
  String get copingStrategies;

  /// No description provided for @mindfulnessExercise.
  ///
  /// In en, this message translates to:
  /// **'Guide me through a mindfulness exercise'**
  String get mindfulnessExercise;

  /// No description provided for @talkAboutGoals.
  ///
  /// In en, this message translates to:
  /// **'I\'d like to talk about my goals'**
  String get talkAboutGoals;

  /// No description provided for @processEmotions.
  ///
  /// In en, this message translates to:
  /// **'Help me process my emotions'**
  String get processEmotions;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @moodToday.
  ///
  /// In en, this message translates to:
  /// **'How\'s your mood today?'**
  String get moodToday;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @wellnessInsights.
  ///
  /// In en, this message translates to:
  /// **'Wellness Insights'**
  String get wellnessInsights;

  /// No description provided for @progressOverview.
  ///
  /// In en, this message translates to:
  /// **'Progress Overview'**
  String get progressOverview;

  /// No description provided for @recommendedActions.
  ///
  /// In en, this message translates to:
  /// **'Recommended Actions'**
  String get recommendedActions;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
