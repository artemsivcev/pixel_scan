import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_scan/data/models/document_model.dart';
import 'package:pixel_scan/data/repository/onboarding_repository.dart';
import 'package:pixel_scan/presentation/document/document_screen.dart';
import 'package:pixel_scan/presentation/editor/editor_screen.dart';
import 'package:pixel_scan/presentation/home/home_screen.dart';
import 'package:pixel_scan/presentation/onboarding/onboarding_screen.dart';
import 'package:pixel_scan/presentation/paywall/paywall_screen.dart';
import 'package:provider/provider.dart';

final homeRoute = '/';
final onboardingRoute = '/onboarding';
final documentRoute = '/document';
final editorRoute = '/editor';
final paywallRoute = '/paywall';

final router = GoRouter(
  initialLocation: homeRoute,
  routes: [
    GoRoute(
      path: homeRoute,
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: onboardingRoute,
      builder: (context, state) => OnboardingScreen(),
    ),
    GoRoute(
      path: documentRoute,
      builder: (context, state) =>
          DocumentScreen(document: state.extra as DocumentModel),
    ),
    GoRoute(
      path: editorRoute,
      builder: (context, state) => EditorScreen(file: state.extra as File),
    ),
    GoRoute(
      path: paywallRoute,
      builder: (context, state) =>
          PaywallScreen(postAction: state.extra as VoidCallback?),
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) async {
    final onboardingRepo =
        Provider.of<OnboardingRepository>(context, listen: false);
    final isShowOnboarding = await onboardingRepo.getOnboardingStatus();

    FlutterNativeSplash.remove();

    if (isShowOnboarding) {
      onboardingRepo.setOnboardingStatus(false);
      return onboardingRoute;
    }

    return null;
  },
);
