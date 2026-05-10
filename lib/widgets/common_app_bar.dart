import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../helpers/app_navigation.dart';
import '../views/message/message_screen.dart';
import 'bottom_nav_scope.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onNotificationPressed;
  final bool showBackButton;
  final bool showNotificationIcon;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;

  /// Rounded, translucent back button (e.g. Change Language on orange).
  final bool frostedLeadingBackground;

  /// When false, uses a solid [backgroundColor] only (no decorative asset image).
  final bool showBackgroundPattern;

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
    this.frostedLeadingBackground = false,
    this.showBackgroundPattern = true,
  });

  @override
  Widget build(BuildContext context) {
    final hideForBottomNav = BottomNavScope.isInBottomNavRoot(context);
    final shouldShowBackButton = showBackButton && !hideForBottomNav;
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final resolvedBackground =
        backgroundColor ??
        appBarTheme.backgroundColor ??
        AppColors.accentOrange;
    final titleStyleColor =
        titleColor ?? appBarTheme.foregroundColor ?? AppColors.cardWhite;
    final actionIconColor =
        iconColor ?? appBarTheme.foregroundColor ?? AppColors.cardWhite;
    final backIconColor =
        iconColor ?? appBarTheme.foregroundColor ?? AppColors.cardWhite;

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: resolvedBackground,
        image: showBackgroundPattern
            ? DecorationImage(
                image: AssetImage('assets/images/app_bar_background.png'),
                fit: BoxFit.fitWidth,
              )
            : null,
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: shouldShowBackButton
            ? frostedLeadingBackground
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Material(
                        color: titleStyleColor.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(10),
                        child: IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          onPressed:
                              onBackPressed ?? () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: backIconColor,
                            size: 22,
                          ),
                          splashRadius: 22,
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: onBackPressed ?? () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: backIconColor),
                    )
            : null,
        title: Text(
          title,
          style: TextStyle(
            color: titleStyleColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: showNotificationIcon
            ? [
                IconButton(
                  onPressed:
                      onNotificationPressed ??
                      () {
                        AppNavigation.push(
                          context,
                          const MessageScreen(showBackButton: true),
                        );
                      },
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: actionIconColor,
                    size: 26,
                  ),
                ),
              ]
            : const [],
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
