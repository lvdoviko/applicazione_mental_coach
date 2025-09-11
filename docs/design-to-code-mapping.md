# Design Tokens to Code Mapping

This document shows the exact mapping between design tokens, Figma variables, and Flutter code implementation.

## 🎨 Color Mapping

### Primary Colors

| Token | Figma Variable | Flutter Constant | Hex Value |
|-------|---------------|------------------|-----------|
| Primary | `{Colors/Primary}` | `AppColors.primary` | `#7DAEA9` |
| Secondary | `{Colors/Secondary}` | `AppColors.secondary` | `#E6D9F2` |
| Accent | `{Colors/Accent}` | `AppColors.accent` | `#D4C4E8` |

### Surface Colors

| Token | Figma Variable | Flutter Constant | Hex Value |
|-------|---------------|------------------|-----------|
| Background | `{Colors/Background}` | `AppColors.background` | `#FBF9F8` |
| Surface | `{Colors/Surface}` | `AppColors.surface` | `#FFFFFF` |
| Surface Variant | `{Colors/SurfaceVariant}` | `AppColors.surfaceVariant` | `#F8F6F5` |

### Text Colors

| Token | Figma Variable | Flutter Constant | Hex Value |
|-------|---------------|------------------|-----------|
| Text Primary | `{Colors/Text/Primary}` | `AppColors.textPrimary` | `#0F1724` |
| Text Secondary | `{Colors/Text/Secondary}` | `AppColors.textSecondary` | `#6B7280` |
| Text Tertiary | `{Colors/Text/Tertiary}` | `AppColors.textTertiary` | `#9CA3AF` |

### Message Bubble Colors

| Token | Figma Variable | Flutter Constant | Hex Value |
|-------|---------------|------------------|-----------|
| User Bubble | `{Colors/Message/UserBubble}` | `AppColors.userBubble` | `#DCEEF9` |
| User Text | `{Colors/Message/UserText}` | `AppColors.userBubbleText` | `#0F1724` |
| Bot Bubble | `{Colors/Message/BotBubble}` | `AppColors.botBubble` | `#FFF7EA` |
| Bot Text | `{Colors/Message/BotText}` | `AppColors.botBubbleText` | `#0F1724` |

### Status Colors

| Token | Figma Variable | Flutter Constant | Hex Value |
|-------|---------------|------------------|-----------|
| Success | `{Colors/Status/Success}` | `AppColors.success` | `#86EFAC` |
| Warning | `{Colors/Status/Warning}` | `AppColors.warning` | `#FDE68A` |
| Error | `{Colors/Status/Error}` | `AppColors.error` | `#FCA5A5` |
| Info | `{Colors/Status/Info}` | `AppColors.info` | `#BAE6FD` |

### Border Colors

| Token | Figma Variable | Flutter Constant | Hex Value |
|-------|---------------|------------------|-----------|
| Border | `{Colors/Border}` | `AppColors.border` | `#E5E7EB` |
| Border Focus | `{Colors/BorderFocus}` | `AppColors.borderFocus` | `#7DAEA9` |

### Dark Mode Colors

| Token | Figma Variable | Flutter Constant | Hex Value |
|-------|---------------|------------------|-----------|
| Dark Background | `{Colors/Dark/Background}` | `AppColors.darkBackground` | `#0F1117` |
| Dark Surface | `{Colors/Dark/Surface}` | `AppColors.darkSurface` | `#161B22` |
| Dark Text Primary | `{Colors/Dark/TextPrimary}` | `AppColors.darkTextPrimary` | `#E6EDF3` |
| Dark Text Secondary | `{Colors/Dark/TextSecondary}` | `AppColors.darkTextSecondary` | `#7D8590` |

## 🔤 Typography Mapping

### Font Family

| Token | Figma Variable | Flutter Constant | Value |
|-------|---------------|------------------|-------|
| Primary Font | `{Typography/FontFamily}` | `AppTypography.fontFamily` | `'Inter'` |

