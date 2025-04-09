import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

/// A widget that uses the animations package to provide a shared axis page transition
class AnimatedPageTransition extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final SharedAxisTransitionType transitionType;
  final Duration duration;
  
  const AnimatedPageTransition({
    Key? key,
    required this.child,
    required this.isActive,
    this.transitionType = SharedAxisTransitionType.horizontal,
    this.duration = const Duration(milliseconds: 400),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: duration,
      reverse: !isActive,
      transitionBuilder: (
        Widget child,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// A wrapper for the Flutter animations package's OpenContainer
/// for creating beautiful material container transformations
class AnimatedContainerTransform extends StatelessWidget {
  final Widget closedBuilder;
  final Widget openBuilder;
  final Duration duration;
  final Color closedColor;
  final Color openColor;
  final ShapeBorder closedShape;
  final double closedElevation;
  final ClosedCallback<dynamic>? onClosed;
  
  const AnimatedContainerTransform({
    Key? key,
    required this.closedBuilder,
    required this.openBuilder,
    this.duration = const Duration(milliseconds: 500),
    this.closedColor = Colors.transparent,
    this.openColor = Colors.white,
    this.closedShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.closedElevation = 0,
    this.onClosed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      transitionDuration: duration,
      openBuilder: (context, _) => openBuilder,
      closedBuilder: (context, openContainer) => 
        InkWell(
          onTap: openContainer,
          child: closedBuilder,
        ),
      closedColor: closedColor,
      openColor: openColor,
      closedShape: closedShape,
      closedElevation: closedElevation,
      onClosed: onClosed,
    );
  }
} 