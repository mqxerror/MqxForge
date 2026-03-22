import { useState, useEffect, useCallback } from 'react'

export type ThemeId = 'default'

export interface ThemeOption {
  id: ThemeId
  name: string
  description: string
  previewColors: {
    primary: string
    background: string
    accent: string
  }
}

export const THEMES: ThemeOption[] = [
  {
    id: 'default',
    name: '7nashHarness',
    description: 'Glassmorphic violet and teal',
    previewColors: { primary: '#8b5cf6', background: '#1a1625', accent: '#06b6d4' }
  },
]

const DARK_MODE_STORAGE_KEY = '7nash-dark-mode'

export function useTheme() {
  const [theme] = useState<ThemeId>('default')

  const [darkMode, setDarkModeState] = useState(() => {
    try {
      const stored = localStorage.getItem(DARK_MODE_STORAGE_KEY)
      // Default to dark mode (Aceternity-style dark-first)
      return stored === null ? true : stored === 'true'
    } catch {
      return true
    }
  })

  // Apply dark mode class to document
  useEffect(() => {
    const root = document.documentElement

    // Remove legacy theme classes
    root.classList.remove('theme-claude', 'theme-neo-brutalism', 'theme-retro-arcade', 'theme-aurora', 'theme-business')

    // Handle dark mode
    if (darkMode) {
      root.classList.add('dark')
    } else {
      root.classList.remove('dark')
    }

    // Persist to localStorage
    try {
      localStorage.setItem(DARK_MODE_STORAGE_KEY, String(darkMode))
    } catch {
      // localStorage not available
    }
  }, [darkMode])

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const setTheme = useCallback((_newTheme: ThemeId) => {
    // Single theme - no-op
  }, [])

  const setDarkMode = useCallback((enabled: boolean) => {
    setDarkModeState(enabled)
  }, [])

  const toggleDarkMode = useCallback(() => {
    setDarkModeState(prev => !prev)
  }, [])

  return {
    theme,
    setTheme,
    darkMode,
    setDarkMode,
    toggleDarkMode,
    themes: THEMES,
    currentTheme: THEMES[0]
  }
}
