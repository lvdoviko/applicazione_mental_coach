import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../../../core/services/connectivity_service.dart';

/// Offline fallback engine that provides conservative, safe responses
/// when the app is disconnected from the backend platform
class OfflineFallbackEngine {
  final ConnectivityService _connectivityService;
  final Random _random = Random();

  OfflineFallbackEngine({required ConnectivityService connectivityService})
      : _connectivityService = connectivityService;

  /// Check if we should use offline fallback
  bool shouldUseFallback() {
    return _connectivityService.isDisconnected;
  }

  /// Generate a safe, conservative response for offline scenarios
  ChatMessage generateOfflineResponse(String userMessage, {String? sessionId}) {
    final response = _selectAppropriateResponse(userMessage);
    
    return ChatMessage.ai(
      response.text,
      sessionId: sessionId,
      metadata: {
        'offline_mode': true,
        'fallback_type': response.type.name,
        'disclaimer': 'This is an offline response. Full support will resume when connection is restored.',
      },
    );
  }

  /// Analyze user message and select appropriate response category
  OfflineResponse _selectAppropriateResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    // Crisis/Emergency keywords - highest priority
    if (_containsCrisisKeywords(lowerMessage)) {
      return _getCrisisResponse();
    }

    // Stress and anxiety
    if (_containsStressKeywords(lowerMessage)) {
      return _getStressResponse();
    }

    // Sleep-related
    if (_containsSleepKeywords(lowerMessage)) {
      return _getSleepResponse();
    }

    // Performance and competition
    if (_containsPerformanceKeywords(lowerMessage)) {
      return _getPerformanceResponse();
    }

    // Motivation and confidence
    if (_containsMotivationKeywords(lowerMessage)) {
      return _getMotivationResponse();
    }

    // Training and recovery
    if (_containsTrainingKeywords(lowerMessage)) {
      return _getTrainingResponse();
    }

    // General wellness
    if (_containsWellnessKeywords(lowerMessage)) {
      return _getWellnessResponse();
    }

