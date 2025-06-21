import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:url_launcher/url_launcher_string.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

///To save the Excel file in the device open_f
///To save the Excel file in the device
Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
  //Get the storage folder location using path_provider package.
  String? path;
  if (Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isLinux ||
      Platform.isWindows) {
    final Directory directory =
        await path_provider.getApplicationSupportDirectory();
    path = directory.path;
  } else {
    path = await PathProviderPlatform.instance.getApplicationSupportPath();
  }
  final File file =
      File(Platform.isWindows ? '$path\\$fileName' : '$path/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  if (Platform.isAndroid || Platform.isIOS || Platform.isWindows) {
    // Launch the file using url_launcher
    final filePath = Platform.isWindows ? '$path\\$fileName' : '$path/$fileName';
    final uri = Uri.file(filePath).toString();
    if (await canLaunchUrlString(uri)) {
      await launchUrlString(uri);
    }
  } else if (Platform.isWindows) {
    await Process.run('start', <String>['$path\\$fileName'], runInShell: true);
  } else if (Platform.isMacOS) {
    await Process.run('open', <String>['$path/$fileName'], runInShell: true);
  } else if (Platform.isLinux) {
    await Process.run('xdg-open', <String>['$path/$fileName'],
        runInShell: true);
  }
}
