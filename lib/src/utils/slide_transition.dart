import 'package:flutter/material.dart';

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  
  final Widget page;
  
  final bool fromRight;

  SlidePageRoute(
    {
      required this.page,
      this.fromRight = true
    }
  ) : super(

    pageBuilder: ( context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration( milliseconds: 500 ),
    transitionsBuilder: ( context, animation,  secondaryAnimation, child ) {

      if (fromRight) {

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset( 1.0, 0.0 ),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn
            )
          ),
          child: child
        );

      } else {

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset( -1.0, 0.0 ),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn
            )
          ),
          child: child
        );

      }

    }

  );
}