import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:pixel_scan/data/repository/subscription_repository.dart';
import 'package:pixel_scan/presentation/common/app_images.dart';
import 'package:pixel_scan/presentation/loading/loading_overlay.dart';
import 'package:pixel_scan/presentation/paywall/paywall_model.dart';
import 'package:pixel_scan/router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallScreen extends StatefulWidget {
  final VoidCallback? postAction;

  const PaywallScreen({
    super.key,
    this.postAction,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  late final PaywallModel _model;

  @override
  void initState() {
    super.initState();

    _model = PaywallModel(
      subscriptionRepository:
          Provider.of<SubscriptionRepository>(context, listen: false),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor:
            widget.postAction != null ? Color(0xffF7F7F7) : Colors.transparent,
        body: ChangeNotifierProvider<PaywallModel>.value(
          value: _model,
          child: Consumer<PaywallModel>(builder: (_, model, __) {
            if (model.isLoading) {
              Future.delayed(Duration(milliseconds: 200), () {
                if (context.mounted) {
                  LoadingOverlay.show(context);
                }
              });
            } else {
              LoadingOverlay.hide();
            }

            return Padding(
              padding: EdgeInsets.only(top: kToolbarHeight.h),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(left: 52),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 36.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    height: 1,
                                  ),
                                  children: [
                                    TextSpan(text: 'paywall_title_1'.i18n()),
                                    TextSpan(
                                      text: 'paywall_title_2'.i18n(),
                                      style: TextStyle(
                                        color: Color(0xffFD1524),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'paywall_title_3'.i18n(),
                                    ),
                                  ],
                                ),
                              )),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(right: 28.w),
                            child: IconButton(
                                onPressed: () {
                                  context.go(homeRoute);
                                },
                                icon: Icon(
                                  Icons.close,
                                  size: 32.sp,
                                  color: Colors.black.withValues(alpha: 0.1),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Padding(
                        padding: EdgeInsets.only(left: 52.w),
                        child: Text(
                          'paywall_subtitle'.i18n(),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 20.sp,
                            height: 1.2,
                            color: Color(0xff8b7979),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.w),
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Image.asset(
                              AppImages().paywall,
                              width: ScreenUtil().screenWidth,
                              fit: BoxFit.fitWidth,
                            ),
                            Positioned(
                              right: 32,
                              top: -24,
                              child: SvgPicture.asset(
                                AppVectors().rocket,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding:
                          EdgeInsets.only(bottom: kBottomNavigationBarHeight.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 26.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SubscriptionButton(
                                  isSelected: model.selectedSubscription ==
                                      SubscriptionType.premiumWeek,
                                  title: 'week'.i18n(),
                                  subtitle: '3-day-trial'.i18n(),
                                  price: '1.99\$',
                                  onPressed: () {
                                    model.selectSubscription(
                                        SubscriptionType.premiumWeek);
                                  },
                                ),
                                SizedBox(height: 12.h),
                                SubscriptionButton(
                                  isSelected: model.selectedSubscription ==
                                      SubscriptionType.premiumYear,
                                  title: 'year'.i18n(),
                                  price: '10.99\$',
                                  onPressed: () {
                                    model.selectSubscription(
                                        SubscriptionType.premiumYear);
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          SizedBox(
                            width: double.maxFinite,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 26.w),
                              child: FilledButton(
                                  onPressed: () {
                                    model.subscribe().then((_) {
                                      if (widget.postAction != null) {
                                        if (context.mounted) {
                                          context.pop();
                                        }
                                        widget.postAction?.call();
                                      } else {
                                        if (context.mounted) {
                                          context.go(homeRoute);
                                        }
                                      }
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Color(0xffFD1524)),
                                    foregroundColor:
                                        WidgetStateProperty.all(Colors.white),
                                    elevation: WidgetStateProperty.all(8),
                                    shadowColor: WidgetStateProperty.all(
                                        Color(0xffFD1524)
                                            .withValues(alpha: 0.36)),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(18.r),
                                        ),
                                      ),
                                    ),
                                    padding: WidgetStateProperty.all(
                                      EdgeInsets.symmetric(
                                          horizontal: 24.h, vertical: 20.w),
                                    ),
                                  ),
                                  child: Center(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          model.selectedSubscription ==
                                                  SubscriptionType.premiumWeek
                                              ? 'start-free-trial'.i18n()
                                              : 'continue'.i18n(),
                                          textAlign: TextAlign.center,
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
                                    ),
                                  )),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 26.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    model.restoreSubscription().then((_) {
                                      if (widget.postAction != null) {
                                        if (context.mounted) {
                                          context.pop();
                                        }
                                        widget.postAction?.call();
                                      } else {
                                        if (context.mounted) {
                                          context.go(homeRoute);
                                        }
                                      }
                                    });
                                  },
                                  child: Text(
                                    'restore'.i18n(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.sp,
                                      color: Color(0xff8B7979),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 14.h,
                                  width: 1.5.w,
                                  color: Color(0xff8B7979),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    launchUrl(Uri.parse('https://google.com'));
                                  },
                                  child: Text(
                                    'privacy'.i18n(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.sp,
                                      color: Color(0xff8B7979),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 14.h,
                                  width: 1.5.w,
                                  color: Color(0xff8B7979),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    launchUrl(Uri.parse('https://google.com'));
                                  },
                                  child: Text(
                                    'terms'.i18n(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.sp,
                                      color: Color(0xff8B7979),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class SubscriptionButton extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String? subtitle;
  final String price;
  final VoidCallback onPressed;

  const SubscriptionButton({
    super.key,
    required this.isSelected,
    required this.title,
    required this.price,
    required this.onPressed,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 68.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? Color(0xffFD1524) : Colors.white,
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                    ),
                  ),
              ],
            ),
            Spacer(),
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
