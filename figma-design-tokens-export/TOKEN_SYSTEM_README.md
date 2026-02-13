# 🎨 Design Token System - Complete Package

**iOS 26 Liquid Glass Design System for Rummy Scorekeeping App**

---

## 📦 What's Included

This package contains a complete, production-ready design token system that you can use directly in Cursor or export to Figma.

### Files Created:

1. **`/design-tokens.json`** (7.5 KB)
   - Complete DTCG-compliant token definitions
   - All colors, typography, spacing, effects
   - Light & dark mode support
   - Ready for Figma import or tooling

2. **`/src/styles/design-tokens.css`** (15 KB)
   - CSS custom properties for all tokens
   - Utility classes for common patterns
   - Light/dark mode CSS variables
   - Ready to import in your app

3. **`/DESIGN_SYSTEM.md`** (12 KB)
   - Comprehensive documentation
   - Usage examples and code snippets
   - Visual reference tables
   - Figma integration guide

4. **`/CURSOR_GUIDE.md`** (8 KB)
   - Quick reference for Cursor AI
   - Common prompts and patterns
   - Component checklists
   - Pro tips for AI development

5. **`/tokens-reference.json`** (5 KB)
   - Quick-access token values
   - Component recipes (copy-paste ready)
   - Layout patterns
   - State variants

---

## 🚀 Quick Start with Cursor

### Option 1: Direct Usage (Immediate)

**Just mention the tokens in your Cursor prompts:**

```
"Create a button using our design token system"
"Use the glassmorphism card recipe from tokens-reference.json"
"Apply iOS system colors from design-tokens.json"
```

Cursor will automatically read these files in your project!

### Option 2: Import CSS Tokens

Add to your `/src/main.tsx` or `/src/app/App.tsx`:

```tsx
import '@/styles/design-tokens.css';
```

Then use CSS variables in your styles:

```css
.my-button {
  background: var(--gradient-purple-start);
  border-radius: var(--radius-ios-large);
  padding: var(--spacing-4);
}
```

### Option 3: Tailwind Integration

Use inline with Tailwind:

```tsx
<div className="p-[var(--spacing-4)] rounded-[var(--radius-ios-card)]" />
```

---

## 📖 How to Use Each File

### `design-tokens.json`
**Best for:** Complete token reference, tooling integration, Figma export

```javascript
// Token path structure:
color.ios.system.blue.dark → "#0A84FF"
typography.scale.title1.fontSize → "28px"
spacing.4 → "16px"
blur.thick.blur → "40px"
```

### `design-tokens.css`
**Best for:** Direct CSS usage, inline styles

```css
/* Use CSS variables */
color: var(--ios-blue);
font-size: var(--font-size-title1);
padding: var(--spacing-4);
backdrop-filter: blur(var(--blur-thick));

/* Or use utility classes */
.blur-thick
.gradient-purple
.text-title1
.material-regular
```

### `tokens-reference.json`
**Best for:** Quick copy-paste, Cursor prompts, component recipes

```json
// Ready-to-use component patterns
"primaryButton": {
  "properties": { ... },
  "animation": { ... },
  "className": "..."
}
```

### `DESIGN_SYSTEM.md`
**Best for:** Understanding the system, visual reference, documentation

- Full color palette with tables
- Typography scale
- Spacing system
- Code examples
- Figma integration guide

### `CURSOR_GUIDE.md`
**Best for:** Working with Cursor AI, quick reference, prompts

- Common Cursor prompts
- Quick copy values
- Component patterns
- Usage checklist

---

## 🎯 Common Use Cases

### Creating a New Component

**With Cursor:**
```
"Create a player card using our design tokens:
- Use glassmorphismCard recipe
- Title3 typography for name
- Medium avatar (40px)
- Spacing-4 padding"
```

**Manual (with CSS variables):**
```tsx
<div 
  className="rounded-[var(--radius-ios-card)] p-[var(--spacing-4)] border border-white/10"
  style={{
    background: 'var(--material-regular)',
    backdropFilter: `blur(var(--blur-regular)) saturate(var(--saturate-regular))`
  }}
>
  {/* Content */}
</div>
```

### Styling Existing Components

**With Cursor:**
```
"Update the button to use:
- Purple gradient from tokens
- iOS large radius (14px)
- Medium height (44px)"
```

**Manual:**
```tsx
<button 
  className="px-[var(--spacing-6)] py-[var(--spacing-3)] rounded-[var(--radius-ios-large)]"
  style={{ background: 'var(--gradient-purple-start)' }}
>
  Click Me
</button>
```

---

## 🎨 Exporting to Figma

### Step 1: Prepare Figma File

Create a new Figma file with:

1. **Color Styles**
   - Go to `design-tokens.json` → `color` section
   - Create color styles for each iOS system color (light & dark)
   - Name: `iOS/System/Blue/Light`, `iOS/System/Blue/Dark`

2. **Text Styles**
   - Go to `typography.scale` section
   - Create text styles for each scale
   - Name: `iOS/Large Title`, `iOS/Title 1`, etc.
   - Use SF Pro Display/Text fonts

3. **Effect Styles**
   - Go to `blur` and `shadow` sections
   - Create blur effects: `iOS/Blur/Thick`, etc.
   - Create shadows: `iOS/Shadow/Card`, etc.

