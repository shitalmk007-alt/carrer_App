import 'package:url_launcher/url_launcher.dart';

class YouTubeService {
  static Future<void> searchVideos(String query) async {
    final encodedQuery = Uri.encodeComponent(query);

    final url = Uri.parse(
      'https://www.youtube.com/results?search_query=$encodedQuery',
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }
}