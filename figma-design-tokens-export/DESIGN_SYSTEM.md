# iOS 26 Liquid Glass Design System
## Rummy Scorekeeping App

**Version:** 1.0.0  
**Last Updated:** February 3, 2026

---

## 📋 Table of Contents
- [Overview](#overview)
- [How to Use with Cursor](#how-to-use-with-cursor)
- [Color System](#color-system)
- [Typography](#typography)
- [Spacing & Layout](#spacing--layout)
- [Effects](#effects)
- [Components](#components)
- [Code Examples](#code-examples)

---

## Overview

This design system implements the iOS 26 liquid glass aesthetic with:
- **SF Pro Font System** - Native iOS typography
- **iOS System Colors** - Automatic light/dark mode
- **Glassmorphism Materials** - Backdrop blur effects
- **Spring Animations** - Native iOS motion
- **8pt Grid System** - Consistent spacing

### Files Structure
```
/design-tokens.json         # Complete token definitions
/src/styles/theme.css       # CSS implementation
/src/styles/fonts.css       # Font imports
/DESIGN_SYSTEM.md          # This documentation
```

---

## How to Use with Cursor

### 1. Reference Tokens in Prompts
When asking Cursor to build components:

```
"Create a button using the design tokens from design-tokens.json"
"Use the iOS system colors from our token file"
"Apply the spring animation tokens"
```

### 2. Token Path References
```javascript
// In your code/prompts, reference tokens like:
- Colors: color.ios.system.blue.dark
- Typography: typography.scale.title1
- Spacing: spacing.4 (16px)
- Blur: blur.thick
```

### 3. Quick Token Access
Cursor can read these files automatically. Just mention:
- "Use our design system"
- "Follow the token structure"
- "Apply iOS 26 styling"

---

## Color System

### iOS System Colors
Full light/dark mode support:

| Color | Light | Dark | Usage |
|-------|-------|------|-------|
| **Blue** | #007AFF | #0A84FF | Primary actions, links |
| **Purple** | #AF52DE | #BF5AF2 | Highlights, gradients |
| **Indigo** | #5856D6 | #5E5CE6 | Secondary actions |
| **Green** | #34C759 | #30D158 | Success states |
| **Red** | #FF3B30 | #FF453A | Error states |
| **Orange** | #FF9500 | #FF9F0A | Warnings |
| **Yellow** | #FFCC00 | #FFD60A | Caution |
| **Pink** | #FF2D55 | #FF375F | Accents |
| **Teal** | #5AC8FA | #64D2FF | Info |

### Gradients

**Cosmic Background** (Main app background)
```css
background: linear-gradient(135deg, #0a0015, #1a0b2e, #0f0520);
```

**Purple Gradient** (Primary buttons)
```css
background: linear-gradient(135deg, #8B5CF6, #6366F1);
```

**Blue Gradient** (Secondary buttons)
```css
background: linear-gradient(135deg, #3B82F6, #1D4ED8);
```

**Gradient Orbs** (Background decoration)
- Purple Orb: `from-purple-600/20 to-indigo-600/20`
- Blue Orb: `from-blue-600/15 to-violet-600/15`

### Glassmorphism Materials

| Level | Light | Dark | Blur | Usage |
|-------|-------|------|------|-------|
| **Thick** | `rgba(255,255,255,0.7)` | `rgba(28,28,30,0.85)` | 40px | Modals, dialogs |
| **Regular** | `rgba(255,255,255,0.5)` | `rgba(44,44,46,0.75)` | 30px | Cards, panels |
| **Thin** | `rgba(255,255,255,0.3)` | `rgba(58,58,60,0.6)` | 20px | Overlays |
| **Ultra Thin** | `rgba(255,255,255,0.15)` | `rgba(72,72,74,0.4)` | 10px | Subtle effects |

### Text Colors

| Level | Light | Dark | Opacity |
|-------|-------|------|---------|
| Primary | #000000 | #FFFFFF | 100% |
| Secondary | #3C3C43 | #EBEBF5 | 100% |
| Tertiary | #3C3C43 | #EBEBF5 | 60% |
| Quaternary | #3C3C43 | #EBEBF5 | 30% |

---

## Typography

### Font Family
```css
font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", 
             "SF Pro Text", "Helvetica Neue", "Inter", system-ui, sans-serif;
```

### iOS Typography Scale

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| **Large Title** | 34px | 700 | 1.2 | -0.02em | Hero sections |
| **Title 1** | 28px | 700 | 1.2 | -0.02em | Page titles |
| **Title 2** | 22px | 600 | 1.25 | -0.01em | Section headers |
| **Title 3** | 20px | 600 | 1.3 | -0.01em | Card titles |
| **Headline** | 17px | 600 | 1.4 | 0 | Emphasized text |
| **Body** | 17px | 400 | 1.4 | 0 | Body text (default) |
| **Callout** | 16px | 400 | 1.4 | 0 | Secondary body |
| **Subheadline** | 15px | 400 | 1.4 | 0 | Labels |
| **Footnote** | 13px | 400 | 1.4 | 0 | Captions |
| **Caption 1** | 12px | 400 | 1.4 | 0 | Metadata |
| **Caption 2** | 11px | 400 | 1.4 | 0 | Small text |

### Font Weights
- Regular: 400
- Medium: 500
- Semibold: 600
- Bold: 700

---

## Spacing & Layout

### iOS 8pt Grid System

| Token | Value | Usage |
|-------|-------|-------|
| spacing.0 | 0px | None |
| spacing.1 | 4px | Tight spacing |
| spacing.2 | 8px | Extra small |
| spacing.3 | 12px | Small |
| spacing.4 | 16px | Medium (default) |
| spacing.5 | 20px | Large |
| spacing.6 | 24px | Extra large |
| spacing.8 | 32px | XXL |
| spacing.10 | 40px | XXXL |
| spacing.12 | 48px | Section gaps |
| spacing.16 | 64px | Large sections |
| spacing.20 | 80px | Hero spacing |
| spacing.24 | 96px | Page margins |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| borderRadius.sm | 8px | Small elements |
| borderRadius.md | 12px | Medium cards |
| borderRadius.lg | 16px | Large cards |
| borderRadius.xl | 20px | Extra large |
| borderRadius.2xl | 24px | Hero cards |
| borderRadius.full | 9999px | Circles |
| borderRadius.ios.default | 10px | iOS standard |
| borderRadius.ios.large | 14px | iOS buttons |
| borderRadius.ios.card | 16px | iOS cards |

### Safe Area Insets
```css
--safe-area-top: env(safe-area-inset-top);
--safe-area-bottom: env(safe-area-inset-bottom);
--safe-area-left: env(safe-area-inset-left);
--safe-area-right: env(safe-area-inset-right);
```

### Layout Dimensions
- **Status Bar**: 44px
- **Tab Bar**: 80px
- **Navigation Bar**: 44px
- **Max Content Width**: 896px (iPhone 16 Pro Max)

---

## Effects

### Backdrop Blur

| Level | Blur | Saturate | CSS Class |
|-------|------|----------|-----------|
| **Thick** | 40px | 180% | `.ios-blur-thick` |
| **Regular** | 30px | 160% | `.ios-blur-regular` |
| **Thin** | 20px | 140% | `.ios-blur-thin` |
| **Ultra Thin** | 10px | 120% | `.ios-blur-ultra-thin` |
| **Vibrancy** | 40px | 180% + 110% brightness | `.ios-vibrancy` |

### Shadows

**Small**
```css
box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.05);
```

**Medium**
```css
box-shadow: 0px 4px 6px -1px rgba(0, 0, 0, 0.1);
```

**Large**
```css
box-shadow: 0px 10px 15px -3px rgba(0, 0, 0, 0.1);
```

**iOS Card**
```css
box-shadow: 0px 2px 20px 0px rgba(0, 0, 0, 0.3);
```

**iOS Modal**
```css
box-shadow: 0px 10px 40px 0px rgba(0, 0, 0, 0.5);
```

---

## Components

### Button Sizes
- **Small**: 32px height, 12px padding
- **Medium**: 44px height, 16px padding (iOS standard)
- **Large**: 50px height, 20px padding

### Input
- **Height**: 44px (iOS standard)
- **Padding**: 16px horizontal, 12px vertical

### Avatar Sizes
- **Small**: 32px
- **Medium**: 40px
- **Large**: 56px
- **Extra Large**: 80px

### Card
- **Padding**: 16px
- **Gap**: 12px between elements

---

## Animation

### Spring Animations

**Bouncy** (Tab switches, modals)
```javascript
transition={{ type: 'spring', stiffness: 400, damping: 25 }}
```

**Smooth** (General interactions)
```javascript
transition={{ type: 'spring', stiffness: 300, damping: 30 }}
```

**Snappy** (Quick feedback)
```javascript
transition={{ type: 'spring', stiffness: 500, damping: 30 }}
```

### Duration
- **Fast**: 150ms
- **Normal**: 300ms
- **Slow**: 500ms

### Easing
- **Ease In**: `cubic-bezier(0.42, 0, 1, 1)`
- **Ease Out**: `cubic-bezier(0, 0, 0.58, 1)`
- **Ease In Out**: `cubic-bezier(0.42, 0, 0.58, 1)`

---

## Code Examples

### Using Glassmorphism Card
```tsx
<div 
  className="ios-blur-regular rounded-[16px] p-4 border border-white/10"
  style={{
    background: 'rgba(255, 255, 255, 0.1)',
    boxShadow: '0 2px 20px rgba(0, 0, 0, 0.3)'
  }}
>
  {/* Content */}
</div>
```

### Primary Button with Gradient
```tsx
<motion.button
  whileTap={{ scale: 0.97 }}
  className="px-6 py-3 rounded-[14px] text-white font-semibold"
  style={{
    background: 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
    boxShadow: '0 4px 12px rgba(139, 92, 246, 0.3)'
  }}
  transition={{ type: 'spring', stiffness: 400, damping: 25 }}
>
  Button Text
</motion.button>
```

### iOS Tab Bar Item
```tsx
<button 
  className="flex flex-col items-center gap-1 py-1 px-4 rounded-xl"
>
  <Icon 
    className={`w-6 h-6 ${isActive ? 'text-[#0A84FF]' : 'text-gray-400'}`}
    strokeWidth={isActive ? 2.5 : 2}
  />
  <span className={`text-[10px] font-medium ${
    isActive ? 'text-[#0A84FF]' : 'text-gray-400'
  }`}>
    Label
  </span>
</button>
```

### Typography Example
```tsx
<h1 className="text-[34px] font-bold leading-[1.2] tracking-[-0.02em]">
  Large Title
</h1>

<h2 className="text-[28px] font-bold leading-[1.2] tracking-[-0.02em]">
  Title 1
</h2>

<p className="text-[17px] font-normal leading-[1.4]">
  Body text using iOS standard size
</p>
```

### Background with Gradient Orbs
```tsx
<div className="min-h-screen bg-gradient-to-br from-[#0a0015] via-[#1a0b2e] to-[#0f0520] relative">
  {/* Gradient Orbs */}
  <div className="fixed inset-0 overflow-hidden pointer-events-none">
    <div 
      className="absolute w-[600px] h-[600px] rounded-full bg-gradient-to-br from-purple-600/20 to-indigo-600/20 blur-3xl -top-48 -right-48 animate-pulse"
      style={{ animationDuration: '8s' }}
    />
    <div 
      className="absolute w-[500px] h-[500px] rounded-full bg-gradient-to-br from-blue-600/15 to-violet-600/15 blur-3xl -bottom-32 -left-32 animate-pulse"
      style={{ animationDuration: '10s' }}
    />
  </div>
  
  {/* Content */}
</div>
```

---

## Token Usage in Cursor

### Example Prompts

**Creating a New Component:**
```
"Create a player card component using:
- Material thick blur from design-tokens.json
- Title 3 typography scale
- Spacing.4 for padding
- iOS card border radius
- Include avatar (medium size)"
```

**Updating Styling:**
```
"Update the button to use:
- Purple gradient from our token system
- Medium button height
- Spring animation (bouncy)
- iOS large border radius"
```

**Building a Layout:**
```
"Create a lobby screen with:
- Safe area insets
- iOS tab bar spacing at bottom
- Spacing.6 between sections
- Glassmorphism cards with regular blur"
```

---

## Integration with Figma

### Recommended Figma Structure

**1. Color Styles**
- Create color styles for all iOS system colors
- Name: `iOS/System/Blue/Light` and `iOS/System/Blue/Dark`
- Use exact hex values from tokens

**2. Text Styles**
- Create text styles for all typography scales
- Name: `iOS/Large Title`, `iOS/Title 1`, etc.
- Use SF Pro Display/Text fonts

**3. Effect Styles**
- Create blur effects: `iOS/Blur/Thick`, etc.
- Create shadows: `iOS/Shadow/Card`, etc.

**4. Components**
- Build component library matching token structure
- Name components: `Button/Primary`, `Card/Glass`, etc.

**5. Variables (Figma Variables)**
- Set up color variables for light/dark modes
- Link to color styles for automatic switching

### After Creating Figma File

1. Share Figma URL with Cursor (via Figma MCP)
2. Cursor will read your design system
3. Generate code matching Figma designs
4. Maintain sync between design and code

---

## Quick Reference

### Most Common Tokens

**Colors:**
- Primary Blue: `#0A84FF` (dark mode)
- Purple Gradient: `linear-gradient(135deg, #8B5CF6, #6366F1)`
- Material Regular: `rgba(44, 44, 46, 0.75)`

**Typography:**
- Body: 17px / 400 / 1.4
- Title: 28px / 700 / 1.2 / -0.02em
- Button: 17px / 600 / 1.4

**Spacing:**
- Base: 16px (spacing.4)
- Card padding: 16px
- Section gap: 24px (spacing.6)

**Effects:**
- Blur: 30px saturate(160%)
- Border radius: 16px
- Spring: stiffness 300, damping 30

---

## Maintenance

### Updating Tokens

1. Edit `/design-tokens.json`
2. Update `/src/styles/theme.css` to match
3. Update this documentation
4. Tell Cursor: "Use updated design tokens"

### Adding New Tokens

1. Add to appropriate category in `design-tokens.json`
2. Add CSS variable in `theme.css`
3. Document here with usage examples

---

## Support

**Questions about tokens?**
- Reference this file
- Check `design-tokens.json` for exact values
- Look at existing components for examples

**Using with Cursor?**
- Simply mention "use design tokens"
- Reference specific token paths
- Cursor reads these files automatically

---

**Generated:** February 3, 2026  
**For:** Rummy Scorekeeping App  
**Design System:** iOS 26 Liquid Glass Aesthetic
