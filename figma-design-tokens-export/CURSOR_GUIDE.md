# Quick Reference Guide for Cursor AI

## 🎯 How to Use Design Tokens with Cursor

### **Method 1: Reference Token Files Directly**
```
"Create a button using the design tokens from /design-tokens.json"
"Style this card with the glassmorphism tokens from design-tokens.css"
```

### **Method 2: Mention Token Categories**
```
"Use the iOS system blue color from our design tokens"
"Apply the title1 typography scale"
"Use spring-bouncy animation settings"
```

### **Method 3: Reference by Path**
```
"Use color.ios.system.blue.dark"
"Apply typography.scale.title1"
"Use blur.thick settings"
```

---

## 📚 Common Cursor Prompts

### Creating Components

**Button:**
```
"Create a primary button component using:
- Purple gradient (gradient-purple)
- iOS large border radius (14px)
- Medium height (44px)
- Spring animation (bouncy)
- Semibold font weight"
```

**Card:**
```
"Create a glassmorphism card with:
- Material regular blur
- iOS card border radius (16px)
- Spacing-4 padding (16px)
- Border with white/10 opacity
- iOS card shadow"
```

**Input Field:**
```
"Create an iOS-style input with:
- 44px height
- iOS default border radius
- Material thin background
- Body text size (17px)
- Border with primary color"
```

### Styling Elements

**Typography:**
```
"Style the heading as iOS Title 1:
- 28px font size
- Bold weight (700)
- Line height 1.2
- Letter spacing -0.02em"
```

**Background:**
```
"Add the cosmic gradient background with gradient orbs:
- Main: from #0a0015 via #1a0b2e to #0f0520
- Purple orb: top-right, 600px, blur-3xl
- Blue orb: bottom-left, 500px, blur-3xl"
```

**Blur Effect:**
```
"Apply thick iOS blur:
- 40px blur
- 180% saturate
- Use the ios-blur-thick class"
```

### Layout

**Safe Areas:**
```
"Add iOS safe area spacing:
- Top: env(safe-area-inset-top) minimum 44px
- Bottom: env(safe-area-inset-bottom)
- Account for tab bar height (80px)"
```

**Spacing:**
```
"Use our 8pt grid spacing:
- Gap between sections: spacing-6 (24px)
- Card padding: spacing-4 (16px)
- Tight spacing: spacing-2 (8px)"
```

### Animation

**Spring Animation:**
```
"Add spring animation:
- Type: spring
- Stiffness: 300
- Damping: 30
- Scale to 0.97 on tap"
```

**Transition:**
```
"Add page transition:
- Initial: opacity 0, x: 20
- Animate: opacity 1, x: 0
- Spring: stiffness 300, damping 30"
```

---

## 🎨 Color Reference (Quick Copy)

### iOS System Colors (Dark Mode)
- **Blue**: `#0A84FF`
- **Purple**: `#BF5AF2`
- **Indigo**: `#5E5CE6`
- **Green**: `#30D158`
- **Red**: `#FF453A`
- **Orange**: `#FF9F0A`
- **Yellow**: `#FFD60A`

### Gradients
- **Purple**: `linear-gradient(135deg, #8B5CF6, #6366F1)`
- **Blue**: `linear-gradient(135deg, #3B82F6, #1D4ED8)`
- **Cosmic**: `linear-gradient(135deg, #0a0015, #1a0b2e, #0f0520)`

### Materials (Dark Mode)
- **Thick**: `rgba(28, 28, 30, 0.85)`
- **Regular**: `rgba(44, 44, 46, 0.75)`
- **Thin**: `rgba(58, 58, 60, 0.6)`
- **Ultra Thin**: `rgba(72, 72, 74, 0.4)`

---

## 📏 Spacing Quick Reference

```
spacing-1  = 4px   (tight)
spacing-2  = 8px   (extra small)
spacing-3  = 12px  (small)
spacing-4  = 16px  (medium) ← DEFAULT
spacing-5  = 20px  (large)
spacing-6  = 24px  (extra large)
spacing-8  = 32px  (XXL)
spacing-10 = 40px  (XXXL)
```

---

## 🔤 Typography Quick Reference

```
Caption 2:    11px / 400 / 1.4
Caption 1:    12px / 400 / 1.4
Footnote:     13px / 400 / 1.4
Subheadline:  15px / 400 / 1.4
Callout:      16px / 400 / 1.4
Body:         17px / 400 / 1.4  ← DEFAULT
Headline:     17px / 600 / 1.4
Title 3:      20px / 600 / 1.3
Title 2:      22px / 600 / 1.25
Title 1:      28px / 700 / 1.2
Large Title:  34px / 700 / 1.2
```

---

## 🎭 Effect Quick Reference

### Border Radius
```
radius-sm        = 8px
radius-md        = 12px
radius-lg        = 16px   ← Cards
radius-xl        = 20px
radius-2xl       = 24px
radius-ios-large = 14px   ← Buttons
```

### Blur
```
blur-ultra-thin = 10px + saturate(120%)
blur-thin       = 20px + saturate(140%)
blur-regular    = 30px + saturate(160%)  ← DEFAULT
blur-thick      = 40px + saturate(180%)
```