### Font Weights

| Token | Figma Variable | Flutter Constant | Value |
|-------|---------------|------------------|-------|
| Light | `{Typography/Weight/Light}` | `FontWeight.w300` | `300` |
| Regular | `{Typography/Weight/Regular}` | `FontWeight.w400` | `400` |
| Medium | `{Typography/Weight/Medium}` | `FontWeight.w500` | `500` |
| Semi Bold | `{Typography/Weight/SemiBold}` | `FontWeight.w600` | `600` |
| Bold | `{Typography/Weight/Bold}` | `FontWeight.w700` | `700` |

### Text Styles

| Token | Figma Style | Flutter Constant | Size | Weight | Line Height |
|-------|------------|------------------|------|--------|-------------|
| Large Title | `Typography/LargeTitle` | `AppTypography.largeTitle` | 34px | 400 | 1.2 |
| H1 | `Typography/H1` | `AppTypography.h1` | 28px | 600 | 1.3 |
| H2 | `Typography/H2` | `AppTypography.h2` | 24px | 600 | 1.4 |
| H3 | `Typography/H3` | `AppTypography.h3` | 20px | 500 | 1.4 |
| H4 | `Typography/H4` | `AppTypography.h4` | 18px | 500 | 1.4 |
| Body Large | `Typography/BodyLarge` | `AppTypography.bodyLarge` | 17px | 400 | 1.5 |
| Body Medium | `Typography/BodyMedium` | `AppTypography.bodyMedium` | 16px | 400 | 1.5 |
| Body Small | `Typography/BodySmall` | `AppTypography.bodySmall` | 14px | 400 | 1.4 |
| Button Large | `Typography/ButtonLarge` | `AppTypography.buttonLarge` | 17px | 600 | 1.2 |
| Button Medium | `Typography/ButtonMedium` | `AppTypography.buttonMedium` | 16px | 500 | 1.2 |
| Caption | `Typography/Caption` | `AppTypography.caption` | 12px | 400 | 1.3 |
| Overline | `Typography/Overline` | `AppTypography.overline` | 11px | 500 | 1.3 |

### Chat-Specific Text Styles

| Token | Figma Style | Flutter Constant | Size | Weight | Line Height |
|-------|------------|------------------|------|--------|-------------|
| Chat User Bubble | `Typography/ChatBubbleUser` | `AppTypography.chatBubbleUser` | 16px | 400 | 1.4 |
| Chat Bot Bubble | `Typography/ChatBubbleBot` | `AppTypography.chatBubbleBot` | 16px | 400 | 1.4 |
| Chat Timestamp | `Typography/ChatTimestamp` | `AppTypography.chatTimestamp` | 12px | 400 | 1.3 |
| Composer Placeholder | `Typography/ComposerPlaceholder` | `AppTypography.composerPlaceholder` | 16px | 400 | 1.5 |

## 📐 Spacing Mapping

### Base Spacing Scale

| Token | Figma Variable | Flutter Constant | Value |
|-------|---------------|------------------|-------|
| XS | `{Spacing/XS}` | `AppSpacing.xs` | `4.0` |
| SM | `{Spacing/SM}` | `AppSpacing.sm` | `8.0` |
| MD | `{Spacing/MD}` | `AppSpacing.md` | `12.0` |
| LG | `{Spacing/LG}` | `AppSpacing.lg` | `16.0` |
| XL | `{Spacing/XL}` | `AppSpacing.xl` | `24.0` |
| 2XL | `{Spacing/2XL}` | `AppSpacing.xxl` | `32.0` |
| 3XL | `{Spacing/3XL}` | `AppSpacing.massive` | `48.0` |

### Semantic Spacing

