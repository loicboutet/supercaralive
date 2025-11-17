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
      colors: {
        'red-hero': '#E63946',
        'red-dark': '#d32f3c',
        'blue-hero': '#457B9D',
        'blue-dark': '#3a6782',
        'yellow-hero': '#F4A261',
        'yellow-dark': '#d89150',
        'soft': '#FAFAFA',
      },
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    // require('@tailwindcss/forms'),
    // require('@tailwindcss/typography'),
    // require('@tailwindcss/container-queries'),
  ]
}
