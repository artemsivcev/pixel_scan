import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:pixel_scan/data/models/document_model.dart';
import 'package:pixel_scan/data/repository/documents_repository.dart';
import 'package:pixel_scan/data/repository/pdf_repository.dart';
import 'package:pixel_scan/data/repository/subscription_repository.dart';
import 'package:pixel_scan/presentation/document/document_screen_model.dart';
import 'package:pixel_scan/presentation/loading/loading_overlay.dart';
import 'package:pixel_scan/router.dart';
import 'package:provider/provider.dart';

class DocumentScreen extends StatefulWidget {
  final DocumentModel document;

  const DocumentScreen({super.key, required this.document});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  late final DocumentScreenModel _model;

  final controller = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      final page = controller.page?.round() ?? 0;
      if (currentPage != page) {
        setState(() {
          currentPage = page;
        });
      }
    });

    _model = DocumentScreenModel(
      subscriptionRepository:
          Provider.of<SubscriptionRepository>(context, listen: false),
      documentsRepository:
          Provider.of<DocumentsRepository>(context, listen: false),
      pdfRepository: Provider.of<PdfRepository>(context, listen: false),
      document: widget.document,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DocumentScreenModel>.value(
      value: _model,
      child: Consumer<DocumentScreenModel>(builder: (_, model, __) {
        if (model.isLoading) {
          Future.delayed(Duration(milliseconds: 200), () {
            if (context.mounted) {
              LoadingOverlay.show(context);
            }
          });
        } else {
          LoadingOverlay.hide();
        }
        return Scaffold(
          backgroundColor: Color(0xffF7F7F7),
          body: Column(
            children: [
              SizedBox(height: kToolbarHeight.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x35353540).withValues(alpha: 0.05),
                        offset: Offset(0, 0),
                        blurRadius: 1,
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          size: 24.h,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                model.document.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18.sp,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            Text(
                              ' | ${currentPage + 1} ${'of'.i18n()} ${model.document.files.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 15.sp,
                                color: Color(0xffCBCBCB),
                                height: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      TextButton(
                        onPressed: () async {
                          final file = await model.createPdf();

                          if (file == null) {
                            return;
                          }

                          if (!model.subscriptionRepository.isSubscribed()) {
                            if (context.mounted) {
                              context.push(paywallRoute, extra: () {
                                model.shareDocument(file);
                              });
                            }
                          } else {
                            model.shareDocument(file);
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'share'.i18n(),
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 17.sp,
                                height: 0.8,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(Icons.share),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(24.h),
                  child: PageView.builder(
                    controller: controller,
                    itemCount: model.document.files.length,
                    itemBuilder: (context, index) {
                      return Image.file(File(model.document.files[index]));
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: 67.h,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: model.document.files.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final needBorder =
                          _isFileCurrentlyVisible(model.document.files[index]);
                      return GestureDetector(
                        onTap: () {
                          controller.jumpToPage(index);
                        },
                        child: Container(
                          height: 67.h,
                          width: 52.w,
                          decoration: BoxDecoration(
                            border: needBorder
                                ? Border.all(
                                    color: Color(0xffFD1524),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Image.file(
                            File(
                              model.document.files[index],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(width: 12.w);
                    },
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16),
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x34343414).withValues(alpha: 0.1),
                      offset: Offset(0, 0),
                      blurRadius: 24,
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        final file = File(model.document.files[currentPage]);
                        context.push(editorRoute, extra: file).then((value) {
                          if (value != null) {
                            model.document.files[currentPage] = value as String;
                            model.updateDocument();
                          }
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit),
                          SizedBox(height: 4),
                          Text(
                            'edit'.i18n(),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        model.addFiles();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add),
                          SizedBox(height: 4),
                          Text(
                            'add'.i18n(),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  bool _isFileCurrentlyVisible(String file) {
    return _model.document.files[currentPage] == file;
  }
}
