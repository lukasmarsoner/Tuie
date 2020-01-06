import 'package:flutter/material.dart';
import 'package:tuie/ui_elements/design.dart';

class DynamicTopMenu extends StatelessWidget{
  final Widget tabBar;

  DynamicTopMenu({this.tabBar});

  @override
  //TODO: Add user information
  Widget build(BuildContext context) {
    double _screenHeight = MediaQuery.of(context).size.height;
    return new SliverAppBar(
        expandedHeight: _screenHeight * 3/8,
        pinned: true,
        snap: true,
        bottom: tabBar,
        floating: true,
        flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: seasonalImage
            ),
      );
  }
}