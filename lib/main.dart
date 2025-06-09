import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:localization/localization.dart';
import 'package:pixel_scan/data/repository/documents_repository.dart';
import 'package:pixel_scan/data/repository/onboarding_repository.dart';
import 'package:pixel_scan/data/repository/pdf_repository.dart';
import 'package:pixel_scan/data/repository/subscription_repository.dart';
import 'package:pixel_scan/router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  LocalJsonLocalization.delegate.directories = ['lib/i18n'];

  final providers = await createProviders();
  runApp(MyApp(providers: providers));
}

Future<List<SingleChildWidget>> createProviders() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final onboardingRepository = OnboardingRepository(prefs: sharedPreferences);
  final subscriptionRepository =
      SubscriptionRepository(prefs: sharedPreferences);
  final documentsRepository = DocumentsRepository(prefs: sharedPreferences);
  final pdfRepository = PdfRepository();

  return [
    Provider<OnboardingRepository>.value(value: onboardingRepository),
    Provider<SubscriptionRepository>.value(value: subscriptionRepository),
    Provider<DocumentsRepository>.value(value: documentsRepository),
    Provider<PdfRepository>.value(value: pdfRepository),
  ];
}

class MyApp extends StatelessWidget {
  final List<SingleChildWidget> providers;

  const MyApp({super.key, required this.providers});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      child: MultiProvider(
        providers: providers,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: [
            LocalJsonLocalization.delegate,
          ],
        ),
      ),
    );
  }
}
