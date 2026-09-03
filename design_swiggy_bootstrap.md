# Design System Specification (Swiggy-inspired)

## Framework & Tech Stack
*   **CSS Framework:** Bootstrap 5 (Do NOT use Tailwind).
*   **Icons:** FontAwesome or Bootstrap Icons.
*   **Font:** 'Inter', sans-serif (clean, modern, highly legible).

## Core Philosophy
The UI must feel extremely premium, vibrant, and incredibly user-friendly—just like **Swiggy**. It should not look like a boring, standard corporate dashboard. Use plenty of whitespace, large rounded corners, soft playful shadows, and a bright primary brand color to draw the user's attention.

## Color Palette
*   **Primary Brand Color (The "Swiggy" Orange):** `#FC8019` - Use this for primary call-to-action buttons, active states, and important highlights.
*   **Secondary/Accent Color:** `#FF9A42` (Lighter orange for gradients or hovers).
*   **Background (Body):** `#F3F4F6` (Very light, cool grey to make white cards pop).
*   **Surface (Cards/Panels):** `#FFFFFF` (Pure white).
*   **Text (Primary):** `#282C3F` (Deep, soft charcoal—never pure `#000000`).
*   **Text (Secondary/Muted):** `#686B78` (For subtitles, timestamps, and minor details).
*   **Success (Delivered/Approved):** `#60B246` (Swiggy's success green).
*   **Danger/Error (Loss/Delay):** `#E46D47` (Soft red).

## Typography
*   **Headings:** Bold, punchy, and tightly spaced. Use Bootstrap's `.fw-bold` or `.fw-bolder`.
*   **Body Text:** 14px to 16px, highly readable with generous line-height (`lh-lg`).

## Component Styling (Bootstrap Overrides/Rules)

### 1. Cards (The core building block)
*   Do not use standard sharp Bootstrap cards.
*   Always use `.border-0`, `.rounded-4` (large 16px border-radius), and `.shadow-sm` or a custom soft shadow.
*   Padding inside cards should be generous: use `.p-4`.
*   *Swiggy Vibe:* Cards should feel like distinct, clickable, floating elements. 

### 2. Buttons
*   **Primary Buttons:** Must be the Swiggy Orange (`#FC8019`). Text must be pure white and bold (`.fw-bold`). 
*   **Shape:** Use `.rounded-pill` or `.rounded-3` (slightly softer than default).
*   **Hover State:** Buttons should slightly elevate (translate Y) and increase shadow on hover. Add a CSS transition.
*   Do not use standard Bootstrap `.btn-primary` blue. Override the primary color variable or use custom inline styles to force the orange.

### 3. Inputs & Forms
*   Forms should be clean and distraction-free.
*   Inputs: `.form-control-lg`, `.bg-light`, `.border-0`. No harsh outlines.
*   Focus State: When an input is focused, add a subtle orange glow or bottom border, do not use the default blue Bootstrap ring.
*   Use floating labels (`.form-floating`) for a modern, app-like feel.

### 4. Navigation & Headers
*   **Navbar:** Pure white background (`.bg-white`), sticky at the top (`.sticky-top`), with a very subtle bottom shadow (`.shadow-sm`).
*   **Active Links:** Highlight active navigation links with the Primary Orange color and a heavy font weight.

### 5. Badges & Pills (For Statuses)
*   Statuses (e.g., "In Transit", "Delivered") should use `.badge`, `.rounded-pill`.
*   Use `.bg-opacity-10` with text colored to match the badge context (e.g., light green background with dark green text for success) to create a soft, modern look instead of harsh solid colors.

## Animation & Micro-interactions
*   **Hover Effects:** Add `.transition-all` (a custom CSS class you should define) to cards and buttons so they smoothly scale up by `1.02` when hovered.
*   **Loading:** Use subtle pulse animations for loading states.

## Layout & Spacing
*   Use standard Bootstrap grid (`.container-fluid`, `.row`, `.col-lg-4`, etc.).
*   Keep layouts breathable. Use `.gap-4`, `.mb-4`, and `.py-5` liberally. Avoid cramped UI.

---
**CRITICAL INSTRUCTION FOR AI:** Whenever generating HTML/CSS based on this document, absolutely refuse to use default blue Bootstrap components. Inject custom CSS or override Bootstrap utility classes to enforce the Swiggy-orange palette, heavy border radii, and soft drop-shadows. The result MUST look like a premium consumer app.
