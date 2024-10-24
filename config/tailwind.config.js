const colors = require('tailwindcss/colors')

module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/views/**/*.html',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
  ],
  theme: {
    extend: {
      colors: {
        cookblue: {
          100: '#90b7cc',
          200: '#82a1b2',
        },
          sgray: '#373d44'  
      },
        spacing: {
        '15': '100px',
      }
    },
  },
  plugins: [],
}

