// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'KAIX';

  @override
  String get welcome => 'Benvenuto';

  @override
  String get getStarted => 'Inizia';

  @override
  String get continueButton => 'Continua';

  @override
  String get skip => 'Salta';

  @override
  String get done => 'Fatto';

  @override
  String get cancel => 'Annulla';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Riprova';

  @override
  String get close => 'Chiudi';

  @override
  String get dismiss => 'Ignora';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get search => 'Cerca';

  @override
  String get loading => 'Caricamento...';

  @override
  String get onboardingTitle => 'Il Tuo AI Mental Coach Personale';

  @override
  String get onboardingSubtitle =>
      'Supportiamo la tua performance mentale con professionalità e competenza';

  @override
  String get welcomeFeature1 => 'Consulenza\nPersonalizzata';

  @override
  String get welcomeFeature2 => 'Supporto\nH24';

  @override
  String get welcomeFeature3 => 'Privacy\nTotale';

  @override
  String get welcomeTerms =>
      'Continuando accetti i Termini di Servizio\ne la Privacy Policy.';

  @override
  String welcomeUser(String userName) {
    return 'Ciao, $userName';
  }

  @override
  String get yourCoaches => 'I Tuoi Coach';

  @override
  String get selectCoach => 'Seleziona Coach';

  @override
  String welcomeMessage(String coachName) {
    return 'Ciao! Sono $coachName, il tuo Mental Performance Coach. Sono qui per ottimizzare il tuo mindset. Come ti senti oggi?';
  }

  @override
  String get consentTitle => 'Privacy e Dati';

  @override
  String get consentSubtitle =>
      'Diamo priorità alla tua privacy e alla sicurezza dei dati';

  @override
  String get consent => 'Acconsento al trattamento dei dati';

  @override
  String get healthDataPermission => 'Consenti accesso ai dati sanitari';

  @override
  String get notificationPermission => 'Abilita notifiche';

  @override
  String get languageSelectionTitle => 'Scegli la tua lingua';

  @override
  String get journeyStartsHere => 'Il tuo coaching inizia qui';

  @override
  String get userDetailsTitle => 'Piacere di conoscerti';

  @override
  String get userDetailsSubtitle => 'Raccontaci qualcosa di te';

  @override
  String get nameLabel => 'Come ti chiami?';

  @override
  String get genderLabel => 'Genere';

  @override
  String get yourAgeLabel => 'LA TUA ETÀ';

  @override
  String get genderMale => 'Maschio';

  @override
  String get genderFemale => 'Femmina';

  @override
  String get genderOther => 'Altro';

  @override
  String get avatarSelectionTitle => 'Scegli la tua guida';

  @override
  String get avatarSelectionSubtitle => 'Chi ti accompagnerà nel tuo percorso?';

  @override
  String get coachAtlas => 'Atlas';

  @override
  String get coachSerena => 'Serena';

  @override
  String get coachAtlasDesc => 'Resilienza, Focus, Strategia';

  @override
  String get coachSerenaDesc => 'Empatia, Calma, Intuizione';

  @override
  String get startJourney => 'Inizia il Coaching';

  @override
  String get back => 'Indietro';

  @override
  String loadingConfiguring(String coachName) {
    return 'Configurazione di $coachName...';
  }

  @override
  String loadingCalibrating(String userName) {
    return 'Calibrazione del piano per $userName...';
  }

  @override
  String get loadingReady => 'Tutto pronto.';

  @override
  String get chatPlaceholder => 'Condividi cosa hai in mente...';

  @override
  String get send => 'Invia';

  @override
  String get sending => 'Invio in corso...';

  @override
  String get voiceToText => 'Voce in Testo';

  @override
  String get quickReplies => 'Risposte Rapide';

  @override
  String get escalateToHuman => 'Parla con un Coach Umano';

  @override
  String get customizeAvatar => 'Personalizza Avatar';

  @override
  String get startRecording => 'Inizia registrazione vocale';

  @override
  String get stopRecording => 'Interrompi registrazione';

  @override
  String get aiCoachTyping => 'Il Coach AI sta scrivendo...';

  @override
  String get messageDelivered => 'Consegnato';

  @override
  String get messageRead => 'Letto';

  @override
  String get messageFailed => 'Invio fallito';

  @override
  String get attachFile => 'Allega file';

  @override
  String get addAttachment => 'Aggiungi allegato';

  @override
  String get conversations => 'Conversazioni';

  @override
  String get noConversations => 'Nessuna conversazione ancora';

  @override
  String get noConversationsMessage =>
      'Inizia una conversazione con il tuo coach AI per iniziare il tuo percorso di benessere.';

  @override
  String get newConversation => 'Nuova conversazione';

  @override
  String get searchConversations => 'Cerca conversazioni...';

  @override
  String get conversationPreview => 'Anteprima conversazione';

  @override
  String get settings => 'Impostazioni';

  @override
  String get appearance => 'Aspetto';

  @override
  String get darkMode => 'Modalità Scura';

  @override
  String get darkModeDescription => 'Usa il tema scura in tutta l\'app';

  @override
  String get themeColor => 'Colore del Tema';

  @override
  String get themeColorDescription => 'Personalizza i colori principali';

  @override
  String get textSize => 'Dimensione Testo';

  @override
  String get textSizeDescription => 'Regola dimensione font e accessibilità';

  @override
  String get notifications => 'Notifiche e Suoni';

  @override
  String get pushNotifications => 'Notifiche Push';

  @override
  String get pushNotificationsDescription =>
      'Ricevi notifiche per nuovi messaggi';

  @override
  String get soundEffects => 'Effetti Sonori';

  @override
  String get soundEffectsDescription => 'Riproduci suoni per le interazioni';

  @override
  String get hapticFeedback => 'Feedback Aptico';

  @override
  String get hapticFeedbackDescription =>
      'Senti le vibrazioni per le interazioni';

  @override
  String get sidebarChat => 'Chat';

  @override
  String get freePlan => 'PIANO GRATUITO';

  @override
  String get privacyAndSecurity => 'Privacy e Sicurezza';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyPolicy => 'Informativa sulla Privacy';

  @override
  String get privacyPolicyDescription =>
      'Leggi la nostra informativa sulla privacy';

  @override
  String get dataEncryption => 'Crittografia Dati';

  @override
  String get dataEncryptionDescription => 'Visualizza i dettagli di sicurezza';

  @override
  String get anonymousAnalytics => 'Analisi Anonime';

  @override
  String get anonymousAnalyticsDescription =>
      'Aiuta a migliorare l\'app (opzionale)';

  @override
  String get yourData => 'I Tuoi Dati';

  @override
  String get dataExport => 'Esporta Dati';

  @override
  String get dataExportDescription =>
      'Scarica la cronologia delle tue conversazioni';

  @override
  String get syncSettings => 'Impostazioni Sincronizzazione';

  @override
  String get syncSettingsDescription =>
      'Backup e sincronizzazione su dispositivi';

  @override
  String get deleteAccount => 'Elimina Account';

  @override
  String get deleteAccountDescription =>
      'Elimina permanentemente il tuo account';

  @override
  String get deleteAccountWarning =>
      'Questo eliminerà permanentemente il tuo account e tutti i dati. Questa azione non può essere annullata.';

  @override
  String get supportAndFeedback => 'Supporto e Feedback';

  @override
  String get helpCenter => 'Centro Assistenza';

  @override
  String get helpCenterDescription => 'Trova risposte e tutorial';

  @override
  String get sendFeedback => 'Invia Feedback';

  @override
  String get sendFeedbackDescription =>
      'Segnala problemi o suggerisci funzionalità';

  @override
  String get about => 'Informazioni';

  @override
  String get aboutDescription => 'Informazioni versione e legali';

  @override
  String get error => 'Errore';

  @override
  String get warning => 'Avviso';

  @override
  String get information => 'Informazioni';

  @override
  String get criticalError => 'Errore Critico';

  @override
  String get connectionError => 'Errore di Connessione';

  @override
  String get connectionErrorMessage =>
      'Impossibile connettersi al server. Controlla la connessione internet e riprova.';

  @override
  String get serverError => 'Errore del Server';

  @override
  String get serverErrorMessage =>
      'Qualcosa è andato storto dal nostro lato. Il nostro team è stato notificato e sta lavorando a una soluzione.';

  @override
  String get invalidInput => 'Input Non Valido';

  @override
  String get permissionRequired => 'Autorizzazione Richiesta';

  @override
  String get permissionRequiredMessage =>
      'Questa funzionalità richiede autorizzazioni aggiuntive per funzionare correttamente.';

  @override
  String get underMaintenance => 'In Manutenzione';

  @override
  String get underMaintenanceMessage =>
      'L\'app è temporaneamente non disponibile per manutenzione programmata. Riprova tra poco.';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get contactSupport => 'Contatta il Supporto';

  @override
  String get fixInput => 'Correggi Input';

  @override
  String get grantPermission => 'Concedi Autorizzazione';

  @override
  String get skipForNow => 'Salta per Ora';

  @override
  String get checkAgain => 'Controlla di Nuovo';

  @override
  String get noSearchResults => 'Nessun risultato trovato';

  @override
  String get noSearchResultsMessage =>
      'Prova a modificare i termini di ricerca o sfoglia tutte le conversazioni.';

  @override
  String get clearSearch => 'Cancella Ricerca';

  @override
  String get allCaughtUp => 'Tutto aggiornato';

  @override
  String get allCaughtUpMessage =>
      'Non hai nuove notifiche. Controlla più tardi per aggiornamenti.';

  @override
  String get connectionLost => 'Connessione persa';

  @override
  String get connectionLostMessage =>
      'Controlla la connessione internet e riprova.';

  @override
  String get nothingHere => 'Niente qui';

  @override
  String get nothingHereMessage =>
      'Questa sezione si popolerà con contenuti man mano che usi l\'app.';

  @override
  String get sendMessage => 'Invia messaggio';

  @override
  String get sendMessageHint => 'Invia il tuo messaggio al coach AI';

  @override
  String get voiceRecordingHint =>
      'Tocca per iniziare a registrare un messaggio vocale';

  @override
  String get stopRecordingHint =>
      'Tocca per interrompere la registrazione vocale e inviare il messaggio';

  @override
  String get attachmentHint =>
      'Tocca per aggiungere file, immagini o altri allegati al messaggio';

  @override
  String get messageInputLabel => 'Input messaggio';

  @override
  String get messageInputHint => 'Scrivi il tuo messaggio al coach AI';

  @override
  String get retryMessage =>
      'Tocca due volte per riprovare l\'invio del messaggio';

  @override
  String get aiCoachMessage => 'Risposta del Coach AI';

  @override
  String get userMessage => 'Il tuo messaggio';

  @override
  String get systemMessage => 'Messaggio di sistema';

  @override
  String get howAreYouFeeling => 'Come ti senti oggi?';

  @override
  String get needSupport => 'Ho bisogno di supporto';

  @override
  String get stressedAnxious => 'Mi sento stressato e ansioso';

  @override
  String get celebrateSuccess => 'Voglio celebrare un successo';

  @override
  String get copingStrategies => 'Puoi suggerire strategie di coping?';

  @override
  String get mindfulnessExercise =>
      'Guidami attraverso un esercizio di mindfulness';

  @override
  String get talkAboutGoals => 'Vorrei parlare dei miei obiettivi';

  @override
  String get processEmotions => 'Aiutami a elaborare le mie emozioni';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get welcomeBack => 'Bentornato';

  @override
  String get moodToday => 'Come va l\'umore oggi?';

  @override
  String get recentActivity => 'Attività Recente';

  @override
  String get wellnessInsights => 'Approfondimenti sul Benessere';

  @override
  String get progressOverview => 'Panoramica Progressi';

  @override
  String get recommendedActions => 'Azioni Consigliate';

  @override
  String get morningBriefingInsight =>
      'Il tuo recupero è all\'85%. Sei pronto per una sessione di focus?';

  @override
  String get startActivation => 'Inizia Attivazione (3 min)';

  @override
  String get mentalEnergy => 'Energia Mentale';

  @override
  String get biometrics => 'Biometria';

  @override
  String get sleep => 'Sonno';

  @override
  String get hrv => 'HRV';

  @override
  String get rhr => 'RHR';

  @override
  String get trend => 'Trend';

  @override
  String get focusIncreasing => 'Focus in aumento';

  @override
  String get coherenceImproved =>
      'La tua coerenza è migliorata del 15% questa settimana.';

  @override
  String get now => 'ora';

  @override
  String minutesAgo(int count) {
    return '${count}m fa';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h fa';
  }

  @override
  String get yesterday => 'ieri';

  @override
  String daysAgo(int count) {
    return '$count giorni fa';
  }
}
