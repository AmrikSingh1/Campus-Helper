import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

/// A utility class for creating beautiful route transitions
class AppRoutes {
  /// Creates a fade transition to a new page
  static Route createFadeRoute(Widget page, {Duration? duration}) {
    return PageTransition(
      type: PageTransitionType.fade,
      child: page,
      duration: duration ?? const Duration(milliseconds: 400),
      reverseDuration: duration ?? const Duration(milliseconds: 400),
    );
  }

  /// Creates a slide transition (right to left)
  static Route createSlideRoute(Widget page, {Duration? duration}) {
    return PageTransition(
      type: PageTransitionType.rightToLeft,
      child: page,
      duration: duration ?? const Duration(milliseconds: 400),
      reverseDuration: duration ?? const Duration(milliseconds: 400),
    );
  }

  /// Creates a zoom transition for a futuristic effect
  static Route createZoomRoute(Widget page, {Duration? duration}) {
    return PageTransition(
      type: PageTransitionType.scale,
      alignment: Alignment.center,
      child: page,
      duration: duration ?? const Duration(milliseconds: 400),
      reverseDuration: duration ?? const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
    );
  }

  /// Creates a bottom-to-top transition for dialogs and modals
  static Route createBottomToTopRoute(Widget page, {Duration? duration}) {
    return PageTransition(
      type: PageTransitionType.bottomToTop,
      child: page,
      duration: duration ?? const Duration(milliseconds: 300),
      reverseDuration: duration ?? const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Creates a smooth right-to-left transition with fade for primary navigation
  static Route createSmoothRoute(Widget page, {Duration? duration}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.05, 0.0);
        var end = Offset.zero;
        var curve = Curves.easeOutQuint;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: duration ?? const Duration(milliseconds: 500),
    );
  }
} 