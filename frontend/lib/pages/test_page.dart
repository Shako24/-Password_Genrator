import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PageViewExample extends StatefulWidget {
  const PageViewExample({super.key});

  @override
  _PageViewExampleState createState() => _PageViewExampleState();
}

class _PageViewExampleState extends State<PageViewExample> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PageView with Indicator')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: <Widget>[
                Container(color: Colors.red, child: const Center(child: Text('Page 1'))),
                Container(color: Colors.green, child: const Center(child: Text('Page 2'))),
                Container(color: Colors.blue, child: const Center(child: Text('Page 3'))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SmoothPageIndicator(
              controller: _controller,  // PageController
              count: 3,  // Number of pages
              effect: const WormEffect(  // You can change the effect here
                dotHeight: 12,
                dotWidth: 12,
                activeDotColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
