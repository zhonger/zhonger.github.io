var gulp = require('gulp'),
    concat = require("gulp-concat"),
    uglify = require('gulp-uglify'), // 压缩js文件
    // sass = require('gulp-sass'), // 编译sass
    cleanCSS = require('gulp-clean-css'), // 压缩css文件
    rename = require('gulp-rename'), // 文件重命名
    minifyCSS = require('gulp-minify-css');

gulp.task('scripts', (cb) => {
    gulp.src('dev/js/index.js')
        .pipe(uglify())
        .pipe(rename({suffix: '.min'}))
        .pipe(gulp.dest('assets/js'));
    cb();
});

gulp.task('sass', (cb) => {
    gulp.src('dev/sass/app.css')
        // .pipe(sass())
        // .pipe(gulp.dest('dev/sass'))
        .pipe(cleanCSS())
        .pipe(rename({suffix: '.min'}))
        .pipe(gulp.dest('assets/css'));
    cb();
});

gulp.task('css', (cb) => {
    gulp.src(['dev/sass/prism.css', 'dev/sass/github-markdown.css', 'dev/sass/share.min.css'])
        .pipe(concat('plugins.min.css'))
        .pipe(minifyCSS())
        .pipe(gulp.dest('assets/css'));

    cb();
});

gulp.task('watch', function() {
    gulp.watch('dev/sass/*.scss', gulp.series("sass"));
    gulp.watch('dev/sass/*.css', gulp.series("css"));
    gulp.watch('dev/js/*.js', gulp.series("scripts"));
});

gulp.task('default', gulp.series("scripts", "sass", "css", "watch"));