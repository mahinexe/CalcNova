import 'dart:async';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackService {
  const FeedbackService._();

  static void onControlTap(SharedPreferences preferences) {
    if (preferences.getBool('haptics') ?? true) {
      HapticFeedback.lightImpact();
    }
    if (preferences.getBool('sound') ?? false) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
  }
}
