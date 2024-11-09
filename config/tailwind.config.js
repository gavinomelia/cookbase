const colors = require('tailwindcss/colors')

module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/views/**/*.html',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
    './app/views/**/*.turbo_stream.erb'
  ],
  theme: {
    extend: {
      colors: {
        cookblue: {
          50:  '#e3eff5',
          75: '#b6cde2',
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

