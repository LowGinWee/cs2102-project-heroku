var express = require('express')
var path = require('path')
var cookieParser = require('cookie-parser');
var createError = require('http-errors');
var path = require('path');
var logger = require('morgan');
var flash = require('connect-flash');
var passport = require("passport");
var request = require('request');
var session = require("express-session");
const PORT = process.env.PORT || 5000




/* --- V7: Using dotenv     --- */
require('dotenv').config();

var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');

/* --- V2: Adding Web Pages --- */
var aboutRouter = require('./routes/about');
/* ---------------------------- */

/* --- V3: Basic Template   --- */
var tableRouter = require('./routes/table');
var loopsRouter = require('./routes/loops');
/* ---------------------------- */

/* --- V4: Database Connect --- */
var selectRouter = require('./routes/select');
/* ---------------------------- */

/* --- V5: Adding Forms     --- */
var formsRouter = require('./routes/forms');
/* ---------------------------- */

/* --- V6: Modify Database  --- */
var insertRouter = require('./routes/insert');
/* ---------------------------- */

/* --- login --- */
var loginRouter = require('./routes/login');
var signupRouter = require('./routes/signup');
var accountRouter = require('./routes/account');

/* --- preferences --- */
var updatePreferenceRouter = require('./routes/updatePreference');
var selectProfilesRouter = require('./routes/selectProfiles');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/users', usersRouter);

/* --- V2: Adding Web Pages --- */
app.use('/about', aboutRouter);
/* ---------------------------- */

/* --- V3: Basic Template   --- */
app.use('/table', tableRouter);
app.use('/loops', loopsRouter);
/* ---------------------------- */

/* --- V4: Database Connect --- */
app.use('/select', selectRouter);
/* ---------------------------- */

/* --- V5: Adding Forms     --- */
app.use('/forms', formsRouter);
/* ---------------------------- */

/* --- V6: Modify Database  --- */
var bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use('/insert', insertRouter);
/* ---------------------------- */

/* --- login --- */
const expressSession = require('express-session');
app.use(expressSession({secret: 'mySecretKey'})); //TODO change this
app.use(passport.initialize());
app.use(passport.session());
app.use('/public', express.static(__dirname + '/public'));
app.use(flash());
//app.use(session({secret: 'keyboard cat'})) //TODO change this
app.use('/login', loginRouter);
app.use('/signup', signupRouter);
app.use('/account', accountRouter);

/* --- Preferences --- */
app.use('/updatePreference', updatePreferenceRouter);
app.use('/selectProfiles', selectProfilesRouter);


// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

app.listen(PORT, () => console.log(`Listening on ${ PORT }`))

module.exports = app;
