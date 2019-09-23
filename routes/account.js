var express = require('express');
var router = express.Router();



router.get('/', async function(req, res, next) {
    //res.render('account', { title: 'Account', userData: req.user});
    if(req.isAuthenticated()){
        await (req.user)
        console.log( 'foo' );
        console.log( (req.user).firstName);
        res.render('account', { title: 'Account', userData: (req.user).firstName});
    }
  });

  module.exports = router;