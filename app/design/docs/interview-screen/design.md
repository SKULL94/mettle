---
name: Technical Precision
colors:
  surface: '#131316'
  surface-dim: '#131316'
  surface-bright: '#39393c'
  surface-container-lowest: '#0e0e11'
  surface-container-low: '#1b1b1e'
  surface-container: '#1f1f22'
  surface-container-high: '#2a2a2d'
  surface-container-highest: '#353438'
  on-surface: '#e4e1e6'
  on-surface-variant: '#c9c4d3'
  inverse-surface: '#e4e1e6'
  inverse-on-surface: '#303033'
  outline: '#938f9d'
  outline-variant: '#484552'
  surface-tint: '#c9beff'
  primary: '#c9beff'
  on-primary: '#311c7e'
  primary-container: '#9d8df1'
  on-primary-container: '#331f80'
  inverse-primary: '#6050af'
  secondary: '#c7c5cf'
  on-secondary: '#303037'
  secondary-container: '#46464e'
  on-secondary-container: '#b6b4bd'
  tertiary: '#dac941'
  on-tertiary: '#373100'
  tertiary-container: '#bdad25'
  on-tertiary-container: '#474000'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e6deff'
  primary-fixed-dim: '#c9beff'
  on-primary-fixed: '#1b0062'
  on-primary-fixed-variant: '#483795'
  secondary-fixed: '#e4e1eb'
  secondary-fixed-dim: '#c7c5cf'
  on-secondary-fixed: '#1b1b22'
  on-secondary-fixed-variant: '#46464e'
  tertiary-fixed: '#f7e55a'
  tertiary-fixed-dim: '#d9c840'
  on-tertiary-fixed: '#201c00'
  on-tertiary-fixed-variant: '#4f4700'
  background: '#131316'
  on-background: '#e4e1e6'
  surface-variant: '#353438'
typography:
  display:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.015em
  title:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.005em
  body:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.06em
  code-inline:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: 0em
  code-block:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The design system establishes a high-focus, distraction-free environment tailored specifically for mobile and Flutter engineers preparing for technical interviews. The brand personality is disciplined, analytical, and respectful of cognitive bandwidth. The aesthetic completely rejects decorative consumer-tech tropes—avoiding playful illustrations, multi-stop gradients, and ambient blur or glow effects. 

Instead, the design system adopts a stark, utilitarian, dark-first study tool aesthetic rooted in Material 3 principles. The visual hierarchy relies strictly on surgical micro-typography, precise structural layout, and calibrated surface brightness tiers. The interface evokes a feeling of terminal-grade focus, quiet competence, and professional readiness.

## Colors

The palette is engineered for low eye strain during intense, long-duration practice sessions. It operates on a low-chroma scale where chromatic saturation is reserved strictly for interactive state focus and performance scoring.

### Base & Surface Hierarchy
- **Canvas / Background (`#0E0E11`)**: The baseline dark canvas.
- **Surface Level 1 (`#17171C`)**: Base container tone for cards, list tiles, and stationary panels.
- **Elevated Surface Level 2 (`#1F1F26`)**: Interactive states, bottom sheets, dialogs, and active segments.
- **Structural Border / Outline (`#2E2E38`)**: Uniform 1px border applied to separate planes and bounded components.

### Typography & Content
- **Text Primary (`#EDEDF2`)**: High-contrast readable layer for technical prompts, questions, and active labels.
- **Text Secondary (`#9A9AA8`)**: Subheadings, descriptive metadata, and passive feedback.
- **Text Muted (`#6B6B78`)**: Timestamps, disabled actions, and de-emphasized structural hints.

### Accent & Interaction
- **Accent Primary (`#9D8DF1`)**: Soft desaturated violet, used exclusively for primary calls to action, active indicators, and focus outlines.
- **On-Accent (`#16111F`)**: Deep violet-tinted black for text and icons placed directly over the accent fill.

### Functional Score Metrics
Score colors represent the only highly saturated tokens in the app. They must never appear as bare decorative splashes; they must always be directly coupled with numerical values, metrics, or explicit diagnostic labels:
- **Weak (0–39)**: `#F87171`
- **Developing (40–59)**: `#FB923C`
- **Solid (60–79)**: `#FBBF24`
- **Strong (80–100)**: `#34D399`

## Typography

Typography prioritizes legibility, density, and immediate scannability. Inter handles all product UI and natural language prompts, while JetBrains Mono provides exact code framing for Flutter/Dart and native mobile snippets.

- **Display (32/40, Semibold, -0.02em)**: Used exclusively for top-tier milestone evaluations, end-of-interview summary scores, and onboarding step headers.
- **Headline (24/32, Semibold, -0.015em)**: Screen titles, interview question prompts, and section headlines.
- **Title (16/24, Semibold, -0.005em)**: Card headers, modal headlines, category groupings, and active response titles.
- **Body (16/24, Regular)**: Main conversational text, feedback analysis, and question context.
- **Body Small (14/20, Regular)**: Secondary explanations, metadata, and supporting technical hints.
- **Uppercase Label (12/16, Semibold, +0.06em)**: Category tags, state badges, metric labels, and table column headers. Always rendered in uppercase.
- **Monospace Styles (JetBrains Mono)**: `code-inline` embedded within prose uses 14/22; `code-block` containers use 13/20 to preserve structural horizontal real estate on 390px screens.

