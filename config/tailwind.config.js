const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        display: ['Anton', 'Impact', ...defaultTheme.fontFamily.sans],
        sans: ['Space Grotesk', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        // CardMonkey design system — "editorial / bold" (cream + ink + 1 pop)
        cm: {
          bg: '#f4efe3',          // cream paper
          surface: '#ffffff',     // panels
          'surface-2': '#ece3d2', // tinted panel
          border: '#14110d',      // bold ink borders (print look)
          ink: '#14110d',
          text: '#14110d',
          'text-muted': '#6b6357',
          'text-subtle': '#9a9182',
          accent: '#1f6feb',      // pop — electric blue
          'accent-2': '#ff3b1d',  // secondary pop — vermilion (rare use)
          success: '#1f8a4c',
          danger: '#d61f1f',
          warning: '#e0a400',
        },
      },
      boxShadow: {
        'cm-hard': '6px 6px 0 0 #14110d',
        'cm-hard-sm': '4px 4px 0 0 #14110d',
      },
      animation: {
        'fade-in': 'fadeIn 0.2s ease-out forwards',
        'slide-down': 'slideDown 0.3s ease-out forwards',
        'spin-slow': 'spin 2s linear infinite',
        'marquee': 'marquee 22s linear infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'scale(0.97)' },
          '100%': { opacity: '1', transform: 'scale(1)' },
        },
        slideDown: {
          '0%': { opacity: '0', transform: 'translateY(-10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        marquee: {
          '0%': { transform: 'translateX(0)' },
          '100%': { transform: 'translateX(-50%)' },
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
