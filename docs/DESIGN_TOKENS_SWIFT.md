# Design Tokens — Swift Mapping

Map from Figma `design-tokens.json` to Swift APIs in `Core/DesignSystem.swift`.

## Colors

| Figma Token Path | Swift |
|------------------|-------|
| `color.background.gradient.cosmic` | `AppTheme.backgroundCosmic` |
| `color.background.gradient.purple` | `AppTheme.gradientPrimary` |
| `color.background.gradient.blue` | `AppTheme.gradientSecondary` |
| `color.ios.system.blue.dark` | `AppTheme.iosBlue` |
| `color.ios.system.purple.dark` | `AppTheme.iosPurple` |
| `color.ios.system.green.dark` | `AppTheme.iosGreen` |
| `color.ios.system.red.dark` | `AppTheme.iosRed` |
| `color.text.primary.dark` | `AppTheme.textPrimary` |
| `color.text.secondary.dark` | `AppTheme.textSecondary` |
| `color.semantic.success.dark` | `AppTheme.positiveColor` |
| `color.semantic.error.dark` | `AppTheme.destructiveColor` |

## Typography

| Figma Token | Swift |
|-------------|-------|
| `typography.scale.largeTitle` | `AppTypography.largeTitle()` |
| `typography.scale.title1` | `AppTypography.title1()` |
| `typography.scale.title2` | `AppTypography.title2()` |
| `typography.scale.title3` | `AppTypography.title3()` |
| `typography.scale.headline` | `AppTypography.headline()` |
| `typography.scale.body` | `AppTypography.body()` |
| `typography.scale.callout` | `AppTypography.callout()` |
| `typography.scale.subheadline` | `AppTypography.subheadline()` |
| `typography.scale.footnote` | `AppTypography.footnote()` |
| `typography.scale.caption1` | `AppTypography.caption1()` |
| `typography.scale.caption2` | `AppTypography.caption2()` |

## Spacing (8pt grid)

| Figma | Swift |
|-------|-------|
| `spacing.0` | `AppSpacing._0` |
| `spacing.1` | `AppSpacing._1` (4pt) |
| `spacing.2` | `AppSpacing._2` (8pt) |
| `spacing.3` | `AppSpacing._3` (12pt) |
| `spacing.4` | `AppSpacing._4` (16pt) |
| `spacing.5` | `AppSpacing._5` (20pt) |
| `spacing.6` | `AppSpacing._6` (24pt) |
| `spacing.8` | `AppSpacing._8` (32pt) |
| `spacing.12` | `AppSpacing._12` (48pt) |
| `spacing.16` | `AppSpacing._16` (64pt) |

Aliases: `AppSpacing.tight`, `small`, `medium`, `large`, `xLarge`.

## Border Radius

| Figma | Swift |
|-------|-------|
| `borderRadius.sm` | `AppRadius.sm` (8) |
| `borderRadius.md` | `AppRadius.md` (12) |
| `borderRadius.lg` | `AppRadius.lg` (16) |
| `borderRadius.xl` | `AppRadius.xl` (20) |
| `borderRadius.ios.large` | `AppRadius.iosLarge` (14) |
| `borderRadius.ios.card` | `AppRadius.iosCard` (16) |

## Animation

| Figma | Swift |
|-------|-------|
| `animation.spring.bouncy` | `AppAnimation.springBouncy` |
| `animation.spring.smooth` | `AppAnimation.springSmooth` |
| `animation.spring.snappy` | `AppAnimation.springSnappy` |
| `animation.duration.fast` | `AppAnimation.durationFast` (0.15) |
| `animation.duration.normal` | `AppAnimation.durationNormal` (0.3) |

## Components

| Figma | Swift |
|-------|-------|
| `component.button.height.md` | `AppComponent.Button.heightMd` (44) |
| `component.button.height.lg` | `AppComponent.Button.heightLg` (50) |
| `component.input.height` | `AppComponent.Input.height` (44) |
| `component.card.padding` | `AppComponent.Card.padding` (16) |
| `component.avatar.size.md` | `AppComponent.Avatar.sizeMd` (40) |
| `component.avatar.size.lg` | `AppComponent.Avatar.sizeLg` (56) |
| `layout.tabBar.height` | `AppComponent.Layout.tabBarHeight` (80) |
