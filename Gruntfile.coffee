module.exports = (grunt) ->
  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
      
    coffee:
      compile:
        files:
          './tmp/init-coffee.js': 'app/init.coffee'
          './tmp/main-coffee.js': 'app/**/*.coffee'
        
    uglify:
      options:
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd h:M:s") %> */\n'
        
      build:
        src: ['app/init.js', 'app/**/*.js', './tmp/*.js']
        dest: 'build/<%= pkg.name %>.min.js'
        
    clean: ['.tmp']

  # Load the plugins that provides the tasks above:
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  # Default task(s). (The one that is ran when 'grunt' command is called from the directory)
  grunt.registerTask('default', ['coffee', 'uglify', 'clean'])