### Shadow
```
shadow-sm        = 0 1px 2px rgba(0,0,0,0.05)
shadow-md        = 0 4px 6px rgba(0,0,0,0.1)
shadow-ios-card  = 0 2px 20px rgba(0,0,0,0.3)  ← Cards
shadow-ios-modal = 0 10px 40px rgba(0,0,0,0.5)
```

---

## 💡 Example Prompts for Common Tasks

### "Create a new tab/screen"
```
"Create a new Settings tab with:
- Safe area insets at top (44px minimum)
- Cosmic gradient background
- Gradient orbs
- Glassmorphism cards with regular blur
- iOS title1 headers
- spacing-6 between sections
- Tab bar spacing at bottom (80px)"
```

### "Add a player card"
```
"Create a player card component:
- Material regular background
- Regular blur effect
- iOS card radius (16px)
- spacing-4 padding
- Avatar (medium - 40px)
- Title3 for name
- Footnote for subtitle
- Border white/10"
```

### "Style a modal"
```
"Create a modal dialog:
- Material thick background
- Thick blur effect
- iOS large radius (14px)
- iOS modal shadow
- spacing-6 padding
- Title2 heading
- Body text content
- Primary button at bottom"
```

### "Add a list"
```
"Create a player list:
- spacing-3 between items
- Each row: material-thin + thin blur
- iOS default radius (10px)
- spacing-4 padding
- Avatar left (md - 40px)
- Headline text
- Caption secondary info"
```

### "Create a button group"
```
"Create a two-button group:
- Primary: purple gradient, white text
- Secondary: material-regular, blue text
- Both: iOS large radius (14px)
- Height: 44px (medium)
- Spring animation on tap
- spacing-3 gap between"
```

---

## 🔧 Token File Locations

```
/design-tokens.json              # Complete token definitions (JSON format)
/src/styles/design-tokens.css    # CSS custom properties
/src/styles/theme.css            # Current implementation
/DESIGN_SYSTEM.md               # Full documentation
/CURSOR_GUIDE.md                # This file
```

---

## 📱 Component Patterns

### Glassmorphism Card Pattern
```tsx
<div 
  className="rounded-[16px] p-4 border border-white/10"
  style={{
    background: 'var(--material-regular)',
    backdropFilter: 'blur(30px) saturate(160%)',
    boxShadow: '0 2px 20px rgba(0, 0, 0, 0.3)'
  }}
>
  Content
</div>
```

### iOS Button Pattern
```tsx
<motion.button
  whileTap={{ scale: 0.97 }}
  className="px-6 py-3 rounded-[14px] text-white font-semibold"
  style={{
    background: 'linear-gradient(135deg, #8B5CF6, #6366F1)',
  }}
  transition={{ type: 'spring', stiffness: 400, damping: 25 }}
>
  Text
</motion.button>
```

### iOS Tab Bar Item Pattern
```tsx
<button className="flex flex-col items-center gap-1 py-1 px-4 rounded-xl">
  <Icon 
    className={`w-6 h-6 ${active ? 'text-[#0A84FF]' : 'text-gray-400'}`}
    strokeWidth={active ? 2.5 : 2}
  />
  <span className={`text-[10px] font-medium ${active ? 'text-[#0A84FF]' : 'text-gray-400'}`}>
    Label
  </span>
</button>
```

---

## ✅ Checklist for New Components

When asking Cursor to create a component, include:

- [ ] **Color**: iOS system color or gradient
- [ ] **Typography**: iOS scale (title1, body, etc.)
- [ ] **Spacing**: 8pt grid (spacing-4, spacing-6, etc.)
- [ ] **Radius**: iOS radius (10px, 14px, 16px)
- [ ] **Material**: Blur level (regular, thick, thin)
- [ ] **Shadow**: iOS shadow (card or modal)
- [ ] **Animation**: Spring settings (bouncy, smooth)
- [ ] **Safe Areas**: If near edges
- [ ] **Responsive**: Mobile-first design

---

## 🚀 Pro Tips for Cursor

1. **Always mention "use our design tokens"** to ensure consistency
2. **Reference specific token paths** for precision
3. **Mention iOS aesthetic** to maintain native feel
4. **Use glassmorphism** for depth and modern look
5. **Include spring animations** for natural motion
6. **Consider safe areas** for iPhone layouts
7. **Test dark mode** by checking both color sets
8. **Use 8pt grid** for perfect alignment

---

## 🎯 Quick Start Template

Copy this into Cursor when creating anything new:

```
"Create a [COMPONENT] using our iOS 26 design system:
- Use design tokens from design-tokens.json
- iOS glassmorphism with [regular/thick/thin] blur
- [title1/title2/body] typography scale
- iOS [10/14/16]px border radius
- Spacing-[4/6] for padding
- [Purple/Blue] gradient or iOS [blue/purple] color
- Spring animation (bouncy/smooth)
- Include safe area insets if needed
- Dark mode compatible"
```

---

**Last Updated:** February 3, 2026  
**For:** Cursor AI Integration  
**Design System:** iOS 26 Liquid Glass
