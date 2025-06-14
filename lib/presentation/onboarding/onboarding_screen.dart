import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:localization/localization.dart';
import 'package:pixel_scan/presentation/common/app_images.dart';
import 'package:pixel_scan/presentation/paywall/paywall_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController(viewportFraction: 1, keepPage: true);

  @override
  void initState() {
    super.initState();
    controller.addListener(() async {
      if (controller.page == 1) {
        final InAppReview inAppReview = InAppReview.instance;

        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF7F7F7),
      body: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned(
            right: 0,
            top: kToolbarHeight.h,
            child: Image.asset(
              AppImages().onboardingBgRightTop,
            ),
          ),
          Positioned(
            left: 24.w,
            top: kToolbarHeight.h,
            child: RotatedBox(
              quarterTurns: 1,
              child: SmoothPageIndicator(
                controller: controller,
                count: 3,
                effect: ExpandingDotsEffect(
                  dotHeight: 5,
                  dotWidth: 12,
                  activeDotColor: Color(0xffFD1524),
                ),
              ),
            ),
          ),
          PageView.builder(
            controller: controller,
            itemCount: 3,
            physics: NeverScrollableScrollPhysics(),
            hitTestBehavior: HitTestBehavior.translucent,
            clipBehavior: Clip.none,
            scrollDirection: Axis.vertical,
            itemBuilder: (_, index) {
              switch (index) {
                case 0:
                  return OnboardingPage(
                    controller: controller,
                    title: 'onboarding_title_1'.i18n(),
                    subtitle: 'onboarding_subtitle_1'.i18n(),
                    image: AppImages().onboardingOne,
                  );
                case 1:
                  return OnboardingPage(
                    controller: controller,
                    title: 'onboarding_title_2'.i18n(),
                    subtitle: 'onboarding_subtitle_2'.i18n(),
                    image: AppImages().onboardingTwo,
                  );
                case 2:
                  return PaywallScreen();
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final PageController controller;
  final String title;
  final String subtitle;
  final String image;

  const OnboardingPage({
    super.key,
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: kToolbarHeight.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 52.w),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 36.sp,
                height: 0.8,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.only(left: 52.w),
            child: Text(
              subtitle,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20.sp,
                height: 1.2,
                color: Color(0xff8b7979),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Center(
              child: Image.asset(
                image,
                width: 330.w,
                height: 450.h,
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight.h),
            child: SizedBox(
              width: double.maxFinite,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 26.w),
                child: FilledButton(
                    onPressed: () {
                      controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Color(0xffFD1524)),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      elevation: WidgetStateProperty.all(8),
                      shadowColor: WidgetStateProperty.all(
                          Color(0xffFD1524).withValues(alpha: 0.36)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(18.r),
                          ),
                        ),
                      ),
                      padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 24.h, vertical: 20.w),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'continue'.i18n(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17.sp,
                            height: 1.2,
                          ),
                        ),
                        Spacer(),
                        SvgPicture.asset(
                          AppVectors().arrowNext,
                          width: 48.w,
                          height: 16.h,
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
