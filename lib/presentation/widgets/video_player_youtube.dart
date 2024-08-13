import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class PlayerWidget extends StatelessWidget {
  final String videoUrl;
  const PlayerWidget({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    String? videoId = YoutubePlayerController.convertUrlToId(videoUrl);
    return YoutubePlayer(
      controller: YoutubePlayerController.fromVideoId(
        videoId: videoId ?? 'https://www.youtube.com/watch?v=aqz-KE-bpKQ',
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      ),
      aspectRatio: 16 / 9,
    );
  }
}
