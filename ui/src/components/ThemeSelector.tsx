import type { ThemeId, ThemeOption } from '../hooks/useTheme'

interface ThemeSelectorProps {
  themes: ThemeOption[]
  currentTheme: ThemeId
  onThemeChange: (theme: ThemeId) => void
}

// ThemeSelector is deprecated - single theme system.
// Kept for backwards compatibility, renders nothing.
// eslint-disable-next-line @typescript-eslint/no-unused-vars
export function ThemeSelector(_props: ThemeSelectorProps) {
  return null
}
