# Design System Strategy: The Neon Editorial

## 1. Overview & Creative North Star
**The Creative North Star: "Hyper-Fluent Precision"**

This design system moves beyond the standard "fintech" aesthetic by merging the structural discipline of high-end editorial magazines with the kinetic energy of Gen-Z digital culture. We are not building a ledger; we are building a dashboard for financial self-expression. 

The "Simplex" aesthetic is achieved through a radical commitment to **Negative Space as Structure**. By removing traditional borders and lines, we allow the content—dynamic expense data and vibrant accents—to breathe. We break the "template" look by using intentional asymmetry in our chart placements and utilizing a high-contrast typography scale that feels both authoritative and playful. This is a "Flutter-first" system, designed around modular widgets that feel like physical objects resting on a dark, liquid-ink background.

---

## 2. Colors: Tonal Depth & Kinetic Accents
The palette is anchored in a "Deep Charcoal" ecosystem to provide a sophisticated canvas for high-chroma accents.

*   **The "No-Line" Rule:** Visual separation is strictly enforced through **Surface Shifts**, never 1px lines. To separate a transaction list from a summary card, use `surface_container_low` against a `surface` background. The eye should perceive change through tonal mass, not strokes.
*   **Surface Hierarchy & Nesting:** 
    *   **Level 0 (Background):** `surface` (#0e0e0e) for the primary application canvas.
    *   **Level 1 (Sections):** `surface_container_low` (#131313) for large grouping areas.
    *   **Level 2 (Interactive Elements):** `surface_container_high` (#20201f) for cards and input wrappers.
*   **The "Glass & Gradient" Rule:** Floating action buttons and high-priority modals must utilize **Glassmorphism**. Apply `surface_variant` at 60% opacity with a 20px backdrop blur to create a "frosted obsidian" effect.
*   **Signature Textures:** For primary CTAs and hero charts, use a linear gradient from `primary` (#f3ffca) to `primary_container` (#cafd00). This "Neon Lime" glow creates a sense of light-emission against the dark UI, signaling high energy.

---

## 3. Typography: The Editorial Voice
We use a dual-font strategy to balance technical clarity with expressive personality.

*   **Expressive Layer (Display & Headlines):** **Space Grotesk.** This font brings a "Neo-Brutalist" tech edge. Use `display-lg` (3.5rem) for big spend numbers and `headline-md` (1.75rem) for category titles. Its wide apertures and geometric forms feel sophisticated yet approachable.
*   **Functional Layer (Body & Labels):** **Manrope.** A highly legible sans-serif for the "fine print" of financial data. Use `body-md` (0.875rem) for transaction details and `label-md` (0.75rem) for timestamps.
*   **Hierarchy Note:** Always pair a `display-sm` Space Grotesk header with a `label-md` Manrope sub-header in `on_surface_variant` (#adaaaa) to create a clear editorial "lockup."

---

## 4. Elevation & Depth: Tonal Layering
Traditional shadows are largely replaced by **Luminance Layering**. 

*   **The Layering Principle:** Depth is conveyed by the "Brightness = Proximity" rule. The lighter the surface color (from `surface_container_lowest` to `surface_bright`), the closer it is to the user.
*   **Ambient Shadows:** For floating elements (e.g., a bottom sheet), use a shadow color derived from `secondary` (#d277ff) at 5% opacity with a 40px blur. This creates a "glow" rather than a "shadow," fitting the neon aesthetic.
*   **The "Ghost Border" Fallback:** In high-density data views where a boundary is critical, use a `outline_variant` (#484847) at 15% opacity. This "Ghost Border" provides just enough structure for accessibility without cluttering the Simplex layout.
*   **Glassmorphism:** Use semi-transparent layers for the Bottom Navigation Bar. This allows the vibrant chart colors to "peek through" as the user scrolls, creating a sense of fluid depth.

---

## 5. Components: Modular Widgets

*   **Buttons:**
    *   **Primary:** Solid `primary` (#f3ffca) with `on_primary` text. `xl` (0.75rem) corner radius. No shadow.
    *   **Secondary:** Ghost style. `outline` (#767575) at 20% opacity with `secondary` (#d277ff) text.
*   **Charts (The Hero Component):** 
    *   Lines and bars should use `primary_dim` and `secondary_dim`. 
    *   Use `tertiary_container` for "Savings" goals to provide a cooling contrast to the neon lime.
    *   Charts should never have axes or grid lines. Use vertical white space and `body-sm` labels for orientation.
*   **Input Fields:**
    *   Use `surface_container_highest` (#262626) as the fill color. 
    *   The "Active" state is indicated by a 2px bottom-border only in `secondary` (#d277ff), moving away from the "boxy" input feel.
*   **Cards:**
    *   **Forbid Dividers.** Use an 8dp or 16dp spacing jump to separate content within a card.
    *   Group related transactions using a slight background shift from `surface_container` to `surface_container_low`.
*   **Progress Indicators:**
    *   Use a thick 8dp stroke for progress bars. Use `surface_variant` for the track and a `primary` to `tertiary` gradient for the fill.

---

## 6. Do's and Don'ts

### Do:
*   **DO** use extreme typographic contrast (e.g., pairing a 3.5rem display number with a 0.68rem label).
*   **DO** utilize the `full` (9999px) roundedness for chips and "Pill" buttons to soften the brutalist typography.
*   **DO** use `secondary` (Electric Purple) for "Wealth Growth" and `error` (Soft Coral) for "Outgoing Expenses" to create an intuitive emotional color-code.

### Don't:
*   **DON'T** use 1px solid dividers to separate list items. Use 12dp of padding and a subtle background color change if necessary.
*   **DON'T** use pure black (#000000) for containers; it kills the "Glassmorphism" effect. Always use the `surface` tokens.
*   **DON'T** use standard Material shadows. If an element doesn't feel "raised" enough, increase its surface brightness rather than adding a dark shadow.
*   **DON'T** clutter the UI with icons. Let the bold typography and color blocks guide the user's eye. Use icons only for primary navigation.