4. **Components**
   - Use `tokens-reference.json` → `componentRecipes`
   - Build components: Button, Card, Input, etc.

### Step 2: Connect via Figma MCP

1. Share your Figma file (get URL)
2. In Cursor, paste the Figma URL
3. Cursor reads your design system
4. Generate code from Figma designs
5. Maintain design-code sync

---

## 📊 Token Coverage

✅ **Colors**
- iOS System Colors (9 colors × 2 modes)
- Gradients (Cosmic, Purple, Blue, Orbs)
- Materials (4 levels × 2 modes)
- Text colors (4 levels × 2 modes)
- Semantic colors (Success, Warning, Error, Info)

✅ **Typography**
- Font family (SF Pro system stack)
- 11 iOS scales (Large Title → Caption 2)
- 4 font weights
- Line heights & letter spacing

✅ **Spacing**
- 13 spacing values (0px → 96px)
- 8pt grid system

✅ **Border Radius**
- 7 standard sizes
- 3 iOS-specific sizes

✅ **Effects**
- 4 blur levels with saturation
- 5 shadow presets
- iOS-specific shadows

✅ **Animation**
- 3 spring presets
- 3 duration presets
- 3 easing curves

✅ **Layout**
- Safe area insets
- Component dimensions
- iOS standard heights

✅ **Components**
- Button sizes & variants
- Input specifications
- Card patterns
- Avatar sizes

---

## 🔧 Integration Options

### 1. Cursor AI (Recommended)
✅ Zero setup - just use the files  
✅ Mention tokens in prompts  
✅ Automatic consistency  

### 2. CSS Variables
✅ Import design-tokens.css  
✅ Use var(--token-name)  
✅ Works with any framework  

### 3. Tailwind Classes
✅ Use inline: `className="p-[var(--spacing-4)]"`  
✅ Mix with Tailwind utilities  
✅ Dynamic values  

### 4. Figma Sync
✅ Export tokens to Figma  
✅ Design in Figma  
✅ Generate code via MCP  
✅ Maintain single source of truth  

---

## 📚 Documentation Quick Links

| Need | File | Section |
|------|------|---------|
| **Full color palette** | DESIGN_SYSTEM.md | Color System |
| **Typography scale** | DESIGN_SYSTEM.md | Typography |
| **Component recipes** | tokens-reference.json | componentRecipes |
| **Cursor prompts** | CURSOR_GUIDE.md | Example Prompts |
| **Quick values** | CURSOR_GUIDE.md | Quick Reference |
| **CSS variables** | design-tokens.css | All sections |
| **JSON tokens** | design-tokens.json | All categories |

---

## 💡 Pro Tips

### For Cursor Users:
1. Always say "use our design tokens" in prompts
2. Reference specific recipes: "use glassmorphismCard recipe"
3. Mention token paths: "use color.ios.system.blue.dark"
4. Cursor reads all files automatically

### For Manual Coding:
1. Import `design-tokens.css` in your main file
2. Use CSS variables: `var(--token-name)`
3. Reference DESIGN_SYSTEM.md for values
4. Check tokens-reference.json for recipes

### For Figma Export:
1. Read DESIGN_SYSTEM.md → Figma Integration
2. Create styles matching token structure
3. Use exact hex values from design-tokens.json
4. Connect via Figma MCP for sync

---

## 🎯 What Makes This System Special

✅ **Complete Coverage** - Every aspect of iOS 26 design  
✅ **Ready to Use** - Works immediately with Cursor  
✅ **Well Documented** - Multiple reference files  
✅ **Production Ready** - Based on real iOS standards  
✅ **Figma Compatible** - Can be exported/imported  
✅ **Dark Mode** - Full light/dark mode support  
✅ **Consistent** - Single source of truth  
✅ **Flexible** - Use with any tool/workflow  

---

## 🚀 Next Steps

### Immediate (Use Now):
1. ✅ Files are ready in your project
2. ✅ Tell Cursor "use our design tokens"
3. ✅ Start building components

### Short Term (Optional):
1. Import `design-tokens.css` in main file
2. Try component recipes from tokens-reference.json
3. Reference DESIGN_SYSTEM.md when needed

### Long Term (Advanced):
1. Create Figma design system
2. Export tokens to Figma
3. Connect via Figma MCP
4. Maintain design-code sync

---

## 📞 Quick Help

**Can't find a value?**
→ Check CURSOR_GUIDE.md Quick Reference

**Need a component pattern?**
→ Check tokens-reference.json Component Recipes

**Want full documentation?**
→ Check DESIGN_SYSTEM.md

**Using with Cursor?**
→ Just mention tokens in your prompts!

**Need CSS variables?**
→ Import design-tokens.css

**Want Figma export?**
→ Read DESIGN_SYSTEM.md → Integration with Figma

---

## ✨ Summary

You now have a **complete, production-ready design token system** that:

- 📦 Works immediately with Cursor AI
- 🎨 Contains all iOS 26 liquid glass design elements
- 📖 Is fully documented with examples
- 🔄 Supports light/dark mode
- 🎯 Includes ready-to-use component recipes
- 📱 Follows iOS design standards
- 🚀 Can be exported to Figma

**Just tell Cursor to "use our design tokens" and start building!**

---

**Created:** February 3, 2026  
**Version:** 1.0.0  
**For:** Rummy Scorekeeping App  
**Design:** iOS 26 Liquid Glass Aesthetic
