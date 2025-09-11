import 'package:flutter/material.dart';

/// **Responsive Design Helper**
/// 
/// **Functional Description:**
/// Provides responsive utilities for different screen sizes and form factors.
/// Supports phones, tablets, foldables, and large screens with lo-fi breakpoints.
/// 
/// **Breakpoints:**
/// - Mobile: < 600px (phones)
/// - Tablet: 600px - 900px (small tablets)
/// - Desktop: 900px - 1200px (large tablets/small desktop)
/// - Large: > 1200px (desktop/external displays)
/// 
/// **Usage:**
/// ```dart
/// ResponsiveHelper.isMobile(context)
/// ResponsiveHelper.getColumns(context)
/// ResponsiveHelper.adaptivePadding(context)
/// ```
class ResponsiveHelper {
  ResponsiveHelper._();

  // Breakpoint constants
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  /// Get the current device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else if (width < desktopBreakpoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.large;
    }
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if device is tablet or larger
  static bool isTabletOrLarger(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tablet || 
           deviceType == DeviceType.desktop || 
           deviceType == DeviceType.large;
  }

  /// Check if device is desktop or larger
  static bool isDesktopOrLarger(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.desktop || deviceType == DeviceType.large;
  }

  /// Get responsive grid columns
  static int getColumns(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
      case DeviceType.large:
        return 4;
    }
  }

  /// Get adaptive padding based on screen size
  static EdgeInsets adaptivePadding(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16.0);
      case DeviceType.tablet:
        return const EdgeInsets.all(24.0);
      case DeviceType.desktop:
        return const EdgeInsets.all(32.0);
      case DeviceType.large:
        return const EdgeInsets.all(48.0);
    }
  }

  /// Get adaptive content width with max constraints
  static double getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return screenWidth;
      case DeviceType.tablet:
        return screenWidth * 0.9;
      case DeviceType.desktop:
        return 800.0; // Max content width for readability
      case DeviceType.large:
        return 1000.0;
    }
  }

  /// Get adaptive font scale
  static double getFontScale(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 1.0;
      case DeviceType.tablet:
        return 1.1;
      case DeviceType.desktop:
        return 1.2;
      case DeviceType.large:
        return 1.3;
    }
  }

  /// Get adaptive icon size
  static double getIconSize(BuildContext context, double baseSize) {
    final scale = getFontScale(context);
    return baseSize * scale;
  }

  /// Check if device supports hover interactions
  static bool supportsHover(BuildContext context) {
    return isTabletOrLarger(context) && 
           Theme.of(context).platform != TargetPlatform.iOS &&
           Theme.of(context).platform != TargetPlatform.android;
  }

  /// Get safe area padding for different orientations
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation;
    
    if (orientation == Orientation.landscape && isMobile(context)) {
      // Handle landscape mode on phones
      return EdgeInsets.only(
        left: mediaQuery.padding.left + 16,
        right: mediaQuery.padding.right + 16,
        top: mediaQuery.padding.top + 8,
        bottom: mediaQuery.padding.bottom + 8,
      );
    }
    
    return EdgeInsets.only(
      left: mediaQuery.padding.left + 16,
      right: mediaQuery.padding.right + 16,
      top: mediaQuery.padding.top + 16,
      bottom: mediaQuery.padding.bottom + 16,
    );
  }

  /// Get adaptive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return screenWidth * 0.9;
      case DeviceType.tablet:
        return 400.0;
      case DeviceType.desktop:
        return 500.0;
      case DeviceType.large:
        return 600.0;
    }
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get adaptive list spacing
  static double getListSpacing(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 8.0;
      case DeviceType.tablet:
        return 12.0;
      case DeviceType.desktop:
        return 16.0;
      case DeviceType.large:
        return 20.0;
    }
  }

  /// Get adaptive border radius
  static double getBorderRadius(BuildContext context, double baseRadius) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return baseRadius;
      case DeviceType.tablet:
        return baseRadius * 1.2;
      case DeviceType.desktop:
        return baseRadius * 1.4;
      case DeviceType.large:
        return baseRadius * 1.6;
    }
  }

  /// Get foldable-aware layout constraints
  static BoxConstraints getFoldableConstraints(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > size.height * 1.5; // Detect unfolded state
    
    if (isWide && isMobile(context)) {
      // Device is likely unfolded
      return BoxConstraints(
        maxWidth: size.width * 0.6, // Use 60% of width for content
        minHeight: size.height * 0.8,
      );
    }
    
    return BoxConstraints(
      maxWidth: double.infinity,
      minHeight: size.height * 0.3,
    );
  }
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
  large,
}

/// Widget that builds different layouts for different screen sizes
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType)? builder;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? large;

  const ResponsiveBuilder({
    super.key,
    this.builder,
    this.mobile,
    this.tablet,
    this.desktop,
    this.large,
  }) : assert(
    builder != null || mobile != null,
    'Either builder or mobile widget must be provided',
  );

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    if (builder != null) {
      return builder!(context, deviceType);
    }

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile!;
      case DeviceType.tablet:
        return tablet ?? mobile!;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile!;
      case DeviceType.large:
        return large ?? desktop ?? tablet ?? mobile!;
    }
  }
}

/// Widget that provides responsive padding
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;
  final EdgeInsets? large;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
    this.large,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding;
    
    switch (ResponsiveHelper.getDeviceType(context)) {
      case DeviceType.mobile:
        padding = mobile ?? const EdgeInsets.all(16);
        break;
      case DeviceType.tablet:
        padding = tablet ?? mobile ?? const EdgeInsets.all(24);
        break;
      case DeviceType.desktop:
        padding = desktop ?? tablet ?? mobile ?? const EdgeInsets.all(32);
        break;
      case DeviceType.large:
        padding = large ?? desktop ?? tablet ?? mobile ?? const EdgeInsets.all(48);
        break;
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Widget that centers content with max width on larger screens
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final contentWidth = maxWidth ?? ResponsiveHelper.getContentWidth(context);
    
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: contentWidth),
        child: child,
      ),
    );
  }
}