## Layout & Spacing

The layout is optimized for single-column mobile viewports (calibrated to 390px reference width), operating under Material 3 layout mechanics.

### Margin & Gutter System
- **Screen Margins**: Uniform 16px (`1rem`) edge-to-edge padding across standard mobile screens.
- **Column Structure**: 4-column fluid mobile grid with 16px (`1rem`) gutters between items.
- **Vertical Rhythm**: 8px baseline grid logic. Micro-spacing uses 4px (`space-xs`) and 8px (`space-sm`); layout separation uses 16px (`space-md`), 24px (`space-lg`), and 32px (`space-xl`).

### Touch Targets
- All interactive elements must strictly honor a minimum 48×48px accessible touch target area. If an icon or control displays at a visually smaller dimension (e.g., 20px icon or 32px chip), its transparent touch container must pad out to at least 48px.

## Elevation & Depth

This design system uses **zero drop shadows or blur filters** in dark mode. Elevation is expressed entirely through tonal surface shifts and crisp border delineation:

- **Level 0 (Base)**: `#0E0E11` canvas background. No borders.
- **Level 1 (Cards, Containers, Input Fields)**: Surface `#17171C` bounded by a crisp 1px outline of `#2E2E38`.
- **Level 2 (Modals, Overlays, Active Focus States, Toolbars)**: Elevated Surface `#1F1F26` enclosed with a 1px outline of `#2E2E38`.
- **Focus / Selected Elevation**: Retains the respective surface tone but alters the 1px outline to the accent color `#9D8DF1`.

## Shapes

The design system establishes a strict, predictable shape hierarchy governed by function:

- **Default Elements (12px / `rounded-md`)**: Text input fields, code snippet blocks, bottom sheets, and secondary buttons.
- **Cards & Structured Containers (16px / `rounded-lg`)**: Primary question cards, diagnostic report containers, and mock interview scenario panels.
- **Pills & Compact Controls (Fully Rounded / 9999px)**: Filter chips, category tags, status badges, voice recording triggers, and pill action buttons.

## Components

### Buttons
- **Primary Button**: Pill shape (9999px) or 12px rounded rect. Solid `#9D8DF1` fill with `#16111F` bold typography. Height is minimum 48px. No shadow.
- **Secondary Button**: 12px rounded rect. Surface `#17171C`, 1px outline `#2E2E38`, `#EDEDF2` text. Active state shifts background to `#1F1F26`.
- **Ghost / Text Button**: Transparent background, `#EDEDF2` text, `#9D8DF1` on press. 48px minimum target boundary.

### Cards & Panels
- Constructed with `#17171C` fill and 1px `#2E2E38` border. Corner radius: 16px.
- Internal padding: 16px (`space-md`) or 24px (`space-lg`).
- Never use drop shadows. Nesting inside cards is achieved by using elevated surface `#1F1F26` panels.

### Text Input & Code Inputs
- **Base State**: 12px radius, `#17171C` surface, 1px `#2E2E38` border. Minimum height: 48px. Text `#EDEDF2`, placeholder `#6B6B78`.
- **Focused State**: Border shifts to 1px `#9D8DF1`. No glow or spread shadow.
- **Code Field**: JetBrains Mono 14/22, `#17171C` surface, padded with 16px, formatted for indentation stability.

### Chips & Tags
- **Filter & Category Chips**: Height 32px (within a 48px hit area), fully rounded (9999px). Surface `#17171C`, border 1px `#2E2E38`, typography `label-caps` in `#9A9AA8`.
- **Selected Chip**: Surface `#1F1F26`, border 1px `#9D8DF1`, label `#EDEDF2`.

### Checkboxes & Radio Buttons
- 20×20px visual boundary placed inside a 48×48px transparent hit area.
- Unselected: Surface `#17171C`, 1px border `#2E2E38`.
- Selected: `#9D8DF1` fill with `#16111F` checkmark or radio dot.

### Lists & Evaluation Rows
- Edge-to-edge or inset 16px within cards.
- Dividers: 1px `#2E2E38`.
- Interactive list rows feature 48px minimum height, surface hover/press feedback shifting from `#17171C` to `#1F1F26`.

### Performance Score Indicators
- Pill containers with `#1F1F26` surface and 1px `#2E2E38` border.
- The score value text and an adjacent 6px circular dot use the corresponding functional score token (`#F87171`, `#FB923C`, `#FBBF24`, or `#34D399`). Text labels remain `#EDEDF2` to prevent saturation fatigue.