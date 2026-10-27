---
trigger: always_on
---

# UI-First Pixel-Perfect & API-Ready Development Rules

## 1. Design Fidelity (Highest Priority)
- When given a screenshot, Figma link, or detailed design prompt, replicate it EXACTLY — same spacing, colors, font sizes, border radii, shadows, icon sizes, and alignment. Do not "improve" or simplify the design unless explicitly asked.
- If exact values (hex codes, px/dp sizes) aren't visible, extract/estimate them as precisely as possible from the image rather than guessing generic values.
- Match responsive behavior expected on real devices (safe areas, notches, different screen sizes) while preserving the exact visual layout.
- If any part of the design is ambiguous, ask for clarification instead of assuming.

## 2. No Backend / API Calls Yet
- Do NOT write real network requests, HTTP clients, or live API integration code at this stage.
- Instead, use static/mock/dummy data (local constants, JSON files, or mock providers) to populate the UI.
- Design all data-dependent widgets/components to consume data through an abstraction layer (interfaces/models), not hardcoded inline, so mock data can be swapped for real API data later with minimal changes.

## 3. Modular, Well-Distributed Codebase
- NEVER put all code in one file or cram everything into 3–5 large files.
- Organize code by feature and responsibility using a clear folder structure, e.g.:
  - /screens (or /pages) — one file per screen
  - /widgets (or /components) — reusable UI pieces, one component per file
  - /models — data models/entities
  - /providers or /services — data-fetching abstraction (mocked for now)
  - /theme — colors, text styles, spacing constants, shared design tokens
  - /constants — static/dummy data, enums, app-wide constants
  - /utils — helper functions
- Each file should have a single clear responsibility. Split large widgets into smaller sub-widgets in their own files.
- Use consistent naming conventions (PascalCase for components/classes, camelCase for variables/functions, snake_case or kebab-case for files as per project convention).

## 4. API-Ready Architecture (Future-Proofing)
- Use a class/OOP-oriented, layered architecture:
  - Model classes for all data entities (with fromJson/toJson or equivalent serialization methods stubbed in, even if unused now).
  - Repository/Service classes as the single source of truth for data — UI components should call these, never touch mock data directly.
  - Keep UI (View) layer completely decoupled from data-fetching logic (e.g., via Provider/BLoC/ViewModel/Hooks pattern depending on stack).
- Structure repository/service classes so swapping a mock data source for a real API call later requires changing ONLY the implementation inside that class — not the UI code that consumes it.
- Add clear TODO comments where real API integration will later be plugged in (e.g., // TODO: Replace mock data with real API call here).

## 5. Code Quality
- Write clean, readable, well-commented code.
- Reuse shared design tokens (colors, spacing, typography) from a central theme file instead of hardcoding values across widgets.
- Avoid duplication — extract repeated UI patterns into reusable components.
- Keep functions/components small and focused (single responsibility principle).

## 6. Workflow
- Before generating code, briefly confirm the file/folder structure you plan to create for that screen/feature.
- After generating, summarize what was created and where, so it's easy to review and manually debug specific files.