    // Default supportive response
    return _getGeneralSupportResponse();
  }

  // === Crisis Detection and Response ===
  
  bool _containsCrisisKeywords(String message) {
    const crisisKeywords = [
      'suicidal', 'suicide', 'kill myself', 'end it all', 'hurt myself',
      'self harm', 'cutting', 'overdose', 'can\'t go on', 'worthless',
      'hopeless', 'desperate', 'emergency', 'crisis', 'help me'
    ];
    
    return crisisKeywords.any((keyword) => message.contains(keyword));
  }

  OfflineResponse _getCrisisResponse() {
    const responses = [
      "I understand you're going through a very difficult time. Please reach out to a mental health professional or crisis hotline immediately. In Italy, you can contact Telefono Amico at 199 284 284. Your safety and wellbeing are the top priority.",
      "It sounds like you're in distress. Please don't face this alone - contact a crisis support service right away. In Italy: Samaritans 199 284 284, or go to your nearest emergency room. You deserve support and care.",
      "I'm concerned about what you're sharing. Please seek immediate help from a mental health professional or call a crisis line: Italy 199 284 284. You matter, and there are people who want to help you through this difficult time."
    ];

    return OfflineResponse(
      text: responses[_random.nextInt(responses.length)],
      type: OfflineResponseType.crisis,
    );
  }

  // === Stress and Anxiety Responses ===

  bool _containsStressKeywords(String message) {
    const stressKeywords = [
      'stress', 'stressed', 'anxiety', 'anxious', 'worried', 'panic',
      'overwhelmed', 'pressure', 'tense', 'nervous', 'scared', 'afraid'
    ];
    
    return stressKeywords.any((keyword) => message.contains(keyword));
  }

  OfflineResponse _getStressResponse() {
    const responses = [
      "Stress is a natural part of athletic performance, but managing it is key. Try the 4-7-8 breathing technique: inhale for 4, hold for 7, exhale for 8. This can help activate your body's relaxation response.",
      "When feeling overwhelmed, grounding techniques can help. Try the 5-4-3-2-1 method: name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste. This brings you back to the present moment.",
      "Anxiety before competition is normal. Channel that energy positively through visualization - imagine yourself performing successfully. Progressive muscle relaxation can also help release physical tension."
    ];

    return OfflineResponse(
      text: responses[_random.nextInt(responses.length)],
      type: OfflineResponseType.stress,
    );
  }

  // === Sleep-related Responses ===

  bool _containsSleepKeywords(String message) {
    const sleepKeywords = [
      'sleep', 'insomnia', 'tired', 'exhausted', 'fatigue', 'rest',
      'can\'t sleep', 'sleepless', 'restless', 'drowsy'
    ];
    
    return sleepKeywords.any((keyword) => message.contains(keyword));
  }

  OfflineResponse _getSleepResponse() {
    const responses = [
      "Quality sleep is crucial for athletic performance and recovery. Try maintaining a consistent sleep schedule, avoiding screens 1 hour before bed, and keeping your room cool and dark.",
      "Sleep difficulties can impact both performance and mental wellbeing. Consider a pre-sleep routine: light stretching, reading, or meditation. Avoid caffeine 6 hours before bedtime.",
      "For better rest, try the 'sleep hygiene' basics: regular bedtime, comfortable environment, no large meals before bed, and limit daytime naps to 20-30 minutes if needed."
    ];

    return OfflineResponse(
      text: responses[_random.nextInt(responses.length)],
      type: OfflineResponseType.sleep,
    );
  }

  // === Performance and Competition Responses ===

  bool _containsPerformanceKeywords(String message) {
    const performanceKeywords = [
      'performance', 'competition', 'compete', 'game', 'match', 'race',
      'tournament', 'championship', 'pressure', 'choke', 'fail', 'lose'
    ];
    
    return performanceKeywords.any((keyword) => message.contains(keyword));
  }

  OfflineResponse _getPerformanceResponse() {
    const responses = [
      "Peak performance comes from preparation and mindset. Focus on your process rather than outcomes - control what you can control and let go of the rest.",
      "Pre-competition nerves are normal and can actually enhance performance when channeled properly. Use visualization techniques and positive self-talk to build confidence.",
      "Remember that every athlete faces setbacks. What matters is how you respond and learn. Focus on your strengths and the preparation you've done."
    ];

    return OfflineResponse(
      text: responses[_random.nextInt(responses.length)],
      type: OfflineResponseType.performance,
    );
  }

  // === Motivation and Confidence Responses ===

  bool _containsMotivationKeywords(String message) {
    const motivationKeywords = [
      'motivation', 'motivated', 'confidence', 'confident', 'doubt',
      'believe', 'discouraged', 'inspiration', 'goals', 'dreams'
    ];
    
    return motivationKeywords.any((keyword) => message.contains(keyword));
  }

  OfflineResponse _getMotivationResponse() {
    const responses = [
      "Confidence is built through preparation and acknowledging your progress. Reflect on your improvements, no matter how small - each step forward matters.",
      "Motivation fluctuates naturally. On tough days, remember why you started and connect with your deeper 'why'. Sometimes showing up when you don't feel like it builds the strongest character.",
      "Self-belief is a skill that can be developed. Practice positive self-talk and celebrate your efforts, not just results. You're capable of more than you realize."
    ];

    return OfflineResponse(
      text: responses[_random.nextInt(responses.length)],
      type: OfflineResponseType.motivation,
    );
  }

  // === Training and Recovery Responses ===

  bool _containsTrainingKeywords(String message) {
    const trainingKeywords = [
      'training', 'workout', 'exercise', 'recovery', 'injury', 'pain',
      'sore', 'overtraining', 'burnout', 'plateau'
    ];
    
    return trainingKeywords.any((keyword) => message.contains(keyword));
  }

  OfflineResponse _getTrainingResponse() {
    const responses = [
      "Recovery is just as important as training. Make sure you're getting adequate rest, nutrition, and hydration. Listen to your body's signals.",
      "Training plateaus are normal parts of athletic development. Consider varying your routine, focusing on technique, or consulting with a coach for fresh perspectives.",
      "If you're experiencing unusual pain or persistent fatigue, it's important to rest and consider consulting a healthcare professional. Your long-term health is the priority."
    ];

    return OfflineResponse(
      text: responses[_random.nextInt(responses.length)],
      type: OfflineResponseType.training,
    );
  }

  // === General Wellness Responses ===

  bool _containsWellnessKeywords(String message) {
    const wellnessKeywords = [
      'wellness', 'health', 'balance', 'mindfulness', 'meditation',
      'nutrition', 'hydration', 'mental health', 'wellbeing'
    ];
    
    return wellnessKeywords.any((keyword) => message.contains(keyword));
  }

  OfflineResponse _getWellnessResponse() {
    const responses = [
      "Holistic wellness includes physical, mental, and emotional health. Small daily practices like mindful breathing, gratitude, and consistent routines can make a big difference.",
      "Balance is key in athletic pursuits. Make time for activities outside your sport that bring you joy and help you recharge mentally.",
      "Mental wellness is as important as physical fitness. Regular self-check-ins, connecting with supportive people, and stress management are all valuable practices."
    ];

    return OfflineResponse(
      text: responses[_random.nextInt(responses.length)],
      type: OfflineResponseType.wellness,
    );
  }

  // === General Support Response ===

  OfflineResponse _getGeneralSupportResponse() {
    const responses = [
      "I understand you're looking for support. While I'm operating in offline mode with limited capabilities, I want you to know that your feelings and experiences are valid.",
      "Thank you for sharing. In offline mode, I can only provide general support. When connection resumes, I'll be able to offer more personalized guidance based on your specific situation.",
      "I appreciate you reaching out. While my responses are limited in offline mode, please know that seeking support is a positive step. Consider talking to a trusted coach, friend, or counselor."
    ];

    return OfflineResponse(
      text: responses[_random.nextInt(responses.length)],
      type: OfflineResponseType.general,
    );
  }

  /// Generate system message explaining offline mode
  ChatMessage generateOfflineModeExplanation({String? sessionId}) {
    return ChatMessage.system(
      "You're currently offline. I can provide basic support and wellness tips, but my full capabilities will resume when you're connected. For urgent mental health concerns, please contact a healthcare professional.",
      sessionId: sessionId,
      metadata: const {
        'offline_mode': true,
        'message_type': 'explanation',
      },
    );
  }

  /// Generate a message suggesting reconnection
  ChatMessage generateReconnectionSuggestion({String? sessionId}) {
    return ChatMessage.system(
      "I notice you're offline. For personalized guidance and my full coaching capabilities, please check your internet connection.",
      sessionId: sessionId,
      metadata: const {
        'offline_mode': true,
        'message_type': 'reconnection_suggestion',
      },
    );
  }

  /// Check if a response should include crisis resources
  bool _shouldIncludeCrisisResources(OfflineResponseType type) {
    return type == OfflineResponseType.crisis || 
           type == OfflineResponseType.stress;
  }
}

// === Supporting Classes ===

class OfflineResponse {
  final String text;
  final OfflineResponseType type;

  const OfflineResponse({
    required this.text,
    required this.type,
  });
}

enum OfflineResponseType {
  crisis,
  stress,
  sleep,
  performance,
  motivation,
  training,
  wellness,
  general,
}