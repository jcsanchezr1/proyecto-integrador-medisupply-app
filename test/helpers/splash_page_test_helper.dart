import 'package:flutter/material.dart';
import 'package:medisupply_app/src/pages/splash_page.dart';
import 'package:medisupply_app/src/pages/login_page.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';

class SplashPageWrapper extends StatelessWidget {
  final FetchData fetchData;
  final TextsUtil textsUtil;
  const SplashPageWrapper({super.key, required this.fetchData, required this.textsUtil});

  @override
  Widget build(BuildContext context) {
    return SplashPageNavigator(
      fetchData: fetchData,
      textsUtil: textsUtil,
    );
  }
}

class SplashPageNavigator extends StatefulWidget {
  final FetchData fetchData;
  final TextsUtil textsUtil;
  const SplashPageNavigator({super.key, required this.fetchData, required this.textsUtil});

  @override
  State<SplashPageNavigator> createState() => _SplashPageNavigatorState();
}

class _SplashPageNavigatorState extends State<SplashPageNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => SplashPage(),
        );
      },
      observers: [
        _SplashToLoginObserver(
          fetchData: widget.fetchData,
          textsUtil: widget.textsUtil
        )
      ]
    );
  }
}

class _SplashToLoginObserver extends NavigatorObserver {
  final FetchData fetchData;
  final TextsUtil textsUtil;
  _SplashToLoginObserver({required this.fetchData, required this.textsUtil});

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute?.settings.name == null && newRoute is MaterialPageRoute) {
      newRoute.navigator?.pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(fetchData: fetchData, textsUtil: textsUtil)
        )
      );
    }
  }
}