import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class CarouselWithControls extends StatefulWidget {
  final double width;
  final double height;
  final List<String> images;

  const CarouselWithControls({
    super.key,
    required this.width,
    required this.height,
    required this.images,
  });

  @override
  State<CarouselWithControls> createState() => _CarouselWithControlsState();
}

class _CarouselWithControlsState extends State<CarouselWithControls> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          items: widget.images.map((e) {
            return Center(
              child: e.startsWith('http') || e.startsWith('https')
                  ? Image.network(
                      e,
                      fit: BoxFit.cover,
                      width: widget.width,
                      height: widget.height,
                    )
                  : Image.asset(
                      e,
                      fit: BoxFit.cover,
                      width: widget.width,
                      height: widget.height,
                    ),
            );
          }).toList(),
          carouselController: _controller,
          options: CarouselOptions(
            height: widget.height,
            aspectRatio: widget.width / widget.height,
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),
        ),
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
              dotsCount: widget.images.length,
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
}
