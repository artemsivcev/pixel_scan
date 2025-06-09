import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionType {
  free,
  premiumWeek,
  premiumYear,
}

class SubscriptionRepository {
  final subscriptionStatus = 'subscription_status';
  final SharedPreferences prefs;

  SubscriptionRepository({required this.prefs});

  void subscribe(SubscriptionType type) {
    prefs.setStringList(
      subscriptionStatus,
      [
        DateTime.now().toString(),
        type.toString(),
      ],
    );
  }

  bool isSubscribed() {
    final subscription = prefs.getStringList(subscriptionStatus);
    if (subscription == null) {
      return false;
    }

    final subscriptionType = SubscriptionType.values.firstWhere(
      (type) => type.toString() == subscription[1],
    );
    if (subscriptionType == SubscriptionType.free) {
      return false;
    }

    final lastSubscriptionDate = DateTime.parse(subscription[0]);
    final now = DateTime.now();

    if (subscriptionType == SubscriptionType.premiumWeek) {
      return now.difference(lastSubscriptionDate).inMinutes >=
          7; // Not inDays, cause, why should it be inDays right now
    } else {
      return now.difference(lastSubscriptionDate).inMinutes >= 365;
    }
  }
}
