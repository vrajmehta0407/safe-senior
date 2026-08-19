# SafeSenior Design System (Design DNA)

Extracted from Google Stitch Project: `SafeSenior Pinterest-Style Protection Suite` (ID: `2431491891201658390`)
Theme: **Serene Safe Haven (Modern Tactile / Pinterest-inspired Masonry)**

---

## 1. Brand & Style Philosophy

The SafeSenior design system is crafted to balance high-utility safety features with a warm, inviting aesthetic that avoids the clinical "medical" feel of traditional senior-care apps. Drawing inspiration from modern editorial layouts, it utilizes a **Pinterest-inspired Masonry feed** to present security insights as discoverable, empowering information rather than intimidating warnings.

The style is **Modern Tactile**, prioritizing high legibility and large interactive surfaces:
- Soft drop shadows create physical hierarchy to assist seniors with declining depth perception.
- High contrast compliant with WCAG AA (minimum 4.5:1 ratio for normal text, 3:1 for large text).
- Warm off-white backgrounds to reduce blue-light glare and eye strain.

---

## 2. Color Palette & Tokens

### Primary & Semantic
- **Primary Teal (`#006565` / `#008080`)**: Core brand, primary CTA buttons, active navigation, safe status indicators.
  - `on-primary`: `#ffffff`
  - `primary-container`: `#008080`
  - `on-primary-container`: `#e3fffe`
  - `primary-fixed`: `#93f2f2`
  - `primary-fixed-dim`: `#76d6d5`
- **Secondary / Danger Terracotta (`#aa361f` / `#c2472e`)**: High-visibility alert and risk indicator without panic-inducing harshness.
  - `on-secondary`: `#ffffff`
  - `secondary-container`: `#fe7356`
  - `on-secondary-container`: `#6d0f00`
  - `secondary-fixed`: `#ffdad3`
- **Tertiary / Warm Gold (`#735c00` / `#cca830` / `#d4af37`)**: Milestone celebrations, safety achievements, badges.
  - `on-tertiary`: `#ffffff`
  - `tertiary-container`: `#cca830`
  - `tertiary-fixed`: `#ffe088`

### Surface & Background Tokens
- **Background**: `#fbf9f9` (Warm off-white)
- **Surface**: `#fbf9f9`
- **Surface Container Lowest**: `#ffffff` (Elevated cards & interactive containers)
- **Surface Container Low**: `#f5f3f3`
- **Surface Container**: `#efeded`
- **Surface Container High**: `#e9e8e7`
- **Surface Container Highest**: `#e3e2e2`
- **Surface Dim**: `#dbdad9`
- **On Surface (Text)**: `#1b1c1c` (Deep dark slate)
- **On Surface Variant (Muted Text)**: `#3e4949`
- **Outline / Border**: `#6e7979`
- **Outline Variant**: `#bdc9c8`

---

## 3. Typography Hierarchy

### Font Families
- **Headlines / Display**: `Plus Jakarta Sans`
- **Body / Labels / UI**: `Atkinson Hyperlegible Next` (Engineered for hyper-legibility and seniors with low vision)

### Type Scale
| Token | Font Family | Size | Weight | Line Height | Letter Spacing |
|---|---|---|---|---|---|
| `headline-lg` | Plus Jakarta Sans | 32px | 700 (Bold) | 40px | -0.02em |
| `headline-md` | Plus Jakarta Sans | 24px | 600 (SemiBold) | 32px | Normal |
| `headline-sm` | Plus Jakarta Sans | 20px | 600 (SemiBold) | 28px | Normal |
| `body-lg` | Atkinson Hyperlegible Next | 18px | 400 (Regular) | 28px | Normal |
| `body-md` | Atkinson Hyperlegible Next | 16px | 400 (Regular) | 24px | Normal |
| `label-lg` | Atkinson Hyperlegible Next | 18px | 600 (SemiBold) | 24px | Normal |
| `label-md` | Atkinson Hyperlegible Next | 14px | 700 (Bold) | 20px | +0.05em |

> **Accessibility Rule:** No body text falls below 16px in mobile or web views.

---

## 4. Spacing, Dimensions & Radius

### Spacing Scale
- **Base Unit**: `8px`
- **Gutter Mobile**: `16px`
- **Margin Mobile**: `20px`
- **Gutter Desktop**: `24px`
- **Margin Desktop**: `64px`
- **Interactive Touch Targets**: Strict minimum of **48x48px**

### Corner Radius
- `sm`: 4px (`0.25rem`)
- `DEFAULT`: 8px (`0.5rem`)
- `md`: 12px (`0.75rem`) — Form inputs & cards
- `lg`: 16px (`1rem`)
- `xl`: 24px (`1.5rem`) — Hero cards, masonry containers, sheets
- `full`: 9999px (Pill buttons, chips, avatars)

### Elevation & Shadows
- **Level 0 (Background)**: `#fbf9f9`
- **Level 1 (Cards & Masonry Units)**: `#ffffff` with `0px 4px 12px rgba(0, 0, 0, 0.08)`
- **Level 2 (Dropdowns & Modals)**: `0px 10px 25px rgba(0, 0, 0, 0.12)`
- **Detail Screens (Bottom Sheet)**: 32px top corner radius with drag handle indicator.

---

## 5. UI Component Specs

### 1. Masonry Cards
- Image-forward card with image taking up $\ge 50-60\%$ height.
- Card padding: consistent 20px.
- Status badge (e.g. "Safe", "Suspicious", "Review") floating on top-right.

### 2. Primary & Secondary Buttons
- Height: 52px to 56px, fully rounded (pill) with 18px typography.
- Solid high-contrast teal (`#006565`) with white text and subtle 1px border.

### 3. Filter Chips
- Pill-shaped filter chips (`#e0f2f2` inactive with `#006565` text; solid `#006565` when active with white text).

### 4. Form Inputs
- 56px height, 12px radius, 18px text, `#717171` placeholder, 3px teal outline on focus.
