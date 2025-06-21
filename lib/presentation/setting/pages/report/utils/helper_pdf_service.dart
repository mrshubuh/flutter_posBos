import 'dart:io';
import 'dart:developer';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HelperPdfService {
  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    try {
      final bytes = await pdf.save();

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$name');
      log("file: $file");
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      log("Failed to save document: $e");
      return Future.error("Failed to save document: $e");
    }
  }

  static Future<void> openFile(File file) async {
    try {
      final url = Uri.file(file.path).toString();
      log("Opening file: $url");
      
      if (await canLaunchUrlString(url)) {
        await launchUrlString(
          url,
          mode: LaunchMode.externalApplication,
        );
        log("Successfully launched file: $url");
      } else {
        log("Could not launch URL: $url");
      }
    } catch (e) {
      log("Failed to open file: $e");
      rethrow;
    }
  }
}
