exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app/
        'js/vendor.js': /^(bower_components)/
    stylesheets:
      joinTo: 'index.css'
    templates:
      joinTo: 'index.js'
