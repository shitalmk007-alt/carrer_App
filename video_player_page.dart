import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoId;
  final String videoTitle;

  const VideoPlayerPage({
    super.key,
    required this.videoId,
    required this.videoTitle,
  });

  @override
  State<VideoPlayerPage> createState() =>
      _VideoPlayerPageState();
}

class _VideoPlayerPageState
    extends State<VideoPlayerPage> {
  late final YoutubePlayerController controller;

  @override
  void initState() {
    super.initState();

    controller =
        YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
      ),
    );
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerControllerProvider(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.videoTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            YoutubePlayer(
              controller: controller,
              aspectRatio: 16 / 9,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.videoTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}