import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:pixel_scan/data/models/document_model.dart';
import 'package:pixel_scan/data/repository/documents_repository.dart';
import 'package:pixel_scan/data/repository/pdf_repository.dart';
import 'package:pixel_scan/data/repository/subscription_repository.dart';
import 'package:pixel_scan/presentation/common/app_images.dart';
import 'package:pixel_scan/presentation/home/home_model.dart';
import 'package:pixel_scan/presentation/loading/loading_overlay.dart';
import 'package:pixel_scan/router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeModel _model;
  final searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _model = HomeModel(
      subscriptionRepository:
          Provider.of<SubscriptionRepository>(context, listen: false),
      documentsRepository:
          Provider.of<DocumentsRepository>(context, listen: false),
      pdfRepository: Provider.of<PdfRepository>(context, listen: false),
    )..init();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>.value(
      value: _model,
      child: Consumer<HomeModel>(builder: (_, model, __) {
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: MediaQuery.of(context).viewInsets.bottom > 0
              ? null
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 64.w),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 68,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100.r),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x35353540).withValues(alpha: 0.1),
                                offset: Offset(0, 0),
                                blurRadius: 24,
                                spreadRadius: 0,
                              )
                            ]),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        model.scanDocument();
                      },
                      child: Container(
                        width: 82.w,
                        height: 82.w,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Color(0x35353540).withValues(alpha: 0.25),
                                offset: Offset(0, 0),
                                blurRadius: 12,
                                spreadRadius: 0,
                              )
                            ]),
                        child: Container(
                          width: 79.w,
                          height: 79.w,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Color(0xffFD1524),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(AppVectors().scanButton),
                        ),
                      ),
                    )
                  ],
                ),
          body: Padding(
            padding: EdgeInsets.only(
              top: kToolbarHeight.h + 30.h,
              left: 18.w,
              right: 18.w,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    AppImages().loading,
                    width: 150.w,
                  ),
                  SizedBox(height: 24.h),
                  TextField(
                    controller: searchTextController,
                    onChanged: (text) {
                      model.searchDocuments(text);
                    },
                    decoration: InputDecoration(
                      hintText: 'search'.i18n(),
                      suffixIcon: searchTextController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                searchTextController.clear();
                                model.searchDocuments('');
                              },
                              icon: Icon(Icons.close),
                            )
                          : Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 22.w,
                        vertical: 15.h,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 0),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 0),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 0),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 26.h),
                  if (model.documents.isEmpty)
                    EmptyDocuments()
                  else
                    Padding(
                      padding: EdgeInsets.only(bottom: 120.h),
                      child: DocumentsList(),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class EmptyDocuments extends StatelessWidget {
  const EmptyDocuments({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Color(0x35353540).withValues(alpha: 0.05),
            offset: Offset(0, 0),
            blurRadius: 4,
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'documents'.i18n(),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 21.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages().emptyDocs,
                  width: 190.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 16.h),
                Text(
                  'no-documents'.i18n(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 19.sp,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'tap-to-scan'.i18n(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15.sp,
                    color: Color(0xff767676),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DocumentsList extends StatelessWidget {
  const DocumentsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeModel>(builder: (_, model, __) {
      return Container(
        padding: EdgeInsets.all(16.w),
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Color(0x35353540).withValues(alpha: 0.05),
              offset: Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'documents'.i18n(),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 21.sp,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    model.sortDocuments();
                  },
                  icon: Container(
                    width: 34.w,
                    height: 34.w,
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Color(0xffFD1524),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(AppVectors().swap),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: model.documents.length,
                itemBuilder: (context, index) {
                  return DocumentTile(
                    document: model.documents[index],
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 14.h);
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

class DocumentTile extends StatelessWidget {
  final DocumentModel document;

  const DocumentTile({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeModel>(builder: (_, model, __) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          context.push(documentRoute, extra: document).then((_) {
            model.init();
          });
        },
        child: Container(
          padding: EdgeInsets.all(12.w),
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            color: Color(0xffF7F7F7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Image.file(
                File(document.files.first),
                height: 64.h,
                width: 49.w,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox.shrink();
                },
              ),
              SizedBox(width: 16.w),
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      document.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17.sp,
                      ),
                    ),
                    Text(
                      '${document.files.length} | ${document.createdAt.toString()}',
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        color: Color(0xffCBCBCB),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  showCupertinoModalPopup<void>(
                      context: context,
                      builder: (_) => CupertinoActionSheet(
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                  showRenameBottomSheet(
                                    context,
                                    document.name,
                                    (newName) {
                                      if (document.name != newName) {
                                        model.renameDocument(document, newName);
                                      }
                                    },
                                  );
                                },
                                child: Text(
                                  'rename'.i18n(),
                                ),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  context.pop();
                                  final file = await model.createPdf(document);

                                  if (file == null) return;

                                  if (!context.mounted) return;

                                  if (!model.subscriptionRepository
                                      .isSubscribed()) {
                                    context.push(paywallRoute, extra: () {
                                      model.printDocument(file);
                                    });
                                  } else {
                                    model.printDocument(file);
                                  }
                                },
                                child: Text(
                                  'print'.i18n(),
                                ),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  context.pop();
                                  final file = await model.createPdf(document);

                                  if (file == null) return;

                                  if (!context.mounted) return;

                                  if (!model.subscriptionRepository
                                      .isSubscribed()) {
                                    context.push(paywallRoute, extra: () {
                                      model.shareDocument(file);
                                    });
                                  } else {
                                    model.shareDocument(file);
                                  }
                                },
                                child: Text(
                                  'share'.i18n(),
                                ),
                              ),
                              CupertinoActionSheetAction(
                                isDestructiveAction: true,
                                onPressed: () {
                                  Navigator.pop(context);
                                  model.deleteDocument(document);
                                },
                                child: Text(
                                  'delete'.i18n(),
                                ),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              isDefaultAction: true,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'cancel'.i18n(),
                              ),
                            ),
                          ));
                },
                icon: Icon(
                  Icons.more_vert,
                  color: Color(0xffFD1524),
                  size: 24.w,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

void showRenameBottomSheet(
  BuildContext context,
  String oldName,
  void Function(String newName) onSave,
) {
  final TextEditingController controller = TextEditingController(text: oldName);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 18,
          left: 18,
          right: 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  'Rename',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              focusNode: FocusNode()..requestFocus(),
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Color(0xffFD1524)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Color(0xffFD1524)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffFD1524), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffFD1524),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    final newName = controller.text.trim();
                    if (newName.isNotEmpty) {
                      Navigator.of(context).pop();
                      onSave(newName);
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'save'.i18n(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                      Icon(Icons.check),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
