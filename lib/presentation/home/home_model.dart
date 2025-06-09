import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:pixel_scan/data/models/document_model.dart';
import 'package:pixel_scan/data/repository/documents_repository.dart';
import 'package:pixel_scan/data/repository/pdf_repository.dart';
import 'package:pixel_scan/data/repository/subscription_repository.dart';

class HomeModel extends ChangeNotifier {
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

  List<DocumentModel> allDocuments = [];
  List<DocumentModel> documents = [
    DocumentModel(id: 1, files: [''], createdAt: DateTime.now(), name: 'Test')
  ];
  bool sortAscending = true;

  HomeModel({
    required this.documentsRepository,
    required this.subscriptionRepository,
    required this.pdfRepository,
  });

  void init() {
    allDocuments = documentsRepository.getScannedDocuments();
    // documents = allDocuments;
    notifyListeners();
  }

  Future<void> scanDocument() async {
    final imagesPath = await CunningDocumentScanner.getPictures();
    if (imagesPath != null && imagesPath.isNotEmpty) {
      allDocuments.add(
        DocumentModel(
            id: documents.length + 1,
            files: imagesPath,
            createdAt: DateTime.now(),
            name: 'Document ${documents.length + 1}'),
      );
      documents = allDocuments;
      notifyListeners();
    }

    documentsRepository.saveDocuments(allDocuments);
  }

  void renameDocument(DocumentModel document, String newName) {
    document.name = newName;
    notifyListeners();
    documentsRepository.updateDocument(document);
    init();
  }

  Future<void> printDocument(File file) async {
    pdfRepository.printPdfFile(file);
  }

  Future<File?> createPdf(DocumentModel document) async {
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

  void deleteDocument(DocumentModel document) {
    allDocuments.remove(document);
    documents = allDocuments;
    notifyListeners();
    documentsRepository.saveDocuments(documents);
  }

  void sortDocuments() {
    sortAscending = !sortAscending;
    if (sortAscending) {
      documents.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    notifyListeners();
  }

  void searchDocuments(String text) {
    documents = allDocuments
        .where((element) =>
            element.name.toLowerCase().contains(text.toLowerCase()))
        .toList();
    notifyListeners();
  }
}
