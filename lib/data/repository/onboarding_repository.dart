import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepository {
  final onboardingStatus = 'onboarding_status';
  final SharedPreferences prefs;

  OnboardingRepository({required this.prefs});

  Future<bool> getOnboardingStatus() async {
    return prefs.getBool(onboardingStatus) ?? true;
  }

  void setOnboardingStatus(bool status) {
    prefs.setBool(onboardingStatus, status);
  }
}
