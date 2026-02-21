const express = require('express');
const app = express();
const cors = require('cors');

app.set('view engine', 'pug');

// ✅ Middleware FIRST
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


// ✅ Routes
const usersRouter = require('./routes/users');
const insertRouter = require('./routes/insert');
const loginRouter = require('./routes/login');
const indexRouter = require('./routes/index');
const uploadRouter = require('./routes/uploadfile');

var db = require('./routes/db');
const protect = require('./routes/middleware/protect');

app.use('/users',  usersRouter);
app.use('/insert',protect, insertRouter);
app.use('/login', loginRouter);
app.use('/index', indexRouter);
app.use('/upload', uploadRouter);

app.get('/', (req, res) => {
  res.send('Hello World!');
});

const PORT = process.env.PORT || 8000;
app.listen(PORT, function () {
  console.log("Listening on :" + PORT);
});

module.exports = app;
