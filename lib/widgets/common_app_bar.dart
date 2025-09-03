import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onNotificationPressed;
  final bool showBackButton;
  final bool showNotificationIcon;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;

  const CommonAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.onNotificationPressed,
    this.showBackButton = true,
    this.showNotificationIcon = true,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.accentOrange,
        image: DecorationImage(
          image: AssetImage('assets/images/app_bar_background.png'),
          fit: BoxFit.fitWidth,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: showBackButton == true
            ? IconButton(
                onPressed: onBackPressed ?? () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: AppColors.cardWhite),
              )
            : null,
        title: Text(title, style: TextStyle(color: AppColors.cardWhite)),
        actions: [
          IconButton(
            onPressed: onNotificationPressed,
            icon: Icon(Icons.notifications, color: AppColors.cardWhite),
          ),
        ],
      ),

      // SafeArea(
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 20),
      //     child: Row(
      //       children: [
      //         // Back button
      //         if (showBackButton)
      //           Container(
      //             width: 44,
      //             height: 44,
      //             child: IconButton(
      //               onPressed: onBackPressed ?? () => Navigator.pop(context),
      //               icon: Icon(Icons.arrow_back, color: AppColors.cardWhite),
      //             ),
      //           ),
      //         // Title
      //         Expanded(
      //           child: Center(
      //             child: Text(
      //               title,
      //               style: TextStyle(
      //                 fontSize: 20,
      //                 fontWeight: FontWeight.w600,
      //                 color: titleColor ?? AppColors.textBlack,
      //               ),
      //             ),
      //           ),
      //         ),
      //         // Notification icon
      //         if (showNotificationIcon)
      //           Container(
      //             width: 44,
      //             height: 44,
      //             child: IconButton(
      //               onPressed: onNotificationPressed,
      //               icon: Icon(Icons.notifications, color: AppColors.cardWhite),
      //             ),
      //           ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}
