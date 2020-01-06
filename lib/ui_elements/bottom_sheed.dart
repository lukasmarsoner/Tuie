import 'package:flutter/material.dart';
import 'package:tuie/ui_elements/design.dart';
import 'dart:ui';
import 'dart:math' show min, max;

//Expanding bottom menu inspired by Marcin Szałek
class ExpandingBottonSheet extends StatefulWidget {

  @override
  ExpandingBottonSheetState createState() => ExpandingBottonSheetState();
}

class ExpandingBottonSheetState extends State<ExpandingBottonSheet>
  with SingleTickerProviderStateMixin{
  AnimationController _controller;
  double minHeight = 40;
  double get maxHeight => MediaQuery.of(context).size.height;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600), 
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double lerp(double min, double max) =>
      lerpDouble(min, max, _controller.value); 

  void _toggle() {
    final bool isOpen = _controller.status == AnimationStatus.completed;
    //Snap the sheet in the appropriate direction
    _controller.fling(velocity: isOpen ? -2 : 2);
  }

  //Functions for dragging the sheet
  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.primaryDelta / maxHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / maxHeight;
    if (flingVelocity < 0.0)
      //Continue animation upwards
      _controller.fling(velocity: max(2.0, -flingVelocity));
    else if (flingVelocity > 0.0)
      //Continue animation downwards
      _controller.fling(velocity: min(-2.0, -flingVelocity));
    else
      //Continue to the closer edge of the screen
      _controller.fling(velocity: _controller.value < 0.5 ? -2.0 : 2.0);
  }
   
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          height: lerp(minHeight, maxHeight),
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _toggle,
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: Container(
              child: _controller.status == AnimationStatus.completed
                ?null
                :Center(child: Opacity(opacity: 1 - _controller.value, child: Text('New Task', style: TextStyle(fontSize: 20.0, color: bottomMenuTextColor)))),
              padding: EdgeInsets.symmetric(horizontal: 32),
              color: primaryColor,
            ),
          ),
        );
      }
    );
  }
}