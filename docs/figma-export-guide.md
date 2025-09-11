# KAIX Lo-Fi Design System - Figma Export Guide

## Overview

This guide explains how to export and implement the KAIX lo-fi design system tokens in Figma, ensuring perfect design-to-development handoff and maintaining visual consistency.

## 🎨 Design System Structure

### Color Collections

#### **Primary Colors**
- **Primary**: `#7DAEA9` - Soft teal for buttons and primary actions
- **Secondary**: `#E6D9F2` - Soft lavender for highlights and accents
- **Accent**: `#D4C4E8` - Muted purple for subtle emphasis

#### **Surface Colors**
- **Background**: `#FBF9F8` - Soft paper white for main backgrounds
- **Surface**: `#FFFFFF` - Pure white for cards and components
- **Surface Variant**: `#F8F6F5` - Subtle background variant

#### **Text Colors** 
- **Text Primary**: `#0F1724` - Deep blue-black for main content
- **Text Secondary**: `#6B7280` - Muted blue-gray for secondary text
- **Text Tertiary**: `#9CA3AF` - Light blue-gray for subtle text

#### **Message Bubble Colors**
- **User Bubble**: `#DCEEF9` - Soft blue background for user messages
- **Bot Bubble**: `#FFF7EA` - Soft cream background for bot messages
- **User/Bot Text**: `#0F1724` - Consistent dark text for readability

#### **Status Colors**
- **Success**: `#86EFAC` - Soft success green
- **Warning**: `#FDE68A` - Soft warning yellow
- **Error**: `#FCA5A5` - Soft error red
- **Info**: `#BAE6FD` - Soft info blue

### Typography System

#### **Font Family**
- **Primary**: Inter (Google Fonts)
- **Fallback**: -apple-system, BlinkMacSystemFont, Roboto, sans-serif

#### **Text Styles**

**Headers:**
- **Large Title**: 34px / 400 weight / -0.5px letter-spacing
- **H1**: 28px / 600 weight / -0.3px letter-spacing
- **H2**: 24px / 600 weight / -0.2px letter-spacing  
- **H3**: 20px / 500 weight / 0px letter-spacing

**Body Text:**
- **Body Large**: 17px / 400 weight / 1.5 line-height
- **Body Medium**: 16px / 400 weight / 1.5 line-height
- **Body Small**: 14px / 400 weight / 1.4 line-height

**Interface Text:**
- **Button Large**: 17px / 600 weight
- **Button Medium**: 16px / 500 weight
- **Caption**: 12px / 400 weight
- **Overline**: 11px / 500 weight / uppercase

### Spacing Scale

**Base Unit**: 4px grid system

- **XS**: 4px
- **SM**: 8px  
- **MD**: 12px
- **LG**: 16px
- **XL**: 24px
- **2XL**: 32px
- **3XL**: 40px
- **4XL**: 48px
- **5XL**: 64px

### Border Radius

- **None**: 0px
- **Small**: 6px
- **Medium**: 12px (buttons, inputs)
- **Large**: 20px (cards)
- **XL**: 24px
- **Full**: 9999px (pills, avatars)

### Component-Specific Values

#### **Message Bubbles**
- Border Radius: 16px with 4px tail radius
- Padding: 16px horizontal, 12px vertical
- Max Width: 75% of container
- Margin Bottom: 8px

#### **Input Composer**
- Min Height: 54px
- Border Radius: 12px
- Padding: 16px horizontal, 12px vertical

#### **Buttons**
- Min Height: 44px (accessibility)
- Border Radius: 12px
- Padding: 16px horizontal, 12px vertical

## 📱 Figma Setup Instructions

### 1. Create Variable Collections

#### **Colors Collection**
1. Create new variable collection: "KAIX Colors"
2. Add modes: "Light" and "Dark"
3. Create color variables for each token:
   ```
   Primary/Primary -> #7DAEA9
   Primary/Secondary -> #E6D9F2
   Surface/Background -> #FBF9F8
   Surface/Surface -> #FFFFFF
   Text/Primary -> #0F1724
   Text/Secondary -> #6B7280
   [etc...]
   ```

#### **Spacing Collection** 
1. Create new variable collection: "KAIX Spacing"
2. Add number variables:
   ```
   XS -> 4
   SM -> 8
   MD -> 12
   LG -> 16
   [etc...]
   ```

