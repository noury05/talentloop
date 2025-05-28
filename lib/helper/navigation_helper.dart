import 'package:flutter/material.dart';

class NavigationHelper {
  static const Duration _transitionDuration = Duration(milliseconds: 500);

  static void navigateWithFade(BuildContext context, Widget page) {
    Navigator.of(context).push(_createFadeRoute(page));
  }

  static void navigateWithSlide(BuildContext context, Widget page) {
    Navigator.of(context).push(_createSlideRoute(page));
  }

  static void navigateWithSlideFromTop(BuildContext context, Widget page) {
    Navigator.of(context).push(_createSlideFromTopRoute(page));
  }

  static void navigateWithSlideFromBottom(BuildContext context, Widget page) {
    Navigator.of(context).push(_createSlideFromBottomRoute(page));
  }

  static void navigateWithSlideFromRight(BuildContext context, Widget page) {
    Navigator.of(context).push(_createSlideFromRightRoute(page));
  }

  static void navigateWithSlideFromLeft(BuildContext context, Widget page) {
    Navigator.of(context).push(_createSlideFromLeftRoute(page));
  }

  static void navigateWithScale(BuildContext context, Widget page) {
    Navigator.of(context).push(_createScaleRoute(page));
  }

  static void navigateWithRotation(BuildContext context, Widget page) {
    Navigator.of(context).push(_createRotationRoute(page));
  }

  static void navigateWithSize(BuildContext context, Widget page) {
    Navigator.of(context).push(_createSizeRoute(page));
  }

  static PageRouteBuilder _createFadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static PageRouteBuilder _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  static PageRouteBuilder _createSlideFromTopRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  static PageRouteBuilder _createSlideFromBottomRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  static PageRouteBuilder _createSlideFromRightRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Starts off-screen to the right.
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  static PageRouteBuilder _createSlideFromLeftRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Starts off-screen to the left.
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  static PageRouteBuilder _createScaleRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
        return ScaleTransition(scale: scaleAnimation, child: child);
      },
    );
  }

  static PageRouteBuilder _createRotationRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
        return RotationTransition(turns: rotateAnimation, child: child);
      },
    );
  }

  static PageRouteBuilder _createSizeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final sizeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
        return Align(
          child: SizeTransition(
            sizeFactor: sizeAnimation,
            axisAlignment: 0.0,
            child: child,
          ),
        );
      },
    );
  }
}
