import 'dart:convert';

import 'package:pixel_scan/data/models/document_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentsRepository {
  final documentsKey = 'documents';
  final SharedPreferences prefs;

  DocumentsRepository({required this.prefs});

  List<DocumentModel> getScannedDocuments() {
    final jsonList = prefs.getStringList(documentsKey);

    if (jsonList == null) return <DocumentModel>[];

    return jsonList
        .map((jsonStr) => DocumentModel.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  void saveDocuments(List<DocumentModel> documents) {
    final jsonList = documents.map((doc) => jsonEncode(doc.toJson())).toList();

    prefs.setStringList(documentsKey, jsonList);
  }

  void updateDocument(DocumentModel updatedDoc) {
    final documents = getScannedDocuments();

    final index = documents.indexWhere((doc) => doc.id == updatedDoc.id);
    if (index == -1) return;

    documents[index] = updatedDoc;

    saveDocuments(documents);
  }
}
