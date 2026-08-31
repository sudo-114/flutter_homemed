import 'package:homemed/main.dart';

class PatientFile {
  static String type(String filePath) {
    final List<String> dir = filePath.split('/');

    if (dir.length > 1) {
      return dir[1];
    }

    return "unknown";
  }

  static Future<String> url(String filePath) async {
    final cacheKey = 'signed_url_$filePath';
    final cached = storage.read(cacheKey);

    if (cached != null) {
      final expiresAt = DateTime.parse(cached['expiresAt']);

      if (DateTime.now().isBefore(expiresAt)) {
        return cached['url'];
      }
    }

    final url = await supabase.storage
        .from('consultation-files')
        .createSignedUrl(filePath, 86400);

    storage.write(cacheKey, {
      'url': url,
      'expiresAt': DateTime.now()
          .add(const Duration(hours: 23))
          .toIso8601String(),
    });

    return url;
  }
}
