var gulp = require('gulp');
var bower = require('gulp-bower');
var purescript = require('gulp-purescript');
var browserify = require('browserify');
var source = require('vinyl-source-stream');

var sources = [
    'src/**/*.purs',
    'bower_components/**/src/**/*.purs',
];

gulp.task('bower', function() {
    return bower();
});

gulp.task('purescript', ['bower'], function () {
    return gulp.src(sources)
               .pipe(purescript.pscMake({ output: './build' }));
});

gulp.task('.psci', function() {
    return gulp.src(sources)
               .pipe(purescript.dotPsci());
});

gulp.task('browserify-client', ['purescript'], function() {
    return browserify({ paths: ['./build'], entries: ['Client'], debug: true, standalone: 'client' })
        .bundle()
        .pipe(source('client.js'))
        .pipe(gulp.dest('./dist'));
});

gulp.task('browserify-server', ['purescript'], function() {
    return browserify({ paths: ['./build'], entries: ['Server'], standalone: 'server' })
        .bundle()
        .pipe(source('server.js'))
        .pipe(gulp.dest('./dist'));
});

gulp.task('browserify', ['browserify-client', 'browserify-server'], function() {
});

gulp.task('default', ['browserify', '.psci']);
