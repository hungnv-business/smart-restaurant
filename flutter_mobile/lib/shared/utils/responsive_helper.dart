import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive helper utilities for SmartRestaurant mobile app
/// Designed for tablet-first approach as specified in requirements
class ResponsiveHelper {
  // Private constructor to prevent instantiation
  ResponsiveHelper._();

  // Device type breakpoints (based on width in dp)
  static const double _tabletMinWidth = 600.0;
  static const double _desktopMinWidth = 1200.0;

  /// Check if current device is a smartphone
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < _tabletMinWidth;
  }

  /// Check if current device is a tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _tabletMinWidth && width < _desktopMinWidth;
  }

  /// Check if current device is a desktop/large screen
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _desktopMinWidth;
  }

  /// Get responsive value based on device type
  /// Tablet-first approach: tablet value is used as default
  static T responsive<T>({
    required BuildContext context,
    required T tablet,
    T? phone,
    T? desktop,
  }) {
    if (isPhone(context) && phone != null) {
      return phone;
    } else if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    return tablet;
  }

  /// Get responsive padding for different screen sizes
  static EdgeInsets responsivePadding(BuildContext context) {
    return responsive<EdgeInsets>(
      context: context,
      phone: EdgeInsets.all(16.w),
      tablet: EdgeInsets.all(20.w),
      desktop: EdgeInsets.all(24.w),
    );
  }

  /// Get responsive margin for different screen sizes
  static EdgeInsets responsiveMargin(BuildContext context) {
    return responsive<EdgeInsets>(
      context: context,
      phone: EdgeInsets.all(8.w),
      tablet: EdgeInsets.all(12.w),
      desktop: EdgeInsets.all(16.w),
    );
  }

  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, {
    double? phone,
    required double tablet,
    double? desktop,
  }) {
    return responsive<double>(
      context: context,
      phone: phone?.sp ?? (tablet * 0.9).sp,
      tablet: tablet.sp,
      desktop: desktop?.sp ?? (tablet * 1.1).sp,
    );
  }

  /// Get responsive icon size
  static double responsiveIconSize(BuildContext context, {
    double? phone,
    required double tablet,
    double? desktop,
  }) {
    return responsive<double>(
      context: context,
      phone: phone?.r ?? (tablet * 0.9).r,
      tablet: tablet.r,
      desktop: desktop?.r ?? (tablet * 1.1).r,
    );
  }

  /// Get responsive card elevation
  static double responsiveElevation(BuildContext context) {
    return responsive<double>(
      context: context,
      phone: 2.0,
      tablet: 4.0,
      desktop: 6.0,
    );
  }

  /// Get responsive border radius
  static BorderRadius responsiveBorderRadius(BuildContext context, {
    double? phone,
    required double tablet,
    double? desktop,
  }) {
    final radius = responsive<double>(
      context: context,
      phone: phone ?? (tablet * 0.8),
      tablet: tablet,
      desktop: desktop ?? (tablet * 1.2),
    );
    return BorderRadius.circular(radius.r);
  }

  /// Get responsive grid columns count
  static int responsiveColumns(BuildContext context, {
    int? phone,
    required int tablet,
    int? desktop,
  }) {
    return responsive<int>(
      context: context,
      phone: phone ?? 1,
      tablet: tablet,
      desktop: desktop ?? (tablet * 2),
    );
  }

  /// Get responsive list item height
  static double responsiveListItemHeight(BuildContext context) {
    return responsive<double>(
      context: context,
      phone: 80.h,
      tablet: 100.h,
      desktop: 120.h,
    );
  }

  /// Get responsive app bar height
  static double responsiveAppBarHeight(BuildContext context) {
    return responsive<double>(
      context: context,
      phone: kToolbarHeight,
      tablet: kToolbarHeight + 16.h,
      desktop: kToolbarHeight + 24.h,
    );
  }

  /// Get responsive bottom navigation bar height
  static double responsiveBottomNavHeight(BuildContext context) {
    return responsive<double>(
      context: context,
      phone: 60.h,
      tablet: 70.h,
      desktop: 80.h,
    );
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get safe area padding for different orientations
  static EdgeInsets responsiveSafeArea(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;
    
    return EdgeInsets.only(
      top: safePadding.top,
      bottom: isPortrait(context) ? safePadding.bottom : 8.h,
      left: safePadding.left,
      right: safePadding.right,
    );
  }

  /// Get responsive dialog width
  static double responsiveDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return responsive<double>(
      context: context,
      phone: screenWidth * 0.9,
      tablet: screenWidth * 0.7,
      desktop: screenWidth * 0.5,
    );
  }

  /// Get responsive dialog height
  static double responsiveDialogHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return responsive<double>(
      context: context,
      phone: screenHeight * 0.8,
      tablet: screenHeight * 0.7,
      desktop: screenHeight * 0.6,
    );
  }

  /// Build responsive layout based on available width
  static Widget responsiveBuilder({
    required BuildContext context,
    required Widget Function(BuildContext context, BoxConstraints constraints) builder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, constraints);
      },
    );
  }

  /// Get responsive spacing between elements
  static SizedBox responsiveSpacing(BuildContext context, {
    double? phone,
    required double tablet,
    double? desktop,
  }) {
    final spacing = responsive<double>(
      context: context,
      phone: phone ?? (tablet * 0.8),
      tablet: tablet,
      desktop: desktop ?? (tablet * 1.2),
    );
    
    return SizedBox(
      height: spacing.h,
      width: spacing.w,
    );
  }

  /// Get responsive form field constraints
  static BoxConstraints responsiveFormFieldConstraints(BuildContext context) {
    return BoxConstraints(
      minWidth: responsive<double>(
        context: context,
        phone: 250.w,
        tablet: 300.w,
        desktop: 400.w,
      ),
      maxWidth: responsive<double>(
        context: context,
        phone: double.infinity,
        tablet: 500.w,
        desktop: 600.w,
      ),
    );
  }

  /// Get responsive content max width for readability
  static double responsiveContentMaxWidth(BuildContext context) {
    return responsive<double>(
      context: context,
      phone: double.infinity,
      tablet: 800.w,
      desktop: 1000.w,
    );
  }

  /// Restaurant-specific responsive breakpoints
  /// Optimized for restaurant tablet use cases
  
  /// Check if device is suitable for kitchen display
  static bool isKitchenDisplay(BuildContext context) {
    return isTablet(context) && isLandscape(context);
  }

  /// Check if device is suitable for cashier operations
  static bool isCashierDevice(BuildContext context) {
    return isTablet(context) || (isPhone(context) && isPortrait(context));
  }

  /// Check if device is suitable for waiter/waitstaff operations
  static bool isWaiterDevice(BuildContext context) {
    return isPhone(context) || (isTablet(context) && isPortrait(context));
  }

  /// Get responsive card layout for orders, reservations, takeaway
  static Widget responsiveCard({
    required BuildContext context,
    required Widget child,
    VoidCallback? onTap,
    Color? backgroundColor,
    double? elevation,
  }) {
    return Card(
      elevation: elevation ?? responsiveElevation(context),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: responsiveBorderRadius(
          context: context,
          tablet: 12.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: responsiveBorderRadius(
          context: context,
          tablet: 12.0,
        ),
        child: Padding(
          padding: responsivePadding(context),
          child: child,
        ),
      ),
    );
  }

  /// Get responsive grid layout for menu items, products, etc.
  static Widget responsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    int? phoneColumns,
    required int tabletColumns,
    int? desktopColumns,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
  }) {
    final columns = responsiveColumns(
      context: context,
      phone: phoneColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: crossAxisSpacing ?? 16.w,
        mainAxisSpacing: mainAxisSpacing ?? 16.h,
        childAspectRatio: responsive<double>(
          context: context,
          phone: 0.8,
          tablet: 1.0,
          desktop: 1.2,
        ),
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}