import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubeCarousel extends StatefulWidget {
  final List<String> videoUrls;
  final double width;
  final double height;

  const YouTubeCarousel({
    super.key,
    required this.videoUrls,
    required this.width,
    required this.height,
  });

  @override
  State<YouTubeCarousel> createState() => _YouTubeCarouselState();
}

class _YouTubeCarouselState extends State<YouTubeCarousel> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;
  YoutubePlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrls.isNotEmpty) {
      _loadVideo(_currentIndex);
    }
  }

  void _loadVideo(int index) {
    if (_videoController != null) {
      _videoController!.close();
    }

    String? videoId =
        YoutubePlayerController.convertUrlToId(widget.videoUrls[index]);
    _videoController = YoutubePlayerController.fromVideoId(
      videoId: videoId ?? 'aqz-KE-bpKQ',
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrls.isEmpty) {
      // Si no hay videos, muestra un SizedBox vacío
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: Text(
            'No hay videos disponibles',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: [
        widget.videoUrls.length > 1
            ? CarouselSlider(
                items: List.generate(widget.videoUrls.length, (index) {
                  if (index == _currentIndex) {
                    return YoutubePlayer(
                      controller: _videoController!,
                      aspectRatio: 16 / 9,
                    );
                  } else {
                    return Center(
                      child: Text('Video ${index + 1}'),
                    );
                  }
                }),
                carouselController: _controller,
                options: CarouselOptions(
                  height: widget.height,
                  aspectRatio: widget.width / widget.height,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: false,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                      _loadVideo(index);
                    });
                  },
                  scrollDirection: Axis.horizontal,
                ),
              )
            : YoutubePlayer(
                // Cuando solo hay un video, se muestra directamente
                controller: _videoController!,
                aspectRatio: 16 / 9,
              ),
        if (widget.videoUrls.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _controller.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear,
                ),
              ),
              DotsIndicator(
                dotsCount: widget.videoUrls.length,
                position: _currentIndex,
                decorator: DotsDecorator(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  size: const Size.square(9.0),
                  activeSize: const Size(18.0, 9.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear,
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  void dispose() {
    _videoController?.close();
    super.dispose();
  }
}
