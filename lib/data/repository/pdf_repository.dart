import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pixel_scan/data/models/document_model.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PdfRepository {
  PdfRepository();

  Future<File> createPdf(DocumentModel document) async {
    final pdf = pw.Document();

    for (final path in document.files) {
      final image = pw.MemoryImage(File(path).readAsBytesSync());
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Center(child: pw.Image(image));
          },
          margin: pw.EdgeInsets.zero,
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${document.name}.pdf');
    return await file.writeAsBytes(await pdf.save());
  }

  Future<void> printPdfFile(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }

  void sharePdf(File file) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }
}
