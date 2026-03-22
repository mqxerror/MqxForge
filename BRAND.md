# Brand Guidelines — Easy Rebrand Reference

Use this file to rebrand the entire project. All brand-related values are centralized here.

## Current Brand

| Property | Value |
|---|---|
| **Name** | 7nashHarness |
| **Slug** | `7nash-harness` |
| **npm Package** | `7nash-harness` |
| **UI Package** | `7nash-harness-ui` |
| **CSS Class Prefix** | `7nash-` |
| **localStorage Prefix** | `7nash-` |
| **Config Directory** | `~/.autoforge/` *(not yet renamed — see backend section)* |
| **Project Directory** | `.autoforge/` *(not yet renamed — see backend section)* |

---

## Files to Change When Rebranding

### Tier 1: User-Facing (must change)

| File | What to Change |
|---|---|
| `ui/index.html` | `<title>` tag |
| `ui/src/App.tsx` | Header title (`text-gradient` h1), welcome message text |
| `ui/src/components/NewProjectModal.tsx` | Template description text referencing brand |
| `ui/public/logo.png` | Logo image (238KB, displayed at 36x36px) |

### Tier 2: Storage Keys & Package Names

| File | What to Change |
|---|---|
| `ui/src/App.tsx` | `STORAGE_KEY` and `VIEW_MODE_KEY` constants (prefix `7nash-`) |
| `ui/src/hooks/useTheme.ts` | `DARK_MODE_STORAGE_KEY` constant (prefix `7nash-`) |
| `ui/src/components/AgentMissionControl.tsx` | `ACTIVITY_COLLAPSED_KEY` constant (prefix `7nash-`) |
| `package.json` | `name` field |
| `ui/package.json` | `name` field and dependency reference to root package |

### Tier 3: CLI & Backend

| File | What to Change |
|---|---|
| `bin/autoforge.js` | Entry point (rename file + update `package.json` `bin` field) |
| `lib/cli.js` | Banner text, help text, `CONFIG_HOME` path, all "AutoForge" strings |
| `start_ui.sh` | Banner text |
| `start_ui.py` | Banner text, argparse description |
| `install.sh` | Banner text in `banner()` and `start_server()` functions |
| `autoforge_paths.py` | Module name (rename file + update all imports) |

### Tier 4: Documentation

| File | What to Change |
|---|---|
| `README.md` | All references |
| `CLAUDE.md` | Project overview, command examples |
| `.claude/commands/*.md` | References in slash command docs |

---

## Design System Tokens

All design values live in `ui/src/styles/globals.css`. Change these to rebrand the look:

### Color Palette (OKLCH)

```css
/* Primary — Violet */
--primary: oklch(0.55 0.25 270);        /* Light mode */
--primary: oklch(0.65 0.27 270);        /* Dark mode */

/* Accent — Teal */
--accent: oklch(0.65 0.20 200);         /* Light mode */
--accent: oklch(0.60 0.22 200);         /* Dark mode */

/* Background */
--background: oklch(0.98 0.005 260);    /* Light mode */
--background: oklch(0.12 0.02 270);     /* Dark mode */
```

To shift the entire palette (e.g., to blue), change the hue angle:
- Violet: `270`
- Blue: `245`
- Teal: `200`
- Green: `160`
- Orange: `50`
- Pink: `330`

### Glow Effects

```css
--glow: oklch(0.55 0.25 270 / 0.15);        /* Card hover glow */
--glow-accent: oklch(0.65 0.20 200 / 0.15); /* Accent hover glow */
```

### Typography

```css
--font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
--font-mono: 'JetBrains Mono', 'Fira Code', ui-monospace, monospace;
```

To change fonts:
1. Update `ui/index.html` Google Fonts `<link>` tag
2. Update `--font-sans` / `--font-mono` in globals.css `:root` and `.dark`

### Border Radius

```css
--radius: 0.75rem;  /* Base radius — all components derive from this */
```

### Shadows

Light and dark mode have separate shadow definitions. Dark mode uses deeper shadows.

---

## CSS Utility Classes (Aceternity-Inspired)

These classes are available in all components:

| Class | Effect |
|---|---|
| `.glass` | Glassmorphic surface (backdrop-blur + semi-transparent bg) |
| `.glow-border` | Subtle glow on hover |
| `.text-gradient` | Gradient text (primary → accent) |
| `.bg-dot-pattern` | Dot grid background |
| `.animate-gradient-beam` | Animated gradient for progress bars |

---

## Theme System

The app uses a single unified theme with light/dark mode toggle (defaults to dark).

- Theme hook: `ui/src/hooks/useTheme.ts`
- Theme type: `ThemeId = 'default'`
- Dark mode default: `true` (Aceternity-style dark-first)
- `ThemeSelector` component exists but renders `null` (kept for compatibility)

To add new themes: restore the multi-theme pattern from git history and add new `.theme-*` blocks in globals.css.

---

## Quick Rebrand Checklist

1. [ ] Choose new name, slug, and localStorage prefix
2. [ ] Replace logo at `ui/public/logo.png`
3. [ ] Find-and-replace brand name in Tier 1 files
4. [ ] Update storage key prefixes in Tier 2 files
5. [ ] Update package.json `name` fields
6. [ ] Adjust color hue angles in globals.css if desired
7. [ ] Update fonts in `index.html` + globals.css if desired
8. [ ] Update CLI/backend strings in Tier 3 files
9. [ ] Update docs in Tier 4 files
10. [ ] Run `cd ui && npm run build` to verify
11. [ ] Run `./install.sh --install-only` to verify full pipeline
