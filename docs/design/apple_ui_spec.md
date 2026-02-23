# trueLedger Design Specification: Premium Apple Design Language

**Version**: 1.0  
**Author**: Senior UI Designer (Apple Persona)  
**Objective**: To elevate trueLedger to a Tier-1 financial companion through rigorous adherence to Apple's Human Interface Guidelines (HIG), refined with modern glassmorphism and tactile feedback.

---

## 1. Wireframe Structure & Information Architecture

### A. Dashboard (The Nerve Center)
*   **Hero Area**: `WealthHero` card occupying the top 35% of the viewport. Dynamic background mesh that reacts to net worth status (Green for growth, Red/Amber for overspent).
*   **Quick Insights**: Horizontal sliver of `AppleGlassCard` metrics (Burn Rate, Daily Spend).
*   **Timeline**: Vertical list of `LedgerItems` with grouped date headers.

### B. Navigation & Transitions
*   **Root Level**: Persistent `BottomNavigationBar` with blur background (`ui.ImageFilter`).
*   **Drill-down**: Push/Pop transitions with horizontal slide and scale.
*   **Task Flow**: Modal sheets (Apple-style rounded corners) for "Add Transaction" or "Edit Loan".

---

## 2. Component Inventory (Design System)

| Component | Description | Interaction |
| :--- | :--- | :--- |
| `AppleScaffold` | Multi-layered root with animated mesh background. | Scroll-reactive AppBars. |
| `AppleGlassCard` | Content container using `BackdropFilter` (sigma: 20-30). | Subtle scale (0.98x) on press. |
| `AppleSectionHeader`| Upper-case subtitle (tracking: 1.5) over Bold Title. | Haptic trigger on action icon. |
| `HapticEngine` | Centralized feedback system using `ImpactLight`. | Tactile confirmation on every tap. |

---

## 3. Interaction Design Specifications

### A. Motion Language
*   **Entry**: `slideY(begin: 0.1, end: 0)` combined with `fadeIn`.
*   **Focus**: Active elements use a 1.02x scale shimmer effect.
*   **Curve**: `Curves.easeOutQuart` (The "Apple" curve) for natural acceleration/deceleration.

### B. Feedback Loops
*   **Visual**: Ripple effect constrained within the `AppleGlassCard` borders.
*   **Tactile**: `HapticFeedback.lightImpact()` on button release.
*   **Auditory**: (Optional) Subtle "tick" on scroll milestones (TBD).

---

## 4. Accessibility & Inclusive Design

### A. Visual Clarity
*   **Contrast**: All text must meet 4.5:1 ratio against glass backgrounds.
*   **Typography**: Using `Outfit` (or `Inter` fallback) with weights 400, 600, 800.
*   **Dynamic Type**: Support for system font scaling up to 200%.

### B. Assistive Technology
*   **Semantics**: Use `ExcludeSemantics` for decorative gradients and animated mesh spheres to reduce screen reader noise.
*   **Focus Management**: Explicit `FocusNode` handling in transaction sheets.
*   **Haptics as Cues**: Use haptics to confirm successful "Commit to Ledger" actions for users with visual impairments.

---

## 5. Visual Hierarchy & Color Theory

*   **Primary (Brand)**: `#007AFF` (Apple Blue)
*   **Success**: `#34C759` (Apple Green)
*   **Critical**: `#FF3B30` (Apple Red)
*   **Depth**: Use of `Material.surfaceCombined` for dark mode depth layering.