#### **Typography Collection**
1. Create new variable collection: "KAIX Typography"
2. Add number variables for font sizes:
   ```
   XS -> 10
   SM -> 12
   Base -> 14
   MD -> 16
   [etc...]
   ```

### 2. Create Text Styles

For each text style in the system:

1. **Large Title**
   - Font: Inter
   - Size: 34px
   - Weight: Regular (400)
   - Line Height: 120%
   - Letter Spacing: -0.5px

2. **H1** 
   - Font: Inter
   - Size: 28px
   - Weight: Semi Bold (600)
   - Line Height: 130%
   - Letter Spacing: -0.3px

[Continue for all text styles...]

### 3. Create Color Styles

Create color styles for quick application:

1. **UI Colors**
   - Primary/Primary
   - Primary/Secondary
   - Surface/Background
   - Surface/Surface
   - Text/Primary
   - Text/Secondary
   - Text/Tertiary

2. **Message Colors**
   - Message/User Bubble
   - Message/Bot Bubble
   - Message/User Text
   - Message/Bot Text

3. **Status Colors**
   - Status/Success
   - Status/Warning
   - Status/Error
   - Status/Info

### 4. Component Structure

#### **Message Bubble Component**
- Create component with variants: "User" and "Bot"
- Use color variables for backgrounds
- Apply proper border radius (16px with tail)
- Set up text styles
- Add proper spacing

#### **Input Composer Component**
- Min height: 54px
- Border radius: 12px variable
- Background: Surface variable
- Text style: Body Medium
- Proper padding variables

#### **Button Components**
- Create variants: Primary, Secondary, Text
- Min height: 44px
- Border radius: 12px variable
- Proper padding and text styles

## 🔄 Token Synchronization

### Export Process

1. **JSON Export**: Use the `design_tokens.json` file as single source of truth
2. **Figma Plugin**: Use "Design Tokens" or "Figma Tokens" plugin to sync
3. **Code Generation**: Tokens automatically generate Flutter code

### Import to Figma

1. Install "Figma Tokens" plugin
2. Load `design_tokens.json` file
3. Map tokens to Figma variables and styles
4. Apply to components automatically

### Validation Checklist

- [ ] All color tokens imported correctly
- [ ] Typography styles match exactly
- [ ] Spacing variables applied to components  
- [ ] Border radius values correct
- [ ] Component variants working
- [ ] Dark mode variables configured
- [ ] Animation values documented

## 🎭 Component Examples

### Message Bubble Usage
```
Background: {Message/User Bubble} or {Message/Bot Bubble}
Text Color: {Message/User Text} or {Message/Bot Text}
Border Radius: 16px with 4px tail
Padding: {LG} horizontal, {MD} vertical
Max Width: 75% container
```

### Button Usage
```
Primary Button:
- Background: {Primary/Primary}
- Text: {Surface/Surface}
- Border Radius: {MD}
- Padding: {LG} horizontal, {MD} vertical
- Min Height: 44px
- Text Style: Button Medium
```

### Input Field Usage
```
Background: {Surface/Surface Variant}
Border: 1px solid {Border/Border}
Border Radius: {MD}
Padding: {LG}
Text Style: Body Medium
Focus Border: {Border/Focus}
```

## 🌙 Dark Mode Implementation

All color tokens include dark mode variants:

- Surface colors become darker variants
- Text colors invert appropriately  
- Primary colors remain consistent
- Message bubbles use dark variants
- Proper contrast maintained

## 📐 Responsive Design

### Breakpoints
- **Mobile**: < 600px
- **Tablet**: 600px - 900px  
- **Desktop**: 900px - 1200px
- **Large**: > 1200px

### Adaptive Scaling
- Typography scales: 1.0x (mobile) to 1.3x (large)
- Spacing scales appropriately
- Component sizes adapt
- Grid columns: 1 (mobile) to 4 (large)

## 🚀 Developer Handoff

### Design Specs
- All measurements in px
- Color values as hex codes
- Typography with exact specifications
- Animation curves and durations
- Spacing using 4px grid

### Code Implementation
- Flutter implementation matches exactly
- Design tokens generate code
- Consistent naming convention
- Automated testing validates design

## 📝 Maintenance

### Updates
1. Modify `design_tokens.json`
2. Re-import to Figma
3. Update components automatically
4. Test in development
5. Deploy changes

### Version Control
- Token versioning
- Component library versioning
- Change documentation
- Migration guides

---

**Design System Version**: 1.0.0  
**Last Updated**: January 2024  
**Maintainers**: Design System Team