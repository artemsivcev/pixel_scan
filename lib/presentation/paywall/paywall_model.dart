import 'package:flutter/material.dart';
import 'package:pixel_scan/data/repository/subscription_repository.dart';

class PaywallModel extends ChangeNotifier {
  SubscriptionRepository subscriptionRepository;

  SubscriptionType selectedSubscription = SubscriptionType.premiumWeek;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    if (value != _isLoading) {
      _isLoading = value;
      notifyListeners();
    }
  }

  PaywallModel({
    required this.subscriptionRepository,
  });

  void selectSubscription(SubscriptionType type) {
    selectedSubscription = type;
    notifyListeners();
  }

  Future<void> subscribe() async {
    isLoading = true;
    await Future.delayed(Duration(seconds: 2));
    subscriptionRepository.subscribe(selectedSubscription);
    isLoading = false;
  }

  Future<void> restoreSubscription() async {
    isLoading = true;
    await Future.delayed(Duration(seconds: 2));
    subscriptionRepository.subscribe(selectedSubscription);
    isLoading = false;
  }
}