| Token | Figma Variable | Flutter Constant | Value | Usage |
|-------|---------------|------------------|-------|-------|
| Screen Padding | `{Spacing/ScreenPadding}` | `AppSpacing.screenPadding` | `24.0` | Edge margins |
| Section Spacing | `{Spacing/SectionSpacing}` | `AppSpacing.sectionSpacing` | `32.0` | Between sections |
| List Item Spacing | `{Spacing/ListItemSpacing}` | `AppSpacing.listItemSpacing` | `12.0` | Between list items |
| List Item Padding | `{Spacing/ListItemPadding}` | `AppSpacing.listItemPadding` | `16.0` | Inside list items |

### Chat-Specific Spacing

| Token | Figma Variable | Flutter Constant | Value | Usage |
|-------|---------------|------------------|-------|-------|
| Message Bubble Margin | `{Spacing/MessageBubbleMargin}` | `AppSpacing.messageBubbleMargin` | `8.0` | Between bubbles |
| Message Bubble Padding | `{Spacing/MessageBubblePadding}` | `AppSpacing.messageBubblePadding` | `16.0` | Inside bubbles |
| Composer Padding | `{Spacing/ComposerPadding}` | `AppSpacing.composerPadding` | `16.0` | Input composer |
| Composer Min Height | `{Spacing/ComposerMinHeight}` | `AppSpacing.composerMinHeight` | `54.0` | Minimum touch target |
| Button Padding | `{Spacing/ButtonPadding}` | `AppSpacing.buttonPadding` | `12.0` | Button internal padding |

### Chip Spacing

| Token | Figma Variable | Flutter Constant | Value | Usage |
|-------|---------------|------------------|-------|-------|
| Chip Horizontal Padding | `{Spacing/ChipPaddingH}` | `AppSpacing.chipPaddingHorizontal` | `16.0` | Inside chips |
| Chip Vertical Padding | `{Spacing/ChipPaddingV}` | `AppSpacing.chipPaddingVertical` | `8.0` | Inside chips |
| Chip Spacing | `{Spacing/ChipSpacing}` | `AppSpacing.chipSpacing` | `8.0` | Between chips |

## 🔄 Border Radius Mapping

| Token | Figma Variable | Flutter Constant | Value | Usage |
|-------|---------------|------------------|-------|-------|
| None | `{BorderRadius/None}` | `AppBorderRadius.none` | `0.0` | Sharp corners |
| Small | `{BorderRadius/SM}` | `AppBorderRadius.sm` | `6.0` | Small elements |
| Medium | `{BorderRadius/MD}` | `AppBorderRadius.md` | `12.0` | Buttons, inputs |
| Large | `{BorderRadius/LG}` | `AppBorderRadius.lg` | `20.0` | Cards |
| Extra Large | `{BorderRadius/XL}` | `AppBorderRadius.xl` | `24.0` | Large cards |
| Full | `{BorderRadius/Full}` | `AppBorderRadius.full` | `9999.0` | Pills, avatars |

### Component-Specific Border Radius

| Token | Figma Variable | Flutter Constant | Value | Usage |
|-------|---------------|------------------|-------|-------|
| Message Bubble | `{BorderRadius/MessageBubble}` | `AppBorderRadius.messageBubble` | `16.0` | Chat bubbles |
| Composer | `{BorderRadius/Composer}` | `AppBorderRadius.composer` | `12.0` | Input field |
| Chip | `{BorderRadius/Chip}` | `AppBorderRadius.chip` | `20.0` | Suggestion chips |
| Card | `{BorderRadius/Card}` | `AppBorderRadius.card` | `20.0` | Content cards |
| Button | `{BorderRadius/Button}` | `AppBorderRadius.button` | `12.0` | All buttons |
| Avatar | `{BorderRadius/Avatar}` | `AppBorderRadius.avatar` | `9999.0` | Profile images |

## ⏱️ Animation Mapping

### Durations

