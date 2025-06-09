import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:pixel_scan/data/models/document_model.dart';
import 'package:pixel_scan/data/repository/documents_repository.dart';
import 'package:pixel_scan/data/repository/pdf_repository.dart';
import 'package:pixel_scan/data/repository/subscription_repository.dart';

class DocumentScreenModel extends ChangeNotifier {
  DocumentModel document;
  SubscriptionRepository subscriptionRepository;
  DocumentsRepository documentsRepository;
  PdfRepository pdfRepository;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    if (value != _isLoading) {
      _isLoading = value;
      notifyListeners();
    }
  }

  DocumentScreenModel({
    required this.documentsRepository,
    required this.subscriptionRepository,
    required this.pdfRepository,
    required this.document,
  });

  Future<void> addFiles() async {
    final imagesPath = await CunningDocumentScanner.getPictures();
    if (imagesPath != null && imagesPath.isNotEmpty) {
      document = DocumentModel(
        id: document.id,
        files: document.files + imagesPath,
        createdAt: document.createdAt,
        name: document.name,
      );
      notifyListeners();
    }

    documentsRepository.updateDocument(document);
  }

  Future<File?> createPdf() async {
    File? file;
    try {
      isLoading = true;
      file = await pdfRepository.createPdf(document);
    } catch (_) {
    } finally {
      Future.delayed(Duration(milliseconds: 500), () {
        isLoading = false;
      });
    }

    return file;
  }

  Future<void> shareDocument(File file) async {
    pdfRepository.sharePdf(file);
  }

  void updateDocument() {
    documentsRepository.updateDocument(document);
    notifyListeners();
  }
}
