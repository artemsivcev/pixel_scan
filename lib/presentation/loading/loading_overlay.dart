import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:localization/localization.dart';
import 'package:pixel_scan/presentation/common/app_images.dart';

class LoadingOverlay {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context) {
    if (_currentOverlay != null) return;

    _currentOverlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.white.withValues(alpha: 0.5),
        child: Stack(
          children: [
            ModalBarrier(
              color: Colors.white.withValues(alpha: 0.5),
              dismissible: false,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages().loading,
                    width: 150,
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'loading'.i18n(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 19.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}
