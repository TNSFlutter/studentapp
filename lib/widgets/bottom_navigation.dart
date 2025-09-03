import 'package:fancy_bottom_navigation_plus/fancy_bottom_navigation_plus.dart';
import 'package:flutter/material.dart';
import 'package:studentapp/constants/app_colors.dart';

class CustomBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final GlobalKey<FancyBottomNavigationPlusState> bottomNavigationKey =
      GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FancyBottomNavigationPlus(
      tabs: [
        TabData(
          icon: const Icon(Icons.attach_money),
          title: "Fee",
          onclick: () {
            widget.onTap(0);
            _animationController.reset();
            _animationController.forward();
          },
        ),
        TabData(
          icon: const Icon(Icons.assignment),
          title: "Homework",
          onclick: () {
            widget.onTap(1);
            _animationController.reset();
            _animationController.forward();
          },
        ),
        TabData(
          icon: const Icon(Icons.home_outlined),
          title: "Home",
          onclick: () {
            widget.onTap(2);
            _animationController.reset();
            _animationController.forward();
          },
        ),
        TabData(
          icon: const Icon(Icons.message),
          title: "Message",
          onclick: () {
            widget.onTap(3);
            _animationController.reset();
            _animationController.forward();
          },
        ),
        TabData(
          icon: const Icon(Icons.grid_view),
          title: "More",
          onclick: () {
            widget.onTap(4);
            _animationController.reset();
            _animationController.forward();
          },
        ),
      ],
      initialSelection: widget.currentIndex,
      key: bottomNavigationKey,
      barBackgroundColor: Colors.purple,
      //activeIconColor: AppColors.accentOrange,
      circleColor: AppColors.accentOrange,
      onTabChangedListener: (int position) {
        widget.onTap(position);
        _animationController.reset();
        _animationController.forward();
      },
    );
  }
}