| Token | Figma Variable | Flutter Constant | Value | Usage |
|-------|---------------|------------------|-------|-------|
| Micro | `{Animations/Micro}` | `AppAnimations.micro` | `120ms` | Button press |
| Small | `{Animations/Small}` | `AppAnimations.small` | `200ms` | Small transitions |
| Medium | `{Animations/Medium}` | `AppAnimations.medium` | `350ms` | Standard transitions |
| Large | `{Animations/Large}` | `AppAnimations.large` | `600ms` | Complex animations |

### Message-Specific Durations

| Token | Figma Variable | Flutter Constant | Value | Usage |
|-------|---------------|------------------|-------|-------|
| Message Fade In | `{Animations/MessageFadeIn}` | `AppAnimations.messageFadeIn` | `350ms` | Message appear |
| Message Slide In | `{Animations/MessageSlideIn}` | `AppAnimations.messageSlideIn` | `200ms` | Message slide |
| Button Press | `{Animations/ButtonPress}` | `AppAnimations.buttonPress` | `120ms` | Button feedback |
| Typing Indicator | `{Animations/TypingIndicator}` | `AppAnimations.typingIndicator` | `900ms` | Dot animation |

### Easing Curves

| Token | Figma Variable | Flutter Constant | CSS Value | Usage |
|-------|---------------|------------------|-----------|-------|
| Ease Out | `{Animations/EaseOut}` | `AppAnimations.easeOut` | `Curves.easeOut` | Natural deceleration |
| Ease In | `{Animations/EaseIn}` | `AppAnimations.easeIn` | `Curves.easeIn` | Natural acceleration |
| Ease In Out | `{Animations/EaseInOut}` | `AppAnimations.easeInOut` | `Curves.easeInOut` | Smooth both ways |
| Ease Out Cubic | `{Animations/EaseOutCubic}` | `AppAnimations.easeOutCubic` | `Curves.easeOutCubic` | Strong deceleration |

## 🌙 Dark Mode Mapping

All tokens have corresponding dark mode variants:

```dart
// Light mode
AppColors.background → #FBF9F8
AppColors.surface → #FFFFFF
AppColors.textPrimary → #0F1724

// Dark mode  
AppColors.darkBackground → #0F1117
AppColors.darkSurface → #161B22
AppColors.darkTextPrimary → #E6EDF3
```

## 🎯 Component Usage Examples

### Message Bubble Implementation

**Figma Component:**
```
Background: {Colors/Message/UserBubble}
Text Color: {Colors/Message/UserText}
Border Radius: {BorderRadius/MessageBubble}
Padding: {Spacing/MessageBubblePadding}
Margin Bottom: {Spacing/MessageBubbleMargin}
```

**Flutter Implementation:**
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.userBubble,
    borderRadius: BorderRadius.circular(AppBorderRadius.messageBubble),
  ),
  padding: EdgeInsets.all(AppSpacing.messageBubblePadding),
  margin: EdgeInsets.only(bottom: AppSpacing.messageBubbleMargin),
  child: Text(
    message,
    style: AppTypography.chatBubbleUser.copyWith(
      color: AppColors.userBubbleText,
    ),
  ),
)
```

### Button Implementation

**Figma Component:**
```
Background: {Colors/Primary}
Text Color: {Colors/Surface}
Border Radius: {BorderRadius/Button}
Padding: {Spacing/ButtonPadding}
Min Height: {Spacing/ComposerMinHeight}
```

**Flutter Implementation:**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.button),
    ),
    padding: EdgeInsets.all(AppSpacing.buttonPadding),
    minimumSize: Size(0, AppSpacing.composerMinHeight),
  ),
  child: Text('Button', style: AppTypography.buttonMedium),
)
```

## 🔄 Sync Process

1. **Design Changes**: Update tokens in Figma
2. **Export**: Generate JSON from Figma tokens plugin  
3. **Import**: Update `design_tokens.json` file
4. **Generate**: Run token-to-code generation script
5. **Update**: Flutter constants automatically updated
6. **Test**: Verify visual consistency

---

**Last Updated**: January 2024  
**Token Version**: 1.0.0