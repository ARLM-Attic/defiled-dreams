gulp = require 'gulp'
gutil = require 'gulp-util'

coffee = require 'gulp-coffee'
browserify = require 'gulp-browserify'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
sass = require 'gulp-sass'
refresh = require 'gulp-livereload'
imagemin = require 'gulp-imagemin'
ftp = require 'gulp-ftp'

connect = require 'connect'
http = require 'http'
path = require 'path'
lr = require 'tiny-lr'

server = lr()

gulp.task 'webserver', ->
  port = 3000
  hostname = null
  base = path.resolve '.'
  directory = path.resolve '.'

  app = connect()
    .use(connect.static base)
    .use(connect.directory directory)

  http.createServer(app).listen port, hostname

# Starts the livereload server
gulp.task 'livereload', ->
  server.listen 35729, (err) ->
    console.log err if err?

gulp.task 'vendor', ->
  gulp.src('scripts/vendor/*.js')
    .pipe(concat 'vendor.js')
    .pipe(gulp.dest 'assets/')
    .pipe(refresh server)

gulp.task 'scripts', ->
  gulp.src(['scripts/coffee/!(app|init)*.coffee', 'scripts/coffee/init.coffee'])
    .pipe(concat 'app.coffee')
    .pipe(gulp.dest 'scripts/coffee/')

  gulp.src('scripts/coffee/app.coffee', { read: false })
    .pipe(browserify(transform: ['coffeeify'], extensions: ['.coffee']).on('error', (e) -> console.log e; gutil.beep()))
    .pipe(concat 'scripts.js')
    .pipe(gulp.dest 'assets/')
    .pipe(refresh server)

gulp.task 'styles', ->
  gulp.src('styles/scss/init.scss')
    .pipe(sass includePaths: ['styles/scss/includes'])
    .pipe(concat 'styles.css')
    .pipe(gulp.dest 'assets/')
    .pipe(refresh server)

gulp.task 'html', ->
  gulp.src('*.html')
    .pipe(refresh server)

gulp.task 'images', ->
  gulp.src('resources/img/**')
    .pipe(imagemin())
    .pipe(gulp.dest('assets/img/'))

gulp.task 'maps', ->
  gulp.src('resources/maps/**')
    .pipe gulp.dest 'assets/maps/'
    .pipe(refresh server)

gulp.task 'sfx', ->
  gulp.src('resources/sfx/**')
    .pipe gulp.dest 'assets/sfx/'
    .pipe(refresh server)

gulp.task 'watch', ->
  gulp.watch 'scripts/vendor/**', ['vendor']
  gulp.watch 'scripts/coffee/**', ['scripts']
  gulp.watch 'styles/scss/**', ['styles']
  gulp.watch 'resources/img/**', ['images']
  gulp.watch 'resources/sfx/**', ['sfx']
  gulp.watch 'resources/maps/**', ['maps']
  gulp.watch '*.html', ['html']

gulp.task 'default', ['webserver', 'livereload', 'scripts', 'styles', 'vendor', 'images', 'maps', 'sfx', 'watch']

