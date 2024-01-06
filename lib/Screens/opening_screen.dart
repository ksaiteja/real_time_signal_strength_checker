import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:real_time_signal_strength_checker/Screens/color_constants.dart';
import 'package:real_time_signal_strength_checker/Screens/register_screen.dart';

class OpeningPage extends StatefulWidget {
  @override
  _OpeningPageState createState() => _OpeningPageState();
}

class _OpeningPageState extends State<OpeningPage> {
  int _currentPage = 0;
  final List<String> _pages = [
    'assets/opening1.svg',
    'assets/opening2.svg',
    'assets/opening3.svg'
  ];
  final List<String> _texts = [
    'Make connects with explora',
    'To your dream trip',
    'Start Exploring'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 60,
          ),
          Container(
            height:
                MediaQuery.of(context).size.height * 0.5, // adjust as needed
            width: MediaQuery.of(context).size.width, // adjust as needed
            child: SvgPicture.asset(
              _pages[_currentPage],
              // fit: BoxFit.cover, // maintain aspect ratio
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            _texts[_currentPage],
            style: const TextStyle(
              fontSize: 24.0, // adjust as needed
              fontWeight: FontWeight.bold, // adjust as needed
              color: Colors.black, // adjust as needed
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(_pages.length, (int index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 10.0,
                width: 10.0,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? ColorConstants.primary
                      : Colors.grey,
                ),
              );
            }),
          ),
          const SizedBox(
            height: 60,
          ),
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              onPressed: () {
                if (_currentPage == _pages.length - 1) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterScreen()));
                }
                if (_currentPage < _pages.length - 1) {
                  setState(() {
                    _currentPage = (_currentPage + 1);
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
